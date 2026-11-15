package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import ohburger.common.DB;
import ohburger.model.Metric;
import ohburger.model.TierEntry;

/**
 * 티어 계산 (T-01, T-02, B-02 의 티어 배지).
 * 티어는 저장하지 않고 조회할 때마다 RANK() 로 계산한다. 규칙은 기능 명세서 4.3, 쿼리 설명은 DB설계.md 4번.
 */
public class TierDao {

    /**
     * 순위는 항상 전체 버거 기준으로 매기고(ranked), 바깥 SELECT 에서만 조건을 걸어
     * 브랜드로 걸러도 티어가 바뀌지 않게 한다.
     */
    private static String sql(Metric metric, String outerWhere) {
        return "WITH score AS ("
             + "  SELECT b.burger_id, b.name, b.image_url, b.brand_id, br.name AS brand_name, " + metric.getSqlExpr() + " AS val"
             + "  FROM burger b JOIN brand br ON br.brand_id = b.brand_id"
             + "), ranked AS ("
             + "  SELECT s.*, (RANK() OVER (ORDER BY val " + (metric.isHigherIsBetter() ? "DESC" : "ASC") + ") - 1)"
             + "         / COUNT(*) OVER () AS p"
             + "  FROM score s"
             + "  WHERE val IS NOT NULL" + (metric.isExcludeZero() ? " AND val > 0" : "")
             + ") "
             + "SELECT burger_id, name, image_url, brand_name, val,"
             + "       CASE WHEN p < 0.10 THEN 'S' WHEN p < 0.30 THEN 'A' WHEN p < 0.70 THEN 'B'"
             + "            WHEN p < 0.90 THEN 'C' ELSE 'D' END AS tier "
             + "FROM ranked " + outerWhere + " ORDER BY p, name";
    }

    /**
     * 한 기준의 티어표를 상위부터 돌려준다.
     *
     * @param brandId 표시할 브랜드. null 이면 전체
     */
    public List<TierEntry> list(Metric metric, Integer brandId) throws SQLException {
        List<TierEntry> list = new ArrayList<>();
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql(metric, brandId == null ? "" : "WHERE brand_id = ?"))) {
            if (brandId != null) {
                ps.setInt(1, brandId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TierEntry(rs.getInt("burger_id"), rs.getString("name"), rs.getString("image_url"),
                            rs.getString("brand_name"), rs.getBigDecimal("val"), rs.getString("tier")));
                }
            }
        }
        return list;
    }

    /**
     * 버거 한 종의 티어 4종을 돌려준다. 키는 Metric 의 key, 값은 S ~ D.
     * 티어가 없는 기준(영양 정보 없음, 인기 점수 0)은 맵에 들어가지 않는다.
     */
    public Map<String, String> tiersOf(int burgerId) throws SQLException {
        Map<String, String> tiers = new LinkedHashMap<>();
        try (Connection con = DB.getConnection()) {
            for (Metric metric : Metric.values()) {
                try (PreparedStatement ps = con.prepareStatement(sql(metric, "WHERE burger_id = ?"))) {
                    ps.setInt(1, burgerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            tiers.put(metric.getKey(), rs.getString("tier"));
                        }
                    }
                }
            }
        }
        return tiers;
    }
}
