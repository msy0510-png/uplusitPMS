package kr.co.uplusit.pms.quality;

import kr.co.uplusit.pms.common.ApiResponse;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

/** 품질/산출물 결재 (UC-QLT-02 / REQ-QLT-01,02,03). 스텁. */
@RestController
@RequestMapping("/api/v1")
public class ApprovalController {

    @PostMapping("/deliverables/{id}/approvals")
    public ApiResponse<Map<String, Object>> submit(@PathVariable Long id) {
        // TODO: 결재선 생성·상신
        return ApiResponse.ok(Map.of("deliverableId", id, "status", "inprogress"));
    }

    @PatchMapping("/approval-lines/{lineId}")
    public ApiResponse<Map<String, Object>> act(@PathVariable Long lineId,
                                                @RequestBody Map<String, Object> body) {
        // approve/reject(+reason) → 최종 승인 시 버전 확정·폴더 잠금
        return ApiResponse.ok(Map.of("lineId", lineId, "status", body.get("status")));
    }
}
