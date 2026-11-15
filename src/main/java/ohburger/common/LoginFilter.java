package ohburger.common;

import java.io.IOException;
import java.net.URLEncoder;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 로그인이 필요한 주소에 비회원이 오면 로그인 화면으로 보낸다 (M-02).
 * 어떤 주소에 걸리는지는 web.xml 의 filter-mapping 에 있다. 로그인이 필요한 기능을 새로 만들면 거기에 추가한다.
 * 관리자 주소(/admin/*)는 여기서 로그인만 검사하고, 관리자 권한은 뒤에 도는 AdminFilter 가 검사한다.
 */
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

        String next = null;
        if ("GET".equals(req.getMethod())) {
            // 로그인 뒤에 원래 가려던 화면으로 돌아오게 주소를 넘긴다
            next = req.getServletPath();
            if (req.getQueryString() != null) {
                next += "?" + req.getQueryString();
            }
        } else {
            // 세션이 만료된 뒤 양식을 보낸 경우: 쓴 내용을 맡아 두고, 로그인 뒤 그 내용을 다시 보여 줄 화면으로 돌려보낸다
            next = returnPage(req);
            if (next != null) {
                PendingForm.save(req);
            }
        }

        String login = req.getContextPath() + "/login";
        if (next != null) {
            login += "?next=" + URLEncoder.encode(next, "UTF-8");
        }
        resp.sendRedirect(login);
    }

    /**
     * 양식을 받는 주소마다, 로그인 뒤 돌아가서 맡아 둔 내용을 다시 보여 줄 화면.
     * 삭제처럼 다시 보여 줄 내용이 없는 요청은 null (로그인 뒤 메인으로 간다).
     */
    private static String returnPage(HttpServletRequest req) {
        switch (req.getServletPath()) {
            case "/posts/write":
                return "/posts/write";
            case "/posts/edit":
                return isNumber(req.getParameter("id")) ? "/posts/edit?id=" + req.getParameter("id") : null;
            case "/comments/write":
                return isNumber(req.getParameter("postId"))
                        ? "/posts/detail?id=" + req.getParameter("postId") + "#comments" : null;
            case "/admin/burgers/new":
                return "/admin/burgers/new";
            case "/admin/burgers/edit":
                return isNumber(req.getParameter("id")) ? "/admin/burgers/edit?id=" + req.getParameter("id") : null;
            default:
                return null;
        }
    }

    private static boolean isNumber(String s) {
        return s != null && s.matches("\\d{1,9}");
    }
}
