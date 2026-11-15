package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.Auth;
import ohburger.common.ViewCounter;
import ohburger.dao.BurgerDao;
import ohburger.dao.LikeDao;
import ohburger.dao.PostDao;
import ohburger.dao.TierDao;
import ohburger.model.Burger;
import ohburger.model.LoginMember;
import ohburger.model.Metric;

/** 버거 상세 (B-02): 기본 · 영양 정보, 티어 배지 4종, 추천 상태, 태그된 게시글 상위 5개. */
@WebServlet("/burgers/detail")
public class BurgerDetailServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int RELATED_POST_LIMIT = 5;

    private final BurgerDao burgerDao = new BurgerDao();
    private final TierDao tierDao = new TierDao();
    private final PostDao postDao = new PostDao();
    private final LikeDao likeDao = LikeDao.BURGER;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int id;
        try {
            id = Integer.parseInt(req.getParameter("id"));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        try {
            Burger burger = burgerDao.findById(id);
            if (burger == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            // 같은 세션에서 같은 버거는 조회수를 한 번만 올린다
            if (ViewCounter.firstView(req.getSession(), "burger", id)) {
                burgerDao.increaseViewCount(id);
                burger.setViewCount(burger.getViewCount() + 1);
            }
            // 로그인한 회원이면 이 버거를 추천했는지 알려 줘서 버튼을 눌린 모양으로 그린다
            LoginMember member = Auth.current(req);
            req.setAttribute("liked", member != null && likeDao.isLiked(member.getId(), id));
            req.setAttribute("burger", burger);
            req.setAttribute("metrics", Metric.values());
            req.setAttribute("tiers", tierDao.tiersOf(id));
            req.setAttribute("posts", postDao.findTopByBurger(id, RELATED_POST_LIMIT));
        } catch (SQLException e) {
            throw new ServletException("버거 상세 조회 실패", e);
        }
        req.getRequestDispatcher("/WEB-INF/views/burger.jsp").forward(req, resp);
    }
}
