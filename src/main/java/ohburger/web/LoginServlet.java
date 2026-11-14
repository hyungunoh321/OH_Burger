package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.Auth;
import ohburger.common.PasswordUtil;
import ohburger.dao.MemberDao;

/**
 * 로그인 (M-02).
 * next 파라미터에 로그인 전에 보던 주소(컨텍스트 경로를 뺀 경로)가 오면 로그인 뒤 그곳으로 돌아간다.
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final MemberDao memberDao = new MemberDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (Auth.current(req) != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.setAttribute("next", Auth.safeNext(req.getParameter("next")));
        req.setAttribute("joined", req.getParameter("joined") != null);
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String loginId = req.getParameter("loginId");
        loginId = (loginId == null) ? "" : loginId.trim();
        String password = req.getParameter("password");
        password = (password == null) ? "" : password;
        String next = Auth.safeNext(req.getParameter("next"));

        MemberDao.Account account;
        try {
            account = memberDao.findByLoginId(loginId);
        } catch (SQLException e) {
            throw new ServletException("로그인 처리 실패", e);
        }

        if (account == null || !PasswordUtil.matches(account.getSalt(), password, account.getPasswordHash())) {
            // 아이디와 비밀번호 중 어느 쪽이 틀렸는지는 알리지 않는다
            req.setAttribute("error", "아이디 또는 비밀번호가 올바르지 않습니다.");
            req.setAttribute("loginId", loginId);
            req.setAttribute("next", next);
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            return;
        }

        // 로그인 전의 세션 번호를 그대로 쓰지 않게 바꾼다 (세션 고정 공격 방지). 세션에 담긴 값은 유지된다
        req.getSession();
        req.changeSessionId();
        req.getSession().setAttribute(Auth.SESSION_KEY, account.getMember());
        resp.sendRedirect(req.getContextPath() + (next != null ? next : "/home"));
    }
}
