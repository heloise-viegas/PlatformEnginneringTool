import os
import socket
import time
import uuid

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from prometheus_fastapi_instrumentator import Instrumentator
from pydantic import BaseModel

# Dummy service, standing in for a real payment service so the
# scaffold-service workflow (see .github/workflows/scaffold-service.yml)
# has something real to generate a Dockerfile/Helm chart/CI pipeline for.
# Charges are stored in memory only - nothing here talks to a real
# processor or persists anything.

SERVICE_NAME = os.getenv("SERVICE_NAME", "payment-service")
SERVICE_VERSION = os.getenv("SERVICE_VERSION", "0.1.0")

start_time = time.time()

app = FastAPI(title=SERVICE_NAME, version=SERVICE_VERSION)

Instrumentator().instrument(app).expose(app, endpoint="/metrics")

_charges: dict[str, dict] = {}


class ChargeRequest(BaseModel):
    amount_cents: int
    currency: str = "usd"


@app.get("/")
def root():
    return {
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "hostname": socket.gethostname(),
    }


@app.get("/healthz")
def healthz():
    """Liveness probe: is the process up and able to respond at all."""
    return JSONResponse({"status": "ok"})


@app.get("/readyz")
def readyz():
    """Readiness probe: is the service ready to receive traffic."""
    return JSONResponse({"status": "ready"})


@app.get("/version")
def version():
    return {
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "uptime_seconds": round(time.time() - start_time, 2),
    }


@app.post("/charges")
def create_charge(charge: ChargeRequest):
    if charge.amount_cents <= 0:
        raise HTTPException(status_code=400, detail="amount_cents must be positive")
    charge_id = str(uuid.uuid4())
    _charges[charge_id] = {
        "id": charge_id,
        "amount_cents": charge.amount_cents,
        "currency": charge.currency,
        "status": "succeeded",
    }
    return _charges[charge_id]


@app.get("/charges/{charge_id}")
def get_charge(charge_id: str):
    charge = _charges.get(charge_id)
    if charge is None:
        raise HTTPException(status_code=404, detail="charge not found")
    return charge
