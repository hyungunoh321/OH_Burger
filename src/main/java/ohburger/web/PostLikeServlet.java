package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.Auth;
import ohburger.dao.PostDao;
import ohburger.dao.PostLikeDao;
import ohburger.model.LoginMember;
import ohburger.model.Post;

/**
 * 게시글 추천 토글 (P-05). 화면이 fetch 로 부르고 JSON 으로 답한다. 구조는 BurgerLikeServlet 과 같다.
 *
 * 요청: POST /posts/like, 파라미터 id(글 번호), 헤더 X-Requested-With: fetch
 * 응답: 200 {"liked": true|false, "likeCount": n} / 401 비회원 / 403 헤더 없음 또는 자기 글 / 404 없는 글
 */
@WebServlet("/posts/like")
public class PostLikeServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final PostDao postDao = new PostDao();
    private final PostLikeDao likeDao = new PostLikeDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"fetch".equals(req.getHeader("X-Requested-With"))) {
            json(resp, HttpServletResponse.SC_FORBIDDEN, "{\"error\":\"forbidden\"}");
            return;
        }
        LoginMember member = Auth.current(req);
        if (member == null) {
            json(resp, HttpServletResponse.SC_UNAUTHORIZED, "{\"error\":\"login\"}");
            return;
        }

        try {
            Post post = null;
            try {
                post = postDao.findById(Integer.parseInt(req.getParameter("id")));
            } catch (NumberFormatException e) {
                // 아래에서 404
            }
            if (post == null) {
                json(resp, HttpServletResponse.SC_NOT_FOUND, "{\"error\":\"notfound\"}");
                return;
            }
            if (post.getMemberId() == member.getId()) {
                json(resp, HttpServletResponse.SC_FORBIDDEN, "{\"error\":\"own\"}"); // 자기 글은 추천할 수 없다
                return;
            }
            boolean liked = likeDao.toggle(member.getId(), post.getId());
            int likeCount = likeDao.count(post.getId());
            json(resp, HttpServletResponse.SC_OK, "{\"liked\":" + liked + ",\"likeCount\":" + likeCount + "}");
        } catch (SQLException e) {
            throw new ServletException("게시글 추천 처리 실패", e);
        }
    }

    private static void json(HttpServletResponse resp, int status, String body) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json; charset=UTF-8");
        resp.setHeader("Cache-Control", "no-store");
        resp.getWriter().write(body);
    }
}
