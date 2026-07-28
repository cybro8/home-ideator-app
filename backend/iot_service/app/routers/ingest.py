from datetime import datetime, timezone
from fastapi import APIRouter, HTTPException
from app.db.mongo import get_db
from app.db.mysql import get_device
from app.models.reading import SensorReading, IngestResponse

router = APIRouter(prefix="/ingest", tags=["ingest"])


@router.post("/{device_id}", response_model=IngestResponse, status_code=201)
async def ingest_reading(device_id: str, payload: SensorReading):
    """
    Receive a sensor reading from an IoT device and persist it to MongoDB.

    Steps:
    1. Validate the device exists in MySQL user_devices.
    2. Build a document from the payload + device metadata.
    3. Insert into MongoDB device_readings collection.
    """
    # 1. Look up device in MySQL
    device = await get_device(device_id)
    if device is None:
        raise HTTPException(status_code=404, detail=f"Device '{device_id}' not registered.")

    # 2. Build document
    doc = {
        "device_id":   device_id,
        "user_uid":    device["user_uid"],
        "product_id":  device.get("product_id"),
        "device_name": device.get("device_name", ""),
        "device_type": device.get("device_type", ""),
        "timestamp":   datetime.now(timezone.utc).isoformat(),
        "readings": {
            "Voltage":       payload.Voltage,
            "Current":       payload.Current,
            "Power":         payload.Power,
            "temperature_C": payload.temperature_C,
        },
        "status": "Active",
    }

    # 3. Insert into MongoDB
    db = await get_db()
    result = await db.device_readings.insert_one(doc)

    return IngestResponse(
        device_id=device_id,
        message="Reading stored successfully.",
        inserted_id=str(result.inserted_id),
    )
