from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, profile, devices, shop
from app.db.connections import close_all


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await close_all()


app = FastAPI(
    title="Home Ideator — User Service",
    description="End-user API: authentication, profile management, device data, and shop.",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(profile.router)
app.include_router(devices.router)
app.include_router(shop.router)


@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok", "service": "user_service"}
