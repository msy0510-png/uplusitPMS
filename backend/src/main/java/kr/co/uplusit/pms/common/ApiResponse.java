package kr.co.uplusit.pms.common;

/** 표준 응답 래퍼 (설계서 §C.1). */
public record ApiResponse<T>(boolean success, T data, PageMeta page, ApiError error) {
    public static <T> ApiResponse<T> ok(T data) { return new ApiResponse<>(true, data, null, null); }
    public static <T> ApiResponse<T> ok(T data, PageMeta page) { return new ApiResponse<>(true, data, page, null); }
    public static <T> ApiResponse<T> fail(ApiError error) { return new ApiResponse<>(false, null, null, error); }
}
