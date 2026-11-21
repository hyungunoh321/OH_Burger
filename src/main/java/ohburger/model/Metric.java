package ohburger.model;

import java.util.ArrayList;
import java.util.List;

/**
 * 티어표의 기준 (기능 명세서 4.3). 버거 티어표는 5종 전부, 사이드 티어표는 forSide 인 4종을 쓴다.
 * sqlExpr 는 메뉴 테이블 별칭 b 를 기준으로 한 기준 값 식이며, 코드에 고정된 값이라 SQL 에 그대로 붙여도 안전하다.
 * burger 와 side_menu 는 영양 · 가격 열 이름이 같아서 인기를 뺀 식은 두 테이블에 그대로 쓸 수 있다.
 * 식의 값이 NULL 인 메뉴는 그 티어표에서 빠진다.
 */
public enum Metric {

    // 추천 · 태그 테이블이 버거에만 있어 사이드 티어표에는 쓰지 않는다
    POPULARITY("popularity", "인기", "점", "추천×5 + 태그된 글×3 + 조회수",
            "(SELECT COUNT(*) FROM burger_like bl WHERE bl.burger_id = b.burger_id) * 5"
          + " + (SELECT COUNT(*) FROM post_burger pb WHERE pb.burger_id = b.burger_id) * 3"
          + " + b.view_count",
            true, true, false),
    PROTEIN("protein", "단백질", "g", "단백질이 많을수록 상위", "b.protein_g", true, false, true),
    KCAL("kcal", "열량", "kcal", "열량이 낮을수록 상위", "b.calories_kcal", false, false, true),
    SATFAT("satfat", "포화지방", "g", "포화지방이 낮을수록 상위", "b.sat_fat_g", false, false, true),
    // 1,000원당 단백질(g). 화면에 보이는 값(소수 1자리)으로 순위를 매기도록 식에서 반올림한다.
    // 가격 · 단백질 중 하나라도 NULL 이면 NULL 이 되어 대상에서 빠진다.
    VALUE("value", "가성비", "g/천원", "1,000원당 단백질이 많을수록 상위 (가격이 공개된 메뉴만)",
            "ROUND(b.protein_g * 1000 / NULLIF(b.price, 0), 1)", true, false, true);

    private final String key;
    private final String label;
    private final String unit;
    private final String note;
    private final String sqlExpr;
    private final boolean higherIsBetter;
    private final boolean excludeZero;
    private final boolean forSide;

    Metric(String key, String label, String unit, String note, String sqlExpr,
           boolean higherIsBetter, boolean excludeZero, boolean forSide) {
        this.key = key;
        this.label = label;
        this.unit = unit;
        this.note = note;
        this.sqlExpr = sqlExpr;
        this.higherIsBetter = higherIsBetter;
        this.excludeZero = excludeZero;
        this.forSide = forSide;
    }

    /** 요청 파라미터 값으로 버거 티어표 기준을 찾는다. 없거나 모르는 값이면 인기. */
    public static Metric fromKey(String key) {
        for (Metric m : values()) {
            if (m.key.equals(key)) {
                return m;
            }
        }
        return POPULARITY;
    }

    /** 사이드 티어표에서 쓰는 기준 (탭 순서). */
    public static List<Metric> sideValues() {
        List<Metric> list = new ArrayList<>();
        for (Metric m : values()) {
            if (m.forSide) {
                list.add(m);
            }
        }
        return list;
    }

    /** 요청 파라미터 값으로 사이드 티어표 기준을 찾는다. 없거나 사이드에 없는 기준이면 첫 기준(단백질). */
    public static Metric fromSideKey(String key) {
        List<Metric> side = sideValues();
        for (Metric m : side) {
            if (m.key.equals(key)) {
                return m;
            }
        }
        return side.get(0);
    }

    public String getKey() { return key; }
    public String getLabel() { return label; }
    public String getUnit() { return unit; }
    public String getNote() { return note; }
    public String getSqlExpr() { return sqlExpr; }
    public boolean isHigherIsBetter() { return higherIsBetter; }

    /** 값이 0 인 메뉴를 티어 대상에서 빼는지 (인기 점수 0 = "집계 중"). */
    public boolean isExcludeZero() { return excludeZero; }

    /** 사이드 티어표에서 쓰는 기준인지. */
    public boolean isForSide() { return forSide; }
}
