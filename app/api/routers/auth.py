from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import CurrentUser, get_current_user
from app.schemas.account import (
    AuthResponse,
    LoginRequest,
    ProfileResponse,
    ProfileUpdate,
    RegisterRequest,
)
from app.services.account_service import (
    get_profile,
    login_user,
    logout_user,
    register_user,
    update_profile,
)

router = APIRouter(prefix="/auth", tags=["Autenticación"])


@router.post(
    "/register",
    response_model=AuthResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(
    payload: RegisterRequest,
    db: Session = Depends(get_db),
):
    return register_user(db, payload)


@router.post("/login", response_model=AuthResponse)
def login(
    payload: LoginRequest,
    db: Session = Depends(get_db),
):
    return login_user(db, payload)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(
    db: Session = Depends(get_db),
    current_user: CurrentUser = Depends(get_current_user),
):
    logout_user(db, current_user)
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/me", response_model=ProfileResponse)
def read_current_profile(
    db: Session = Depends(get_db),
    current_user: CurrentUser = Depends(get_current_user),
):
    return get_profile(db, current_user)


@router.patch("/me", response_model=ProfileResponse)
def edit_current_profile(
    payload: ProfileUpdate,
    db: Session = Depends(get_db),
    current_user: CurrentUser = Depends(get_current_user),
):
    return update_profile(db, current_user, payload)
