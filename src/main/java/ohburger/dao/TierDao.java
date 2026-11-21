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
import ohburger.model.SideKind;
import ohburger.model.TierEntry;

/**
 * 티어 계산 (T-01, T-02, T-03, B-02 의 티어 배지).
 * 티어는 저장하지 않고 조회할 때마다 RANK() 로 계산한다. 규칙은 기능 명세서 4.3, 쿼리 설명은 DB설계.md 4번.
 */
public class TierDao {

    /**
     * 티어 계산 쿼리. 버거(burger)와 사이드(side_menu)가 같이 쓴다.
     * 순위는 scopeWhere 로 고른 메뉴 전체를 기준으로 매기고(ranked), 바깥 SELECT 에서만 outerWhere 를 걸어
     * 브랜드로 걸러도 티어가 바뀌지 않게 한다.
     *
     * @param table      메뉴 테이블 (코드에 고정된 값만 넘긴다)
     * @param idColumn   그 테이블의 기본키 열
     * @param scopeWhere 순위를 매길 대상 조건 (사이드의 종류). 없으면 ""
     * @param outerWhere 표시할 메뉴 조건 (브랜드 · 메뉴 번호). 없으면 ""
     */
    private static String sql(String table, String idColumn, Metric metric, String scopeWhere, String outerWhere) {
        return "WITH score AS ("
             + "  SELECT b." + idColumn + " AS item_id, b.name, b.image_url, b.brand_id, br.name AS brand_name, "
             +      metric.getSqlExpr() + " AS val"
             + "  FROM " + table + " b JOIN brand br ON br.brand_id = b.brand_id " + scopeWhere
             + "), ranked AS ("
             + "  SELECT s.*, (RANK() OVER (ORDER BY val " + (metric.isHigherIsBetter() ? "DESC" : "ASC") + ") - 1)"
             + "         / COUNT(*) OVER () AS p"
             + "  FROM score s"
             + "  WHERE val IS NOT NULL" + (metric.isExcludeZero() ? " AND val > 0" : "")
             + ") "
             + "SELECT item_id, name, image_url, brand_name, val,"
             + "       CASE WHEN p < 0.10 THEN 'S' WHEN p < 0.30 THEN 'A' WHEN p < 0.70 THEN 'B'"
             + "            WHEN p < 0.90 THEN 'C' ELSE 'D' END AS tier "
             + "FROM ranked " + outerWhere + " ORDER BY p, name";
    }

    /**
     * 버거 티어표 한 기준을 상위부터 돌려준다.
     *
     * @param brandId 표시할 브랜드. null 이면 전체
     */
    public List<TierEntry> list(Metric metric, Integer brandId) throws SQLException {
        return query(sql("burger", "burger_id", metric, "", brandId == null ? "" : "WHERE brand_id = ?"),
                brandId == null ? new Object[0] : new Object[] { brandId });
    }

    /**
     * 사이드 티어표 한 기준을 상위부터 돌려준다 (T-03).
     * 종류를 고르면 그 종류 안에서만 순위를 매기고, 브랜드는 버거와 같이 표시만 거른다.
     *
     * @param kind    순위를 매길 종류. null 이면 사이드 메뉴 전체
     * @param brandId 표시할 브랜드. null 이면 전체
     */
    public List<TierEntry> listSides(Metric metric, SideKind kind, Integer brandId) throws SQLException {
        List<Object> params = new ArrayList<>();
        if (kind != null) {
            params.add(kind.name());
        }
        if (brandId != null) {
            params.add(brandId);
        }
        return query(sql("side_menu", "side_id", metric,
                kind == null ? "" : "WHERE b.kind = ?",
                brandId == null ? "" : "WHERE brand_id = ?"), params.toArray());
    }

    private List<TierEntry> query(String sql, Object[] params) throws SQLException {
        List<TierEntry> list = new ArrayList<>();
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TierEntry(rs.getInt("item_id"), rs.getString("name"), rs.getString("image_url"),
                            rs.getString("brand_name"), rs.getBigDecimal("val"), rs.getString("tier")));
                }
            }
        }
        return list;
    }

    /**
     * 버거 한 종의 티어 5종을 돌려준다. 키는 Metric 의 key, 값은 S ~ D.
     * 티어가 없는 기준(영양 정보 없음, 인기 점수 0)은 맵에 들어가지 않는다.
     */
    public Map<String, String> tiersOf(int burgerId) throws SQLException {
        Map<String, String> tiers = new LinkedHashMap<>();
        try (Connection con = DB.getConnection()) {
            for (Metric metric : Metric.values()) {
                try (PreparedStatement ps = con.prepareStatement(sql("burger", "burger_id", metric, "", "WHERE item_id = ?"))) {
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
