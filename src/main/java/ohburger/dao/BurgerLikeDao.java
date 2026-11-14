package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;

import ohburger.common.DB;

/** burger_like 테이블 (B-03). 회원 1명이 버거 1개에 1회, 행이 있으면 추천한 상태다. */
public class BurgerLikeDao {

    /**
     * 추천을 뒤집는다: 추천한 상태면 취소하고, 아니면 추천한다.
     * 버거가 있는지는 부르는 쪽에서 먼저 확인한다.
     *
     * @return 뒤집은 뒤의 상태. 추천한 상태면 true
     */
    public boolean toggle(int memberId, int burgerId) throws SQLException {
        try (Connection con = DB.getConnection()) {
            try (PreparedStatement del = con.prepareStatement(
                    "DELETE FROM burger_like WHERE member_id = ? AND burger_id = ?")) {
                del.setInt(1, memberId);
                del.setInt(2, burgerId);
                if (del.executeUpdate() > 0) {
                    return false; // 있던 추천을 취소했다
                }
            }
            try (PreparedStatement ins = con.prepareStatement(
                    "INSERT INTO burger_like (member_id, burger_id) VALUES (?, ?)")) {
                ins.setInt(1, memberId);
                ins.setInt(2, burgerId);
                ins.executeUpdate();
            } catch (SQLIntegrityConstraintViolationException e) {
                // 같은 요청이 거의 동시에 두 번 온 경우: 이미 추천돼 있으므로 그대로 둔다
            }
            return true;
        }
    }

    /** 이 회원이 이 버거를 추천했는지. */
    public boolean isLiked(int memberId, int burgerId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT 1 FROM burger_like WHERE member_id = ? AND burger_id = ?")) {
            ps.setInt(1, memberId);
            ps.setInt(2, burgerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /** 버거의 추천 수. */
    public int count(int burgerId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT COUNT(*) FROM burger_like WHERE burger_id = ?")) {
            ps.setInt(1, burgerId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }
}
