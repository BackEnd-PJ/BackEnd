package com.dongyang.dao; // 👈 DAO 패키지

import java.sql.Connection;
import java.sql.PreparedStatement;
// (DB Connection 관리를 위한 util 클래스가 필요합니다. 예: DBManager.java)
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import com.dongyang.dto.SafeZoneDTO;
import com.dongyang.util.JdbcConnectUtil;

public class SafeZoneDAO {

    /**
     * safe_zones 테이블에 데이터를 INSERT하는 메소드
     */
    public int insertSafeZone(String name, String address, double latitude, double longitude) {
    	String sql = "INSERT INTO safe_zones (zone_name, address, latitude, longitude) VALUES (?, ?, ?, ?)";
        Connection con = null;
        PreparedStatement pstmt = null;
        
        try {
            // 2. DBManager를 통해 커넥션을 얻어옵니다.
            con = JdbcConnectUtil.getConnection(); 
            
            // 3. SQL 쿼리 준비
            pstmt = con.prepareStatement(sql);
            
            // 4. SQL의 '?' 부분에 값을 바인딩
            pstmt.setString(1, name);
            pstmt.setString(2, address);
            pstmt.setDouble(3, latitude);
            pstmt.setDouble(4, longitude);
            
            // 5. 쿼리 실행 (성공 시 1 반환)
            return pstmt.executeUpdate(); 
            
        } catch (Exception e) {
            System.out.println("DB INSERT 오류: " + name);
            e.printStackTrace();
            return 0; // 실패 시 0 반환
        } finally {
            // 6. 자원 해제
        	JdbcConnectUtil.close(con, pstmt); 
        }
    }
    public List<SafeZoneDTO> getAllSafeZones() {
        String sql = "SELECT zone_name, address, latitude, longitude FROM safe_zones";
        
        List<SafeZoneDTO> list = new ArrayList<>();
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = JdbcConnectUtil.getConnection();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                SafeZoneDTO dto = new SafeZoneDTO();
                
                // (DTO 구조에 맞게 임시값도 설정)
                dto.setName(rs.getString("zone_name"));
                dto.setAddr(rs.getString("address"));
                dto.setLat(rs.getDouble("latitude"));
                dto.setLng(rs.getDouble("longitude"));
                
                dto.setPrice(0); // (임시) 가격 0원
                dto.setImageUrl("https://placehold.co/80x80/007BFF/white?text=Zone"); // 👈 (임시 테스트 이미지)
                dto.setCategory("안전구역"); // (임시) 카테고리
                
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
        	JdbcConnectUtil.close(con, pstmt, rs);
        }
        return list;
    }
}
