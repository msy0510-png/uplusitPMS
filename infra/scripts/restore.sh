#!/usr/bin/env bash
# PostgreSQL 복원 (REQ-OPS-01) — 사용법: restore.sh <dumpfile>
set -euo pipefail
source .env
docker compose exec -T postgres pg_restore -U "$POSTGRES_USER" -d "$POSTGRES_DB" --clean < "$1"
echo "복원 완료: $1"
