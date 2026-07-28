from datetime import datetime, timedelta, timezone
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def hash_password(plain: str) -> str:
    return pwd_context.hash(plain)

def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)

def create_access_token(data: dict) -> str:
    payload = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(hours=settings.user_token_expire_hours)
    payload.update({"exp": expire, "aud": "user"})
    return jwt.encode(payload, settings.user_jwt_secret, algorithm=settings.jwt_algorithm)

async def get_current_user(token: str = Depends(oauth2_scheme)) -> dict:
    try:
        return jwt.decode(token, settings.user_jwt_secret,
                          algorithms=[settings.jwt_algorithm], audience="user")
    except JWTError as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Invalid or expired token.",
                            headers={"WWW-Authenticate": "Bearer"}) from exc
