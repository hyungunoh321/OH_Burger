package ohburger.model;

import java.io.Serializable;

/** 세션에 담아 두는 로그인한 회원 정보 (회원 번호 · 닉네임 · 권한). 비밀번호 해시는 담지 않는다. */
public class LoginMember implements Serializable {

    private static final long serialVersionUID = 1L;

    private final int id;
    private final String nickname;
    private final String role;

    public LoginMember(int id, String nickname, String role) {
        this.id = id;
        this.nickname = nickname;
        this.role = role;
    }

    public int getId() { return id; }
    public String getNickname() { return nickname; }
    public String getRole() { return role; }

    public boolean isAdmin() { return "ADMIN".equals(role); }
}
