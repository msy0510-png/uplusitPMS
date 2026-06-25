-- uplusitPMS 코어 스키마 초안 (설계서 §B 기준). MVP 핵심 테이블.
-- 공통 컬럼 규약: created_at/by, updated_at/by, version(낙관적 락).

-- ===== 보안/조직 =====
CREATE TABLE users (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  emp_no        VARCHAR(30),
  name          VARCHAR(100) NOT NULL,
  login_id      VARCHAR(60)  NOT NULL UNIQUE,
  email         VARCHAR(120),
  status        VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',
  created_at    TIMESTAMP    NOT NULL DEFAULT now(),
  created_by    BIGINT,
  updated_at    TIMESTAMP,
  updated_by    BIGINT,
  version       BIGINT       NOT NULL DEFAULT 0
);

CREATE TABLE organizations (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  parent_id  BIGINT REFERENCES organizations(id),
  sort       INT DEFAULT 0
);

CREATE TABLE roles (
  id            BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  role_code     VARCHAR(30) NOT NULL UNIQUE,
  name          VARCHAR(100) NOT NULL,
  is_monitoring BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE permissions (
  id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  perm_code VARCHAR(60) NOT NULL UNIQUE,
  name      VARCHAR(120) NOT NULL,
  module    VARCHAR(40)
);

CREATE TABLE role_permissions (
  role_id       BIGINT NOT NULL REFERENCES roles(id),
  permission_id BIGINT NOT NULL REFERENCES permissions(id),
  PRIMARY KEY (role_id, permission_id)
);

-- ===== 프로젝트/기준정보 =====
CREATE TABLE projects (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  mgmt_no      VARCHAR(30) NOT NULL UNIQUE,            -- 행안부 채번 PMS-YYYY-9999
  name         VARCHAR(200) NOT NULL,
  client_org   VARCHAR(200),
  start_date   DATE,
  end_date     DATE,
  tech_env_json JSONB,
  status       VARCHAR(20) NOT NULL DEFAULT 'PLANNED',
  created_at   TIMESTAMP NOT NULL DEFAULT now(),
  version      BIGINT NOT NULL DEFAULT 0
);

CREATE TABLE user_roles (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id),
  user_id    BIGINT NOT NULL REFERENCES users(id),
  role_id    BIGINT NOT NULL REFERENCES roles(id),
  org_id     BIGINT REFERENCES organizations(id),
  UNIQUE (project_id, user_id, role_id)
);

CREATE TABLE project_members (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id  BIGINT NOT NULL REFERENCES projects(id),
  user_id     BIGINT NOT NULL REFERENCES users(id),
  role_code   VARCHAR(30),
  alloc_start DATE,
  alloc_end   DATE,
  mm          NUMERIC(6,2)
);

CREATE TABLE codes (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  group_code VARCHAR(40) NOT NULL,
  code       VARCHAR(40) NOT NULL,
  name       VARCHAR(120) NOT NULL,
  sort       INT DEFAULT 0,
  use_yn     BOOLEAN DEFAULT TRUE,
  UNIQUE (group_code, code)
);

CREATE TABLE holidays (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  ymd          DATE NOT NULL UNIQUE,
  name         VARCHAR(60),
  is_statutory BOOLEAN DEFAULT TRUE
);

CREATE TABLE meta_standards (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  kind       VARCHAR(20) NOT NULL,   -- word/domain/term/infotype
  name       VARCHAR(120) NOT NULL,
  value_json JSONB
);

-- ===== 일정/진척 + 브리지 =====
CREATE TABLE wbs_tasks (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id   BIGINT NOT NULL REFERENCES projects(id),
  parent_id    BIGINT REFERENCES wbs_tasks(id),
  phase_code   VARCHAR(30),
  name         VARCHAR(300) NOT NULL,
  depth        INT NOT NULL DEFAULT 1,
  sort         INT DEFAULT 0,
  plan_start   DATE, plan_end DATE,
  act_start    DATE, act_end  DATE,
  weight       NUMERIC(7,3) DEFAULT 0,
  progress     NUMERIC(5,2) DEFAULT 0,
  cap_progress NUMERIC(5,2) DEFAULT 100,
  assignee_id  BIGINT REFERENCES users(id),
  version      BIGINT NOT NULL DEFAULT 0
);
CREATE INDEX ix_wbs_project ON wbs_tasks(project_id);

CREATE TABLE task_dependencies (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id   BIGINT NOT NULL REFERENCES projects(id),
  pred_task_id BIGINT NOT NULL REFERENCES wbs_tasks(id),
  succ_task_id BIGINT NOT NULL REFERENCES wbs_tasks(id),
  type         VARCHAR(4) NOT NULL DEFAULT 'FS',  -- FS/SS/FF/SF
  lag          INT DEFAULT 0,
  UNIQUE (pred_task_id, succ_task_id)
);

