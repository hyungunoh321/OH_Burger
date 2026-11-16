package ohburger.web;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import ohburger.common.PendingForm;
import ohburger.dao.BurgerDao;
import ohburger.model.Brand;
import ohburger.model.Burger;

/**
 * 버거 등록 · 수정 화면의 입력값과 검사 결과 (B-04).
 * 오류가 나면 친 그대로 화면에 돌려주기 위해 입력값은 문자열로 들고 있고, 검사를 통과한 값은 toBurger() 로 꺼낸다.
 * 가격 · 영양 정보는 비워 둘 수 있다(모르는 값은 NULL).
 */
public class BurgerForm {

    public static final int NAME_MAX = 60;
    public static final int DESCRIPTION_MAX = 500;
    public static final int IMAGE_URL_MAX = 255;

    /**
     * 숫자 칸: 이름 → {화면 표시 이름, 하한, 상한, 소수 자릿수}. DB 열의 범위에 맞춘다.
     * 가격 · 중량은 0 일 수 없으므로 1 부터 받는다(모르면 비워 둔다). 영양 성분은 0 일 수 있다.
     */
    private static final Object[][] NUMBERS = {
        {"price", "가격", 1, 1_000_000, 0},
        {"weightG", "중량", 1, 5_000, 0},
        {"caloriesKcal", "열량", 0, 10_000, 0},
        {"proteinG", "단백질", 0, 999, 1},
        {"satFatG", "포화지방", 0, 999, 1},
        {"sugarG", "당류", 0, 999, 1},
        {"sodiumMg", "나트륨", 0, 100_000, 0},
    };

    /** 입력 칸 이름 → 친 값 (화면에 그대로 다시 보여 준다). */
    private final Map<String, String> values = new LinkedHashMap<>();
    /** 입력 칸 이름 → 사유. */
    private final Map<String, String> errors = new LinkedHashMap<>();
    /** 검사를 통과한 숫자 값. 비워 둔 칸은 들어 있지 않다. */
    private final Map<String, BigDecimal> numbers = new LinkedHashMap<>();
    private int brandId;

    /** 빈 양식. */
    public static BurgerForm empty() {
        return new BurgerForm();
    }

    /** 기존 버거의 값으로 채운 양식 (수정 화면). */
    public static BurgerForm of(Burger b) {
        BurgerForm form = new BurgerForm();
        form.brandId = b.getBrandId();
        form.values.put("brandId", String.valueOf(b.getBrandId()));
        form.values.put("name", b.getName());
        form.values.put("pattyType", b.getPattyType());
        form.values.put("description", text(b.getDescription()));
        form.values.put("imageUrl", text(b.getImageUrl()));
        form.values.put("price", text(b.getPrice()));
        form.values.put("weightG", text(b.getWeightG()));
        form.values.put("caloriesKcal", text(b.getCaloriesKcal()));
        form.values.put("proteinG", text(b.getProteinG()));
        form.values.put("satFatG", text(b.getSatFatG()));
        form.values.put("sugarG", text(b.getSugarG()));
        form.values.put("sodiumMg", text(b.getSodiumMg()));
        return form;
    }

    /**
     * 입력값 맵을 읽고 검사한다. 로그인이 풀려 맡아 두었던 입력값(PendingForm)을 되살릴 때도 쓴다.
     *
     * @param params   입력 칸 이름 → 값들 (HttpServletRequest.getParameterMap 과 같은 모양)
     * @param brands   고를 수 있는 브랜드 전체
     * @param burgerId 수정하는 버거 번호. 새로 등록할 때는 null (이름 중복 검사에서 자기 자신을 빼는 데 쓴다)
     */
    public static BurgerForm from(Map<String, String[]> params, List<Brand> brands, Integer burgerId,
            BurgerDao burgerDao) throws SQLException {
        BurgerForm form = new BurgerForm();
        for (String name : new String[] {"brandId", "name", "pattyType", "description", "imageUrl"}) {
            form.read(params, name);
        }

        try {
            int id = Integer.parseInt(form.values.get("brandId"));
            for (Brand brand : brands) {
                if (brand.getId() == id) {
                    form.brandId = id;
                }
            }
        } catch (NumberFormatException e) {
            // 아래에서 오류 처리
        }
        if (form.brandId == 0) {
            form.errors.put("brandId", "브랜드를 선택해 주세요.");
        }

        String name = form.values.get("name");
        if (name.isEmpty()) {
            form.errors.put("name", "이름을 입력해 주세요.");
        } else if (length(name) > NAME_MAX) {
            form.errors.put("name", "이름은 " + NAME_MAX + "자 이내로 입력해 주세요.");
        } else if (form.brandId != 0 && burgerDao.existsName(form.brandId, name, burgerId)) {
            form.errors.put("name", "같은 브랜드에 같은 이름의 버거가 이미 있습니다.");
        }

        if (!Burger.PATTY_LABELS.containsKey(form.values.get("pattyType"))) {
            form.errors.put("pattyType", "패티 종류를 선택해 주세요.");
        }
        if (length(form.values.get("description")) > DESCRIPTION_MAX) {
            form.errors.put("description", "설명은 " + DESCRIPTION_MAX + "자 이내로 입력해 주세요.");
        }

        String imageUrl = form.values.get("imageUrl");
        if (!imageUrl.isEmpty()) {
            if (imageUrl.length() > IMAGE_URL_MAX) {
                form.errors.put("imageUrl", "사진 주소는 " + IMAGE_URL_MAX + "자 이내로 입력해 주세요.");
            } else if (!imageUrl.matches("https?://\\S+")) {
                form.errors.put("imageUrl", "사진 주소는 http:// 또는 https:// 로 시작해야 합니다.");
            }
        }

        for (Object[] spec : NUMBERS) {
            form.readNumber(params, (String) spec[0], (String) spec[1], (Integer) spec[2], (Integer) spec[3], (Integer) spec[4]);
        }
        return form;
    }

