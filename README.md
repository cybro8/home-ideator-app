# Home Ideator — Backend System

Microservices backend and Admin UI for the Home Ideator IoT app.

## Stack
- **FastAPI** (Python 3.11) — Backend services (`iot_service`, `user_service`, `admin_service`)
- **uv** — Package management
- **MySQL 8** — User, Admin, and Product relational data
- **MongoDB 7** — Real-time high-throughput device sensor readings
- **Angular 17** — Admin web UI dashboard
- **Docker / docker-compose** — Full environment containerization

## Services

| Service | Port | Purpose |
|---|---|---|
| `iot_service` | 8001 (internal) | Receives IoT readings → MongoDB |
| `user_service` | 8002 | End-user mobile app API |
| `admin_service` | 8003 | Admin dashboard API |
| `frontend` | 4201 | Angular Admin UI |
| `db_seeder` | - | Automates DB initialization and seeding on startup |

## Quick Start (Local Development)

```bash
# 1. Start all containers (including databases, APIs, frontend, and the DB Seeder)
cd docker
docker compose up --build -d
```

### Accessing the Application
- **Angular Admin UI**: [http://localhost:4201](http://localhost:4201)
- **Admin API Docs**: [http://localhost:8003/docs](http://localhost:8003/docs)
- **User API Docs**: [http://localhost:8002/docs](http://localhost:8002/docs)

---

## 🔐 Credentials & Default Accounts

### Admin Account
Used for logging into the Angular Admin Dashboard:
- **Email:** `admin@homeideator.com`
- **Password:** `Admin@1234`

### End User Accounts (Seeded Data)
Used for testing the End-User application and generating device data.
- **Password for all users:** `User@1234`
- **User Emails:**
  - `ravi.kumar@homeideator.com`
  - `priya.sharma@homeideator.com`
  - `arjun.patel@homeideator.com`
  - `meena.nair@homeideator.com`
  - `suresh.reddy@homeideator.com`

---

## 🛠 Features Highlights

### Automated Database Seeding (`db_seeder`)
You **do not** need to manually load data into the system. The `db_seeder` container is designed to run automatically on `docker compose up`. It waits for MySQL and MongoDB to become healthy, and securely injects:
1. **5 End Users** (with hashed passwords).
2. **50 IoT Devices** (Fans, ACs, Fridges, TVs, etc.) linked to those users.
3. **5,000 Sensor Readings** (voltage, current, power, temperature, and anomalies) into MongoDB.

*Note: The seeder is idempotent. It will safely skip inserting duplicates if the database is already populated.*

### Admin Dashboard (Device Data)
- **Real-time Monitoring**: Monitor telemetry for any user appliance in the network.
- **Anomaly Highlighting**: Visual indicators on sensor tables when devices draw excessive power or overheat.
- **Unified Download Panel**: A responsive right-side drawer allows you to easily extract data:
  - **Filter by User:** Select an owner to see their devices.
  - **Filter by Device:** Select an individual appliance or download data for **All Devices** owned by that user.
  - **Date/Time Filtering:** Set custom `From` and `To` timestamps.
  - **Format Options:** Download reports in either **CSV** or **Excel (.xlsx)** formats.

---

## Running Tests

```bash
# iot_service
cd backend/iot_service
uv sync --all-groups
uv run pytest tests/ -v --cov=app

# admin_service
cd backend/admin_service
uv sync --all-groups
uv run pytest tests/ -v --cov=app

# user_service
cd backend/user_service
uv sync --all-groups
uv run pytest tests/ -v --cov=app
```
