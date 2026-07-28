from fastapi import APIRouter, Depends, Query
from app.core.security import get_current_user
from app.db.connections import get_pool, get_mongo_db
import aiomysql
from datetime import datetime

router = APIRouter(prefix="/my", tags=["devices"])

@router.get("/devices")
async def list_devices(current: dict = Depends(get_current_user)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM user_devices WHERE user_uid=%s", (current["sub"],))
            return await cur.fetchall()

@router.get("/devices/{device_id}/data")
async def get_device_data(
    device_id: str,
    limit: int = Query(100, le=500),
    from_ts: datetime | None = Query(None, alias="from"),
    to_ts: datetime | None = Query(None, alias="to"),
    current: dict = Depends(get_current_user),
):
    db = await get_mongo_db()
    query: dict = {"device_id": device_id, "user_uid": current["sub"]}
    if from_ts or to_ts:
        ts: dict = {}
        if from_ts: ts["$gte"] = from_ts.isoformat()
        if to_ts: ts["$lte"] = to_ts.isoformat()
        query["timestamp"] = ts
    docs = await db.device_readings.find(query).sort("timestamp",-1).limit(limit).to_list(limit)
    for d in docs:
        d["_id"] = str(d["_id"])
        readings = d.pop("readings", {})
        d.update(readings)
    return docs
