package ohburger.model;

/**
 * 티어표 4종의 기준 (기능 명세서 4.3).
 * sqlExpr 는 burger b 를 기준으로 한 기준 값 식이며, 코드에 고정된 값이라 SQL 에 그대로 붙여도 안전하다.
 */
public enum Metric {

    POPULARITY("popularity", "인기", "점", "추천×5 + 태그된 글×3 + 조회수",
            "(SELECT COUNT(*) FROM burger_like bl WHERE bl.burger_id = b.burger_id) * 5"
          + " + (SELECT COUNT(*) FROM post_burger pb WHERE pb.burger_id = b.burger_id) * 3"
          + " + b.view_count",
            true, true),
    PROTEIN("protein", "단백질", "g", "단백질이 많을수록 상위", "b.protein_g", true, false),
    KCAL("kcal", "열량", "kcal", "열량이 낮을수록 상위", "b.calories_kcal", false, false),
    SATFAT("satfat", "포화지방", "g", "포화지방이 낮을수록 상위", "b.sat_fat_g", false, false);

    private final String key;
    private final String label;
    private final String unit;
    private final String note;
    private final String sqlExpr;
    private final boolean higherIsBetter;
    private final boolean excludeZero;

    Metric(String key, String label, String unit, String note, String sqlExpr,
           boolean higherIsBetter, boolean excludeZero) {
        this.key = key;
        this.label = label;
        this.unit = unit;
        this.note = note;
        this.sqlExpr = sqlExpr;
        this.higherIsBetter = higherIsBetter;
        this.excludeZero = excludeZero;
    }

    /** 요청 파라미터 값으로 기준을 찾는다. 없거나 모르는 값이면 인기. */
    public static Metric fromKey(String key) {
        for (Metric m : values()) {
            if (m.key.equals(key)) {
                return m;
            }
        }
        return POPULARITY;
    }

    public String getKey() { return key; }
    public String getLabel() { return label; }
    public String getUnit() { return unit; }
    public String getNote() { return note; }
    public String getSqlExpr() { return sqlExpr; }
    public boolean isHigherIsBetter() { return higherIsBetter; }

    /** 값이 0 인 버거를 티어 대상에서 빼는지 (인기 점수 0 = "집계 중"). */
    public boolean isExcludeZero() { return excludeZero; }
}
