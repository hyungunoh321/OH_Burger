package ohburger.model;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/** 댓글 한 건. */
public class Comment {

    public static final int CONTENT_MAX = 500;

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final int id;
    private final int postId;
    private final int memberId;
    private final String nickname;
    private final String content;
    private final LocalDateTime createdAt;

    public Comment(int id, int postId, int memberId, String nickname, String content, LocalDateTime createdAt) {
        this.id = id;
        this.postId = postId;
        this.memberId = memberId;
        this.nickname = nickname;
        this.content = content;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public int getPostId() { return postId; }
    public int getMemberId() { return memberId; }
    public String getNickname() { return nickname; }
    public String getContent() { return content; }

    /** 작성 일시 (예: 2026-11-14 18:20). */
    public String getCreatedDateTime() { return createdAt.format(DATE_TIME); }
}
