from services.database import db
from schemas import *
from fastapi import APIRouter, HTTPException
from typing import List, Optional

router = APIRouter(prefix="/user", tags=["User"])


@router.get("/{user_id}", response_model=UserModel)
async def get_user(user_id: int):
    user = db.get_user(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user


@router.put("/{user_id}", response_model=UserModel)
async def update_user(user_id: int, update: UserUpdate):
    user = db.update_user(
        user_id,
        username=update.username,
        dark_mode=update.dark_mode,
        eco_tips_notifications=update.eco_tips_notifications
    )
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user