CREATE TABLE work_cards (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id  BIGINT NOT NULL REFERENCES projects(id),
  wbs_task_id BIGINT REFERENCES wbs_tasks(id),       -- ★계획↔실행 브리지
  status      VARCHAR(15) NOT NULL DEFAULT 'TODO',   -- TODO/DOING/REVIEW/DONE
  progress    NUMERIC(5,2) DEFAULT 0,
  assignee_id BIGINT REFERENCES users(id),
  reviewer_id BIGINT REFERENCES users(id),
  category    VARCHAR(40),
  version     BIGINT NOT NULL DEFAULT 0
);
CREATE INDEX ix_card_task ON work_cards(wbs_task_id);

CREATE TABLE work_card_histories (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  work_card_id BIGINT NOT NULL REFERENCES work_cards(id),
  from_status  VARCHAR(15),
  to_status    VARCHAR(15),
  progress     NUMERIC(5,2),
  comment      TEXT,
  at           TIMESTAMP NOT NULL DEFAULT now(),
  by_user      BIGINT
);

CREATE TABLE progress_snapshots (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id),
  base_date  DATE NOT NULL,
  plan_cum   NUMERIC(6,2),
  act_cum    NUMERIC(6,2),
  scope      VARCHAR(10) DEFAULT 'all'  -- all/app
);

-- ===== 요구사항/개발 =====
CREATE TABLE requirements (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id   BIGINT NOT NULL REFERENCES projects(id),
  req_no       VARCHAR(40) NOT NULL,
  type         VARCHAR(10) NOT NULL DEFAULT 'func',   -- func/nonfunc
  title        VARCHAR(400) NOT NULL,
  status       VARCHAR(15) NOT NULL DEFAULT 'unclassified',
  baseline_ver INT NOT NULL DEFAULT 0,
  version      BIGINT NOT NULL DEFAULT 0,
  UNIQUE (project_id, req_no)
);

CREATE TABLE requirement_changes (
  id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  requirement_id  BIGINT NOT NULL REFERENCES requirements(id),
  reason          TEXT NOT NULL,
  evidence_file_id BIGINT,
  approver_id     BIGINT REFERENCES users(id),
  before_json     JSONB,
  after_json      JSONB,
  at              TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE programs (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id),
  prog_no    VARCHAR(40) NOT NULL,
  category   VARCHAR(15) NOT NULL,   -- screen/batch/if/report/common/migration
  plan_date  DATE, act_date DATE,
  status     VARCHAR(20) DEFAULT 'PLANNED',
  UNIQUE (project_id, prog_no)
);

CREATE TABLE requirement_maps (
  id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id     BIGINT NOT NULL REFERENCES projects(id),
  requirement_id BIGINT NOT NULL REFERENCES requirements(id),
  target_type    VARCHAR(15) NOT NULL,   -- program/testcase
  target_id      BIGINT NOT NULL,
  UNIQUE (requirement_id, target_type, target_id)
);

-- ===== 품질/산출물 =====
CREATE TABLE deliverables (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id),
  folder_id  BIGINT,
  name       VARCHAR(300) NOT NULL,
  phase_code VARCHAR(30),
  status     VARCHAR(20) DEFAULT 'DRAFT',
  locked     BOOLEAN DEFAULT FALSE
);

CREATE TABLE deliverable_versions (
  id             BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  deliverable_id BIGINT NOT NULL REFERENCES deliverables(id),
  ver            INT NOT NULL,
  file_id        BIGINT,
  note           VARCHAR(400),
  at             TIMESTAMP NOT NULL DEFAULT now(),
  by_user        BIGINT
);

CREATE TABLE approvals (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id  BIGINT NOT NULL REFERENCES projects(id),
  target_type VARCHAR(20) NOT NULL,
  target_id   BIGINT NOT NULL,
  status      VARCHAR(15) NOT NULL DEFAULT 'draft'  -- draft/inprogress/approved/rejected
);

CREATE TABLE approval_lines (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  approval_id BIGINT NOT NULL REFERENCES approvals(id),
  step        INT NOT NULL,
  approver_id BIGINT NOT NULL REFERENCES users(id),
  status      VARCHAR(15) NOT NULL DEFAULT 'pending',
  reason      VARCHAR(400),
  acted_at    TIMESTAMP
);

