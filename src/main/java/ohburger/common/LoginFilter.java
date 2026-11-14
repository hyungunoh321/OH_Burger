package ohburger.common;

import java.io.IOException;
import java.net.URLEncoder;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 로그인이 필요한 주소에 비회원이 오면 로그인 화면으로 보낸다 (M-02).
 * 로그인이 필요한 기능을 새로 만들면 그 주소를 urlPatterns 에 추가한다.
 * 관리자 주소(/admin/*)는 여기서 로그인만 검사하고, 관리자 권한은 해당 서블릿에서 따로 검사한다.
 */
@WebFilter(urlPatterns = { "/posts/write", "/posts/edit", "/posts/delete", "/mypage", "/admin/*" })
public class LoginFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        if (Auth.current(req) != null) {
            chain.doFilter(request, response);
            return;
        }

        String login = req.getContextPath() + "/login";
        if ("GET".equals(req.getMethod())) {
            // 로그인 뒤에 원래 가려던 화면으로 돌아오게 주소를 넘긴다
            String here = req.getRequestURI().substring(req.getContextPath().length());
            if (req.getQueryString() != null) {
                here += "?" + req.getQueryString();
            }
            login += "?next=" + URLEncoder.encode(here, "UTF-8");
        }
        resp.sendRedirect(login);
    }
}
