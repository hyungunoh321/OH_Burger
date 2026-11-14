package ohburger.web;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.DB;

/**
 * 메인 화면. 지금은 환경 확인용으로 브랜드별 버거 수만 보여 준다.
 * 티어표 구현 단계에서 교체한다.
 */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String SQL =
            "SELECT br.name, COUNT(b.burger_id) AS cnt "
          + "FROM brand br LEFT JOIN burger b ON b.brand_id = br.brand_id "
          + "GROUP BY br.brand_id, br.name ORDER BY br.brand_id";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        int total = 0;
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(SQL);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                counts.put(rs.getString("name"), rs.getInt("cnt"));
                total += rs.getInt("cnt");
            }
        } catch (SQLException e) {
            throw new ServletException("브랜드별 버거 수 조회 실패", e);
        }
        req.setAttribute("counts", counts);
        req.setAttribute("total", total);
        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
