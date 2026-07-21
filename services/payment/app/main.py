import os
import socket
import time

from fastapi import FastAPI
from fastapi.responses import JSONResponse
from prometheus_fastapi_instrumentator import Instrumentator

SERVICE_NAME = os.getenv("SERVICE_NAME", "reference-service")
SERVICE_VERSION = os.getenv("SERVICE_VERSION", "0.1.0")

start_time = time.time()

app = FastAPI(title=SERVICE_NAME, version=SERVICE_VERSION)

# Exposes /metrics in Prometheus format. Feeds directly into the observability
# stack (Prometheus/Grafana) that lands in Week 9 - every service built on
# this reference gets scrapeable metrics for free.
Instrumentator().instrument(app).expose(app, endpoint="/metrics")


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
    """Readiness probe: is the service ready to receive traffic.

    Extend this with real dependency checks (DB, cache, downstream APIs)
    as they get added to whatever service is built from this template.
    """
    return JSONResponse({"status": "ready"})


@app.get("/version")
def version():
    return {
        "service": SERVICE_NAME,
        "version": SERVICE_VERSION,
        "uptime_seconds": round(time.time() - start_time, 2),
    }
