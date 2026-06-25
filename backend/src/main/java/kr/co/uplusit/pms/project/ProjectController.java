package kr.co.uplusit.pms.project;

import kr.co.uplusit.pms.common.ApiResponse;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

/** 프로젝트 기본관리 (UC-PRJ-01 / REQ-PRJ-01,02). 스텁. */
@RestController
@RequestMapping("/api/v1/projects")
public class ProjectController {

    @GetMapping
    public ApiResponse<List<Map<String, Object>>> list() {
        return ApiResponse.ok(List.of());
    }

    @PostMapping
    public ApiResponse<Map<String, Object>> create(@RequestBody Map<String, Object> body) {
        // TODO: 행안부 표준 채번(PMS-YYYY-9999) 생성 후 저장
        return ApiResponse.ok(Map.of("id", 0, "mgmtNo", "PMS-2026-0000"));
    }

    @GetMapping("/{pid}")
    public ApiResponse<Map<String, Object>> get(@PathVariable Long pid) {
        return ApiResponse.ok(Map.of("id", pid));
    }
}
