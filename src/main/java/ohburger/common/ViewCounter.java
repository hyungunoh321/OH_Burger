package ohburger.common;

import java.util.HashSet;
import java.util.Set;

import javax.servlet.http.HttpSession;

/** 조회수를 같은 세션에서 한 번만 올리기 위한 기록 (B-02 버거 상세, P-02 게시글 상세). */
public final class ViewCounter {

    private ViewCounter() {
    }

    /**
     * 이 세션에서 처음 보는 대상이면 기록하고 true 를 돌려준다. true 일 때만 조회수를 올린다.
     *
     * @param kind 대상 종류 (예: "burger", "post"). 종류마다 따로 기록한다
     */
    public static boolean firstView(HttpSession session, String kind, int id) {
        String key = "viewed:" + kind;
        synchronized (session) {
            @SuppressWarnings("unchecked")
            Set<Integer> viewed = (Set<Integer>) session.getAttribute(key);
            if (viewed == null) {
                viewed = new HashSet<>();
                session.setAttribute(key, viewed);
            }
            return viewed.add(id);
        }
    }
}
