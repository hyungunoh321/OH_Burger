package ohburger.common;

import java.io.IOException;

import javax.servlet.http.HttpServletResponse;

/** JSON 응답을 직접 만들 때 쓰는 작은 도구. 외부 라이브러리 없이 문자열만 안전하게 감싼다. */
public final class Json {

    private Json() {
    }

    /** 상태 코드와 함께 JSON 본문을 응답으로 쓴다. 브라우저가 저장해 두지 않게 한다. */
    public static void write(HttpServletResponse resp, int status, String body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write(body);
    }

    /**
     * 문자열을 JSON 문자열 표기로 바꾼다 (따옴표 포함). null 이면 null 을 돌려준다.
     * 따옴표 · 역슬래시 · 제어 문자를 이스케이프하고, HTML 안에 실려도 안전하게 &lt; &gt; &amp; 도 \\u 표기로 바꾼다.
     */
    public static String quote(String s) {
        if (s == null) {
            return "null";
        }
        StringBuilder sb = new StringBuilder(s.length() + 2).append('"');
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"': sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                default:
                    if (c < 0x20 || c == '<' || c == '>' || c == '&' || c == ' ' || c == ' ') {
                        sb.append(String.format("\\u%04x", (int) c));
                    } else {
                        sb.append(c);
                    }
            }
        }
        return sb.append('"').toString();
    }
}
