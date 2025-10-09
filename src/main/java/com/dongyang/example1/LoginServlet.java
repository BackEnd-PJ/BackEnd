package com.dongyang.example1;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/login.do")
public class LoginServlet extends HttpServlet {
	      

	public void init(ServletConfig config) throws ServletException {
		System.out.println("init 메서드 호출!");
	}

	 protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	        request.setCharacterEncoding("UTF-8");

	        String id = request.getParameter("id");
	        String password = request.getParameter("pw");

	        Connection conn = null;
	        PreparedStatement pstmt = null;
	        ResultSet rs = null;

	        try {
	            // ❗️❗️ 본인 DB 환경에 맞게 수정하세요! ❗️❗️
	            String dbUrl = "jdbc:mysql://localhost:3306/testdb?serverTimezone=UTC";
	            String dbId = "root";
	            String dbPw = "qkdwnsgk";

	            Class.forName("com.mysql.cj.jdbc.Driver");
	            conn = DriverManager.getConnection(dbUrl, dbId, dbPw);
	            
	            String sql = "SELECT name, role FROM members WHERE id = ? AND password = ?";
	            pstmt = conn.prepareStatement(sql);
	            pstmt.setString(1, id);
	            pstmt.setString(2, password);
	            rs = pstmt.executeQuery();

	            if (rs.next()) { 
	                String name = rs.getString("name");
	                String role = rs.getString("role");

	                HttpSession session = request.getSession();
	                session.setAttribute("loginUser", name);
	                session.setAttribute("userRole", role); 

	                if ("admin".equals(role)) {
	                    response.sendRedirect("admin.jsp");
	                } else {
	                    response.sendRedirect("main.jsp");
	                }

	            } else { 
	                request.setAttribute("errorMsg", "아이디 또는 비밀번호가 일치하지 않습니다.");
	                RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
	                dispatcher.forward(request, response);
	            }
	        } catch (Exception e) {
	            e.printStackTrace();
	            request.setAttribute("errorMsg", "로그인 처리 중 오류가 발생했습니다.");
	            RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
	            dispatcher.forward(request, response);
	        } finally {
	            try {
	                if (rs != null) rs.close();
	                if (pstmt != null) pstmt.close();
	                if (conn != null) conn.close();
	            } catch (Exception e) {
	                e.printStackTrace();
	            }
	        }
	    }

}
