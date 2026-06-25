package kr.co.uplusit.pms.dashboard;

import kr.co.uplusit.pms.common.ApiResponse;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

/** 대시보드 (UC-DSH-01 / REQ-DSH-01,02,03,05). 스텁: placeholder 응답. */
@RestController
@RequestMapping("/api/v1/projects/{pid}/dashboard")
public class DashboardController {

    @GetMapping
    public ApiResponse<Map<String, Object>> summary(@PathVariable Long pid) {
        // TODO: SSOT 집계(진척률·품질·이슈/결함) — Claude Code 구현
        return ApiResponse.ok(Map.of(
            "projectId", pid,
            "wbsProgress", 0,
            "qualityRate", 0,
            "issueDefectRate", 0,
            "todayTasks", java.util.List.of()
        ));
    }

    @GetMapping("/widgets/{key}")
    public ApiResponse<Map<String, Object>> drilldown(@PathVariable Long pid, @PathVariable String key) {
        return ApiResponse.ok(Map.of("projectId", pid, "widget", key, "items", java.util.List.of()));
    }
}
