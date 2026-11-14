package ohburger.web;

import java.sql.SQLException;

import javax.servlet.http.HttpServletRequest;

import ohburger.dao.BurgerDao;
import ohburger.model.Post;

/** 글쓰기 · 수정 화면(post_form.jsp)이 공통으로 쓰는 값을 요청에 담는다. */
final class PostFormView {

    private PostFormView() {
    }

    static void prepare(HttpServletRequest req, BurgerDao burgerDao) throws SQLException {
        req.setAttribute("categoryLabels", Post.CATEGORY_LABELS);
        req.setAttribute("titleMax", Post.TITLE_MAX);
        req.setAttribute("contentMax", Post.CONTENT_MAX);
        req.setAttribute("tagMax", Post.TAG_MAX);
        // 버거 태그 선택 목록: 전체 버거를 이름순으로
        req.setAttribute("allBurgers", burgerDao.search(null, null, null, BurgerDao.DEFAULT_SORT));
    }
}
