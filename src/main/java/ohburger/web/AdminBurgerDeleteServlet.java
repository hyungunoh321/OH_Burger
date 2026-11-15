package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.dao.BurgerDao;
import ohburger.model.Burger;

/** 버거 삭제 (B-04). POST 로만 받는다. 관리자 검사는 AdminFilter 가 한다. */
@WebServlet("/admin/burgers/delete")
public class AdminBurgerDeleteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BurgerDao burgerDao = new BurgerDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Burger burger = null;
            try {
                burger = burgerDao.findById(Integer.parseInt(req.getParameter("id")));
            } catch (NumberFormatException e) {
                // 아래에서 404
            }
            if (burger == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            burgerDao.delete(burger.getId());
            resp.sendRedirect(req.getContextPath() + "/admin/burgers");
        } catch (SQLException e) {
            throw new ServletException("버거 삭제 실패", e);
        }
    }
}
