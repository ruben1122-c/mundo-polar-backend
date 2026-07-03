from datetime import datetime, timedelta, timezone
from uuid import uuid4

from fastapi import HTTPException, status
from sqlalchemy import func
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.security import (
    CurrentUser,
    create_access_token,
    hash_password,
    verify_password,
)
from app.models.order import Order
from app.models.user import AuthSession, User
from app.schemas.account import (
    AuthResponse,
    LoginRequest,
    ProfileResponse,
    ProfileUpdate,
    RegisterRequest,
)


def _profile_response(
    db: Session,
    user: User,
) -> ProfileResponse:
    order_count = db.query(Order).filter(Order.user_id == user.id).count()
    return ProfileResponse(
        id=user.id,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
        phone=user.phone,
        document_type=user.document_type,
        document_number=user.document_number,
        gender=user.gender,
        role=user.role,
        is_active=user.is_active,
        order_count=order_count,
        created_at=user.created_at,
        updated_at=user.updated_at,
    )


def _new_session(user: User) -> tuple[AuthSession, str]:
    expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=settings.jwt_expire_minutes,
    )
    auth_session = AuthSession(
        id=uuid4(),
        user_id=user.id,
        expires_at=expires_at,
    )
    token = create_access_token(
        user_id=user.id,
        session_id=auth_session.id,
        expires_at=expires_at,
    )
    return auth_session, token


def register_user(
    db: Session,
    payload: RegisterRequest,
) -> AuthResponse:
    email = str(payload.email).strip().lower()
    existing = (
        db.query(User.id)
        .filter(func.lower(User.email) == email)
        .first()
    )
    if existing:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Este correo ya está registrado.",
        )

    try:
        password_hash = hash_password(payload.password)
    except ValueError as error:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail=str(error),
        ) from None

    user = User(
        id=uuid4(),
        first_name=payload.first_name.strip(),
        last_name=payload.last_name.strip(),
        email=email,
        password_hash=password_hash,
        phone=payload.phone.strip() if payload.phone else None,
        document_type=payload.document_type,
        document_number=(
            payload.document_number.strip()
            if payload.document_number
            else None
        ),
        role="customer",
        is_active=True,
    )
    auth_session, token = _new_session(user)

    try:
        db.add(user)
        db.flush()
        db.add(auth_session)
        db.commit()
        db.refresh(user)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="El correo o documento ya está registrado.",
        ) from None

    return AuthResponse(
        access_token=token,
        expires_at=auth_session.expires_at,
        user=_profile_response(db, user),
    )


def login_user(db: Session, payload: LoginRequest) -> AuthResponse:
    email = str(payload.email).strip().lower()
    user = (
        db.query(User)
        .filter(func.lower(User.email) == email)
        .first()
    )
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Correo o contraseña incorrectos.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="La cuenta está desactivada.",
        )

    auth_session, token = _new_session(user)
    user.last_login_at = datetime.now(timezone.utc)
    db.add(auth_session)
    db.add(user)
    db.commit()
    db.refresh(user)

    return AuthResponse(
        access_token=token,
        expires_at=auth_session.expires_at,
        user=_profile_response(db, user),
    )


def logout_user(db: Session, current_user: CurrentUser) -> None:
    auth_session = (
        db.query(AuthSession)
        .filter(AuthSession.id == current_user.session_id)
        .first()
    )
    if auth_session and not auth_session.revoked_at:
        auth_session.revoked_at = datetime.now(timezone.utc)
        db.add(auth_session)
        db.commit()


def get_profile(db: Session, current_user: CurrentUser) -> ProfileResponse:
    return _profile_response(db, current_user.profile)


def update_profile(
    db: Session,
    current_user: CurrentUser,
    payload: ProfileUpdate,
) -> ProfileResponse:
    user = current_user.profile
    updates = payload.model_dump(exclude_unset=True)

    for field, value in updates.items():
        if isinstance(value, str):
            value = value.strip() or None
        if field in {"first_name", "last_name"} and not value:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail="El nombre y los apellidos no pueden estar vacíos.",
            )
        setattr(user, field, value)

    try:
        db.add(user)
        db.commit()
        db.refresh(user)
    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="El documento ya está asociado a otra cuenta.",
        ) from None

    return _profile_response(db, user)
