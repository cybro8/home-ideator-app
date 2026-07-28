# Home Ideator — Backend System

Microservices backend for the Home Ideator IoT app.

## Stack
- **FastAPI** (Python 3.11) — all services
- **uv** — package management
- **MySQL 8** — user & product data
- **MongoDB 7** — real-time device readings
- **Angular 17** — admin web UI
- **Docker / docker-compose** — containerisation

## Services

| Service | Port | Purpose |
|---|---|---|
| `iot_service` | 8001 (internal) | Receives IoT readings → MongoDB |
| `user_service` | 8002 | End-user Flutter app API |
| `admin_service` | 8003 | Admin web API |
| `frontend` | 4200 | Angular admin dashboard |

## Quick Start (dev)

```bash
# 1. Copy env file
cp .env.example .env

# 2. Start all containers
docker compose up --build

# 3. Access
#   Admin API docs:  http://localhost:8003/docs
#   User API docs:   http://localhost:8002/docs
#   Angular UI:      http://localhost:4200
```

## Default Admin Credentials

| Role | Email | Password |
|---|---|---|
| `admin` | admin@homeideator.com | Admin@1234 |
| `end_user_admin` | euadmin@homeideator.com | Admin@1234 |
| `ml_user` | mluser@homeideator.com | Admin@1234 |

## Running Tests

```bash
# iot_service
cd services/iot_service
uv sync --all-groups
uv run pytest tests/ -v --cov=app

# admin_service
cd services/admin_service
uv sync --all-groups
uv run pytest tests/ -v --cov=app

# user_service
cd services/user_service
uv sync --all-groups
uv run pytest tests/ -v --cov=app

# Angular unit tests
cd frontend
ng test --watch=false

# Angular E2E (requires full stack)
docker compose up -d
cd frontend && npx cypress run
```

## Seed Data

Test fixtures automatically load from:
- `data/home_ideator_sensor_data.csv` → 5 000 MongoDB device readings
- `data/home_ideator_shop_data.csv` → 30 MySQL products

## Admin Role Permissions

| Endpoint Group | admin | end_user_admin | ml_user |
|---|:---:|:---:|:---:|
| Admin account CRUD | ✅ | ❌ | ❌ |
| Own password/details | ✅ | ✅ | ✅ |
| End-user management | ✅ | ✅ | ❌ |
| View device data / download CSV | ✅ | ❌ | ✅ |
| Product management | ✅ | ❌ | ❌ |
