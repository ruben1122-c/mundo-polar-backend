from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class ProductResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    slug: str
    sku: str | None
    name: str
    description: str | None
    image_url: str
    image_alt: str | None
    price: Decimal
    compare_at_price: Decimal | None
    currency: str
    badge: str | None
    stock_quantity: int
    is_featured: bool
    is_new: bool
    is_on_sale: bool
    sort_order: int
    category_slug: str
