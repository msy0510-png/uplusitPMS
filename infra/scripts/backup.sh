#!/usr/bin/env bash
# PostgreSQL 백업 (REQ-OPS-01)
set -euo pipefail
source .env
TS=$(date +%Y%m%d_%H%M%S)
docker compose exec -T postgres pg_dump -U "$POSTGRES_USER" -Fc "$POSTGRES_DB" > "backup_${TS}.dump"
echo "backup_${TS}.dump 생성"
