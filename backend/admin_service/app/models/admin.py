from datetime import datetime
from enum import Enum
from pydantic import BaseModel, EmailStr


class AdminRole(str, Enum):
    admin = "admin"
    end_user_admin = "end_user_admin"
    ml_user = "ml_user"


class AdminCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    role: AdminRole = AdminRole.end_user_admin


class AdminUpdate(BaseModel):
    username: str | None = None
    email: EmailStr | None = None
    role: AdminRole | None = None


class AdminStatusUpdate(BaseModel):
    is_active: bool


class PasswordChange(BaseModel):
    current_password: str
    new_password: str


class AdminOut(BaseModel):
    id: int
    username: str
    email: str
    role: AdminRole
    is_active: bool
    created_at: datetime


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
