package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import ohburger.common.DB;
import ohburger.model.LoginMember;

/** member 테이블 (M-01, M-02). */
public class MemberDao {

    /** 로그인 검사에 필요한 값: 회원 정보와 저장된 해시 · 솔트. */
    public static class Account {

        private final LoginMember member;
        private final String passwordHash;
        private final String salt;

        Account(LoginMember member, String passwordHash, String salt) {
            this.member = member;
            this.passwordHash = passwordHash;
            this.salt = salt;
        }

        public LoginMember getMember() { return member; }
        public String getPasswordHash() { return passwordHash; }
        public String getSalt() { return salt; }
    }

    public boolean existsLoginId(String loginId) throws SQLException {
        return exists("SELECT 1 FROM member WHERE login_id = ?", loginId);
    }

    public boolean existsNickname(String nickname) throws SQLException {
        return exists("SELECT 1 FROM member WHERE nickname = ?", nickname);
    }

    private static boolean exists(String sql, String value) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, value);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    /**
     * 회원을 추가한다. 권한은 기본값 USER.
     * 중복 검사와 삽입 사이에 다른 요청이 끼어들면 UNIQUE 제약 위반
     * (SQLIntegrityConstraintViolationException)이 날 수 있다.
     */
    public void insert(String loginId, String passwordHash, String salt, String nickname) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "INSERT INTO member (login_id, password_hash, salt, nickname) VALUES (?, ?, ?, ?)")) {
            ps.setString(1, loginId);
            ps.setString(2, passwordHash);
            ps.setString(3, salt);
            ps.setString(4, nickname);
            ps.executeUpdate();
        }
    }

    /** 회원 번호로 로그인 정보(닉네임 · 권한)를 다시 읽는다. 회원이 없으면 null. */
    public LoginMember findById(int memberId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT member_id, nickname, role FROM member WHERE member_id = ?")) {
            ps.setInt(1, memberId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next()
                        ? new LoginMember(rs.getInt("member_id"), rs.getString("nickname"), rs.getString("role"))
                        : null;
            }
        }
    }

    /** 아이디로 계정을 찾는다. 없으면 null. */
    public Account findByLoginId(String loginId) throws SQLException {
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT member_id, nickname, role, password_hash, salt FROM member WHERE login_id = ?")) {
            ps.setString(1, loginId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                LoginMember member = new LoginMember(
                        rs.getInt("member_id"), rs.getString("nickname"), rs.getString("role"));
                return new Account(member, rs.getString("password_hash"), rs.getString("salt"));
            }
        }
    }
}
