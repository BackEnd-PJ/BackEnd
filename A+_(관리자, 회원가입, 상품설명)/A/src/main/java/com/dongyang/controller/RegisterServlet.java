// (파일 내용 전체 교체)
package com.dongyang.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set; // Set 임포트

import com.dongyang.dao.EmailVerifyDAO; // (신규)
import com.dongyang.dao.MemberDAO;
import com.dongyang.dto.MemberDTO;
import com.dongyang.util.EmailUtil; // (신규)
import com.dongyang.util.RandomCodeUtil; // (신규)

@WebServlet("/register.do")
public class RegisterServlet extends HttpServlet {

    // (Step 1) 허용할 대학 이메일 도메인 목록
    private static final Set<String> VALID_DOMAINS = Set.of(
        "ac.kr", "edu"
    );

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String id = request.getParameter("id");
	    String password = request.getParameter("pw");
        String name = request.getParameter("name");
	    String email = request.getParameter("email");

        // (Step 1) 도메인 유효성 검사
        String domain = "";
        try {
            domain = email.substring(email.indexOf("@") + 1);
        } catch (Exception e) {
            response.sendRedirect("register.jsp?error=domain");
            return;
        }
        
        if (!VALID_DOMAINS.contains(domain) && !domain.endsWith(".ac.kr")) {
            response.sendRedirect("register.jsp?error=domain");
            return;
        }

        // (Step 2) 회원 DB에 '미인증' 상태로 저장
	    MemberDTO mdto = new MemberDTO();
	    mdto.setMemberid(id);
	    mdto.setPassword(password);
        mdto.setName(name);
        mdto.setEmail(email);
	     
	    MemberDAO mdao = new MemberDAO();
	    int result = mdao.registerMember(mdto); // (DAO는 'memberTbl'에 'is_verified=0'으로 저장)
	     
	    if(result == 1) { // 1. 회원가입 DB 저장 성공
            
            // (Step 2) 인증 코드 생성 및 DB 저장
            String authCode = RandomCodeUtil.createCode();
            EmailVerifyDAO vdao = new EmailVerifyDAO();
            vdao.insertOrUpdateCode(email, authCode); // (DAO는 'email_verifications'에 저장)

            // (Step 3) 이메일 전송
            String subject = "[A+ 마켓] 회원가입 인증 코드입니다.";
            String body = "<html><body>"
                        + "<h2>A+ 마켓 회원가입 인증 코드</h2>"
                        + "<p>인증 코드: <strong style='font-size: 1.5em; color: #DC2626;'>" + authCode + "</strong></p>"
                        + "<p>이 코드를 5분 이내에 입력해주세요.</p>"
                        + "</body></html>";
            
            try {
                EmailUtil.sendEmail(email, subject, body);

                // 성공: 인증 코드 입력 페이지로 이동
                HttpSession session = request.getSession();
                session.setAttribute("verify_email", email); 
                response.sendRedirect("verify_code.jsp");

            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("register.jsp?error=email_fail");
            }

	    } else { // 0. 회원가입 실패 (ID 또는 이메일 중복)
	    	 response.sendRedirect("register.jsp?error=duplicate");
	    }
	}
}