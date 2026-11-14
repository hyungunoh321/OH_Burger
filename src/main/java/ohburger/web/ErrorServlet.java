package ohburger.web;

import java.io.IOException;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 오류 화면 (404 · 403 · 500 등). web.xml 의 error-page 가 오류가 났을 때 이 서블릿으로 보낸다.
 * 예외 내용은 사용자에게 보여 주지 않고 서버 로그에만 남긴다.
 */
@WebServlet("/error")
public class ErrorServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /** 오류는 GET 뿐 아니라 POST 요청에서도 나므로 모든 방식을 같은 곳에서 처리한다. */
    @Override
    protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer status = (Integer) req.getAttribute(RequestDispatcher.ERROR_STATUS_CODE);
        if (status == null) {
            // 오류 없이 주소창에 /error 를 직접 친 경우: 없는 화면으로 본다
            status = HttpServletResponse.SC_NOT_FOUND;
            resp.setStatus(status);
        }

        Throwable error = (Throwable) req.getAttribute(RequestDispatcher.ERROR_EXCEPTION);
        if (error != null) {
            log("요청 처리 중 예외: " + req.getAttribute(RequestDispatcher.ERROR_REQUEST_URI), error);
        }

        String title;
        String message;
        switch (status) {
            case HttpServletResponse.SC_FORBIDDEN:
                title = "권한이 없습니다";
                message = "작성자 본인이나 관리자만 할 수 있는 작업입니다.";
                break;
            case HttpServletResponse.SC_NOT_FOUND:
                title = "화면을 찾을 수 없습니다";
                message = "주소가 잘못됐거나, 삭제된 글 또는 없는 버거일 수 있습니다.";
                break;
            case HttpServletResponse.SC_BAD_REQUEST:
            case HttpServletResponse.SC_METHOD_NOT_ALLOWED:
                title = "잘못된 요청입니다";
                message = "요청을 처리할 수 없습니다. 화면의 버튼과 링크로 다시 시도해 주세요.";
                break;
            default:
                title = "문제가 생겼습니다";
                message = "요청을 처리하지 못했습니다. 잠시 뒤에 다시 시도해 주세요.";
        }
        req.setAttribute("status", status);
        req.setAttribute("errorTitle", title);
        req.setAttribute("errorMessage", message);
        req.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(req, resp);
    }
}
