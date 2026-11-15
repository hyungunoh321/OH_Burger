package ohburger.common;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.model.LoginMember;

/**
 * 관리자 주소(/admin/*)에 관리자가 아닌 회원이 오면 403 으로 거절한다 (B-04).
 * web.xml 에서 LoginFilter 뒤에 돌기 때문에 여기까지 온 요청은 로그인한 상태다.
 * 권한은 SessionRefreshFilter 가 요청마다 DB 에서 다시 읽으므로, 관리자에서 내려온 회원은 바로 막힌다.
 */
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        LoginMember member = Auth.current((HttpServletRequest) request);
        if (member == null || !member.isAdmin()) {
            ((HttpServletResponse) response).sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        chain.doFilter(request, response);
    }
}
