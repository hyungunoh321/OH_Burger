package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.dao.BrandDao;
import ohburger.dao.TierDao;
import ohburger.model.Metric;
import ohburger.model.SideKind;

/**
 * 사이드 티어표 (T-03). 버거 티어표와 같은 tier.jsp 로 그린다.
 * 파라미터: metric(기준, 기본 단백질), kind(SIDE / CHICKEN / DESSERT, 없으면 전체),
 *          brand(브랜드 번호, 없으면 전체), dir=rev(D 티어부터 보기).
 * 종류를 고르면 그 종류 안에서 순위를 다시 매기고, 브랜드는 표시만 거른다.
 */
@WebServlet("/sides/tier")
public class SideTierServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final TierDao tierDao = new TierDao();
    private final BrandDao brandDao = new BrandDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Metric metric = Metric.fromSideKey(req.getParameter("metric"));
        SideKind kind = SideKind.fromKey(req.getParameter("kind"));
        boolean reversed = "rev".equals(req.getParameter("dir"));
        Integer brandId = HomeServlet.brandParam(req);

        try {
            HomeServlet.setRows(req, tierDao.listSides(metric, kind, brandId), reversed);
            req.setAttribute("brands", brandDao.findAll());
        } catch (SQLException e) {
            throw new ServletException("사이드 티어표 조회 실패", e);
        }
        req.setAttribute("side", true);
        req.setAttribute("tierPath", "/sides/tier");
        req.setAttribute("metrics", Metric.sideValues());
        req.setAttribute("metric", metric);
        req.setAttribute("kinds", SideKind.values());
        req.setAttribute("kind", kind);
        req.setAttribute("brandId", brandId);
        req.setAttribute("reversed", reversed);
        req.getRequestDispatcher("/WEB-INF/views/tier.jsp").forward(req, resp);
    }
}
