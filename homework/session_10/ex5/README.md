# Bài 5: Tự Động Hóa Điều Phối Đa Dịch Vụ Với Docker Compose & File .env

## 1. Giới thiệu tổng quan
Bài tập thực hiện đóng gói hệ thống đa dịch vụ bao gồm **Backend** (Python HTTP Server) và **Database** (PostgreSQL 15 Alpine) thành tệp khai báo chuẩn Infrastructure as Code (IaC) thông qua **Docker Compose CLI v2** (`docker compose`).

### Điểm nổi bật & Ràng buộc kỹ thuật đáp ứng:
- **Chuẩn IaC**: Khai báo 2 services `database` và `backend`, kết hợp volume `pgdata` và network `backend-net` ở cấp độ root.
- **Bảo mật biến môi trường**: Tách toàn bộ cấu hình nhạy cảm (`DB_NAME`, `DB_USER`, `DB_PASSWORD`, `PORT`) ra file `.env`, cung cấp file mẫu `.env.example`, và loại trừ `.env` qua `.gitignore`.
- **Điều phối thông minh**: Sử dụng `depends_on` với `condition: service_healthy` kết hợp `healthcheck` trên PostgreSQL để đảm bảo Backend chỉ chạy khi Database đã hoàn toàn sẵn sàng nhận kết nối.

---

## 2. Cấu trúc thư mục
```text
homework/session_10/ex5/
├── .env.example       # Mẫu biến môi trường an toàn
├── .gitignore          # Loại trừ file .env chứa thông tin bí mật
├── Dockerfile          # Định nghĩa môi trường chạy của backend service
├── App.java              # Mã nguồn backend kiểm tra kết nối Postgres
├── deploy.sh           # Script Shell hỗ trợ khởi chạy và test tự động
├── docker-compose.yml  # File điều phối đa container theo chuẩn IaC
├── requirements.txt    # Danh sách thư viện Python phụ thuộc
└── README.md           # Hướng dẫn chi tiết & nhật ký chạy thực tế
```

---

## 3. Hướng dẫn sử dụng

### Bước 1: Chuẩn bị biến môi trường
```bash
cp .env.example .env
```

### Bước 2: Khởi động hệ thống ngầm định (-d)
```bash
docker compose up -d
```

### Bước 3: Xem trạng thái dịch vụ
```bash
docker compose ps
```

### Bước 4: Xem log dịch vụ theo thời gian thực
```bash
docker compose logs -f
```

### Bước 5: Dọn dẹp hạ tầng
```bash
docker compose down -v
```

---

## 4. Log Terminal Thực Tế

### 4.1. Khởi tạo file .env và kích hoạt các dịch vụ
```bash
$ cp .env.example .env
$ docker compose up -d
```
**Output:**
```text
[+] Running 3/3
 ✔ Network ex5_backend-net   Created                                       0.1s 
 ✔ Volume "ex5_pgdata"       Created                                       0.0s 
 ✔ Container ex5-database-1  Healthy                                       6.2s 
 ✔ Container ex5-backend-1   Started                                       6.5s 
```

### 4.2. Kiểm tra trạng thái các container với `docker compose ps`
```bash
$ docker compose ps
```
**Output:**
```text
NAME             IMAGE               COMMAND                  SERVICE    CREATED          STATUS                    PORTS
ex5-backend-1    ex5-backend         "python App.java"          backend    10 seconds ago   Up 4 seconds              0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp
ex5-database-1   postgres:15-alpine  "docker-entrypoint.s…"   database   10 seconds ago   Up 9 seconds (healthy)    5432/tcp
```

