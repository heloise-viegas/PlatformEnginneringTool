# Pinned base image tag on purpose - Week 4's policy engine rejects `latest`.
FROM python:3.12.8-slim AS base

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# Non-root on purpose - Week 4's Kyverno/Gatekeeper policy requires runAsNonRoot.
RUN addgroup --system app && adduser --system --ingroup app app
USER app

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
