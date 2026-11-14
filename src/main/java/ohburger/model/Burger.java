package ohburger.model;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/** 버거 한 종. 브랜드가 공개하지 않은 값(가격 · 영양 정보)은 null 이다. */
public class Burger {

    /** 패티 종류 코드 → 화면 표시 이름. DB 의 ENUM 값과 1:1 로 맞춘다. */
    public static final Map<String, String> PATTY_LABELS;

    static {
        Map<String, String> m = new LinkedHashMap<>();
        m.put("BEEF", "소고기");
        m.put("CHICKEN", "치킨");
        m.put("SEAFOOD", "새우·생선");
        m.put("ETC", "기타");
        PATTY_LABELS = Collections.unmodifiableMap(m);
    }

    private int id;
    private int brandId;
    private String brandName;
    private String name;
    private String description;
    private String imageUrl;
    private String pattyType;
    private Integer price;
    private Integer weightG;
    private Integer caloriesKcal;
    private BigDecimal proteinG;
    private BigDecimal satFatG;
    private BigDecimal sugarG;
    private Integer sodiumMg;
    private int viewCount;
    private int likeCount;

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getBrandId() { return brandId; }
    public void setBrandId(int brandId) { this.brandId = brandId; }

    public String getBrandName() { return brandName; }
    public void setBrandName(String brandName) { this.brandName = brandName; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public String getPattyType() { return pattyType; }
    public void setPattyType(String pattyType) { this.pattyType = pattyType; }

    /** 패티 종류의 화면 표시 이름. */
    public String getPattyLabel() { return PATTY_LABELS.getOrDefault(pattyType, "기타"); }

    public Integer getPrice() { return price; }
    public void setPrice(Integer price) { this.price = price; }

    public Integer getWeightG() { return weightG; }
    public void setWeightG(Integer weightG) { this.weightG = weightG; }

    public Integer getCaloriesKcal() { return caloriesKcal; }
    public void setCaloriesKcal(Integer caloriesKcal) { this.caloriesKcal = caloriesKcal; }

    public BigDecimal getProteinG() { return proteinG; }
    public void setProteinG(BigDecimal proteinG) { this.proteinG = proteinG; }

    public BigDecimal getSatFatG() { return satFatG; }
    public void setSatFatG(BigDecimal satFatG) { this.satFatG = satFatG; }

    public BigDecimal getSugarG() { return sugarG; }
    public void setSugarG(BigDecimal sugarG) { this.sugarG = sugarG; }

    public Integer getSodiumMg() { return sodiumMg; }
    public void setSodiumMg(Integer sodiumMg) { this.sodiumMg = sodiumMg; }

    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }
}
