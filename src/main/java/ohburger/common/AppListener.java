package ohburger.common;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

/** 웹 앱이 내려갈 때 DB 연결 풀을 닫는다. 닫지 않으면 서버를 다시 올릴 때 연결과 스레드가 남는다. */
@WebListener
public class AppListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // 풀은 처음 DB 를 쓸 때 만들어진다
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DB.close();
    }
}
