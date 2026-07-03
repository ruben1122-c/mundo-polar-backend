from fastapi import HTTPException, status
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.security import CurrentUser
from app.models.order import Order
from app.schemas.account import ProfileResponse, ProfileUpdate


def _profile_response(db: Session, current_user: CurrentUser) -> ProfileResponse:
    profile = current_user.profile
    order_count = (
        db.query(Order)
        .filter(Order.user_id == current_user.id)
        .count()
    )
    return ProfileResponse(
        id=profile.id,
        email=current_user.email,
        first_name=profile.first_name,
        last_name=profile.last_name,
        phone=profile.phone,
        document_type=profile.document_type,
        document_number=profile.document_number,
        gender=profile.gender,
        role=profile.role,
        is_active=profile.is_active,
        order_count=order_count,
        created_at=profile.created_at,
        updated_at=profile.updated_at,
    )


def get_profile(db: Session, current_user: CurrentUser) -> ProfileResponse:
    return _profile_response(db, current_user)


def update_profile(
    db: Session,
    current_user: CurrentUser,
    payload: ProfileUpdate,
) -> ProfileResponse:
    profile = current_user.profile
    updates = payload.model_dump(exclude_unset=True)

    for field, value in updates.items():
        if isinstance(value, str):
            value = value.strip() or None
        if field in {"first_name", "last_name"} and not value:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="El nombre y los apellidos no pueden estar vacíos.",
            )
        setattr(profile, field, value)

    try:
        db.add(profile)
        db.commit()
        db.refresh(profile)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="El documento ya está asociado a otra cuenta.",
        ) from None

    return _profile_response(db, current_user)
