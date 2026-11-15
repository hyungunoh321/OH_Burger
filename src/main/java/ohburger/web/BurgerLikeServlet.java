package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.Auth;
import ohburger.common.Json;
import ohburger.dao.BurgerDao;
import ohburger.dao.LikeDao;
import ohburger.model.LoginMember;

/**
 * 버거 추천 토글 (B-03). 화면이 fetch 로 부르고 JSON 으로 답한다.
 *
 * 요청: POST /burgers/like, 파라미터 id(버거 번호), 헤더 X-Requested-With: fetch
 * 응답: 200 {"liked": true|false, "likeCount": n} / 401 비회원 / 403 헤더 없음 / 404 없는 버거
 *
 * 화면 이동이 아니라 JSON 으로 답해야 해서 LoginFilter 에 넣지 않고 여기서 로그인을 검사한다.
 */
@WebServlet("/burgers/like")
public class BurgerLikeServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BurgerDao burgerDao = new BurgerDao();
    private final LikeDao likeDao = LikeDao.BURGER;

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 다른 사이트의 양식(form)으로는 이 헤더를 붙일 수 없다. 남의 사이트가 로그인한 회원 몰래 추천을 누르게 하는 것을 막는다
        if (!"fetch".equals(req.getHeader("X-Requested-With"))) {
            Json.write(resp, HttpServletResponse.SC_FORBIDDEN, "{\"error\":\"forbidden\"}");
            return;
        }
        LoginMember member = Auth.current(req);
        if (member == null) {
            Json.write(resp, HttpServletResponse.SC_UNAUTHORIZED, "{\"error\":\"login\"}");
            return;
        }
        int burgerId;
        try {
            burgerId = Integer.parseInt(req.getParameter("id"));
        } catch (NumberFormatException e) {
            Json.write(resp, HttpServletResponse.SC_NOT_FOUND, "{\"error\":\"notfound\"}");
            return;
        }

        try {
            if (burgerDao.findById(burgerId) == null) {
                Json.write(resp, HttpServletResponse.SC_NOT_FOUND, "{\"error\":\"notfound\"}");
                return;
            }
            boolean liked = likeDao.toggle(member.getId(), burgerId);
            int likeCount = likeDao.count(burgerId);
            Json.write(resp, HttpServletResponse.SC_OK, "{\"liked\":" + liked + ",\"likeCount\":" + likeCount + "}");
        } catch (SQLException e) {
            throw new ServletException("버거 추천 처리 실패", e);
        }
    }
}
