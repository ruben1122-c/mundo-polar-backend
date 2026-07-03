from datetime import datetime, timezone
from decimal import Decimal
from uuid import UUID, uuid4

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.order import Order, OrderItem
from app.models.product import Product
from app.core.security import CurrentUser
from app.schemas.order import OrderCreate


def _find_product(db: Session, reference: str) -> Product | None:
    try:
        product_id = UUID(reference)
    except ValueError:
        product_id = None

    query = db.query(Product).filter(Product.is_active.is_(True))
    if product_id:
        return query.filter(Product.id == product_id).first()
    return query.filter(Product.slug == reference).first()


def _order_number() -> str:
    date_part = datetime.now(timezone.utc).strftime("%Y%m%d")
    return f"MP-{date_part}-{uuid4().hex[:8].upper()}"


def create_pending_order(
    db: Session,
    payload: OrderCreate,
    current_user: CurrentUser,
) -> Order:
    resolved_items: list[tuple[Product, int]] = []
    for item in payload.items:
        product = _find_product(db, item.product_reference)
        if not product:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=(
                    "Uno de los productos ya no está disponible. "
                    "Actualiza el carrito e inténtalo nuevamente."
                ),
            )
        resolved_items.append((product, item.quantity))

    subtotal = sum(
        (product.price * quantity for product, quantity in resolved_items),
        start=Decimal("0.00"),
    )
    shipping_amount = Decimal("0.00")

    order = Order(
        user_id=current_user.id,
        order_number=_order_number(),
        customer_name=(
            f"{current_user.profile.first_name} "
            f"{current_user.profile.last_name}"
        ).strip(),
        customer_email=current_user.email,
        customer_phone=current_user.profile.phone,
        shipping_method=payload.shipping_method,
        shipping_address=payload.shipping_address,
        payment_method=payload.payment_method,
        notes=payload.notes,
        status="pending",
        payment_status="unpaid",
        subtotal=subtotal,
        shipping_amount=shipping_amount,
        total=subtotal + shipping_amount,
        currency="PEN",
    )

    for product, quantity in resolved_items:
        order.items.append(
            OrderItem(
                product_id=product.id,
                product_name=product.name,
                product_slug=product.slug,
                sku=product.sku,
                image_url=product.image_url,
                unit_price=product.price,
                quantity=quantity,
                line_total=product.price * quantity,
            )
        )

    try:
        db.add(order)
        db.commit()
        db.refresh(order)
        return order
    except Exception:
        db.rollback()
        raise
