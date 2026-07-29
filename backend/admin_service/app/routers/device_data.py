import csv
import io
from datetime import datetime
from fastapi import APIRouter, Depends, Query
from fastapi.responses import StreamingResponse
from app.core.rbac import data_access
from app.db.connections import get_mongo_db
import openpyxl

router = APIRouter(prefix="/devices", tags=["device-data"])

READING_FIELDS = ["device_id", "user_uid", "device_name", "device_type",
                  "timestamp", "Voltage", "Current", "Power", "temperature_C",
                  "status", "anomaly_type", "is_anomaly", "fault_score"]


@router.get("", summary="List all distinct device IDs")
async def list_devices(current: dict = Depends(data_access)):
    db = await get_mongo_db()
    device_ids = await db.device_readings.distinct("device_id")
    return sorted(device_ids)


def _flatten(doc: dict) -> dict:
    readings = doc.pop("readings", {})
    doc.update(readings)
    doc.pop("_id", None)
    return doc


@router.get("/{device_id}/data")
async def get_device_data(
    device_id: str,
    from_ts: datetime | None = Query(None, alias="from"),
    to_ts: datetime | None = Query(None, alias="to"),
    limit: int = Query(100, le=1000),
    current: dict = Depends(data_access),
):
    db = await get_mongo_db()
    query: dict = {"device_id": device_id}
    if from_ts or to_ts:
        ts_filter: dict = {}
        if from_ts:
            ts_filter["$gte"] = from_ts.isoformat()
        if to_ts:
            ts_filter["$lte"] = to_ts.isoformat()
        query["timestamp"] = ts_filter

    cursor = db.device_readings.find(query).sort("timestamp", -1).limit(limit)
    docs = await cursor.to_list(length=limit)
    return [_flatten(d) for d in docs]


@router.get("/{device_id}/data/csv")
async def download_csv(
    device_id: str,
    from_ts: datetime | None = Query(None, alias="from"),
    to_ts: datetime | None = Query(None, alias="to"),
    current: dict = Depends(data_access),
):
    db = await get_mongo_db()
    query: dict = {"device_id": device_id}
    if from_ts or to_ts:
        ts_filter: dict = {}
        if from_ts:
            ts_filter["$gte"] = from_ts.isoformat()
        if to_ts:
            ts_filter["$lte"] = to_ts.isoformat()
        query["timestamp"] = ts_filter

    docs = await db.device_readings.find(query).sort("timestamp", -1).to_list(length=10000)
    rows = [_flatten(d) for d in docs]

    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=READING_FIELDS, extrasaction="ignore")
    writer.writeheader()
    writer.writerows(rows)
    output.seek(0)

    filename = f"{device_id}_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.csv"
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv; charset=utf-8",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )


@router.get("/{device_id}/data/excel")
async def download_excel(
    device_id: str,
    from_ts: datetime | None = Query(None, alias="from"),
    to_ts: datetime | None = Query(None, alias="to"),
    current: dict = Depends(data_access),
):
    db = await get_mongo_db()
    query: dict = {"device_id": device_id}
    if from_ts or to_ts:
        ts_filter: dict = {}
        if from_ts:
            ts_filter["$gte"] = from_ts.isoformat()
        if to_ts:
            ts_filter["$lte"] = to_ts.isoformat()
        query["timestamp"] = ts_filter

    docs = await db.device_readings.find(query).sort("timestamp", -1).to_list(length=10000)
    rows = [_flatten(d) for d in docs]

    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Device Readings"
    ws.append(READING_FIELDS)
    for row in rows:
        ws.append([row.get(f) for f in READING_FIELDS])

    output = io.BytesIO()
    wb.save(output)
    output.seek(0)

    filename = f"{device_id}_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.xlsx"
    return StreamingResponse(
        iter([output.read()]),
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        headers={"Content-Disposition": f'attachment; filename="{filename}"'},
    )
