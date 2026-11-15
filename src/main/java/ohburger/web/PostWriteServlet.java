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
import ohburger.model.Burger;

/** 게시글 작성 (P-03). 로그인 검사는 LoginFilter 가 한다. */
@WebServlet("/posts/write")
public class PostWriteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final PostDao postDao = new PostDao();
    private final BurgerDao burgerDao = new BurgerDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // ?burger= 로 넘어오면 그 버거를 미리 태그한다
            Burger burger = null;
            try {
                burger = burgerDao.findById(Integer.parseInt(req.getParameter("burger")));
            } catch (NumberFormatException e) {
                // 없거나 숫자가 아니면 태그 없이 시작
            }
            // 세션이 만료돼 로그인을 다시 하고 돌아온 경우: 쓰던 내용을 되살린다
            Map<String, String[]> pending = PendingForm.take(req, "/posts/write");
            if (pending != null) {
                req.setAttribute("restored", true);
                show(req, resp, PostForm.from(pending, burgerDao));
                return;
            }
            show(req, resp, PostForm.empty(burger));
        } catch (SQLException e) {
            throw new ServletException("글쓰기 화면 준비 실패", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            PostForm form = PostForm.fromRequest(req, burgerDao);
            if (form.hasErrors()) {
                show(req, resp, form);
                return;
            }
            int postId = postDao.insert(Auth.current(req).getId(), form.getCategory(), form.getTitle(),
                    form.getContent(), form.getBurgerIds());
            resp.sendRedirect(req.getContextPath() + "/posts/detail?id=" + postId);
        } catch (SQLException e) {
            throw new ServletException("게시글 등록 실패", e);
        }
    }

    private void show(HttpServletRequest req, HttpServletResponse resp, PostForm form)
            throws ServletException, IOException, SQLException {
        req.setAttribute("form", form);
        req.setAttribute("heading", "글쓰기");
        req.setAttribute("action", "/posts/write");
        req.setAttribute("cancelUrl", "/posts");
        PostFormView.prepare(req, burgerDao);
        req.getRequestDispatcher("/WEB-INF/views/post_form.jsp").forward(req, resp);
    }
}
