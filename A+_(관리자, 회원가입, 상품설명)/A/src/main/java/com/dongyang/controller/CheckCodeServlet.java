package com.dongyang.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import com.dongyang.dao.EmailVerifyDAO;
import com.dongyang.dao.MemberDAO;
import com.dongyang.dto.EmailVerifyDTO;
import com.dongyang.dto.MemberDTO;

/**
 * (신규) verify_code.jsp의 폼을 처리하는 서블릿
 */
@WebServlet("/check_code.do")
public class CheckCodeServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String code = request.getParameter("code"); // ⭐️ 파라미터명 'code'

        // (Step 4/5) DAO를 통해 코드 유효성 검증
        EmailVerifyDAO vdao = new EmailVerifyDAO();
        EmailVerifyDTO validDto = vdao.getValidCode(email, code); // ⭐️ 'code' 사용

        if (validDto != null) {
            // (Step 5) 인증 성공
            // 1. memberTbl 상태를 '인증됨'으로 변경
            MemberDAO mdao = new MemberDAO();
            mdao.activateMember(email);

            // 2. 세션의 임시 이메일 정보 삭제
            HttpSession session = request.getSession();
            session.removeAttribute("verify_email");

            MemberDTO loginUser = (MemberDTO) session.getAttribute("memberId");
            
            // (카카오 등으로 로그인한 상태에서 인증을 완료했을 경우)
            if (loginUser != null && loginUser.getEmail() != null && loginUser.getEmail().equals(email)) {
                loginUser.setVerified(true); // ⭐️ 세션 객체의 상태를 '인증됨'으로 변경
                session.setAttribute("memberId", loginUser); // ⭐️ 갱신된 객체를 세션에 다시 저장
            }
            
            // 3. 인증 완료 -> 로그인 페이지로
            response.sendRedirect("login.jsp?verified=true");
        } else {
            // (Step 5) 인증 실패
            response.sendRedirect("verify_code.jsp?error=invalid");
        }
    }
}