package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import ohburger.common.Auth;
import ohburger.common.PendingForm;
import ohburger.common.ViewCounter;
import ohburger.dao.CommentDao;
import ohburger.dao.PostDao;
import ohburger.dao.LikeDao;
import ohburger.model.Comment;
import ohburger.model.LoginMember;
import ohburger.model.Post;

/** 게시글 상세 (P-02). 수정 · 삭제 버튼을 보여 줄지도 여기서 정해 화면에 넘긴다. */
@WebServlet("/posts/detail")
public class PostDetailServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;


    private final PostDao postDao = new PostDao();
    private final LikeDao likeDao = LikeDao.POST;
    private final CommentDao commentDao = new CommentDao();

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
            if (ViewCounter.firstView(req.getSession(), "post", id)) {
                postDao.increaseViewCount(id);
                post.setViewCount(post.getViewCount() + 1);
            }

            LoginMember member = Auth.current(req);
            boolean author = member != null && member.getId() == post.getMemberId();
            req.setAttribute("post", post);
            req.setAttribute("author", author);                                   // 수정 버튼, 자기 글 추천 불가
            req.setAttribute("canDelete", author || (member != null && member.isAdmin()));
            req.setAttribute("liked", member != null && likeDao.isLiked(member.getId(), id));
            req.setAttribute("comments", commentDao.listByPost(id));
            req.setAttribute("commentMax", Comment.CONTENT_MAX);

            // 댓글 등록이 실패해 돌아온 경우: 사유와 쓰던 내용을 한 번만 보여 주고 세션에서 지운다
            HttpSession session = req.getSession();
            req.setAttribute("commentError", session.getAttribute(CommentWriteServlet.ERROR + id));
            req.setAttribute("commentDraft", session.getAttribute(CommentWriteServlet.DRAFT + id));
            session.removeAttribute(CommentWriteServlet.ERROR + id);
            session.removeAttribute(CommentWriteServlet.DRAFT + id);

            // 세션이 만료돼 로그인을 다시 하고 돌아온 경우: 이 글에 쓰던 댓글을 입력란에 되살린다
            Map<String, String[]> pending = PendingForm.take(req, "/comments/write");
            if (pending != null && String.valueOf(id).equals(PendingForm.first(pending, "postId"))) {
                req.setAttribute("commentDraft", PendingForm.first(pending, "content"));
                req.setAttribute("commentRestored", true);
            }
        } catch (SQLException e) {
            throw new ServletException("게시글 상세 조회 실패", e);
        }
        req.getRequestDispatcher("/WEB-INF/views/post.jsp").forward(req, resp);
    }
}
