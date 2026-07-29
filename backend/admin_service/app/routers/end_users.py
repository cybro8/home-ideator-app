import uuid
import csv
import io
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
from app.core.rbac import eu_admin_access
from app.core.security import hash_password
from app.db.connections import get_pool
from app.models.user import EndUserCreate, EndUserUpdate, EndUserStatusUpdate, EndUserOut
import aiomysql

router = APIRouter(prefix="/users", tags=["end-users"])


@router.get("", response_model=list[EndUserOut])
async def list_users(
    skip: int = 0, limit: int = 50,
    search: str | None = None,
    current: dict = Depends(eu_admin_access),
):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            if search:
                await cur.execute(
                    "SELECT * FROM end_users WHERE username LIKE %s OR email LIKE %s "
                    "ORDER BY created_at DESC LIMIT %s OFFSET %s",
                    (f"%{search}%", f"%{search}%", limit, skip),
                )
            else:
                await cur.execute(
                    "SELECT * FROM end_users ORDER BY created_at DESC LIMIT %s OFFSET %s",
                    (limit, skip),
                )
            return [EndUserOut(**r) for r in await cur.fetchall()]


@router.post("", response_model=EndUserOut, status_code=201)
async def create_user(body: EndUserCreate, current: dict = Depends(eu_admin_access)):
    uid = str(uuid.uuid4())
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            try:
                await cur.execute(
                    "INSERT INTO end_users (uid, username, email, password_hash) "
                    "VALUES (%s, %s, %s, %s)",
                    (uid, body.username, body.email, hash_password(body.password)),
                )
                await cur.execute("SELECT * FROM end_users WHERE uid = %s", (uid,))
                return EndUserOut(**await cur.fetchone())
            except Exception as e:
                if "Duplicate" in str(e):
                    raise HTTPException(status_code=409, detail="Username or email already exists.")
                raise


@router.get("/{uid}", response_model=EndUserOut)
async def get_user(uid: str, current: dict = Depends(eu_admin_access)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute("SELECT * FROM end_users WHERE uid = %s", (uid,))
            row = await cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="User not found.")
    return EndUserOut(**row)


@router.patch("/{uid}", response_model=EndUserOut)
async def update_user(uid: str, body: EndUserUpdate, current: dict = Depends(eu_admin_access)):
    updates = {k: v for k, v in body.model_dump().items() if v is not None}
    if not updates:
        raise HTTPException(status_code=400, detail="No fields to update.")
    set_clause = ", ".join(f"{k} = %s" for k in updates)
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                f"UPDATE end_users SET {set_clause} WHERE uid = %s",
                (*updates.values(), uid),
            )
            await cur.execute("SELECT * FROM end_users WHERE uid = %s", (uid,))
            row = await cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="User not found.")
    return EndUserOut(**row)


@router.patch("/{uid}/status", response_model=EndUserOut)
async def toggle_user_status(
    uid: str, body: EndUserStatusUpdate, current: dict = Depends(eu_admin_access)
):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "UPDATE end_users SET is_active = %s WHERE uid = %s", (body.is_active, uid)
            )
            await cur.execute("SELECT * FROM end_users WHERE uid = %s", (uid,))
            row = await cur.fetchone()
    if not row:
        raise HTTPException(status_code=404, detail="User not found.")
    return EndUserOut(**row)


@router.delete("/{uid}", status_code=204)
async def delete_user(uid: str, current: dict = Depends(eu_admin_access)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            affected = await cur.execute("DELETE FROM end_users WHERE uid = %s", (uid,))
    if not affected:
        raise HTTPException(status_code=404, detail="User not found.")


@router.get("/{uid}/devices")
async def get_user_devices(uid: str, current: dict = Depends(eu_admin_access)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "SELECT ud.*, p.name AS product_name FROM user_devices ud "
                "LEFT JOIN products p ON ud.product_id = p.id WHERE ud.user_uid = %s",
                (uid,),
            )
            return await cur.fetchall()


@router.get("/{uid}/products")
async def get_user_products(uid: str, current: dict = Depends(eu_admin_access)):
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor(aiomysql.DictCursor) as cur:
            await cur.execute(
                "SELECT p.* FROM products p "
                "INNER JOIN user_devices ud ON p.id = ud.product_id "
                "WHERE ud.user_uid = %s",
                (uid,),
            )
            return await cur.fetchall()


@router.get("/{uid}/data/live")
async def get_live_data(uid: str, current: dict = Depends(eu_admin_access)):
    """Return latest reading for each device belonging to this user."""
    from app.db.connections import get_mongo_db
    db = await get_mongo_db()
    pipeline = [
        {"$match": {"user_uid": uid}},
        {"$sort": {"timestamp": -1}},
        {"$group": {"_id": "$device_id", "latest": {"$first": "$$ROOT"}}},
        {"$replaceRoot": {"newRoot": "$latest"}},
    ]
    results = await db.device_readings.aggregate(pipeline).to_list(length=100)
    for r in results:
        r["_id"] = str(r["_id"])
    return results


@router.get("/{uid}/data/csv")
async def get_user_data_csv(
    uid: str,
    from_ts: datetime | None = Query(None, alias="from"),
    to_ts: datetime | None = Query(None, alias="to"),
    current: dict = Depends(eu_admin_access),
):
    from app.db.connections import get_mongo_db
    db = await get_mongo_db()
    query: dict = {"user_uid": uid}
    if from_ts or to_ts:
        ts_filter: dict = {}
        if from_ts:
            ts_filter["$gte"] = from_ts.isoformat()
        if to_ts:
            ts_filter["$lte"] = to_ts.isoformat()
        query["timestamp"] = ts_filter

    docs = await db.device_readings.find(query).sort("timestamp", -1).to_list(length=10000)
    
    READING_FIELDS = ["device_id", "user_uid", "device_name", "device_type",
                      "timestamp", "Voltage", "Current", "Power", "temperature_C",
                      "status", "anomaly_type", "is_anomaly", "fault_score"]

    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=READING_FIELDS, extrasaction="ignore")
    writer.writeheader()
    for doc in docs:
        readings = doc.pop("readings", {})
        doc.update(readings)
        doc.pop("_id", None)
        writer.writerow(doc)
    
    output.seek(0)
    filename = f"user_{uid}_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.csv"
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
