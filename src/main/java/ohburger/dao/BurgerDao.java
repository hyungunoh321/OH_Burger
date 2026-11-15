package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import ohburger.common.DB;
import ohburger.model.Burger;

/** burger 테이블 조회 (B-01, B-02)와 관리자의 등록 · 수정 · 삭제 (B-04). */
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
            sql.append("AND b.name LIKE ? ESCAPE '!' ");
            params.add(DB.likePattern(keyword));
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

    /**
     * 룰렛 후보를 찾는다 (R-01). 조건은 모두 선택 사항이며 null · 빈 목록이면 걸지 않는다.
     * 상한을 걸면 그 값이 없는(NULL) 버거는 후보에서 빠진다 (가격을 공개하지 않은 브랜드 등).
     *
     * @param maxPrice 가격 상한(원)
     * @param maxKcal  열량 상한(kcal)
     */
    public List<Burger> findForRoulette(List<Integer> brandIds, String pattyType, Integer maxPrice, Integer maxKcal)
            throws SQLException {
        StringBuilder sql = new StringBuilder(SELECT).append("WHERE 1 = 1 ");
        List<Object> params = new ArrayList<>();

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
        if (maxPrice != null) {
            sql.append("AND b.price IS NOT NULL AND b.price <= ? ");
            params.add(maxPrice);
        }
        if (maxKcal != null) {
            sql.append("AND b.calories_kcal IS NOT NULL AND b.calories_kcal <= ? ");
            params.add(maxKcal);
        }
        sql.append("ORDER BY b.burger_id");

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

    /** 회원이 추천한 버거 전부를 최근에 추천한 순으로 돌려준다 (마이페이지용). */
    public List<Burger> findLikedBy(int memberId) throws SQLException {
        String sql = SELECT
                   + "JOIN burger_like mine ON mine.burger_id = b.burger_id AND mine.member_id = ? "
                   + "ORDER BY mine.created_at DESC, b.burger_id DESC";
        List<Burger> list = new ArrayList<>();
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    /**
     * 같은 브랜드에 같은 이름의 버거가 있는지 (B-04). burger 테이블의 UNIQUE(brand_id, name) 에 걸리기 전에 미리 알려 주려고 쓴다.
     *
     * @param exceptId 검사에서 뺄 버거 번호 (수정할 때의 자기 자신). 없으면 null
     */
    public boolean existsName(int brandId, String name, Integer exceptId) throws SQLException {
        String sql = "SELECT 1 FROM burger WHERE brand_id = ? AND name = ? AND burger_id <> ?";
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, brandId);
            ps.setString(2, name);
            ps.setInt(3, exceptId == null ? 0 : exceptId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * 버거를 추가한다 (B-04).
     *
     * @return 새 버거 번호
     */
    public int insert(Burger b) throws SQLException {
        String sql = "INSERT INTO burger (brand_id, name, description, image_url, patty_type, price, weight_g, "
                   + "calories_kcal, protein_g, sat_fat_g, sugar_g, sodium_mg) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            bind(ps, b);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                keys.next();
                return keys.getInt(1);
            }
        }
    }

    /** 버거의 내용을 바꾼다 (B-04). 조회수 · 추천은 건드리지 않는다. */
    public void update(int burgerId, Burger b) throws SQLException {
        String sql = "UPDATE burger SET brand_id = ?, name = ?, description = ?, image_url = ?, patty_type = ?, "
                   + "price = ?, weight_g = ?, calories_kcal = ?, protein_g = ?, sat_fat_g = ?, sugar_g = ?, "
                   + "sodium_mg = ? WHERE burger_id = ?";
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            bind(ps, b);
            ps.setInt(13, burgerId);
            ps.executeUpdate();
        }
    }

    /** 버거를 지운다 (B-04). 추천과 게시글의 버거 태그는 ON DELETE CASCADE 로 함께 지워진다(게시글은 남는다). */
    public void delete(int burgerId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM burger WHERE burger_id = ?")) {
            ps.setInt(1, burgerId);
            ps.executeUpdate();
        }
    }

    /** insert · update 가 함께 쓰는 값 12개를 차례로 넣는다. null 은 NULL 로 들어간다. */
    private static void bind(PreparedStatement ps, Burger b) throws SQLException {
        ps.setInt(1, b.getBrandId());
        ps.setString(2, b.getName());
        ps.setString(3, b.getDescription());
        ps.setString(4, b.getImageUrl());
        ps.setString(5, b.getPattyType());
        ps.setObject(6, b.getPrice());
        ps.setObject(7, b.getWeightG());
        ps.setObject(8, b.getCaloriesKcal());
        ps.setBigDecimal(9, b.getProteinG());
        ps.setBigDecimal(10, b.getSatFatG());
        ps.setBigDecimal(11, b.getSugarG());
        ps.setObject(12, b.getSodiumMg());
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
