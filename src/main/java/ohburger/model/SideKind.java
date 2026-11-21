package ohburger.model;

/** 사이드 메뉴 종류. DB 의 side_menu.kind ENUM 과 1:1 로 맞춘다. */
public enum SideKind {

    SIDE("사이드"),
    CHICKEN("치킨"),
    DESSERT("디저트");

    private final String label;

    SideKind(String label) {
        this.label = label;
    }

    /** 요청 파라미터 값(SIDE 등)으로 종류를 찾는다. 없거나 모르는 값이면 null(전체). */
    public static SideKind fromKey(String key) {
        for (SideKind k : values()) {
            if (k.name().equals(key)) {
                return k;
            }
        }
        return null;
    }

    public String getKey() { return name(); }
    public String getLabel() { return label; }
}
