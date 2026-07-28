from pydantic import BaseModel, Field


class SensorReading(BaseModel):
    """Payload sent by an IoT device to /ingest/{device_id}."""
    Voltage: float = Field(..., ge=0, le=500, description="Voltage in Volts")
    Current: float = Field(..., ge=0, le=100, description="Current in Amperes")
    Power: float = Field(..., ge=0, description="Power in Watts")
    temperature_C: float | None = Field(None, description="Temperature in °C")


class IngestResponse(BaseModel):
    device_id: str
    message: str
    inserted_id: str
