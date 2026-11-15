package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import ohburger.common.DB;

/**
 * 추천 테이블 (B-03 버거 추천, P-05 게시글 추천).
 * burger_like 와 post_like 는 (회원 번호, 대상 번호) 모양이 같아서 한 클래스로 다룬다.
 * 회원 1명이 대상 1개에 1회이고, 행이 있으면 추천한 상태다.
 */
public class LikeDao {

    public static final LikeDao BURGER = new LikeDao("burger_like", "burger_id");
    public static final LikeDao POST = new LikeDao("post_like", "post_id");

    /** 테이블 · 열 이름은 위의 두 상수에서만 정해지는 고정 값이라 SQL 에 그대로 붙여도 안전하다. */
    private final String table;
    private final String targetColumn;

    private LikeDao(String table, String targetColumn) {
        this.table = table;
        this.targetColumn = targetColumn;
    }

    /**
     * 추천을 뒤집는다: 추천한 상태면 취소하고, 아니면 추천한다.
     * 대상이 있는지(게시글이면 자기 글이 아닌지)는 부르는 쪽에서 먼저 확인한다.
     *
     * @return 뒤집은 뒤의 상태. 추천한 상태면 true
     */
    public boolean toggle(int memberId, int targetId) throws SQLException {
        try (Connection con = DB.getConnection()) {
            try (PreparedStatement del = con.prepareStatement(
                    "DELETE FROM " + table + " WHERE member_id = ? AND " + targetColumn + " = ?")) {
                del.setInt(1, memberId);
                del.setInt(2, targetId);
                if (del.executeUpdate() > 0) {
                    return false; // 있던 추천을 취소했다
                }
            }
            try (PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO " + table + " (member_id, " + targetColumn + ") VALUES (?, ?)")) {
                ins.setInt(1, memberId);
                ins.setInt(2, targetId);
                ins.executeUpdate();
            } catch (SQLIntegrityConstraintViolationException e) {
                // 같은 요청이 거의 동시에 두 번 온 경우: 이미 추천돼 있으므로 그대로 둔다
            }
            return true;
        }
    }

    /** 이 회원이 이 대상을 추천했는지. */
    public boolean isLiked(int memberId, int targetId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT 1 FROM " + table + " WHERE member_id = ? AND " + targetColumn + " = ?")) {
            ps.setInt(1, memberId);
            ps.setInt(2, targetId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** 대상의 추천 수. */
    public int count(int targetId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) FROM " + table + " WHERE " + targetColumn + " = ?")) {
            ps.setInt(1, targetId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }
}
