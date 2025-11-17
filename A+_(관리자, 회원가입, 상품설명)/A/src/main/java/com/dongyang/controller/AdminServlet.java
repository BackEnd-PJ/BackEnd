package com.dongyang.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

import com.dongyang.dao.MemberDAO;
import com.dongyang.dao.ProductDAO;
import com.dongyang.dto.MemberDTO;

@WebServlet("/admin.do")
public class AdminServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. 관리자 권한 확인 (매우 중요)
        HttpSession session = request.getSession(false);
        MemberDTO loginUser = (session != null) ? (MemberDTO) session.getAttribute("memberId") : null;

        if (loginUser == null || !"admin".equals(loginUser.getRole())) {
            response.sendRedirect("main.jsp"); // 권한 없으면 메인으로
            return;
        }

        // 2. 파라미터 받기
        String action = request.getParameter("action");

        // 3. DAO 준비
        MemberDAO mdao = new MemberDAO();
        ProductDAO pdao = new ProductDAO();

        try {
            if ("deleteMember".equals(action)) {
                // 회원 삭제 로직
                String memberId = request.getParameter("memberId");
                if (memberId != null) {
                    mdao.deleteMember(memberId);
                }
            } else if ("deleteProduct".equals(action)) {
                // 상품 삭제 로직
                int productId = Integer.parseInt(request.getParameter("productId"));
                pdao.deleteProduct(productId);
            }
        } catch (Exception e) {
            e.printStackTrace();
            // 에러 처리 (필요시)
        }

        // 4. 완료 후 관리자 페이지로 리다이렉트
        response.sendRedirect("admin.jsp");
    }
}