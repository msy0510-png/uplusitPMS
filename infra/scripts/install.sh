#!/usr/bin/env bash
# 망분리 오프라인 설치 스크립트 (초안)
set -euo pipefail
echo "[1/4] 오프라인 이미지 로드"
[ -f images.tar ] && docker load -i images.tar || echo " - images.tar 없음(개발 모드)"
echo "[2/4] 환경설정 확인"
[ -f .env ] || cp .env.example .env
echo "[3/4] 컨테이너 기동"
docker compose up -d
echo "[4/4] 마이그레이션은 api 기동 시 Flyway 자동 적용"
echo "완료. WEB_PORT 로 접속하세요."
