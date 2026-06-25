package kr.co.uplusit.pms.common;

/** 업무 규칙 위반 등 표준 예외. */
public class ApiException extends RuntimeException {
    private final String code;
    private final int status;
    public ApiException(String code, String message, int status) {
        super(message); this.code = code; this.status = status;
    }
    public String getCode() { return code; }
    public int getStatus() { return status; }
}
