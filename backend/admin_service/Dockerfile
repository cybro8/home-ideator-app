FROM python:3.11-slim AS base
WORKDIR /app
RUN pip install uv --no-cache-dir

FROM base AS development
COPY pyproject.toml .
RUN uv sync --all-groups
COPY . .
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8003"]

FROM base AS production
COPY pyproject.toml .
RUN uv sync --no-dev
COPY . .
CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8003", "--workers", "2"]
