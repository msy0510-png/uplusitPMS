# Claude Code 이관 안내 (HANDOFF)

이 리포지토리는 Cowork에서 생성한 **초기 골격**이다. 이후 구현·빌드·테스트·패키징은 Claude Code에서 진행한다.

## 이관 시 가장 먼저 할 일
1. `docs/`에 설계 산출물(`07_설계서.md` 등) 동기화 — SSOT 유지.
2. Gradle Wrapper 생성: `gradle wrapper --gradle-version 8.7` (네트워크 가능 환경).
3. 의존성 내려받아 빌드 검증: `cd backend && ./gradlew build`.
4. 프론트엔드: `cd frontend && npm install && npm run build`.
5. `docker compose up` 로 통합 기동 확인.

## 무엇이 들어있나 (스텁 수준)
- `backend/` Spring Boot 골격 + 공통(ApiResponse/예외) + **모듈별 컨트롤러 스텁**(요구/UC 매핑 주석).
- `backend/.../db/migration/` **Flyway 마이그레이션 초안**(V1 코어 테이블, V2 시드).
- `frontend/` React+TS Vite 골격 + API 클라이언트 + 라우팅 스텁.
- `infra/` Dockerfile·nginx·설치/백업 스크립트. 루트 `docker-compose.yml`.

## 무엇이 비어있나 (Claude Code에서 채울 것)
- 도메인 로직(가중치·S-Curve·EVM 계산, 진척 브리지 엔진, 결함 상태머신).
- JPA 엔티티·리포지토리·서비스 구현(현재 컨트롤러는 placeholder 응답).
- 인증/RBAC 실제 구현, 감사 인터셉터, 알림 디스패처.
- 단위/통합 테스트, CI, 오프라인 패키징 스크립트 완성.

## 권장 구현 순서 (MVP)
1. 공통·보안·감사 → 2. 프로젝트/조직/권한 → 3. WBS·진척+브리지 →
4. 요구사항·RTM → 5. 칸반 → 6. 테스트/결함 → 7. 품질/결재 → 8. 대시보드·알림.

## 추적 규칙
- 커밋 메시지에 요구 ID 명시: `feat(REQ-SCH-05): S-Curve 집계 API`.
- 각 컨트롤러/마이그레이션 주석의 `REQ-xxx / UC-xxx` 매핑을 유지·확장.
