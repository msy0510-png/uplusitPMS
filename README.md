# uplusitPMS

유플러스아이티 통합 IT 프로젝트 관리 시스템. NeoPMS / WATCH2 벤치마크 기반, 공공/망분리(폐쇄망) 온프레미스 패키지 납품 대상.

> **상태:** 설계 → 구현 이관용 **골격(스캐폴딩)**. 본 리포지토리는 Cowork에서 생성한 초기 골격이며, 실제 구현·빌드·테스트는 **Claude Code**에서 이어서 진행한다. ([HANDOFF.md](./HANDOFF.md) 참조)

## 스택
- Frontend: React 18 + TypeScript + Vite
- Backend: Java 17 + Spring Boot 3 (Web/Security/Data JPA), Flyway, Quartz
- DB: PostgreSQL 15 · Cache/Bus: Redis
- 배포: Docker + docker-compose (망분리 오프라인 번들)

## 구조
```
uplusitpms/
├── backend/    Spring Boot (API·도메인·마이그레이션)
├── frontend/   React SPA
├── infra/      Dockerfile·nginx·설치/백업 스크립트
├── packaging/  망분리 오프라인 번들 산출물(빌드 시 생성)
└── docs/       설계 산출물 동기화 위치(SSOT)
```

## 로컬 기동(개발)
```bash
cp .env.example .env
docker compose up -d postgres redis
# backend: cd backend && ./gradlew bootRun
# frontend: cd frontend && npm i && npm run dev
```

## 근거 문서
설계: `../07_설계서.md` · 분석: `../06_분석서.md` · 요구: `../02_요구사항정의서.md`
