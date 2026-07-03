from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.schemas.product import ProductResponse
from app.services.product_service import list_products

router = APIRouter(prefix="/products", tags=["Productos"])


@router.get("", response_model=list[ProductResponse])
def get_products(
    category: str | None = Query(default=None, max_length=80),
    featured: bool | None = None,
    new: bool | None = None,
    on_sale: bool | None = None,
    db: Session = Depends(get_db),
):
    products = list_products(
        db,
        category=category,
        featured=featured,
        new=new,
        on_sale=on_sale,
    )
    return [
        ProductResponse.model_validate(
            {
                **product.__dict__,
                "category_slug": product.category.slug,
            }
        )
        for product in products
    ]
