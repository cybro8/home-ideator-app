import uuid
from fastapi import APIRouter, HTTPException, status, Depends
from app.core.security import hash_password, verify_password, create_access_token, get_current_user
from app.db.connections import get_pool
from pydantic import BaseModel, EmailStr
import aiomysql

router = APIRouter(prefix="/auth", tags=["auth"])


class RegisterRequest(BaseModel):
    username: str
    email: EmailStr
    password: str


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


@router.post("/register", status_code=201)
async def register(body: RegisterRequest):
    uid = str(uuid.uuid4())
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            try:
                await cur.execute(
                    "INSERT INTO end_users (uid, username, email, password_hash) "
                    "VALUES (%s, %s, %s, %s)",
                    (uid, body.username, body.email, hash_password(body.password)),
                )
            except Exception as e:
                if "Duplicate" in str(e):
                    raise HTTPException(status_code=409, detail="Username or email already exists.")
                raise
    return {"uid": uid, "message": "Account created successfully."}


@router.post("/login", response_model=TokenResponse)
async def login(body: LoginRequest):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "SELECT * FROM end_users WHERE email = %s AND is_active = TRUE", (body.email,)
            )
            user = await cur.fetchone()

    if not user or not verify_password(body.password, user["password_hash"]):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Invalid credentials.")

    token = create_access_token({"sub": user["uid"], "aud": "user"})
    return TokenResponse(access_token=token)
