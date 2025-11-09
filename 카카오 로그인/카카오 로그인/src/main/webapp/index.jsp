<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>홈</title>
</head>
<body>
<h3> 메뉴 : 홈 학교소개 
<%
String lo=(String)application.getAttribute("loginCheck");
	if(lo == null){
		out.print("<a href=register.jsp>회원가입</a>");
	}else{
		out.print("<a href=#>마이페이지</a>");
	}

%>


</h3>

<%

if(lo != null){
	//로그인 상태
%>
	<form action="logout.do" method="post">
		<input type="submit" value="로그아웃">
	</form>
<%
}else{
	//로그아웃 상태
%>
	<form action="login.do" method="post">
		아이디 : <input type="text" name="id"><br>
		암호 : <input type="password" name="pw"><br>
		<input type="submit" value="로그인">
	</form>
<%
}
%>
<%-- 카카오 로그인 버튼 --%>
<%
    // ❗️❗️ 본인의 REST API 키를 여기에 입력하세요. ❗️❗️
    String REST_API_KEY = "f4ac314dd5c4525d19387589eb2da5ad";
    // ❗️❗️ 카카오 개발자 사이트에 등록한 Redirect URI를 여기에 입력하세요. ❗️❗️
    String REDIRECT_URI = "http://localhost:8000/TestLogin/kakao_login.do";
    
    String kakaoLoginUrl = "https://kauth.kakao.com/oauth/authorize"
            + "?client_id=" + REST_API_KEY
            + "&redirect_uri=" + REDIRECT_URI
            + "&response_type=code"
    		+ "&prompt=login";
%>
<a href="<%= kakaoLoginUrl %>">
    <img src="images/kakao_login_btn.png" width="222" alt="카카오 로그인 버튼">
</a>

<hr>
<h1> 저희 웹사이트에 오신 걸 환영합니다!</h1>
</body>
</html>