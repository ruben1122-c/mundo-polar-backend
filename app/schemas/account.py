from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


DocumentType = Literal["dni", "ce", "passport"]
Gender = Literal["female", "male", "non_binary", "prefer_not_to_say"]
UserRole = Literal["customer", "admin"]


class ProfileUpdate(BaseModel):
    first_name: str | None = Field(default=None, min_length=1, max_length=80)
    last_name: str | None = Field(default=None, min_length=1, max_length=80)
    phone: str | None = Field(default=None, max_length=30)
    document_type: DocumentType | None = None
    document_number: str | None = Field(default=None, max_length=20)
    gender: Gender | None = None


class ProfileResponse(BaseModel):
    id: UUID
    email: EmailStr
    first_name: str
    last_name: str
    phone: str | None
    document_type: DocumentType
    document_number: str | None
    gender: Gender | None
    role: UserRole
    is_active: bool
    order_count: int
    created_at: datetime
    updated_at: datetime
