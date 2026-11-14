package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.dao.BurgerDao;
import ohburger.dao.PostDao;
import ohburger.model.Burger;
import ohburger.model.Post;

/**
 * 게시글 목록 (P-01).
 * 파라미터: category(분류), q(제목 + 내용 검색), sort=likes(추천순, 기본 최신순),
 * burger(이 버거가 태그된 글만), page(쪽 번호).
 */
@WebServlet("/posts")
public class PostListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final int PAGE_SIZE = 10;
    /** 쪽 번호를 한 번에 몇 개까지 보여 줄지. */
    private static final int PAGER_WIDTH = 5;

    private final PostDao postDao = new PostDao();
    private final BurgerDao burgerDao = new BurgerDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String category = req.getParameter("category");
        if (!Post.CATEGORY_LABELS.containsKey(category)) {
            category = null;
        }
        String q = req.getParameter("q");
        q = (q == null) ? "" : q.trim();
        boolean byLikes = "likes".equals(req.getParameter("sort"));
        Integer burgerId = parseInt(req.getParameter("burger"));
        Integer pageParam = parseInt(req.getParameter("page"));

        try {
            // 없는 버거 번호로 걸러 달라고 하면 조건을 무시한다
            Burger burger = (burgerId == null) ? null : burgerDao.findById(burgerId);
            PostDao.Filter filter = new PostDao.Filter(category, q, burger == null ? null : burger.getId());

            int total = postDao.count(filter);
            int totalPages = Math.max(1, (total + PAGE_SIZE - 1) / PAGE_SIZE);
            int page = Math.min(Math.max(1, pageParam == null ? 1 : pageParam), totalPages);

            // 현재 쪽이 가운데 오도록 쪽 번호 범위를 잡는다
            int startPage = Math.max(1, Math.min(page - PAGER_WIDTH / 2, totalPages - PAGER_WIDTH + 1));
            int endPage = Math.min(totalPages, startPage + PAGER_WIDTH - 1);

            req.setAttribute("posts", postDao.list(filter, byLikes, page, PAGE_SIZE));
            req.setAttribute("total", total);
            req.setAttribute("page", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("startPage", startPage);
            req.setAttribute("endPage", endPage);
            req.setAttribute("burger", burger);
        } catch (SQLException e) {
            throw new ServletException("게시글 목록 조회 실패", e);
        }
        req.setAttribute("categoryLabels", Post.CATEGORY_LABELS);
        req.setAttribute("category", category);
        req.setAttribute("q", q);
        req.setAttribute("sort", byLikes ? "likes" : "latest");
        req.getRequestDispatcher("/WEB-INF/views/posts.jsp").forward(req, resp);
    }

    private static Integer parseInt(String s) {
        try {
            return Integer.valueOf(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
