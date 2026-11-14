package ohburger.model;

/** 목록에 한 줄로 보여 줄 게시글 요약. */
public class PostSummary {

    private final int id;
    private final String category;
    private final String title;
    private final String nickname;
    private final int likeCount;
    private final int commentCount;

    public PostSummary(int id, String category, String title, String nickname, int likeCount, int commentCount) {
        this.id = id;
        this.category = category;
        this.title = title;
        this.nickname = nickname;
        this.likeCount = likeCount;
        this.commentCount = commentCount;
    }

    public int getId() { return id; }
    public String getCategory() { return category; }

    /** 분류의 화면 표시 이름. */
    public String getCategoryLabel() {
        switch (category) {
            case "COMBO": return "꿀조합";
            case "TIP": return "꿀팁";
            default: return "자유";
        }
    }

    public String getTitle() { return title; }
    public String getNickname() { return nickname; }
    public int getLikeCount() { return likeCount; }
    public int getCommentCount() { return commentCount; }
}
