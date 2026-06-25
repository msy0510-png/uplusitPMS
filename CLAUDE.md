# CLAUDE.md — uplusitPMS

이 파일은 Claude Code가 매 세션 참조하는 프로젝트 규칙서다. 코드를 작성·수정하기 전에 항상 이 규칙과 `docs/07_설계서.md`, `HANDOFF.md`를 먼저 확인한다.

## 프로젝트 개요
유플러스아이티 사내 **프로젝트 관리 시스템(PMS)**. NeoPMS / WATCH2 벤치마크 기반, 공공/**망분리(폐쇄망) 온프레미스 패키지 납품**을 전제로 한다. 외부 패키지 레지스트리·CDN에 의존하는 구현을 지양하고, 오프라인 번들로 설치 가능한 형태를 유지한다.

**현재 단계는 설계 → 구현 이관용 스캐폴딩이다.** 이 리포는 Cowork가 생성한 골격(컨트롤러 stub, Flyway V1/V2, React 라우팅 stub)이며, 실제 도메인 로직·JPA·인증·테스트는 Claude Code에서 채운다. 작업 시작 전 `HANDOFF.md`의 "무엇이 비어있나"와 아래 구현 순서를 참고할 것.

## 기술 스택
- **프론트엔드**: React 18 + TypeScript + Vite, react-router-dom v6, @tanstack/react-query, axios
- **백엔드**: Spring Boot 3.2.5 / Java 17 (Temurin) — Web / Security / Data JPA / Validation / Data Redis, Gradle
- **DB**: PostgreSQL 15 (마이그레이션은 **Flyway**, `backend/src/main/resources/db/migration/`의 `V1`, `V2` …)
- **캐시**: Redis 7
- **인프라**: Docker / docker compose, nginx (`infra/`)
- **포트·경로**: API 포트 `9090`, Web 포트 `80`(컨테이너 내부), context-path `/`, 프론트는 `/api/v1` 베이스로 호출

## 빌드·실행
```bash
# 로컬 인프라 (DB/캐시)
copy .env.example .env
docker compose up -d postgres redis

# 백엔드 (gradle wrapper는 최초 1회 생성: gradle wrapper --gradle-version 8.7)
cd backend && ./gradlew build
cd backend && ./gradlew bootRun
cd backend && ./gradlew test
cd backend && ./gradlew test --tests "kr.co.uplusit.pms.SomeTest"   # 단일 테스트

# 프론트엔드
cd frontend && npm install
cd frontend && npm run dev      # Vite dev server
cd frontend && npm run build    # tsc -b && vite build

# 전체 통합 기동 (이미지 빌드 포함)
docker compose up --build
# api 기동 시 Flyway가 V1/V2 마이그레이션 자동 적용
```
환경변수는 루트 `.env`로 docker-compose에 주입된다(`POSTGRES_*`, `REDIS_PORT`, `API_PORT`, `WEB_PORT`, `JWT_SECRET`, `TZ`). `.env.example`을 복사해서 시작.

## 디렉터리
- `backend/` — Spring Boot. 공통(ApiResponse/예외) + 모듈별 컨트롤러 스텁(요구/UC 매핑 주석 포함).
- `backend/src/main/resources/db/migration/` — Flyway 마이그레이션(V1 코어 테이블, V2 시드).
- `frontend/` — React+TS Vite 골격 + API 클라이언트 + 라우팅 스텁.
- `infra/` — Dockerfile · nginx · 설치/백업 스크립트(`install.sh`, `backup.sh`, `restore.sh`).
- `docs/` — 설계 산출물(SSOT). **요구/분석/설계의 단일 진실 공급원.**
- `packaging/` — 망분리 오프라인 번들 스크립트(빌드 시 생성).

## 아키텍처 개요

### Backend (`backend/src/main/java/kr/co/uplusit/pms/`)
도메인 모듈은 패키지 단위로 컨트롤러 stub이 미리 잘려 있다. 각 컨트롤러 상단 주석에 `REQ-xxx / UC-xxx` 매핑이 달려 있고, 새 엔드포인트 추가 시에도 이 매핑 규약을 유지·확장한다.

- `common/` — 표준 응답 래퍼 `ApiResponse<T>`(`success/data/page/error`, 설계서 §C.1), `ApiError`, `ApiException`, `GlobalExceptionHandler`, `PageMeta`. **모든 API 응답은 이 래퍼를 통과해야 한다.**
- `config/SecurityConfig` — JWT/RBAC 실제 구현은 비어 있음. `app.jwt.*` 설정만 application.yml에 존재.
- `audit/AuditLogger` — 감사 인터셉터 자리(구현 필요).
- 도메인 컨트롤러: `project`, `schedule`(WBS·S-Curve·EVM), `requirement`(RTM), `kanban`, `test`(TestDefectController, 결함 상태머신), `quality`(ApprovalController, 산출물 결재), `notification`, `dashboard`. 현재는 placeholder 응답.

### DB 스키마 (`backend/src/main/resources/db/migration/`)
Flyway 자동 적용(`baseline-on-migrate: true`). 신규 변경은 항상 새 `V{n}__*.sql`로 추가하고, **V1/V2 등 기존 마이그레이션 파일은 직접 수정하지 않는다.**
- `V1__init_core.sql` — 보안/조직/프로젝트/WBS/요구사항/테스트 등 코어 테이블. 공통 컬럼 규약: `created_at/by`, `updated_at/by`, `version`(낙관적 락).
- `V2__seed_roles.sql` — 역할/권한 시드.
- JPA는 `ddl-auto: validate` — 엔티티는 마이그레이션과 정확히 맞아야 부팅된다.

### Frontend (`frontend/src/`)
- `api/client.ts` — axios 인스턴스(`baseURL: /api/v1`), `localStorage.accessToken`로 Bearer 주입. `ApiResponse<T>` 타입은 백엔드 래퍼와 1:1 대응.
- `routes.tsx` — 설계서 §D.1 사이트맵 기반 라우트(schedule/requirements/kanban/test/quality/reports). 현재 대부분 `<Placeholder />`.
- 신규 페이지는 도메인별 폴더로 분리하고 react-query로 API 호출.

### 망분리 패키징
`infra/scripts/install.sh`·`backup.sh`·`restore.sh` + `packaging/`. 외부 네트워크 없이 동작해야 하므로 신규 의존성 추가 시 오프라인 번들 가능 여부를 먼저 확인한다.

## 참조 문서 (작업 전 반드시 확인 · SSOT)
`docs/` 하위에 동기화되어 있음. 도메인 결정의 근거는 항상 이 문서들이다.
- `docs/07_설계서.md` — **아키텍처 · ERD · API 명세 · 화면 설계** (가장 중요)
- `docs/06_분석서.md` — 분석/유스케이스
- `docs/02_요구사항정의서.md` — 요구사항 정의(REQ ID 원본)
- `docs/04_개선분석보고서.md` — 개선 분석
- `HANDOFF.md` — 이관 안내 · 구현 순서

## 추적 규칙 (중요)
- **커밋 메시지에 요구 ID를 명시**한다: `feat(REQ-SCH-05): S-Curve 집계 API`
  - 형식: `<type>(REQ-xxx 또는 UC-xxx): 설명`
  - type: `feat` / `fix` / `refactor` / `test` / `docs` / `chore`
- 각 **컨트롤러·마이그레이션 주석의 `REQ-xxx / UC-xxx` 매핑을 유지·확장**한다.
- 기능 작업은 브랜치 단위로: `feat/REQ-SCH-progress` → 커밋 → push → GitHub PR 리뷰.
- 원격: `https://github.com/msy0510-png/uplusitPMS`

## 구현 순서 (MVP)
각 모듈은 `엔티티 → 리포지토리 → 서비스(도메인 로직) → 컨트롤러 실연결 → 테스트` 흐름으로 채운다.

1. 공통 · 보안 · 감사 (JWT/RBAC, 감사 인터셉터)
2. 프로젝트 / 조직 / 권한 (채번 포함)
3. WBS · 진척 + 계획↔실행 브리지 엔진 (가중치 · S-Curve 계산)
4. 요구사항 · RTM (베이스라인 · 변경관리)
5. 칸반
6. 테스트 / 결함 (상태머신)
7. 품질 / 결재
8. 대시보드 · 알림

## 코딩 원칙
- 컨트롤러는 얇게, 도메인 로직은 서비스에. 계산 로직(가중치·S-Curve·EVM, 진척 브리지, 결함 상태머신)은 단위 테스트로 검증한다.
- 응답은 공통 `ApiResponse` 포맷을 따른다. 예외는 공통 예외 처리기를 거친다.
- 스키마 변경은 반드시 새 Flyway 마이그레이션(`V{n}__...sql`)으로. 기존 마이그레이션 파일은 수정하지 않는다.
- 망분리 환경을 고려해 신규 외부 의존성 추가 시 오프라인 번들 가능 여부를 먼저 확인한다.

## 검증
- 모듈마다 `./gradlew test`로 단위/통합 테스트 작성.
- 머지 전 Claude Code의 `/review`, `security-review` 활용.