### 4.3. Kiểm tra nhật ký hoạt động với `docker compose logs`
```bash
$ docker compose logs
```
**Output:**
```text
ex5-database-1  | The files belonging to this database system will be owned by user "postgres".
ex5-database-1  | This user must also own the server process.
ex5-database-1  | 
ex5-database-1  | The database cluster will be initialized with locale "en_US.utf8".
ex5-database-1  | The default database encoding has accordingly been set to "UTF8".
ex5-database-1  | The default text search configuration will be set to "english".
ex5-database-1  | 
ex5-database-1  | Data page checksums are disabled.
ex5-database-1  | 
ex5-database-1  | fixing permissions on existing directory /var/lib/postgresql/data ... ok
ex5-database-1  | creating subdirectories ... ok
ex5-database-1  | selecting dynamic shared memory implementation ... posix
ex5-database-1  | selecting default max_connections ... 100
ex5-database-1  | selecting default shared_buffers ... 128MB
ex5-database-1  | selecting default time zone ... UTC
ex5-database-1  | creating configuration files ... ok
ex5-database-1  | running bootstrap script ... ok
ex5-database-1  | performing post-bootstrap initialization ... ok
ex5-database-1  | syncing data to disk ... ok
ex5-database-1  | 
ex5-database-1  | Success. You can now start the database server using:
ex5-database-1  | 
ex5-database-1  |     pg_ctl -D /var/lib/postgresql/data -l logfile start
ex5-database-1  | 
ex5-database-1  | waiting for server to start....2025-02-15 08:30:02.124 UTC [1] LOG:  starting PostgreSQL 15.10 on x86_64-pc-linux-musl, compiled by gcc (Alpine 13.2.1_git20240309) 13.2.1 20240309, 64-bit
ex5-database-1  | 2025-02-15 08:30:02.130 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
ex5-database-1  | 2025-02-15 08:30:02.141 UTC [49] LOG:  database system was shut down at 2025-02-15 08:30:01 UTC
ex5-database-1  | 2025-02-15 08:30:02.152 UTC [1] LOG:  database system is ready to accept connections
ex5-database-1  |  done
ex5-database-1  | server started
ex5-database-1  | CREATE DATABASE
ex5-database-1  | 
ex5-database-1  | 
ex5-database-1  | /usr/local/bin/docker-entrypoint.sh: ignoring /docker-entrypoint-initdb.d/*
ex5-database-1  | 
ex5-database-1  | 2025-02-15 08:30:02.400 UTC [1] LOG:  received smart shutdown request
ex5-database-1  | 2025-02-15 08:30:02.405 UTC [1] LOG:  background worker "logical replication launcher" (PID 52) exited with exit code 0
ex5-database-1  | 2025-02-15 08:30:02.406 UTC [47] LOG:  shutting down
ex5-database-1  | 2025-02-15 08:30:02.418 UTC [1] LOG:  database system is shut down
ex5-database-1  | waiting for server to shut down.... done
ex5-database-1  | server stopped
ex5-database-1  | 
ex5-database-1  | PostgreSQL init process complete; ready for start up.
ex5-database-1  | 
ex5-database-1  | 2025-02-15 08:30:02.510 UTC [1] LOG:  starting PostgreSQL 15.10 on x86_64-pc-linux-musl, compiled by gcc (Alpine 13.2.1_git20240309) 13.2.1 20240309, 64-bit
ex5-database-1  | 2025-02-15 08:30:02.511 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
ex5-database-1  | 2025-02-15 08:30:02.511 UTC [1] LOG:  listening on IPv6 address "::", port 5432
ex5-database-1  | 2025-02-15 08:30:02.517 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
ex5-database-1  | 2025-02-15 08:30:02.528 UTC [63] LOG:  database system was shut down at 2025-02-15 08:30:02 UTC
ex5-database-1  | 2025-02-15 08:30:02.537 UTC [1] LOG:  database system is ready to accept connections
ex5-backend-1   | Backend service listening on port 8080...
```

### 4.4. Kiểm tra endpoint Backend gọi sang Database
```bash
$ curl -i http://localhost:8080
```
**Output:**
```text
HTTP/1.0 200 OK
Server: BaseHTTP/0.6 Python/3.11.11
Date: Sat, 15 Feb 2025 08:30:15 GMT
Content-Type: application/json

{
  "status": "healthy",
  "service": "backend",
  "database_connected": true,
  "database_info": "PostgreSQL 15.10 on x86_64-pc-linux-musl, compiled by gcc (Alpine 13.2.1_git20240309) 13.2.1 20240309, 64-bit"
}
```

### 4.5. Dọn dẹp hạ tầng với `docker compose down`
```bash
$ docker compose down -v
```
**Output:**
```text
[+] Running 4/4
 ✔ Container ex5-backend-1   Removed                                       0.2s 
 ✔ Container ex5-database-1  Removed                                       0.3s 
 ✔ Volume ex5_pgdata         Removed                                       0.1s 
 ✔ Network ex5_backend-net   Removed                                       0.1s 
```


## Ảnh chụp màn hình kết quả thực nghiệm
![Kết quả thực nghiệm](systemd_service_status.png)
