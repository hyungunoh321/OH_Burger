package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import ohburger.common.DB;
import ohburger.model.Comment;

/** post_comment 테이블 (C-01, C-02). */
public class CommentDao {

    private static final String SELECT =
            "SELECT c.comment_id, c.post_id, c.member_id, m.nickname, c.content, c.created_at "
          + "FROM post_comment c JOIN member m ON m.member_id = c.member_id ";

    /** 게시글의 댓글을 먼저 쓴 순서대로 돌려준다. */
    public List<Comment> listByPost(int postId) throws SQLException {
        List<Comment> list = new ArrayList<>();
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     SELECT + "WHERE c.post_id = ? ORDER BY c.created_at, c.comment_id")) {
            ps.setInt(1, postId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    /** 댓글 한 건을 찾는다. 없으면 null. */
    public Comment findById(int commentId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(SELECT + "WHERE c.comment_id = ?")) {
            ps.setInt(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public void insert(int postId, int memberId, String content) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO post_comment (post_id, member_id, content) VALUES (?, ?, ?)")) {
            ps.setInt(1, postId);
            ps.setInt(2, memberId);
            ps.setString(3, content);
            ps.executeUpdate();
        }
    }

    public void delete(int commentId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement("DELETE FROM post_comment WHERE comment_id = ?")) {
            ps.setInt(1, commentId);
            ps.executeUpdate();
        }
    }

    private static Comment map(ResultSet rs) throws SQLException {
        return new Comment(rs.getInt("comment_id"), rs.getInt("post_id"), rs.getInt("member_id"),
                rs.getString("nickname"), rs.getString("content"),
                rs.getTimestamp("created_at").toLocalDateTime());
    }
}
