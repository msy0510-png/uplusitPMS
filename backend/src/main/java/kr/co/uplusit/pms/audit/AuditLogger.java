package kr.co.uplusit.pms.audit;

import org.springframework.stereotype.Component;

/** 전 CUD 감사 로깅 (REQ-SEC-02). 스텁: Claude Code에서 AOP/EntityListener로 audit_logs 적재. */
@Component
public class AuditLogger {
    public void record(String targetType, Long targetId, String action) {
        // TODO: persist to audit_logs (actor, before/after, timestamp)
    }
}
