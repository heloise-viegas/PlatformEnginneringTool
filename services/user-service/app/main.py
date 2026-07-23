import os
import socket
import time
import uuid

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from prometheus_fastapi_instrumentator import Instrumentator
from pydantic import BaseModel

# Dummy service, standing in for a real user service so the
# scaffold-service workflow (see .github/workflows/scaffold-service.yml)
# has something real to generate a Dockerfile/Helm chart/CI pipeline for.
# Users are stored in memory only - nothing here persists anything.

SERVICE_NAME = os.getenv("SERVICE_NAME", "user-service")
SERVICE_VERSION = os.getenv("SERVICE_VERSION", "0.1.0")

start_time = time.time()

app = FastAPI(title=SERVICE_NAME, version=SERVICE_VERSION)

Instrumentator().instrument(app).expose(app, endpoint="/metrics")

_users: dict[str, dict] = {}


class UserRequest(BaseModel):
    name: str
    email: str


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


@app.post("/users")
def create_user(user: UserRequest):
    user_id = str(uuid.uuid4())
    _users[user_id] = {
        "id": user_id,
        "name": user.name,
        "email": user.email,
    }
    return _users[user_id]


@app.get("/users")
def list_users():
    return list(_users.values())


@app.get("/users/{user_id}")
def get_user(user_id: str):
    user = _users.get(user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="user not found")
    return user
