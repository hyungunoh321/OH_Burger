package ohburger.model;

import java.math.BigDecimal;

/** 티어표의 버거 카드 한 장: 버거, 기준 수치, 티어(S ~ D). */
public class TierEntry {

    private final int burgerId;
    private final String name;
    private final String imageUrl;   // 없으면 null
    private final String brandName;
    private final BigDecimal value;
    private final String tier;

    public TierEntry(int burgerId, String name, String imageUrl, String brandName, BigDecimal value, String tier) {
        this.burgerId = burgerId;
        this.name = name;
        this.imageUrl = imageUrl;
        this.brandName = brandName;
        this.value = value;
        this.tier = tier;
    }

    public int getBurgerId() { return burgerId; }
    public String getName() { return name; }
    public String getImageUrl() { return imageUrl; }
    public String getBrandName() { return brandName; }
    public BigDecimal getValue() { return value; }
    public String getTier() { return tier; }
}
