package ohburger.common;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import ohburger.model.LoginMember;

/** 로그인 상태를 다루는 공통 기능. 서블릿과 필터가 함께 쓴다. */
public final class Auth {

    /** 세션에 로그인한 회원을 담는 속성 이름. JSP 에서는 sessionScope.loginMember 로 읽는다. */
    public static final String SESSION_KEY = "loginMember";

    private Auth() {
    }

    /** 로그인한 회원을 돌려준다. 비회원이면 null. 세션을 새로 만들지 않는다. */
    public static LoginMember current(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session == null) ? null : (LoginMember) session.getAttribute(SESSION_KEY);
    }

    /**
     * 로그인 뒤에 돌아갈 주소(next)가 이 사이트 안의 경로인지 검사한다.
     * 외부 주소로 보내는 데 악용되지 않게, "/" 로 시작하는 경로만 받고 그 밖에는 null 을 돌려준다.
     */
    public static String safeNext(String next) {
        if (next == null || !next.startsWith("/") || next.startsWith("//")
                || next.indexOf('\\') >= 0 || next.indexOf('\r') >= 0 || next.indexOf('\n') >= 0) {
            return null;
        }
        return next;
    }
}
