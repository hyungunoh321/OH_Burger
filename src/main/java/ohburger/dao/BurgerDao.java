package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import ohburger.common.DB;
import ohburger.model.Burger;

/** burger 테이블 조회 (B-01, B-02). */
public class BurgerDao {

    /** 정렬 코드 → 화면 표시 이름. 목록 화면의 선택 상자에 그대로 쓴다. */
    public static final Map<String, String> SORT_LABELS;

    /** 정렬 코드 → ORDER BY 절. 값이 없는(NULL) 버거는 항상 맨 뒤로 보낸다. */
    private static final Map<String, String> SORT_SQL = new LinkedHashMap<>();

    public static final String DEFAULT_SORT = "name_asc";

    static {
        Map<String, String> labels = new LinkedHashMap<>();
        addSort(labels, "name_asc", "이름순", "b.name ASC");
        addSort(labels, "name_desc", "이름 역순", "b.name DESC");
        addSort(labels, "likes_desc", "추천 많은 순", "like_count DESC, b.name");
        addSort(labels, "likes_asc", "추천 적은 순", "like_count ASC, b.name");
        addSort(labels, "price_asc", "가격 낮은 순", "b.price IS NULL, b.price ASC, b.name");
        addSort(labels, "price_desc", "가격 높은 순", "b.price IS NULL, b.price DESC, b.name");
        addSort(labels, "kcal_asc", "열량 낮은 순", "b.calories_kcal IS NULL, b.calories_kcal ASC, b.name");
        addSort(labels, "kcal_desc", "열량 높은 순", "b.calories_kcal IS NULL, b.calories_kcal DESC, b.name");
        addSort(labels, "protein_desc", "단백질 많은 순", "b.protein_g IS NULL, b.protein_g DESC, b.name");
        addSort(labels, "protein_asc", "단백질 적은 순", "b.protein_g IS NULL, b.protein_g ASC, b.name");
        addSort(labels, "satfat_asc", "포화지방 낮은 순", "b.sat_fat_g IS NULL, b.sat_fat_g ASC, b.name");
        addSort(labels, "satfat_desc", "포화지방 높은 순", "b.sat_fat_g IS NULL, b.sat_fat_g DESC, b.name");
        SORT_LABELS = Collections.unmodifiableMap(labels);
    }

    private static void addSort(Map<String, String> labels, String code, String label, String orderBy) {
        labels.put(code, label);
        SORT_SQL.put(code, orderBy);
    }

    private static final String SELECT =
            "SELECT b.burger_id, b.brand_id, br.name AS brand_name, b.name, b.description, b.image_url, "
          + "b.patty_type, b.price, b.weight_g, b.calories_kcal, b.protein_g, b.sat_fat_g, b.sugar_g, "
          + "b.sodium_mg, b.view_count, "
          + "(SELECT COUNT(*) FROM burger_like bl WHERE bl.burger_id = b.burger_id) AS like_count "
          + "FROM burger b JOIN brand br ON br.brand_id = b.brand_id ";

    /**
     * 버거 목록을 조건에 맞게 찾는다.
     *
     * @param keyword   이름 검색어 (부분 일치). 비어 있으면 조건 없음
     * @param brandIds  브랜드 번호들. 비어 있으면 전체
     * @param pattyType 패티 종류 코드. null 이면 전체
     * @param sort      정렬 코드. 모르는 값이면 이름순
     */
    public List<Burger> search(String keyword, List<Integer> brandIds, String pattyType, String sort)
            throws SQLException {
        StringBuilder sql = new StringBuilder(SELECT).append("WHERE 1 = 1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isEmpty()) {
            // 검색어 안의 %, _ 가 와일드카드로 쓰이지 않게 ! 로 이스케이프한다
            sql.append("AND b.name LIKE ? ESCAPE '!' ");
            params.add("%" + keyword.replace("!", "!!").replace("%", "!%").replace("_", "!_") + "%");
        }
        if (brandIds != null && !brandIds.isEmpty()) {
            sql.append("AND b.brand_id IN (")
               .append(String.join(", ", Collections.nCopies(brandIds.size(), "?")))
               .append(") ");
            params.addAll(brandIds);
        }
        if (pattyType != null) {
            sql.append("AND b.patty_type = ? ");
            params.add(pattyType);
        }
        sql.append("ORDER BY ").append(SORT_SQL.getOrDefault(sort, SORT_SQL.get(DEFAULT_SORT)));

        List<Burger> list = new ArrayList<>();
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    /** 버거 한 종을 찾는다. 없으면 null. */
    public Burger findById(int burgerId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT + "WHERE b.burger_id = ?")) {
            ps.setInt(1, burgerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    /** 조회수를 1 올린다. */
    public void increaseViewCount(int burgerId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE burger SET view_count = view_count + 1 WHERE burger_id = ?")) {
            ps.setInt(1, burgerId);
            ps.executeUpdate();
        }
    }

    private static Burger map(ResultSet rs) throws SQLException {
        Burger b = new Burger();
        b.setId(rs.getInt("burger_id"));
        b.setBrandId(rs.getInt("brand_id"));
        b.setBrandName(rs.getString("brand_name"));
        b.setName(rs.getString("name"));
        b.setDescription(rs.getString("description"));
        b.setImageUrl(rs.getString("image_url"));
        b.setPattyType(rs.getString("patty_type"));
        b.setPrice(rs.getObject("price", Integer.class));
        b.setWeightG(rs.getObject("weight_g", Integer.class));
        b.setCaloriesKcal(rs.getObject("calories_kcal", Integer.class));
        b.setProteinG(rs.getBigDecimal("protein_g"));
        b.setSatFatG(rs.getBigDecimal("sat_fat_g"));
        b.setSugarG(rs.getBigDecimal("sugar_g"));
        b.setSodiumMg(rs.getObject("sodium_mg", Integer.class));
        b.setViewCount(rs.getInt("view_count"));
        b.setLikeCount(rs.getInt("like_count"));
        return b;
    }
}
