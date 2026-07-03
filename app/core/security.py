from dataclasses import dataclass
from datetime import datetime, timezone
from uuid import UUID

import bcrypt
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt.exceptions import PyJWTError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.models.user import AuthSession, User

JWT_ALGORITHM = "HS256"
JWT_ISSUER = "mundo-polar-api"
JWT_AUDIENCE = "mundo-polar-web"


@dataclass(frozen=True)
class CurrentUser:
    id: UUID
    email: str
    profile: User
    session_id: UUID


bearer_scheme = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    password_bytes = password.encode("utf-8")
    if len(password_bytes) > 72:
        raise ValueError("La contraseña no puede superar 72 bytes.")
    return bcrypt.hashpw(password_bytes, bcrypt.gensalt(rounds=12)).decode()


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return bcrypt.checkpw(
            password.encode("utf-8"),
            password_hash.encode("utf-8"),
        )
    except (TypeError, ValueError):
        return False


def create_access_token(
    *,
    user_id: UUID,
    session_id: UUID,
    expires_at: datetime,
) -> str:
    now = datetime.now(timezone.utc)
    return jwt.encode(
        {
            "sub": str(user_id),
            "jti": str(session_id),
            "iss": JWT_ISSUER,
            "aud": JWT_AUDIENCE,
            "iat": now,
            "exp": expires_at,
        },
        settings.jwt_secret,
        algorithm=JWT_ALGORITHM,
    )


def _unauthorized() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="La sesión no es válida o expiró. Vuelve a iniciar sesión.",
        headers={"WWW-Authenticate": "Bearer"},
    )


def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> CurrentUser:
    if not credentials or credentials.scheme.lower() != "bearer":
        raise _unauthorized()

    try:
        payload = jwt.decode(
            credentials.credentials,
            settings.jwt_secret,
            algorithms=[JWT_ALGORITHM],
            audience=JWT_AUDIENCE,
            issuer=JWT_ISSUER,
            options={"require": ["exp", "iss", "sub", "aud", "jti"]},
        )
        user_id = UUID(payload["sub"])
        session_id = UUID(payload["jti"])
    except (PyJWTError, KeyError, TypeError, ValueError):
        raise _unauthorized() from None

    result = (
        db.query(AuthSession, User)
        .join(User, User.id == AuthSession.user_id)
        .filter(
            AuthSession.id == session_id,
            AuthSession.user_id == user_id,
        )
        .first()
    )
    if not result:
        raise _unauthorized()

    auth_session, user = result
    now = datetime.now(timezone.utc)
    if auth_session.revoked_at or auth_session.expires_at <= now:
        raise _unauthorized()
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="La cuenta está desactivada.",
        )

    return CurrentUser(
        id=user.id,
        email=user.email,
        profile=user,
        session_id=auth_session.id,
    )
