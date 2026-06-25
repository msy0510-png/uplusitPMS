package kr.co.uplusit.pms.test;

import kr.co.uplusit.pms.common.ApiResponse;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

/** 테스트/결함 (UC-TST-02,03 / REQ-TST-01,02,03,04,05,06). 스텁. */
@RestController
@RequestMapping("/api/v1")
public class TestDefectController {

    @PostMapping("/test-cases/{caseId}/executions")
    public ApiResponse<Map<String, Object>> execute(@PathVariable Long caseId,
                                                     @RequestBody Map<String, Object> body) {
        // result: pass/fail/skip/excluded — fail 시 결함 등록 유도
        return ApiResponse.ok(Map.of("caseId", caseId, "result", body.getOrDefault("result", "pass")));
    }

    @PostMapping("/test-cases/{caseId}/defects")
    public ApiResponse<Map<String, Object>> registerDefect(@PathVariable Long caseId,
                                                            @RequestBody List<Map<String, Object>> defects) {
        // 멀티 결함 등록
        return ApiResponse.ok(Map.of("caseId", caseId, "count", defects.size()));
    }

    @PatchMapping("/defects/{defectId}/status")
    public ApiResponse<Map<String, Object>> changeStatus(@PathVariable Long defectId,
                                                         @RequestBody Map<String, Object> body) {
        // TODO: 결함 상태머신(registered→fixing→fixed→closed/reopened/not_defect)
        return ApiResponse.ok(Map.of("defectId", defectId, "status", body.get("status")));
    }
}
