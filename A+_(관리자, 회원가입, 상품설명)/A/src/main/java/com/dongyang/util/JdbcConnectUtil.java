package com.dongyang.util;

import java.sql.*;

public class JdbcConnectUtil {
	public static Connection getConnection() {
		 Connection con=null;
		try {
			// ✅ 드라이버 로드
			Class.forName("com.mysql.cj.jdbc.Driver");
			// ✅ DB 연결 정보 (URL, ID, PW 확인 필수)
			con=DriverManager.getConnection("jdbc:mysql://localhost:3306/porjectdb", "root", "qkdwnsgk");
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		return con;
	}
	
	// ✅ 자원 해제 메서드
	public static void close(Connection con, PreparedStatement pstmt) {
		try {
			if(pstmt != null) pstmt.close(); // pstmt null 체크 추가
			if(con != null) con.close();     // con null 체크 추가
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
	
	public static void close(Connection con, PreparedStatement pstmt, ResultSet rs) {
		try {
			if(rs != null) rs.close();       // rs null 체크 추가
			if(pstmt != null) pstmt.close();
			if(con != null) con.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
	}
}