package kr.co.uplusit.pms.notification;

import kr.co.uplusit.pms.common.ApiResponse;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

/** 통합 알림센터 (UC-NTF-01 / REQ-NTF-01,02,03). 스텁. */
@RestController
@RequestMapping("/api/v1/me/notifications")
public class NotificationController {

    @GetMapping
    public ApiResponse<List<Map<String, Object>>> list() {
        return ApiResponse.ok(List.of());
    }

    @PatchMapping("/{id}/read")
    public ApiResponse<Map<String, Object>> read(@PathVariable Long id) {
        return ApiResponse.ok(Map.of("id", id, "isRead", true));
    }
}
