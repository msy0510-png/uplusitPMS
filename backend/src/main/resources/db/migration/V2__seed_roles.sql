-- 표준 역할/권한 시드 (분석서 §2 액터 기준)
INSERT INTO roles(role_code, name, is_monitoring) VALUES
 ('SYS','시스템관리자',FALSE),
 ('PMO','PMO',FALSE),
 ('PM','프로젝트관리자',FALSE),
 ('PL','팀장',FALSE),
 ('TM','팀원',FALSE),
 ('TST','시험자',FALSE),
 ('CUS','발주처/감리원',TRUE);

INSERT INTO permissions(perm_code, name, module) VALUES
 ('PROJECT_MANAGE','프로젝트 관리','project'),
 ('WBS_MANAGE','WBS/진척 관리','schedule'),
 ('REQ_MANAGE','요구사항 관리','requirement'),
 ('TEST_MANAGE','테스트/결함 관리','test'),
 ('APPROVE','산출물 결재','quality'),
 ('READ_ONLY','조회 전용','common');
