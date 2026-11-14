package ohburger.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** 게시글 한 건. 목록에서는 content 가 비어 있다(null). */
public class Post {

    /** 분류 코드 → 화면 표시 이름. DB 의 ENUM 값과 1:1 로 맞춘다. */
    public static final Map<String, String> CATEGORY_LABELS;

    static {
        Map<String, String> m = new LinkedHashMap<>();
        m.put("COMBO", "꿀조합");
        m.put("TIP", "꿀팁");
        m.put("FREE", "자유");
        CATEGORY_LABELS = Collections.unmodifiableMap(m);
    }

    public static final int TITLE_MAX = 100;
    public static final int CONTENT_MAX = 5000;
    public static final int TAG_MAX = 3;

    private static final DateTimeFormatter DATE = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    /** 게시글에 태그된 버거. */
    public static class Tag {

        private final int burgerId;
        private final String name;
        private final String brandName;

        public Tag(int burgerId, String name, String brandName) {
            this.burgerId = burgerId;
            this.name = name;
            this.brandName = brandName;
        }

        public int getBurgerId() { return burgerId; }
        public String getName() { return name; }
        public String getBrandName() { return brandName; }

        /** 글쓰기 화면의 선택 목록에 쓰는 이름: "브랜드 버거 이름". */
        public String getLabel() { return brandName + " " + name; }
    }

    private int id;
    private int memberId;
    private String nickname;
    private String category;
    private String title;
    private String content;
    private int viewCount;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private int likeCount;
    private int commentCount;
    private List<Tag> tags = new ArrayList<>();

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }

    public String getNickname() { return nickname; }
    public void setNickname(String nickname) { this.nickname = nickname; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    /** 분류의 화면 표시 이름. */
    public String getCategoryLabel() { return CATEGORY_LABELS.getOrDefault(category, "자유"); }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getViewCount() { return viewCount; }
    public void setViewCount(int viewCount) { this.viewCount = viewCount; }

    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    /** 작성일 (목록용, 예: 2026-11-14). */
    public String getCreatedDate() { return createdAt == null ? "" : createdAt.format(DATE); }

    /** 작성 일시 (상세용, 예: 2026-11-14 18:20). */
    public String getCreatedDateTime() { return createdAt == null ? "" : createdAt.format(DATE_TIME); }

    /** 수정한 적이 있는지. */
    public boolean isEdited() { return updatedAt != null; }

    public int getLikeCount() { return likeCount; }
    public void setLikeCount(int likeCount) { this.likeCount = likeCount; }

    public int getCommentCount() { return commentCount; }
    public void setCommentCount(int commentCount) { this.commentCount = commentCount; }

    public List<Tag> getTags() { return tags; }
    public void setTags(List<Tag> tags) { this.tags = tags; }
}
