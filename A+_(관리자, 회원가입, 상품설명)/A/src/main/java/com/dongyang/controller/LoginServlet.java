package com.dongyang.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // HttpSession import

import java.io.IOException;

import com.dongyang.dao.MemberDAO;
import com.dongyang.dto.MemberDTO;

@WebServlet("/login.do")
public class LoginServlet extends HttpServlet {
      
	public void init(ServletConfig config) throws ServletException {		System.out.println("init 메서드 호출!");	}

	// ... (import 및 클래스 정의 부분 유지) ...

	// ... (import 및 클래스 정의 부분 유지) ...

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	    //1. 파라미터 받는다
	     String id=request.getParameter("id");
	     String password=request.getParameter("pw");

//	     MemberDTO mdto=new MemberDTO();
//	     mdto.setMemberid(id);
//	     mdto.setPassword(password);
	     
	     MemberDAO mdao=new MemberDAO();
	     MemberDTO result=mdao.loginCheck(id,password);
	     
	     
	     //2. JDBC
	     if(result != null) {			 
	         // 로그인 성공: 세션 저장 후 index.jsp로 리다이렉트 (성공)
	    	// ⭐️ [핵심 수정] 1. 관리자(admin)인지 먼저 확인
		     if ("admin".equals(result.getRole())) {
		    	 // 관리자는 인증 여부(isVerified)와 상관없이 즉시 로그인
		         HttpSession session = request.getSession();
		         session.setAttribute("loginCheck", "ok"); 
		         session.setAttribute("memberId", result); 
		         response.sendRedirect("admin.jsp");
		         return; // ⭐️ 중요: 여기서 바로 종료
		     }

		     // ⭐️ 2. 일반 사용자인 경우, 인증(isVerified) 여부 확인
		     if (result.isVerified()) {
		    	 // (기존 성공 로직) 인증된 일반 사용자
		         HttpSession session = request.getSession();
		         session.setAttribute("loginCheck", "ok"); 
		         session.setAttribute("memberId", result); 
	             response.sendRedirect("main.jsp"); // 일반 사용자 메인 페이지
		            
		     } else {
	             // ❗️ 인증 안 됨
	             // (세션에 이메일 저장 후 코드 입력 페이지로 강제 이동)
	             HttpSession session = request.getSession();
	             session.setAttribute("verify_email", result.getEmail());
	             response.sendRedirect("verify_code.jsp?error=not_verified");
	        }  
	          
	         
	     } else {			
	         // ✅ [수정] 로그인 실패: URL에 파라미터를 추가하여 클라이언트에게 실패 신호를 전달
	         // 기존 요청은 무시하고 새로운 요청으로 리다이렉트합니다.
	         response.sendRedirect("login.jsp?login_error=true"); 
	     }
	}
	// ... (doPost 유지) ...

	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		doGet(request, response);
	}

}