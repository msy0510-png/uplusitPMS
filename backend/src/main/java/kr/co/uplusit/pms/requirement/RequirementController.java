package kr.co.uplusit.pms.requirement;

import kr.co.uplusit.pms.common.ApiException;
import kr.co.uplusit.pms.common.ApiResponse;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

/** 요구사항/RTM (UC-RQM-01,02 / REQ-RQM-01,02,03,05, REQ-TST-07). 스텁. */
@RestController
@RequestMapping("/api/v1/projects/{pid}/requirements")
public class RequirementController {

    @GetMapping
    public ApiResponse<List<Map<String, Object>>> list(@PathVariable Long pid) {
        return ApiResponse.ok(List.of());
    }

    @PostMapping("/baseline")
    public ApiResponse<Map<String, Object>> baseline(@PathVariable Long pid) {
        // TODO: 수용+미확정 건 일괄 확정, baseline_ver 증가
        return ApiResponse.ok(Map.of("confirmed", 0));
    }

    @PostMapping("/{reqId}/changes")
    public ApiResponse<Map<String, Object>> change(@PathVariable Long pid,
                                                   @PathVariable Long reqId,
                                                   @RequestBody Map<String, Object> body) {
        // 베이스라인 후 변경: 사유·근거·승인자 필수 (설계서 §C.4)
        if (body.get("reason") == null)
            throw new ApiException("REQ_CHANGE_EVIDENCE_REQUIRED", "변경 사유가 필요합니다.", 422);
        return ApiResponse.ok(Map.of("id", 0, "baselineVer", 1));
    }
}
