package ohburger.web;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

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

            // 화면의 링크 주소. 조건을 하나 더 만들면 href() 한 곳만 고치면 된다
            Integer filterBurgerId = (burger == null) ? null : burger.getId();
            Map<String, String> tabHrefs = new LinkedHashMap<>();   // 분류 코드 → 그 분류 탭 주소 ("" 는 전체)
            tabHrefs.put("", href(null, q, byLikes, filterBurgerId, null));
            for (String code : Post.CATEGORY_LABELS.keySet()) {
                tabHrefs.put(code, href(code, q, byLikes, filterBurgerId, null));
            }
            Map<Integer, String> pageHrefs = new LinkedHashMap<>(); // 쪽 번호 → 주소
            for (int n = startPage; n <= endPage; n++) {
                pageHrefs.put(n, href(category, q, byLikes, filterBurgerId, n));
            }
            req.setAttribute("tabHrefs", tabHrefs);
            req.setAttribute("pageHrefs", pageHrefs);
            // 이전 · 다음 쪽은 따로 넘긴다 (EL 에서 page - 1 은 Long 이 돼서 위 맵의 Integer 키와 맞지 않는다)
            req.setAttribute("prevHref", href(category, q, byLikes, filterBurgerId, page - 1));
            req.setAttribute("nextHref", href(category, q, byLikes, filterBurgerId, page + 1));
            req.setAttribute("clearBurgerHref", href(category, q, byLikes, null, null));
        } catch (SQLException e) {
            throw new ServletException("게시글 목록 조회 실패", e);
        }
        req.setAttribute("categoryLabels", Post.CATEGORY_LABELS);
        req.setAttribute("category", category);
        req.setAttribute("q", q);
        req.setAttribute("sort", byLikes ? "likes" : "latest");
        req.getRequestDispatcher("/WEB-INF/views/posts.jsp").forward(req, resp);
    }

    /**
     * 조건을 붙인 게시글 목록 주소(컨텍스트 경로 제외)를 만든다. null · 빈 값인 조건은 붙이지 않는다.
     *
     * @param page 쪽 번호. null 이면 붙이지 않는다(첫 쪽)
     */
    private static String href(String category, String q, boolean byLikes, Integer burgerId, Integer page)
            throws UnsupportedEncodingException {
        List<String> parts = new ArrayList<>();
        if (category != null) {
            parts.add("category=" + category);
        }
        if (q != null && !q.isEmpty()) {
            parts.add("q=" + URLEncoder.encode(q, "UTF-8"));
        }
        if (byLikes) {
            parts.add("sort=likes");
        }
        if (burgerId != null) {
            parts.add("burger=" + burgerId);
        }
        if (page != null) {
            parts.add("page=" + page);
        }
        return parts.isEmpty() ? "/posts" : "/posts?" + String.join("&", parts);
    }

    private static Integer parseInt(String s) {
        try {
            return Integer.valueOf(s);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
