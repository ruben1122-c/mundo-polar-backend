from datetime import datetime
from decimal import Decimal
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class OrderItemCreate(BaseModel):
    product_reference: str = Field(min_length=1, max_length=120)
    quantity: int = Field(ge=1, le=20)


class OrderCreate(BaseModel):
    customer_name: str = Field(min_length=2, max_length=160)
    customer_email: EmailStr
    customer_phone: str | None = Field(default=None, max_length=30)
    shipping_method: Literal["delivery", "store_pickup"]
    shipping_address: dict | None = None
    payment_method: Literal["card", "yape", "plin"]
    notes: str | None = Field(default=None, max_length=1000)
    items: list[OrderItemCreate] = Field(min_length=1, max_length=50)


class OrderItemResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    product_id: UUID | None
    product_name: str
    product_slug: str
    image_url: str | None
    unit_price: Decimal
    quantity: int
    line_total: Decimal


class OrderResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    order_number: str
    customer_name: str
    customer_email: EmailStr
    shipping_method: str
    payment_method: str
    status: str
    payment_status: str
    subtotal: Decimal
    shipping_amount: Decimal
    total: Decimal
    currency: str
    created_at: datetime
    items: list[OrderItemResponse]