    /** 문자열 칸 하나를 읽어 앞뒤 공백을 떼고 담는다. 없으면 빈 문자열. */
    private void read(Map<String, String[]> params, String name) {
        String v = PendingForm.first(params, name);
        // 브라우저가 줄바꿈을 \r\n 으로 보내므로 글자 수가 달라지지 않게 \n 으로 맞춘다
        values.put(name, v == null ? "" : v.replace("\r\n", "\n").trim());
    }

    /** 숫자 칸 하나를 읽는다. 비워 두면 값 없음(NULL), 숫자가 아니거나 범위를 벗어나면 오류. */
    private void readNumber(Map<String, String[]> params, String name, String label, int min, int max, int scale) {
        read(params, name);
        String v = values.get(name).replace(",", "");
        if (v.isEmpty()) {
            return;
        }
        String unit = scale == 0 ? "정수" : "숫자(소수 " + scale + "자리까지)";
        if (!v.matches(scale == 0 ? "\\d{1,9}" : "\\d{1,9}(\\.\\d{1," + scale + "})?")) {
            errors.put(name, label + " 칸에는 " + min + " 이상의 " + unit + "만 입력해 주세요.");
            return;
        }
        BigDecimal n = new BigDecimal(v);
        if (n.compareTo(BigDecimal.valueOf(min)) < 0) {
            errors.put(name, label + " 칸에는 " + min + " 이상의 " + unit + "만 입력해 주세요.");
            return;
        }
        if (n.compareTo(BigDecimal.valueOf(max)) > 0) {
            errors.put(name, label + " 칸에는 " + String.format("%,d", max) + " 이하의 값을 입력해 주세요.");
            return;
        }
        numbers.put(name, n);
    }

    /** 검사를 통과한 입력값을 버거로 옮긴다. hasErrors() 가 false 일 때만 부른다. */
    public Burger toBurger() {
        Burger b = new Burger();
        b.setBrandId(brandId);
        b.setName(values.get("name"));
        b.setPattyType(values.get("pattyType"));
        b.setDescription(emptyToNull(values.get("description")));
        b.setImageUrl(emptyToNull(values.get("imageUrl")));
        b.setPrice(intOrNull("price"));
        b.setWeightG(intOrNull("weightG"));
        b.setCaloriesKcal(intOrNull("caloriesKcal"));
        b.setProteinG(numbers.get("proteinG"));
        b.setSatFatG(numbers.get("satFatG"));
        b.setSugarG(numbers.get("sugarG"));
        b.setSodiumMg(intOrNull("sodiumMg"));
        return b;
    }

    private Integer intOrNull(String name) {
        BigDecimal n = numbers.get(name);
        return n == null ? null : n.intValueExact();
    }

    private static String emptyToNull(String s) {
        return s.isEmpty() ? null : s;
    }

    private static String text(Object value) {
        if (value == null) {
            return "";
        }
        return value instanceof BigDecimal ? ((BigDecimal) value).stripTrailingZeros().toPlainString() : value.toString();
    }

    private static int length(String s) {
        return s.codePointCount(0, s.length());
    }

    public boolean hasErrors() { return !errors.isEmpty(); }

    /** 입력 칸 이름 → 친 값. JSP 에서 form.values.name 처럼 읽는다. */
    public Map<String, String> getValues() { return values; }
    public Map<String, String> getErrors() { return errors; }
}
