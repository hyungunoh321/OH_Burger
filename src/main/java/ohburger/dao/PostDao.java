package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import ohburger.common.DB;
import ohburger.model.PostSummary;

/** post 테이블 조회. 지금은 버거 상세(B-02)에 필요한 것만 있고, 게시판 구현 때 늘린다. */
public class PostDao {

    /** 버거가 태그된 게시글을 추천 많은 순으로 limit 개 돌려준다. */
    public List<PostSummary> findTopByBurger(int burgerId, int limit) throws SQLException {
        String sql =
                "SELECT p.post_id, p.category, p.title, m.nickname, "
              + "(SELECT COUNT(*) FROM post_like pl WHERE pl.post_id = p.post_id) AS like_count, "
              + "(SELECT COUNT(*) FROM post_comment pc WHERE pc.post_id = p.post_id) AS comment_count "
              + "FROM post_burger pb "
              + "JOIN post p ON p.post_id = pb.post_id "
              + "JOIN member m ON m.member_id = p.member_id "
              + "WHERE pb.burger_id = ? "
              + "ORDER BY like_count DESC, p.created_at DESC LIMIT ?";
        List<PostSummary> list = new ArrayList<>();
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, burgerId);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new PostSummary(rs.getInt("post_id"), rs.getString("category"), rs.getString("title"),
                            rs.getString("nickname"), rs.getInt("like_count"), rs.getInt("comment_count")));
                }
            }
        }
        return list;
    }
}
