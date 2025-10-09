package com.dongyang.example1;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;

@WebServlet("/register.do")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String id = request.getParameter("id");
        String pw = request.getParameter("pw");
        String name = request.getParameter("name");

        // 관리자 아이디('admin')로 가입 시도 시 차단
        if ("admin".equals(id)) {
            request.setAttribute("errorMsg", "해당 아이디는 사용하실 수 없습니다.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("register.jsp");
            dispatcher.forward(request, response);
            return; 
        }

        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            // ❗️❗️ 본인 DB 환경에 맞게 수정하세요! ❗️❗️
            String dbUrl = "jdbc:mysql://localhost:3306/testdb?serverTimezone=UTC";
            String dbId = "root";
            String dbPw = "qkdwnsgk";

            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbUrl, dbId, dbPw);
            
            String sql = "INSERT INTO members (id, password, name) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, id);
            pstmt.setString(2, pw);
            pstmt.setString(3, name);

            int count = pstmt.executeUpdate();

            if (count > 0) {
                response.sendRedirect("index.jsp");
            } else {
                response.sendRedirect("register.jsp");
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "이미 사용 중인 아이디이거나 오류가 발생했습니다.");
            RequestDispatcher dispatcher = request.getRequestDispatcher("register.jsp");
            dispatcher.forward(request, response);
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}