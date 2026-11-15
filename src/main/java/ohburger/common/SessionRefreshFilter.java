package ohburger.common;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import ohburger.dao.MemberDao;
import ohburger.model.LoginMember;

/**
 * 로그인한 회원의 정보를 요청마다 DB 에서 다시 읽어 세션을 최신으로 맞춘다.
 *
 * 세션에는 로그인할 때의 닉네임 · 권한이 복사돼 있어서, 그대로 두면 관리자 권한을 회수해도
 * 그 회원이 로그아웃하기 전까지는 계속 관리자로 동작한다. 회원이 지워졌으면 로그아웃시킨다.
 * LoginFilter 와 서블릿보다 먼저 돌아야 하므로 web.xml 에서 순서를 정한다.
 */
public class SessionRefreshFilter implements Filter {

    private final MemberDao memberDao = new MemberDao();

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        // css · js 같은 정적 파일 요청에서는 DB 를 읽지 않는다
        String path = req.getServletPath();
        boolean staticFile = path.startsWith("/css/") || path.startsWith("/js/");
        LoginMember member = staticFile ? null : Auth.current(req);

        if (member != null) {
            HttpSession session = req.getSession(false);
            try {
                LoginMember fresh = memberDao.findById(member.getId());
                if (fresh == null) {
                    session.invalidate(); // 지워진 회원
                } else {
                    session.setAttribute(Auth.SESSION_KEY, fresh);
                }
            } catch (SQLException e) {
                throw new ServletException("회원 정보 확인 실패", e);
            }
        }
        chain.doFilter(request, response);
    }
}
