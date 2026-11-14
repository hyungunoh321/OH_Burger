package ohburger.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import ohburger.common.DB;
import ohburger.model.Brand;

/** brand 테이블 조회. */
public class BrandDao {

    /** 브랜드 전체를 등록 순서대로 돌려준다. */
    public List<Brand> findAll() throws SQLException {
        List<Brand> list = new ArrayList<>();
        try (Connection con = DB.getConnection();
             PreparedStatement ps = con.prepareStatement("SELECT brand_id, name FROM brand ORDER BY brand_id");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Brand(rs.getInt("brand_id"), rs.getString("name")));
            }
        }
        return list;
    }
}
