package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.Auth;
import ohburger.dao.CommentDao;
import ohburger.model.Comment;
import ohburger.model.LoginMember;

/**
 * 댓글 삭제 (C-02). 작성자와 관리자만 할 수 있다. POST 로만 받는다.
 * 로그인 검사는 LoginFilter, 권한 검사는 여기서 한다.
 */
@WebServlet("/comments/delete")
public class CommentDeleteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final CommentDao commentDao = new CommentDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Comment comment = null;
            try {
                comment = commentDao.findById(Integer.parseInt(req.getParameter("id")));
            } catch (NumberFormatException e) {
                // 아래에서 404
            }
            if (comment == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            LoginMember member = Auth.current(req);
            if (comment.getMemberId() != member.getId() && !member.isAdmin()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            commentDao.delete(comment.getId());
            resp.sendRedirect(req.getContextPath() + "/posts/detail?id=" + comment.getPostId() + "#comments");
        } catch (SQLException e) {
            throw new ServletException("댓글 삭제 실패", e);
        }
    }
}
