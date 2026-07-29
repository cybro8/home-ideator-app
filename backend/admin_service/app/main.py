from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, admins, end_users, device_data, products
from app.db.connections import close_mysql, close_mongo


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield
    await close_mysql()
    await close_mongo()


app = FastAPI(
    title="Home Ideator — Admin Service",
    description="Administration service: manage admin accounts, end-user accounts, device data, and products.",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:4200",
        "http://localhost:4201",
        "http://localhost:4205",
        "http://127.0.0.1:4200",
        "http://127.0.0.1:4201",
        "http://127.0.0.1:4205",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(admins.router)
app.include_router(end_users.router)
app.include_router(device_data.router)
app.include_router(products.router)


@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok", "service": "admin_service"}
