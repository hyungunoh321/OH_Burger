package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.dao.BrandDao;
import ohburger.model.Burger;

/** 룰렛 화면 (R-01). 후보 목록은 화면이 /roulette/candidates 에서 따로 받아 온다. */
@WebServlet("/roulette")
public class RouletteServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final BrandDao brandDao = new BrandDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("brands", brandDao.findAll());
        } catch (SQLException e) {
            throw new ServletException("룰렛 화면 준비 실패", e);
        }
        req.setAttribute("pattyLabels", Burger.PATTY_LABELS);
        req.getRequestDispatcher("/WEB-INF/views/roulette.jsp").forward(req, resp);
    }
}
