package ohburger.web;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import ohburger.common.PendingForm;
import ohburger.dao.BrandDao;
import ohburger.dao.BurgerDao;
import ohburger.model.Brand;
import ohburger.model.Burger;

/**
 * 버거 등록(/admin/burgers/new) · 수정(/admin/burgers/edit?id=) (B-04). 관리자 검사는 AdminFilter 가 한다.
 * 두 주소가 같은 화면(burger_form.jsp)과 같은 검사(BurgerForm)를 쓴다. 저장하면 그 버거의 상세 화면으로 간다.
 */
@WebServlet({"/admin/burgers/new", "/admin/burgers/edit"})
public class AdminBurgerFormServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private static final String EDIT = "/admin/burgers/edit";

    private final BurgerDao burgerDao = new BurgerDao();
    private final BrandDao brandDao = new BrandDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Burger burger = target(req, resp);
            if (resp.isCommitted()) {
                return;
            }
            List<Brand> brands = brandDao.findAll();
            // 세션이 만료돼 로그인을 다시 하고 돌아온 경우: 입력하던 내용을 되살린다
            // 수정 화면이면 맡아 둔 내용이 이 버거의 것일 때만 쓴다 (다른 버거에 덮어쓰지 않게)
            Map<String, String[]> pending = PendingForm.take(req, req.getServletPath());
            if (pending != null && burger != null
                    && !String.valueOf(burger.getId()).equals(PendingForm.first(pending, "id"))) {
                pending = null;
            }
            if (pending != null) {
                req.setAttribute("restored", true);
                show(req, resp, burger, brands,
                        BurgerForm.from(pending, brands, burger == null ? null : burger.getId(), burgerDao));
                return;
            }
            show(req, resp, burger, brands, burger == null ? BurgerForm.empty() : BurgerForm.of(burger));
        } catch (SQLException e) {
            throw new ServletException("버거 입력 화면 준비 실패", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            Burger burger = target(req, resp);
            if (resp.isCommitted()) {
                return;
            }
            List<Brand> brands = brandDao.findAll();
            BurgerForm form = BurgerForm.from(req.getParameterMap(), brands,
                    burger == null ? null : burger.getId(), burgerDao);
            if (form.hasErrors()) {
                show(req, resp, burger, brands, form);
                return;
            }
            int burgerId;
            if (burger == null) {
                burgerId = burgerDao.insert(form.toBurger());
            } else {
                burgerId = burger.getId();
                burgerDao.update(burgerId, form.toBurger());
            }
            resp.sendRedirect(req.getContextPath() + "/burgers/detail?id=" + burgerId);
        } catch (SQLException e) {
            throw new ServletException("버거 저장 실패", e);
        }
    }

    /**
     * 수정할 버거를 찾는다. 등록 주소면 null 을 돌려준다.
     * 수정 주소인데 버거가 없으면 404 를 보내므로, 부른 쪽은 resp.isCommitted() 를 확인한다.
     */
    private Burger target(HttpServletRequest req, HttpServletResponse resp) throws SQLException, IOException {
        if (!EDIT.equals(req.getServletPath())) {
            return null;
        }
        Burger burger = null;
        try {
            burger = burgerDao.findById(Integer.parseInt(req.getParameter("id")));
        } catch (NumberFormatException e) {
            // 아래에서 404
        }
        if (burger == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
        return burger;
    }

    private void show(HttpServletRequest req, HttpServletResponse resp, Burger burger, List<Brand> brands,
            BurgerForm form) throws ServletException, IOException {
        req.setAttribute("form", form);
        req.setAttribute("brands", brands);
        req.setAttribute("pattyLabels", Burger.PATTY_LABELS);
        req.setAttribute("heading", burger == null ? "버거 등록" : "버거 수정");
        req.setAttribute("action", burger == null ? "/admin/burgers/new" : EDIT + "?id=" + burger.getId());
        req.setAttribute("cancelUrl", burger == null ? "/admin/burgers" : "/burgers/detail?id=" + burger.getId());
        req.setAttribute("nameMax", BurgerForm.NAME_MAX);
        req.setAttribute("descriptionMax", BurgerForm.DESCRIPTION_MAX);
        req.setAttribute("imageUrlMax", BurgerForm.IMAGE_URL_MAX);
        req.getRequestDispatcher("/WEB-INF/views/burger_form.jsp").forward(req, resp);
    }
}
