package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import ohburger.common.Auth;
import ohburger.dao.PostDao;
import ohburger.dao.PostLikeDao;
import ohburger.model.LoginMember;
import ohburger.model.Post;

/** 게시글 상세 (P-02). 수정 · 삭제 버튼을 보여 줄지도 여기서 정해 화면에 넘긴다. */
@WebServlet("/posts/detail")
public class PostDetailServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /** 세션에 이미 조회한 글 번호를 담아 두는 속성 이름 (조회수 중복 증가 방지). */
    private static final String VIEWED = "viewedPosts";

    private final PostDao postDao = new PostDao();
    private final PostLikeDao likeDao = new PostLikeDao();

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
            Post post = postDao.findById(id);
            if (post == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            // 같은 세션에서 같은 글은 조회수를 한 번만 올린다
            if (markViewed(req.getSession(), id)) {
                postDao.increaseViewCount(id);
                post.setViewCount(post.getViewCount() + 1);
            }

            LoginMember member = Auth.current(req);
            boolean author = member != null && member.getId() == post.getMemberId();
            req.setAttribute("post", post);
            req.setAttribute("author", author);                                   // 수정 버튼, 자기 글 추천 불가
            req.setAttribute("canDelete", author || (member != null && member.isAdmin()));
            req.setAttribute("liked", member != null && likeDao.isLiked(member.getId(), id));
        } catch (SQLException e) {
            throw new ServletException("게시글 상세 조회 실패", e);
        }
        req.getRequestDispatcher("/WEB-INF/views/post.jsp").forward(req, resp);
    }

    /** 이 세션에서 처음 보는 글이면 기록하고 true 를 돌려준다. */
    private static boolean markViewed(HttpSession session, int postId) {
        synchronized (session) {
            @SuppressWarnings("unchecked")
            Set<Integer> viewed = (Set<Integer>) session.getAttribute(VIEWED);
            if (viewed == null) {
                viewed = new HashSet<>();
                session.setAttribute(VIEWED, viewed);
            }
            return viewed.add(postId);
        }
    }
}
