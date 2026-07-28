FROM python:3.11-slim AS base
WORKDIR /app
RUN pip install uv --no-cache-dir

FROM base AS development
COPY pyproject.toml .
RUN uv sync --all-groups
COPY . .
CMD [".venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8002"]

FROM base AS production
COPY pyproject.toml .
RUN uv sync --no-dev
COPY . .
CMD [".venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8002", "--workers", "2"]
