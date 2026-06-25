package kr.co.uplusit.pms.kanban;

import kr.co.uplusit.pms.common.ApiResponse;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.Map;

/** 진척(칸반) (UC-KAN-01 / REQ-KAN-01,02,03,04). 스텁. */
@RestController
@RequestMapping("/api/v1")
public class KanbanController {

    @GetMapping("/projects/{pid}/kanban")
    public ApiResponse<Map<String, Object>> board(@PathVariable Long pid,
                                                  @RequestParam(defaultValue = "board") String view) {
        return ApiResponse.ok(Map.of("TODO", List.of(), "DOING", List.of(), "REVIEW", List.of(), "DONE", List.of()));
    }

    @PatchMapping("/work-cards/{cardId}")
    public ApiResponse<Map<String, Object>> update(@PathVariable Long cardId,
                                                   @RequestBody Map<String, Object> body) {
        // TODO: 상태/진척 변경 → WBS 동기화(브리지 이벤트)
        return ApiResponse.ok(Map.of("cardId", cardId));
    }
}
