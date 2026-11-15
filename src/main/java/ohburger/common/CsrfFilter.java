package ohburger.common;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 다른 사이트가 로그인한 회원 몰래 글을 지우거나 댓글을 달게 하는 요청(CSRF)을 막는다.
 *
 * 브라우저는 내용을 바꾸는 요청(POST 등)에 어느 사이트에서 보냈는지를 Origin(없으면 Referer) 헤더로 알려 준다.
 * 그 주소가 이 사이트가 아니면 403 으로 거절한다. 조회(GET)는 내용을 바꾸지 않으므로 검사하지 않는다.
 * 두 헤더가 모두 없는 요청은 브라우저의 양식 제출이 아니므로(명령줄 도구 등) 통과시킨다.
 */
public class CsrfFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        String method = req.getMethod();

        if (!"GET".equals(method) && !"HEAD".equals(method) && !"OPTIONS".equals(method)) {
            String source = req.getHeader("Origin");
            if (source == null) {
                source = req.getHeader("Referer");
            }
            if (source != null && !sameSite(source, req.getHeader("Host"))) {
                ((HttpServletResponse) response).sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
        }
        chain.doFilter(request, response);
    }

    /** 요청을 보낸 주소(source)의 호스트 · 포트가 이 요청이 도착한 호스트(Host 헤더)와 같은지. */
    private static boolean sameSite(String source, String host) {
        if (host == null) {
            return false;
        }
        try {
            String authority = new URI(source).getAuthority(); // "Origin: null" 이면 authority 가 없다
            return authority != null && authority.equalsIgnoreCase(host);
        } catch (URISyntaxException e) {
            return false;
        }
    }
}
