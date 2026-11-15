package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.Auth;
import ohburger.dao.BurgerDao;
import ohburger.dao.PostDao;
import ohburger.model.LoginMember;

/**
 * 마이페이지 (M-03). 로그인한 회원이 쓴 글과 추천한 버거를 보여 준다.
 * 로그인 검사는 web.xml 의 login 필터가 한다. 남의 것은 볼 수 없게 회원 번호는 세션에서만 읽는다.
 */
@WebServlet("/mypage")
public class MyPageServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final PostDao postDao = new PostDao();
    private final BurgerDao burgerDao = new BurgerDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        LoginMember me = Auth.current(req);
        try {
            req.setAttribute("posts", postDao.findByMember(me.getId()));
            req.setAttribute("burgers", burgerDao.findLikedBy(me.getId()));
        } catch (SQLException e) {
            throw new ServletException("마이페이지 조회 실패", e);
        }
        req.getRequestDispatcher("/WEB-INF/views/mypage.jsp").forward(req, resp);
    }
}
