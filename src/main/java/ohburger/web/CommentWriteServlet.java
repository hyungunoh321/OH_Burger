package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import ohburger.common.Auth;
import ohburger.dao.CommentDao;
import ohburger.dao.PostDao;
import ohburger.model.Comment;

/**
 * 댓글 작성 (C-01). 끝나면 해당 게시글 상세의 댓글 자리로 돌아간다.
 * 로그인 검사는 LoginFilter 가 한다.
 *
 * 입력이 잘못되면 사유와 쓰던 내용을 세션에 잠깐 담아 두고 돌아가며,
 * 게시글 상세(PostDetailServlet)가 한 번 보여 준 뒤 지운다.
 */
@WebServlet("/comments/write")
public class CommentWriteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /** 세션에 잠깐 담는 속성 이름. 뒤에 게시글 번호를 붙여 다른 글과 섞이지 않게 한다. */
    static final String ERROR = "commentError:";
    static final String DRAFT = "commentDraft:";

    private final PostDao postDao = new PostDao();
    private final CommentDao commentDao = new CommentDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int postId;
        try {
            postId = Integer.parseInt(req.getParameter("postId"));
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        String content = req.getParameter("content");
        content = (content == null) ? "" : content.trim();

        try {
            if (postDao.findById(postId) == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            String error = null;
            if (content.isEmpty()) {
                error = "댓글 내용을 입력해 주세요.";
            } else if (content.codePointCount(0, content.length()) > Comment.CONTENT_MAX) {
                error = "댓글은 " + Comment.CONTENT_MAX + "자 이내로 입력해 주세요.";
            }

            if (error == null) {
                commentDao.insert(postId, Auth.current(req).getId(), content);
            } else {
                HttpSession session = req.getSession();
                session.setAttribute(ERROR + postId, error);
                session.setAttribute(DRAFT + postId, content);
            }
        } catch (SQLException e) {
            throw new ServletException("댓글 등록 실패", e);
        }
        resp.sendRedirect(req.getContextPath() + "/posts/detail?id=" + postId + "#comments");
    }
}
