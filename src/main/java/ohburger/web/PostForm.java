package ohburger.web;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.servlet.http.HttpServletRequest;

import ohburger.common.PendingForm;
import ohburger.dao.BurgerDao;
import ohburger.model.Burger;
import ohburger.model.Post;

/**
 * 글쓰기 · 수정 화면의 입력값과 검사 결과 (P-03, P-04).
 * 두 서블릿이 같은 검사를 쓰고, 오류가 나면 입력값을 그대로 화면에 돌려주기 위해 한곳에 모았다.
 */
public class PostForm {

    private String category;
    private String title = "";
    private String content = "";
    private final List<Post.Tag> tags = new ArrayList<>();
    /** 입력 칸 이름 → 사유. */
    private final Map<String, String> errors = new LinkedHashMap<>();

    /** 빈 양식. burger 가 있으면 그 버거를 미리 태그한다 (버거 상세의 "이 버거로 글쓰기"). */
    public static PostForm empty(Burger burger) {
        PostForm form = new PostForm();
        if (burger != null) {
            form.tags.add(new Post.Tag(burger.getId(), burger.getName(), burger.getBrandName()));
        }
        return form;
    }

    /** 기존 글의 내용으로 채운 양식 (수정 화면). */
    public static PostForm of(Post post) {
        PostForm form = new PostForm();
        form.category = post.getCategory();
        form.title = post.getTitle();
        form.content = post.getContent();
        form.tags.addAll(post.getTags());
        return form;
    }

    /** 요청에서 입력값을 읽고 검사한다. 결과는 hasErrors() 로 확인한다. */
    public static PostForm fromRequest(HttpServletRequest req, BurgerDao burgerDao) throws SQLException {
        return from(req.getParameterMap(), burgerDao);
    }

    /**
     * 입력값 맵을 읽고 검사한다. 로그인이 풀려 맡아 두었던 입력값(PendingForm)을 되살릴 때도 쓴다.
     *
     * @param params 입력 칸 이름 → 값들 (HttpServletRequest.getParameterMap 과 같은 모양)
     */
    public static PostForm from(Map<String, String[]> params, BurgerDao burgerDao) throws SQLException {
        PostForm form = new PostForm();

        form.category = PendingForm.first(params, "category");
        if (!Post.CATEGORY_LABELS.containsKey(form.category)) {
            form.category = null;
            form.errors.put("category", "분류를 선택해 주세요.");
        }

        String title = PendingForm.first(params, "title");
        form.title = (title == null) ? "" : title.trim();
        if (form.title.isEmpty()) {
            form.errors.put("title", "제목을 입력해 주세요.");
        } else if (length(form.title) > Post.TITLE_MAX) {
            form.errors.put("title", "제목은 " + Post.TITLE_MAX + "자 이내로 입력해 주세요.");
        }

        // 브라우저가 줄바꿈을 \r\n 으로 보내므로 글자 수가 달라지지 않게 \n 으로 맞춘다
        String content = PendingForm.first(params, "content");
        form.content = (content == null) ? "" : content.replace("\r\n", "\n");
        if (form.content.trim().isEmpty()) {
            form.errors.put("content", "내용을 입력해 주세요.");
        } else if (length(form.content) > Post.CONTENT_MAX) {
            form.errors.put("content", "내용은 " + Post.CONTENT_MAX + "자 이내로 입력해 주세요.");
        }

        // 버거 태그: 같은 번호는 한 번만, 실제로 있는 버거만 받는다
        Set<Integer> ids = new LinkedHashSet<>();
        String[] values = params.get("burgerId");
        if (values != null) {
            for (String v : values) {
                try {
                    ids.add(Integer.valueOf(v));
                } catch (NumberFormatException e) {
                    // 숫자가 아닌 값은 버린다
                }
            }
        }
        // 개수를 먼저 검사한다. 번호를 수천 개 붙여 보내도 DB 조회는 최대 TAG_MAX 번만 한다
        if (ids.size() > Post.TAG_MAX) {
            form.errors.put("tags", "버거는 최대 " + Post.TAG_MAX + "개까지 태그할 수 있습니다.");
        }
        for (int id : ids) {
            if (form.tags.size() == Post.TAG_MAX) {
                break;
            }
            Burger burger = burgerDao.findById(id);
            if (burger != null) {
                form.tags.add(new Post.Tag(burger.getId(), burger.getName(), burger.getBrandName()));
            }
        }
        return form;
    }

    private static int length(String s) {
        return s.codePointCount(0, s.length());
    }

    public boolean hasErrors() { return !errors.isEmpty(); }

    public String getCategory() { return category; }
    public String getTitle() { return title; }
    public String getContent() { return content; }
    public List<Post.Tag> getTags() { return tags; }
    public Map<String, String> getErrors() { return errors; }

    /** 태그한 버거 번호들 (DAO 에 넘길 값). */
    public List<Integer> getBurgerIds() {
        List<Integer> ids = new ArrayList<>();
        for (Post.Tag tag : tags) {
            ids.add(tag.getBurgerId());
        }
        return ids;
    }
}
