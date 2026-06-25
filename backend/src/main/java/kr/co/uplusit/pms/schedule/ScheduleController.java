package kr.co.uplusit.pms.schedule;

import kr.co.uplusit.pms.common.ApiResponse;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

/** 일정/진척 + 계획↔실행 브리지 (UC-SCH-01,02 / UC-BRG-01 / REQ-SCH-01,02,03,05,07, REQ-BRG-01,02). 스텁. */
@RestController
@RequestMapping("/api/v1/projects/{pid}")
public class ScheduleController {

    @GetMapping("/wbs")
    public ApiResponse<List<Map<String, Object>>> wbs(@PathVariable Long pid,
                                                      @RequestParam(defaultValue = "tree") String view) {
        // TODO: tree/gantt/calendar 뷰 데이터
        return ApiResponse.ok(List.of());
    }

    @PatchMapping("/wbs-tasks/{taskId}/actual")
    public ApiResponse<Map<String, Object>> registerActual(@PathVariable Long pid,
                                                            @PathVariable Long taskId,
                                                            @RequestBody Map<String, Object> body) {
        // TODO: 진척률 상한 적용 + 단계×업무·depth 가중치 곱연산 자동 산정 → 브리지 동기화
        return ApiResponse.ok(Map.of("taskId", taskId, "progress", 0));
    }

    @GetMapping("/s-curve")
    public ApiResponse<Map<String, Object>> sCurve(@PathVariable Long pid,
                                                   @RequestParam(defaultValue = "all") String scope) {
        return ApiResponse.ok(Map.of("plan", List.of(), "actual", List.of()));
    }
}
