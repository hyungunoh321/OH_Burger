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

import ohburger.common.Json;
import ohburger.dao.BurgerDao;
import ohburger.model.Burger;

/**
 * 룰렛 후보 목록 (R-01). 조건에 맞는 버거 전부를 JSON 으로 답한다.
 * 12개를 넘을 때 무작위로 추리는 일과 당첨 뽑기는 화면(js/roulette.js)이 한다.
 *
 * 요청: GET /roulette/candidates, 파라미터는 모두 선택 사항
 *       brand(브랜드 번호, 여러 개), patty(패티 코드), maxPrice(가격 상한), maxKcal(열량 상한)
 * 응답: {"burgers": [{"id", "brand", "name", "price", "kcal", "protein"}, ...]}  값이 없으면 null
 */
@WebServlet("/roulette/candidates")
public class RouletteCandidatesServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BurgerDao burgerDao = new BurgerDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Integer> brandIds = new ArrayList<>();
        String[] brandParams = req.getParameterValues("brand");
        if (brandParams != null) {
            for (String s : brandParams) {
                Integer id = positiveInt(s);
                if (id != null) {
                    brandIds.add(id);
                }
            }
        }
        // 모르는 패티 값, 숫자가 아니거나 0 이하인 상한은 조건 없음으로 본다
        String patty = req.getParameter("patty");
        if (!Burger.PATTY_LABELS.containsKey(patty)) {
            patty = null;
        }
        Integer maxPrice = positiveInt(req.getParameter("maxPrice"));
        Integer maxKcal = positiveInt(req.getParameter("maxKcal"));

        List<Burger> burgers;
        try {
            burgers = burgerDao.findForRoulette(brandIds, patty, maxPrice, maxKcal);
        } catch (SQLException e) {
            throw new ServletException("룰렛 후보 조회 실패", e);
        }

        StringBuilder json = new StringBuilder("{\"burgers\":[");
        for (int i = 0; i < burgers.size(); i++) {
            Burger b = burgers.get(i);
            if (i > 0) {
                json.append(',');
            }
            json.append("{\"id\":").append(b.getId())
                .append(",\"brand\":").append(Json.quote(b.getBrandName()))
                .append(",\"name\":").append(Json.quote(b.getName()))
                .append(",\"price\":").append(b.getPrice())          // 숫자 또는 null
                .append(",\"kcal\":").append(b.getCaloriesKcal())
                .append(",\"protein\":").append(b.getProteinG() == null ? null : b.getProteinG().toPlainString())
                .append('}');
        }
        json.append("]}");

        Json.write(resp, HttpServletResponse.SC_OK, json.toString());
    }

    private static Integer positiveInt(String s) {
        try {
            int n = Integer.parseInt(s);
            return n > 0 ? n : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
