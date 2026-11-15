package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.dao.BrandDao;
import ohburger.dao.BurgerDao;

/**
 * 버거 관리 목록 (B-04). 관리자 검사는 AdminFilter 가 한다.
 * 파라미터: q(이름 검색), brand(브랜드 번호).
 */
@WebServlet("/admin/burgers")
public class AdminBurgerListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BurgerDao burgerDao = new BurgerDao();
    private final BrandDao brandDao = new BrandDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String q = req.getParameter("q");
        q = (q == null) ? "" : q.trim();
        Integer brandId = null;
        try {
            brandId = Integer.valueOf(req.getParameter("brand"));
        } catch (NumberFormatException e) {
            // 없거나 숫자가 아니면 전체 브랜드
        }
        List<Integer> brandIds = new ArrayList<>();
        if (brandId != null) {
            brandIds.add(brandId);
        }

        try {
            req.setAttribute("burgers", burgerDao.search(q, brandIds, null, BurgerDao.DEFAULT_SORT));
            req.setAttribute("brands", brandDao.findAll());
        } catch (SQLException e) {
            throw new ServletException("버거 관리 목록 조회 실패", e);
        }
        req.setAttribute("q", q);
        req.setAttribute("brand", brandId);
        req.getRequestDispatcher("/WEB-INF/views/admin_burgers.jsp").forward(req, resp);
    }
}
