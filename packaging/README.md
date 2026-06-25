# packaging — 망분리 오프라인 번들 (P3)

빌드 산출물 디렉터리. Claude Code 단계에서 생성:
- `images.tar` : `docker save` 로 묶은 전체 컨테이너 이미지
- `docker-compose.yml`, `.env.example`, `infra/scripts/*`
- `seed/` : 초기 데이터
- `LICENSE.lic` : RSA 서명 사이트 라이선스

생성 예: `docker save $(docker compose config --images) -o images.tar`
