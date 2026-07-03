from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import CurrentUser, get_current_user
from app.schemas.account import ProfileResponse, ProfileUpdate
from app.services.account_service import get_profile, update_profile

router = APIRouter(prefix="/auth", tags=["Autenticación"])


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