-- ===== 테스트/결함 =====
CREATE TABLE test_runs (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id),
  kind       VARCHAR(5) NOT NULL,   -- UT/IT/UAT/AT
  round      INT NOT NULL DEFAULT 1,
  name       VARCHAR(200) NOT NULL,
  goal_json  JSONB,
  status     VARCHAR(20) DEFAULT 'OPEN'
);

CREATE TABLE scenarios (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  test_run_id BIGINT NOT NULL REFERENCES test_runs(id),
  level       INT NOT NULL DEFAULT 1,
  name        VARCHAR(300) NOT NULL,
  sort        INT DEFAULT 0
);

CREATE TABLE test_cases (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  test_run_id BIGINT NOT NULL REFERENCES test_runs(id),
  scenario_id BIGINT NOT NULL REFERENCES scenarios(id),
  case_no     VARCHAR(50) NOT NULL,   -- 접두어 UT/IT/UAT/AT 자동
  path        VARCHAR(300),
  tester_id   BIGINT REFERENCES users(id),
  assignee_id BIGINT REFERENCES users(id),
  status      VARCHAR(15) NOT NULL DEFAULT 'wait',  -- wait/pass/fail/skip/excluded
  UNIQUE (case_no)
);

CREATE TABLE executions (
  id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  test_case_id     BIGINT NOT NULL REFERENCES test_cases(id),
  result           VARCHAR(10) NOT NULL,   -- pass/fail/skip/excluded
  memo             TEXT,
  evidence_file_id BIGINT,
  start_date       DATE, end_date DATE,
  by_user          BIGINT,
  at               TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE defects (
  id           BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id   BIGINT NOT NULL REFERENCES projects(id),
  test_case_id BIGINT NOT NULL REFERENCES test_cases(id),
  severity     VARCHAR(10) NOT NULL DEFAULT '중',
  dtype        VARCHAR(15),   -- down/func/gui/db/etc
  status       VARCHAR(15) NOT NULL DEFAULT 'registered',
  assignee_id  BIGINT REFERENCES users(id)
);

CREATE TABLE defect_histories (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  defect_id   BIGINT NOT NULL REFERENCES defects(id),
  from_status VARCHAR(15),
  to_status   VARCHAR(15),
  comment     TEXT,
  file_id     BIGINT,
  at          TIMESTAMP NOT NULL DEFAULT now(),
  by_user     BIGINT
);

-- ===== 이슈/리스크 =====
CREATE TABLE issues (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id),
  title      VARCHAR(300) NOT NULL,
  status     VARCHAR(15) NOT NULL DEFAULT 'Opened',
  priority   VARCHAR(10),
  impact     VARCHAR(10),
  owner_id   BIGINT REFERENCES users(id)
);

CREATE TABLE risks (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id),
  title      VARCHAR(300) NOT NULL,
  status     VARCHAR(15) NOT NULL DEFAULT 'Opened',
  priority   VARCHAR(10),
  impact     VARCHAR(10),
  response   VARCHAR(10),  -- 완화/수용/회피/전이
  owner_id   BIGINT REFERENCES users(id)
);

-- ===== 의사소통/보고 =====
CREATE TABLE reports (
  id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id BIGINT NOT NULL REFERENCES projects(id),
  kind       VARCHAR(10) NOT NULL,   -- weekly/monthly
  period     VARCHAR(20),
  status     VARCHAR(15) NOT NULL DEFAULT 'created'  -- created/requested/writing/review/done
);

CREATE TABLE report_sections (
  id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  report_id BIGINT NOT NULL REFERENCES reports(id),
  team_id   BIGINT REFERENCES organizations(id),
  content_json JSONB
);

-- ===== 통합 알림/감사 =====
CREATE TABLE notifications (
  id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id   BIGINT NOT NULL REFERENCES users(id),
  event     VARCHAR(40) NOT NULL,
  ref_type  VARCHAR(30),
  ref_id    BIGINT,
  channel   VARCHAR(15) DEFAULT 'inapp',  -- inapp/mail/rc
  is_read   BOOLEAN DEFAULT FALSE,
  at        TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE notification_subscriptions (
  id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  event   VARCHAR(40) NOT NULL,
  channel VARCHAR(15) NOT NULL DEFAULT 'inapp',
  enabled BOOLEAN DEFAULT TRUE,
  UNIQUE (user_id, event, channel)
);

CREATE TABLE audit_logs (
  id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  project_id  BIGINT,
  actor_id    BIGINT,
  target_type VARCHAR(40),
  target_id   BIGINT,
  action      VARCHAR(10),   -- CREATE/UPDATE/DELETE
  before_json JSONB,
  after_json  JSONB,
  at          TIMESTAMP NOT NULL DEFAULT now()
);
CREATE INDEX ix_audit_target ON audit_logs(target_type, target_id);
