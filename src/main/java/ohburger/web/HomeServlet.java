package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.dao.BrandDao;
import ohburger.dao.TierDao;
import ohburger.model.Metric;
import ohburger.model.TierEntry;

/**
 * 메인 티어표 = 버거 티어표 (T-01, T-02). 사이드 티어표(T-03)는 SideTierServlet 이 같은 tier.jsp 로 그린다.
 * 파라미터: metric(기준, 기본 인기), brand(브랜드 번호, 없으면 전체), dir=rev(D 티어부터 보기).
 */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final TierDao tierDao = new TierDao();
    private final BrandDao brandDao = new BrandDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Metric metric = Metric.fromKey(req.getParameter("metric"));
        boolean reversed = "rev".equals(req.getParameter("dir"));
        Integer brandId = brandParam(req);

        try {
            setRows(req, tierDao.list(metric, brandId), reversed);
            req.setAttribute("brands", brandDao.findAll());
        } catch (SQLException e) {
            throw new ServletException("티어표 조회 실패", e);
        }
        req.setAttribute("tierPath", "/home");
        req.setAttribute("metrics", Metric.values());
        req.setAttribute("metric", metric);
        req.setAttribute("brandId", brandId);
        req.setAttribute("reversed", reversed);
        req.getRequestDispatcher("/WEB-INF/views/tier.jsp").forward(req, resp);
    }

    /** brand 파라미터. 없거나 숫자가 아니면 null(전체 브랜드). */
    static Integer brandParam(HttpServletRequest req) {
        try {
            return Integer.valueOf(req.getParameter("brand"));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * 티어 순서대로 나온 카드를 S ~ D 다섯 줄로 나눠 rows, 카드 수를 shown 에 담는다.
     * 메뉴가 없는 티어도 빈 줄로 보여 주기 위해 다섯 줄을 먼저 만들어 둔다. reversed 면 D 줄부터.
     */
    static void setRows(HttpServletRequest req, List<TierEntry> entries, boolean reversed) {
        List<String> order = new ArrayList<>(Arrays.asList("S", "A", "B", "C", "D"));
        if (reversed) {
            Collections.reverse(order);
            Collections.reverse(entries);
        }
        Map<String, List<TierEntry>> rows = new LinkedHashMap<>();
        for (String tier : order) {
            rows.put(tier, new ArrayList<>());
        }
        for (TierEntry e : entries) {
            rows.get(e.getTier()).add(e);
        }
        req.setAttribute("rows", rows);
        req.setAttribute("shown", entries.size());
    }
}
