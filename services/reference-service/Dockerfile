# Pinned base image tag on purpose - Week 4's policy engine rejects `latest`.
FROM python:3.12.8-slim AS base

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

# Non-root on purpose - Week 4's Kyverno/Gatekeeper policy requires runAsNonRoot.
# Numeric UID/GID (not a name) so kubelet can verify runAsNonRoot at admission
# time without inspecting the image - a named USER fails that check outright.
RUN addgroup --system --gid 10001 app && adduser --system --uid 10001 --ingroup app app
USER 10001:10001

EXPOSE 8080

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
