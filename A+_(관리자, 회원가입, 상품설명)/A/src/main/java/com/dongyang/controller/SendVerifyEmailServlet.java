package com.dongyang.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set; // ⭐️ Set 임포트

import com.dongyang.dao.EmailVerifyDAO;
import com.dongyang.dao.MemberDAO; // ⭐️ MemberDAO 임포트
import com.dongyang.dto.MemberDTO;
import com.dongyang.util.EmailUtil;
import com.dongyang.util.RandomCodeUtil;

/**
 * [수정] 폼(POST)으로 이메일을 받아 인증 코드를 발송하는 서블릿
 */
@WebServlet("/send_verify.do")
public class SendVerifyEmailServlet extends HttpServlet {

    // ⭐️ (Step 1) 허용할 대학 이메일 도메인 목록
    private static final Set<String> VALID_DOMAINS = Set.of(
        "ac.kr", "edu"
    );

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. 로그인 상태인지 확인
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("memberId") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        MemberDTO loginUser = (MemberDTO) session.getAttribute("memberId");

        // 2. 폼에서 사용자가 '직접 입력한' 이메일 받기
        String email = request.getParameter("email");
        if (email == null || email.trim().isEmpty()) {
            response.sendRedirect("main.jsp?error=email_fail");
            return;
        }

        // 3. ⭐️ (Step 1) 도메인 유효성 검사
        String domain = "";
        try {
            domain = email.substring(email.indexOf("@") + 1);
        } catch (Exception e) {
            response.sendRedirect("main.jsp?error=domain"); // 이메일 형식이 아님
            return;
        }
        
        if (!VALID_DOMAINS.contains(domain) && !domain.endsWith(".ac.kr")) {
            response.sendRedirect("main.jsp?error=domain"); // 대학 이메일이 아님
            return;
        }

        // 4. ⭐️ [신규] DB의 회원 이메일 정보 업데이트
        MemberDAO mdao = new MemberDAO();
        mdao.updateEmail(loginUser.getMemberid(), email);

        // 5. ⭐️ [신규] 세션의 이메일 정보도 갱신
        loginUser.setEmail(email);
        session.setAttribute("memberId", loginUser); // 갱신된 DTO로 세션 덮어쓰기

        // 6. (기존) 인증 코드 발송 로직
        try {
            String authCode = RandomCodeUtil.createCode();
            EmailVerifyDAO vdao = new EmailVerifyDAO();
            vdao.insertOrUpdateCode(email, authCode);

            String subject = "[A+ 마켓] 이메일 인증 코드입니다.";
            String body = "<html><body>"
                        + "<h2>A+ 마켓 이메일 인증 코드</h2>"
                        + "<p>인증 코드: <strong style='font-size: 1.5em; color: #DC2626;'>" + authCode + "</strong></p>"
                        + "<p>이 코드를 5분 이내에 입력해주세요.</p>"
                        + "</body></html>";
            
            EmailUtil.sendEmail(email, subject, body);

            // 7. 성공 -> 인증 코드 입력 페이지로 이동
            session.setAttribute("verify_email", email); // ⭐️ email 정보 전달
            response.sendRedirect("verify_code.jsp?status=resend");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("main.jsp?error=email_fail");
        }
    }
}