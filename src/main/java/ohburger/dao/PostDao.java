package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import ohburger.common.DB;
import ohburger.model.Post;

/** post · post_burger 테이블 (P-01 ~ P-04, B-02 의 태그된 글 목록). */
public class PostDao {

    /** 목록 · 상세에서 함께 쓰는 열. 추천 수 · 댓글 수는 저장하지 않고 COUNT 로 센다. */
    private static final String COLUMNS =
            "p.post_id, p.member_id, m.nickname, p.category, p.title, p.view_count, p.created_at, p.updated_at, "
          + "(SELECT COUNT(*) FROM post_like pl WHERE pl.post_id = p.post_id) AS like_count, "
          + "(SELECT COUNT(*) FROM post_comment pc WHERE pc.post_id = p.post_id) AS comment_count ";

    private static final String FROM = "FROM post p JOIN member m ON m.member_id = p.member_id ";

    /** 목록 조건. 비어 있는 값(null)은 조건으로 쓰지 않는다. */
    public static class Filter {

        private final String category;
        private final String keyword;
        private final Integer burgerId;

        /**
         * @param category 분류 코드
         * @param keyword  제목 + 내용 검색어 (부분 일치)
         * @param burgerId 이 버거가 태그된 글만
         */
        public Filter(String category, String keyword, Integer burgerId) {
            this.category = category;
            this.keyword = (keyword == null || keyword.isEmpty()) ? null : keyword;
            this.burgerId = burgerId;
        }

        /** WHERE 절을 만들고 ? 에 넣을 값을 params 에 차례로 담는다. */
        private String where(List<Object> params) {
            StringBuilder sql = new StringBuilder("WHERE 1 = 1 ");
            if (category != null) {
                sql.append("AND p.category = ? ");
                params.add(category);
            }
            if (keyword != null) {
                String like = DB.likePattern(keyword);
                sql.append("AND (p.title LIKE ? ESCAPE '!' OR p.content LIKE ? ESCAPE '!') ");
                params.add(like);
                params.add(like);
            }
            if (burgerId != null) {
                sql.append("AND EXISTS (SELECT 1 FROM post_burger pb WHERE pb.post_id = p.post_id AND pb.burger_id = ?) ");
                params.add(burgerId);
            }
            return sql.toString();
        }
    }

