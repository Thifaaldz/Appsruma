# 🏠 Kos Management System

A scalable and modern boarding house (Kos) management system built using:

- Flutter
- Golang
- PostgreSQL
- Docker

This project provides:
- Owner Application (Ibu Kos)
- Admin/Tenant Application
- REST API Backend
- Multi-role Authentication System

---

# 📌 Overview

This system helps boarding house owners manage:
- Rooms
- Tenants
- Payments
- Complaints
- Admin Accounts
- Financial Reports

The system is designed with clean architecture and scalable backend structure.

---

# 🏗️ System Architecture

```text
                        INTERNET
                            |
                     NGINX / LOAD BALANCER
                            |
                    GOLANG BACKEND API
                            |
        ------------------------------------------------
        |                                              |
  OWNER APPLICATION                          ADMIN/TENANT APPLICATION
        Flutter                                        Flutter
                            |
                      PostgreSQL Database
                            |
                       Redis (Optional)
```

---

# 👥 User Roles

## 1. Super Admin
- Manage all boarding house owners
- Monitor all systems
- System analytics
- Global access

---

## 2. Owner (Ibu Kos)
- Create admin accounts
- Manage rooms
- Manage tenants
- Manage payments
- View reports
- Monitor occupancy

---

## 3. Admin
- Validate tenant data
- Manage daily operational data
- Input payment data
- Handle complaints

---

## 4. Tenant
- View room information
- View bills
- Payment history
- Complaint submission
- Notifications

---

# 🚀 Features

## Authentication
- JWT Authentication
- Role-based Authorization
- Secure Password Hashing

## Room Management
- Add room
- Edit room
- Delete room
- Room availability status

## Tenant Management
- Add tenant
- Move tenant
- Tenant history

## Payment System
- Monthly payment tracking
- Payment history
- Outstanding bills
- Payment status

## Reports
- Occupancy reports
- Monthly income reports
- Financial dashboard

## Notification System
- Payment reminders
- Complaint updates
- Room notifications

---

# 🛠️ Tech Stack

## Frontend
| Technology | Description |
|---|---|
| Flutter | Cross-platform mobile application |

---

## Backend
| Technology | Description |
|---|---|
| Golang | Backend programming language |
| Gin | HTTP Web Framework |
| GORM | ORM for Golang |
| JWT | Authentication |

---

## Database
| Technology | Description |
|---|---|
| PostgreSQL | Relational database |

---

## DevOps
| Technology | Description |
|---|---|
| Docker | Containerization |
| Docker Compose | Multi-container management |
| NGINX | Reverse proxy |

---

# 📂 Project Structure

```text
kos-management-system/
│
├── backend/
│   ├── cmd/
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── repositories/
│   ├── routes/
│   ├── services/
│   ├── utils/
│   ├── main.go
│   ├── go.mod
│   └── Dockerfile
│
├── frontend-owner/
│   ├── lib/
│   ├── assets/
│   └── pubspec.yaml
│
├── frontend-tenant/
│   ├── lib/
│   ├── assets/
│   └── pubspec.yaml
│
├── database/
│   └── init.sql
│
├── docker-compose.yml
│
└── README.md
```

---

# 🗄️ Database Schema

## users

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password TEXT,
    role VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## boarding_houses

```sql
CREATE TABLE boarding_houses (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id),
    name VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## rooms

```sql
CREATE TABLE rooms (
    id SERIAL PRIMARY KEY,
    boarding_house_id INTEGER REFERENCES boarding_houses(id),
    room_number VARCHAR(20),
    price NUMERIC,
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## tenants

```sql
CREATE TABLE tenants (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    room_id INTEGER REFERENCES rooms(id),
    phone VARCHAR(20),
    check_in_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## payments

```sql
CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    tenant_id INTEGER REFERENCES tenants(id),
    amount NUMERIC,
    payment_date DATE,
    status VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

# 🔐 Authentication

This project uses JWT Authentication.

Example JWT Payload:

```json
{
  "user_id": 1,
  "role": "owner"
}
```

---

# 🌐 API Endpoints

# Authentication

```http
POST /api/auth/login
POST /api/auth/register
POST /api/auth/logout
```

---

# Rooms

```http
GET    /api/rooms
GET    /api/rooms/:id
POST   /api/rooms
PUT    /api/rooms/:id
DELETE /api/rooms/:id
```

---

# Tenants

```http
GET    /api/tenants
GET    /api/tenants/:id
POST   /api/tenants
PUT    /api/tenants/:id
DELETE /api/tenants/:id
```

---

# Payments

```http
GET    /api/payments
GET    /api/payments/:id
POST   /api/payments
```

---

# Complaints

```http
GET    /api/complaints
POST   /api/complaints
PUT    /api/complaints/:id
```

---

# ⚙️ Installation

# 1. Clone Repository

```bash
git clone https://github.com/yourusername/kos-management-system.git
cd kos-management-system
```

---

# 2. Create Environment File

Create `.env`

```env
APP_PORT=8080

DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=kosdb

JWT_SECRET=supersecretkey
```

---

# 3. Run Using Docker

```bash
docker compose up --build
```

---

# 4. Stop Containers

```bash
docker compose down
```

---

# 🐳 Docker Setup

## Backend Dockerfile

```dockerfile
FROM golang:1.26

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod tidy

COPY . .

RUN go build -o main .

EXPOSE 8080

CMD ["./main"]
```

---

# Docker Compose

```yaml
version: '3.9'

services:
  backend:
    build: ./backend
    container_name: kos-backend
    ports:
      - "8080:8080"
    depends_on:
      - postgres

  postgres:
    image: postgres:16
    container_name: kos-postgres
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: kosdb
    ports:
      - "5432:5432"
```

---

# ▶️ Run Backend Locally

```bash
go mod tidy
go run main.go
```

---

# 📱 Flutter Setup

```bash
flutter pub get
flutter run
```

---

# 🔒 Security

- JWT Authentication
- bcrypt Password Hashing
- Role-based Access Control
- Middleware Authorization
- Environment Variable Configuration

---

# 📈 Scalability Plan

Future scalable architecture:

```text
Flutter Apps
     |
API Gateway
     |
Microservices
     |
PostgreSQL Cluster
     |
Redis Cache
     |
Message Queue
```

---

# 📌 Future Improvements

- Midtrans Payment Gateway
- WhatsApp Notification
- QRIS Payment
- Realtime Chat
- Push Notification
- Multi-branch Support
- Analytics Dashboard
- Attendance System
- Smart Lock Integration

---

# 🧪 Testing

## Run Unit Test

```bash
go test ./...
```

---

# ☁️ Recommended Deployment

## VPS
- Ubuntu 24.04
- Docker
- NGINX
- PostgreSQL

## Cloud
- AWS
- DigitalOcean
- Google Cloud
- Oracle Cloud

---

# 📄 License

MIT License

---

# 👨‍💻 Author

Developed for scalable boarding house management system architecture.

---

# ⭐ Contribution

Pull requests are welcome.

For major changes:
1. Fork repository
2. Create feature branch
3. Commit changes
4. Push branch
5. Open Pull Request

---

# 📞 Support

If you encounter issues:
- Open GitHub Issues
- Contact project maintainer
- Submit pull requests

---
