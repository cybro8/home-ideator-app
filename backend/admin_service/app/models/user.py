from datetime import datetime
from pydantic import BaseModel, EmailStr


class EndUserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str


class EndUserUpdate(BaseModel):
    username: str | None = None
    email: EmailStr | None = None


class EndUserStatusUpdate(BaseModel):
    is_active: bool


class EndUserOut(BaseModel):
    uid: str
    username: str
    email: str
    is_active: bool
    created_at: datetime
