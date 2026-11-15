package ohburger.common;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import org.apache.tomcat.jdbc.pool.DataSource;
import org.apache.tomcat.jdbc.pool.PoolProperties;

/**
 * DB 연결을 내주는 클래스. 접속 정보는 클래스패스의 db.properties 에서 읽는다.
 *
 * 요청마다 연결을 새로 맺지 않게 연결 풀을 쓴다. 풀은 Tomcat 에 들어 있는 tomcat-jdbc 이며
 * (Tomcat 의 lib/tomcat-jdbc.jar) 따로 넣을 jar 는 없다.
 * getConnection() 으로 받은 연결을 close() 하면 끊기지 않고 풀로 돌아간다.
 */
public final class DB {

    private static final DataSource POOL;

    static {
        Properties props = new Properties();
        try (InputStream in = DB.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new IllegalStateException("db.properties 가 없습니다. db.properties.example 을 복사해 만들어 주세요.");
            }
            props.load(in);
        } catch (IOException e) {
            throw new ExceptionInInitializerError(e);
        }

        PoolProperties p = new PoolProperties();
        p.setDriverClassName("com.mysql.cj.jdbc.Driver");
        p.setUrl(props.getProperty("db.url"));
        p.setUsername(props.getProperty("db.user"));
        p.setPassword(props.getProperty("db.password"));
        p.setInitialSize(1);
        p.setMinIdle(1);
        p.setMaxIdle(5);
        p.setMaxActive(10);
        p.setMaxWait(5000);                 // 연결이 다 쓰이고 있으면 5초까지 기다린다
        p.setDefaultAutoCommit(true);       // 풀에서 꺼낼 때마다 자동 커밋 상태로 되돌린다
        // MySQL 이 오래 쉰 연결을 끊었을 수 있으므로 꺼낼 때 살아 있는지 확인한다 (30초에 한 번만)
        p.setTestOnBorrow(true);
        p.setValidationQuery("SELECT 1");
        p.setValidationInterval(30_000);
        POOL = new DataSource(p);
    }

    private DB() {
    }

    /** 풀에서 연결을 하나 빌려준다. 쓰는 쪽에서 try-with-resources 로 닫아 돌려준다. */
    public static Connection getConnection() throws SQLException {
        return POOL.getConnection();
    }

    /**
     * 부분 일치 검색에 쓸 LIKE 패턴을 만든다. SQL 에서는 {@code LIKE ? ESCAPE '!'} 로 받는다.
     * 검색어 안의 %, _ 가 와일드카드로 쓰이지 않게 ! 로 이스케이프한다.
     */
    public static String likePattern(String keyword) {
        return "%" + keyword.replace("!", "!!").replace("%", "!%").replace("_", "!_") + "%";
    }

    /** 풀의 연결을 모두 끊는다. 웹 앱이 내려갈 때 AppListener 가 부른다. */
    public static void close() {
        POOL.close();
    }
}
