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
import ohburger.model.LoginMember;
import ohburger.model.Post;

/**
 * 게시글 삭제 (P-04). 작성자와 관리자만 할 수 있다. POST 로만 받는다.
 * 로그인 검사는 LoginFilter, 권한 검사는 여기서 한다.
 */
@WebServlet("/posts/delete")
public class PostDeleteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final PostDao postDao = new PostDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Post post = null;
            try {
                post = postDao.findById(Integer.parseInt(req.getParameter("id")));
            } catch (NumberFormatException e) {
                // 아래에서 404
            }
            if (post == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            LoginMember member = Auth.current(req);
            if (post.getMemberId() != member.getId() && !member.isAdmin()) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            }
            postDao.delete(post.getId());
            resp.sendRedirect(req.getContextPath() + "/posts");
        } catch (SQLException e) {
            throw new ServletException("게시글 삭제 실패", e);
        }
    }
}
