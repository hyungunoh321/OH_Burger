package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.dao.BrandDao;
import ohburger.dao.BurgerDao;
import ohburger.model.Burger;

/** 버거 도감 (B-01): 이름 검색, 브랜드 · 패티 필터, 정렬. */
@WebServlet("/burgers")
public class BurgerListServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BurgerDao burgerDao = new BurgerDao();
    private final BrandDao brandDao = new BrandDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String q = req.getParameter("q");
        q = (q == null) ? "" : q.trim();

        // 모르는 패티 · 정렬 값은 조건 없음 / 기본 정렬로 본다
        String patty = req.getParameter("patty");
        if (!Burger.PATTY_LABELS.containsKey(patty)) {
            patty = null;
        }
        String sort = req.getParameter("sort");
        if (!BurgerDao.SORT_LABELS.containsKey(sort)) {
            sort = BurgerDao.DEFAULT_SORT;
        }

        // 브랜드는 복수 선택. 숫자가 아닌 값은 버린다
        List<Integer> brandIds = new ArrayList<>();
        String[] brandParams = req.getParameterValues("brand");
        if (brandParams != null) {
            for (String s : brandParams) {
                try {
                    brandIds.add(Integer.valueOf(s));
                } catch (NumberFormatException e) {
                    // 무시
                }
            }
        }

        try {
            req.setAttribute("burgers", burgerDao.search(q, brandIds, patty, sort));
            req.setAttribute("brands", brandDao.findAll());
        } catch (SQLException e) {
            throw new ServletException("버거 목록 조회 실패", e);
        }
        req.setAttribute("q", q);
        req.setAttribute("patty", patty);
        req.setAttribute("sort", sort);
        req.setAttribute("selectedBrands", new HashSet<>(brandIds));
        req.setAttribute("pattyLabels", Burger.PATTY_LABELS);
        req.setAttribute("sortLabels", BurgerDao.SORT_LABELS);
        req.getRequestDispatcher("/WEB-INF/views/burgers.jsp").forward(req, resp);
    }
}
