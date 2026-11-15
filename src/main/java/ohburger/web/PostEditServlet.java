package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.Auth;
import ohburger.common.PendingForm;
import ohburger.dao.BurgerDao;
import ohburger.dao.PostDao;
import ohburger.model.Post;

/** 게시글 수정 (P-04). 작성자만 할 수 있다. 로그인 검사는 LoginFilter, 작성자 검사는 여기서 한다. */
@WebServlet("/posts/edit")
public class PostEditServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final PostDao postDao = new PostDao();
    private final BurgerDao burgerDao = new BurgerDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Post post = findOwnPost(req, resp);
            if (post == null) {
                return;
            }
            // 세션이 만료돼 로그인을 다시 하고 돌아온 경우: 이 글을 고치던 내용이면 되살린다
            Map<String, String[]> pending = PendingForm.take(req, "/posts/edit");
            if (pending != null && String.valueOf(post.getId()).equals(PendingForm.first(pending, "id"))) {
                req.setAttribute("restored", true);
                show(req, resp, post.getId(), PostForm.from(pending, burgerDao));
                return;
            }
            show(req, resp, post.getId(), PostForm.of(post));
        } catch (SQLException e) {
            throw new ServletException("글 수정 화면 준비 실패", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Post post = findOwnPost(req, resp);
            if (post == null) {
                return;
            }
            PostForm form = PostForm.fromRequest(req, burgerDao);
            if (form.hasErrors()) {
                show(req, resp, post.getId(), form);
                return;
            }
            postDao.update(post.getId(), form.getCategory(), form.getTitle(), form.getContent(), form.getBurgerIds());
            resp.sendRedirect(req.getContextPath() + "/posts/detail?id=" + post.getId());
        } catch (SQLException e) {
            throw new ServletException("게시글 수정 실패", e);
        }
    }

    /**
     * 요청의 id 로 글을 찾고 로그인한 회원이 작성자인지 확인한다.
     * 글이 없으면 404, 작성자가 아니면 403 을 보내고 null 을 돌려준다.
     */
    private Post findOwnPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        Post post = null;
        try {
            post = postDao.findById(Integer.parseInt(req.getParameter("id")));
        } catch (NumberFormatException e) {
            // 아래에서 404
        }
        if (post == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return null;
        }
        if (post.getMemberId() != Auth.current(req).getId()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return post;
    }

    private void show(HttpServletRequest req, HttpServletResponse resp, int postId, PostForm form)
            throws ServletException, IOException, SQLException {
        req.setAttribute("form", form);
        req.setAttribute("heading", "글 수정");
        req.setAttribute("action", "/posts/edit?id=" + postId);
        req.setAttribute("cancelUrl", "/posts/detail?id=" + postId);
        PostFormView.prepare(req, burgerDao);
        req.getRequestDispatcher("/WEB-INF/views/post_form.jsp").forward(req, resp);
    }
}
