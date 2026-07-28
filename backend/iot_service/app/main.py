from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.routers import ingest
from app.db.mongo import close_mongo
from app.db.mysql import close_pool


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield  # startup — pools are created lazily on first request
    await close_mongo()
    await close_pool()


app = FastAPI(
    title="Home Ideator — IoT Service",
    description="Receives real-time electrical sensor readings from IoT devices and stores them in MongoDB.",
    version="1.0.0",
    lifespan=lifespan,
)

app.include_router(ingest.router)


@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok", "service": "iot_service"}
