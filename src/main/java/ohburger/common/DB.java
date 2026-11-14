package ohburger.common;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/** DB 연결을 만들어 주는 클래스. 접속 정보는 클래스패스의 db.properties 에서 읽는다. */
public final class DB {

    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = DB.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new IllegalStateException("db.properties 가 없습니다. db.properties.example 을 복사해 만들어 주세요.");
            }
            PROPS.load(in);
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (IOException | ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private DB() {
    }

    /** 새 연결을 돌려준다. 쓰는 쪽에서 try-with-resources 로 닫는다. */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
                PROPS.getProperty("db.url"),
                PROPS.getProperty("db.user"),
                PROPS.getProperty("db.password"));
    }
}
