package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Pattern;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.Auth;
import ohburger.common.PasswordUtil;
import ohburger.dao.MemberDao;

/** 회원가입 (M-01). */
@WebServlet("/join")
public class JoinServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final Pattern LOGIN_ID = Pattern.compile("[A-Za-z0-9]{4,20}");
    private static final int PASSWORD_MIN = 8;
    private static final int NICKNAME_MIN = 2;
    private static final int NICKNAME_MAX = 10;

    private final MemberDao memberDao = new MemberDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (Auth.current(req) != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/join.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (Auth.current(req) != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }
        String loginId = trim(req.getParameter("loginId"));
        String password = nullToEmpty(req.getParameter("password"));   // 비밀번호는 앞뒤 공백도 그대로 둔다
        String passwordConfirm = nullToEmpty(req.getParameter("passwordConfirm"));
        String nickname = trim(req.getParameter("nickname"));

        // 입력 칸 이름 → 사유. 화면에서 칸마다 보여 준다
        Map<String, String> errors = new LinkedHashMap<>();
        try {
            if (!LOGIN_ID.matcher(loginId).matches()) {
                errors.put("loginId", "아이디는 영문 · 숫자 4~20자로 입력해 주세요.");
            } else if (memberDao.existsLoginId(loginId)) {
                errors.put("loginId", "이미 사용 중인 아이디입니다.");
            }

            if (password.length() < PASSWORD_MIN) {
                errors.put("password", "비밀번호는 8자 이상으로 입력해 주세요.");
            } else if (!password.equals(passwordConfirm)) {
                errors.put("passwordConfirm", "비밀번호가 서로 다릅니다.");
            }

            int nicknameLength = nickname.codePointCount(0, nickname.length());
            if (nicknameLength < NICKNAME_MIN || nicknameLength > NICKNAME_MAX) {
                errors.put("nickname", "닉네임은 2~10자로 입력해 주세요.");
            } else if (memberDao.existsNickname(nickname)) {
                errors.put("nickname", "이미 사용 중인 닉네임입니다.");
            }

            if (errors.isEmpty()) {
                String salt = PasswordUtil.newSalt();
                try {
                    memberDao.insert(loginId, PasswordUtil.hash(salt, password), salt, nickname);
                } catch (SQLIntegrityConstraintViolationException e) {
                    // 검사와 삽입 사이에 같은 아이디 · 닉네임이 먼저 가입된 경우
                    if (memberDao.existsLoginId(loginId)) {
                        errors.put("loginId", "이미 사용 중인 아이디입니다.");
                    } else {
                        errors.put("nickname", "이미 사용 중인 닉네임입니다.");
                    }
                }
            }
        } catch (SQLException e) {
            throw new ServletException("회원가입 처리 실패", e);
        }

        if (errors.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/login?joined=1");
            return;
        }
        // 실패: 사유와 함께 입력 화면으로. 아이디 · 닉네임은 유지하고 비밀번호는 돌려주지 않는다
        req.setAttribute("errors", errors);
        req.setAttribute("loginId", loginId);
        req.setAttribute("nickname", nickname);
        req.getRequestDispatcher("/WEB-INF/views/join.jsp").forward(req, resp);
    }

    private static String trim(String s) {
        return (s == null) ? "" : s.trim();
    }

    private static String nullToEmpty(String s) {
        return (s == null) ? "" : s;
    }
}
