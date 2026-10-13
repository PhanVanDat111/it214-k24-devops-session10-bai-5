#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "[1/5] Kiểm tra file môi trường .env..."
if [ ! -f .env ]; then
  echo "Tạo .env từ .env.example..."
  cp .env.example .env
fi

echo "[2/5] Khởi động hệ thống với Docker Compose CLI v2..."
docker compose up -d --build

echo "[3/5] Kiểm tra danh sách container..."
docker compose ps

echo "[4/5] Kiểm tra kết nối Backend API..."
sleep 3
curl -s -i http://localhost:8080 || true

echo ""
echo "[5/5] Hoàn tất triển khai!"