    /** 조건에 맞는 게시글 수 (페이징용). */
    public int count(Filter filter) throws SQLException {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT COUNT(*) FROM post p " + filter.where(params);
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            bind(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }

    /**
     * 게시글 목록 한 쪽. 본문은 싣지 않고, 태그된 버거는 함께 싣는다.
     *
     * @param byLikes true 면 추천순, false 면 최신순
     * @param page    1 부터 시작하는 쪽 번호
     */
    public List<Post> list(Filter filter, boolean byLikes, int page, int size) throws SQLException {
        List<Object> params = new ArrayList<>();
        String sql = "SELECT " + COLUMNS + FROM + filter.where(params)
                   + "ORDER BY " + (byLikes ? "like_count DESC, " : "") + "p.created_at DESC, p.post_id DESC "
                   + "LIMIT ? OFFSET ?";
        params.add(size);
        params.add((page - 1) * size);

        Map<Integer, Post> posts = new LinkedHashMap<>();
        try (Connection con = DB.getConnection()) {
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                bind(ps, params);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        Post p = map(rs);
                        posts.put(p.getId(), p);
                    }
                }
            }
            loadTags(con, posts);
        }
        return new ArrayList<>(posts.values());
    }

    /** 게시글 한 건을 본문 · 태그와 함께 찾는다. 없으면 null. */
    public Post findById(int postId) throws SQLException {
        String sql = "SELECT " + COLUMNS + ", p.content " + FROM + "WHERE p.post_id = ?";
        try (Connection con = DB.getConnection()) {
            Post post;
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, postId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    post = map(rs);
                    post.setContent(rs.getString("content"));
                }
            }
            loadTags(con, Collections.singletonMap(post.getId(), post));
            return post;
        }
    }

    /** 조회수를 1 올린다. */
    public void increaseViewCount(int postId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "UPDATE post SET view_count = view_count + 1 WHERE post_id = ?")) {
            ps.setInt(1, postId);
            ps.executeUpdate();
        }
    }

    /**
     * 게시글과 버거 태그를 한 트랜잭션으로 추가한다.
     *
     * @return 새 게시글 번호
     */
    public int insert(int memberId, String category, String title, String content, List<Integer> burgerIds)
            throws SQLException {
        try (Connection con = DB.getConnection()) {
            con.setAutoCommit(false);
            try {
                int postId;
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO post (member_id, category, title, content) VALUES (?, ?, ?, ?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, memberId);
                    ps.setString(2, category);
                    ps.setString(3, title);
                    ps.setString(4, content);
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        keys.next();
                        postId = keys.getInt(1);
                    }
                }
                insertTags(con, postId, burgerIds);
                con.commit();
                return postId;
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true); // 연결이 풀로 돌아가므로 원래 상태로 되돌린다
            }
        }
    }

    /** 게시글 내용과 버거 태그를 한 트랜잭션으로 바꾼다. 태그는 지우고 다시 넣는다. */
    public void update(int postId, String category, String title, String content, List<Integer> burgerIds)
            throws SQLException {
        try (Connection con = DB.getConnection()) {
            con.setAutoCommit(false);
            try {
                try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE post SET category = ?, title = ?, content = ?, updated_at = NOW() WHERE post_id = ?")) {
                    ps.setString(1, category);
                    ps.setString(2, title);
                    ps.setString(3, content);
                    ps.setInt(4, postId);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement("DELETE FROM post_burger WHERE post_id = ?")) {
                    ps.setInt(1, postId);
                    ps.executeUpdate();
                }
                insertTags(con, postId, burgerIds);
                con.commit();
            } catch (SQLException e) {
                con.rollback();
                throw e;
            } finally {
                con.setAutoCommit(true); // 연결이 풀로 돌아가므로 원래 상태로 되돌린다
            }
        }
    }

    /** 게시글을 지운다. 댓글 · 추천 · 버거 태그는 ON DELETE CASCADE 로 함께 지워진다. */
    public void delete(int postId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM post WHERE post_id = ?")) {
            ps.setInt(1, postId);
            ps.executeUpdate();
        }
    }

    /** 버거가 태그된 게시글을 추천 많은 순으로 limit 개 돌려준다 (버거 상세용). 본문 · 태그는 싣지 않는다. */
    public List<Post> findTopByBurger(int burgerId, int limit) throws SQLException {
        String sql = "SELECT " + COLUMNS + FROM
                   + "WHERE EXISTS (SELECT 1 FROM post_burger pb WHERE pb.post_id = p.post_id AND pb.burger_id = ?) "
                   + "ORDER BY like_count DESC, p.created_at DESC, p.post_id DESC LIMIT ?";
        List<Post> list = new ArrayList<>();
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, burgerId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    private static void insertTags(Connection con, int postId, List<Integer> burgerIds) throws SQLException {
        if (burgerIds.isEmpty()) {
            return;
        }
        try (PreparedStatement ps = con.prepareStatement(
                "INSERT INTO post_burger (post_id, burger_id) VALUES (?, ?)")) {
            for (int burgerId : burgerIds) {
                ps.setInt(1, postId);
                ps.setInt(2, burgerId);
                ps.addBatch();
            }
            ps.executeBatch();
        }
    }

    /** 여러 게시글의 버거 태그를 쿼리 한 번으로 읽어 각 게시글에 붙인다. */
    private static void loadTags(Connection con, Map<Integer, Post> posts) throws SQLException {
        if (posts.isEmpty()) {
            return;
        }
        String sql = "SELECT pb.post_id, b.burger_id, b.name, br.name AS brand_name "
                   + "FROM post_burger pb "
                   + "JOIN burger b ON b.burger_id = pb.burger_id "
                   + "JOIN brand br ON br.brand_id = b.brand_id "
                   + "WHERE pb.post_id IN (" + String.join(", ", Collections.nCopies(posts.size(), "?")) + ") "
                   + "ORDER BY pb.post_id, br.brand_id, b.name";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            bind(ps, new ArrayList<Object>(posts.keySet()));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    posts.get(rs.getInt("post_id")).getTags().add(
                            new Post.Tag(rs.getInt("burger_id"), rs.getString("name"), rs.getString("brand_name")));
                }
            }
        }
    }

    private static void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
    }

    private static Post map(ResultSet rs) throws SQLException {
        Post p = new Post();
        p.setId(rs.getInt("post_id"));
        p.setMemberId(rs.getInt("member_id"));
        p.setNickname(rs.getString("nickname"));
        p.setCategory(rs.getString("category"));
        p.setTitle(rs.getString("title"));
        p.setViewCount(rs.getInt("view_count"));
        p.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        Timestamp updated = rs.getTimestamp("updated_at");
        p.setUpdatedAt(updated == null ? null : updated.toLocalDateTime());
        p.setLikeCount(rs.getInt("like_count"));
        p.setCommentCount(rs.getInt("comment_count"));
        return p;
    }
}
