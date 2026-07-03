from dataclasses import dataclass
from uuid import UUID

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jwt import PyJWKClient
from jwt.exceptions import PyJWTError, PyJWKClientError
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.models.user_profile import UserProfile


@dataclass(frozen=True)
class CurrentUser:
    id: UUID
    email: str
    profile: UserProfile


bearer_scheme = HTTPBearer(auto_error=False)
issuer = f"{settings.supabase_url}/auth/v1"
jwks_client = PyJWKClient(
    f"{issuer}/.well-known/jwks.json",
    cache_keys=True,
    lifespan=300,
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
        signing_key = jwks_client.get_signing_key_from_jwt(credentials.credentials)
        payload = jwt.decode(
            credentials.credentials,
            signing_key.key,
            algorithms=["ES256"],
            audience="authenticated",
            issuer=issuer,
            options={"require": ["exp", "iss", "sub", "aud"]},
        )
        user_id = UUID(payload["sub"])
        email = str(payload.get("email", "")).strip().lower()
        if not email or payload.get("role") != "authenticated":
            raise ValueError("Missing email claim")
    except (PyJWTError, PyJWKClientError, KeyError, TypeError, ValueError):
        raise _unauthorized() from None

    profile = db.query(UserProfile).filter(UserProfile.id == user_id).first()
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="La cuenta no tiene un perfil válido.",
        )
    if not profile.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="La cuenta está desactivada.",
        )

    return CurrentUser(id=user_id, email=email, profile=profile)
