from sqlalchemy.orm import Session, joinedload

from app.models.product import Product


def list_products(
    db: Session,
    *,
    category: str | None = None,
    featured: bool | None = None,
    new: bool | None = None,
    on_sale: bool | None = None,
):
    query = (
        db.query(Product)
        .options(joinedload(Product.category))
        .filter(Product.is_active.is_(True))
    )
    if category:
        query = query.filter(Product.category.has(slug=category))
    if featured is not None:
        query = query.filter(Product.is_featured.is_(featured))
    if new is not None:
        query = query.filter(Product.is_new.is_(new))
    if on_sale is not None:
        query = query.filter(Product.is_on_sale.is_(on_sale))
    return query.order_by(Product.sort_order, Product.created_at.desc()).all()
