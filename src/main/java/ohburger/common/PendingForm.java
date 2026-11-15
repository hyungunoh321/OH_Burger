package ohburger.common;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

/**
 * 로그인이 풀린 상태에서 보낸 양식(POST)의 입력값을 잠깐 맡아 두는 곳.
 *
 * 글을 오래 쓰다가 세션이 만료된 뒤 등록을 누르면 LoginFilter 가 로그인 화면으로 보내는데,
 * 그때 쓴 내용이 사라지지 않게 세션에 담아 두었다가 로그인 뒤 같은 화면에서 한 번 꺼내 쓴다.
 */
public final class PendingForm implements Serializable {

    private static final long serialVersionUID = 1L;

    private static final String SESSION_KEY = "pendingForm";

    /** 맡아 두는 입력값 전체 길이의 상한(글자 수). 비회원 요청으로 세션이 커지는 것을 막는다. */
    private static final int MAX_CHARS = 20_000;

    private final String path;
    private final HashMap<String, String[]> params;

    private PendingForm(String path, Map<String, String[]> params) {
        this.path = path;
        this.params = new HashMap<>(params);
    }

    /** 지금 요청의 입력값을 세션에 맡긴다. 너무 크면 맡지 않는다. */
    public static void save(HttpServletRequest req) {
        Map<String, String[]> params = req.getParameterMap();
        int total = 0;
        for (String[] values : params.values()) {
            for (String v : values) {
                total += v.length();
            }
        }
        if (total > MAX_CHARS) {
            return;
        }
        req.getSession().setAttribute(SESSION_KEY, new PendingForm(req.getServletPath(), params));
    }

    /**
     * 맡겨 둔 입력값을 꺼내고 세션에서 지운다.
     *
     * @param path 양식을 받는 주소 (예: /posts/write). 다른 주소의 것이면 건드리지 않는다
     * @return 입력값. 없으면 null
     */
    public static Map<String, String[]> take(HttpServletRequest req, String path) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }
        PendingForm pending = (PendingForm) session.getAttribute(SESSION_KEY);
        if (pending == null || !pending.path.equals(path)) {
            return null;
        }
        session.removeAttribute(SESSION_KEY);
        return pending.params;
    }

    /** 맡겨 둔 입력값에서 값 하나를 읽는다. 없으면 null. */
    public static String first(Map<String, String[]> params, String name) {
        String[] values = params.get(name);
        return (values == null || values.length == 0) ? null : values[0];
    }
}
