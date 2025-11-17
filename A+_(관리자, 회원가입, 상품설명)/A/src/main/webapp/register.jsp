<%-- (파일 내용 전체 교체) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String error = request.getParameter("error");
    String message = "";
    if ("domain".equals(error)) {
        message = "대학교 이메일(@ac.kr, @edu)만 가입할 수 있습니다.";
    } else if ("duplicate".equals(error)) {
        message = "이미 사용 중인 아이디 또는 이메일입니다.";
    } else if ("email_fail".equals(error)) {
        message = "인증메일 발송에 실패했습니다. 이메일을 확인해주세요.";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>A+ 회원가입</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">

    <div class="bg-white p-8 rounded-xl shadow-2xl w-full max-w-md border border-gray-100 relative">
        
        <a href="main.jsp" class="absolute top-3 right-3 text-gray-500 hover:text-gray-700">
            <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
        </a>

        <form action="register.do" method="post" id="registerForm">
            <h2 class="text-2xl font-bold text-gray-900 mb-6 text-center">회원가입</h2>
            
            <% if (!message.isEmpty()) { %>
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg relative mb-4" role="alert">
                    <span class="block sm:inline"><%= message %></span>
                </div>
            <% } %>

            <div class="mb-4">
                <label for="reg_id" class="block text-sm font-medium text-gray-700 mb-1">아이디</label>
                <input type="text" name="id" id="reg_id" placeholder="아이디" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500">
            </div>
             <div class="mb-4">
                <label for="reg_pw" class="block text-sm font-medium text-gray-700 mb-1">암호</label>
                <input type="password" name="pw" id="reg_pw" placeholder="비밀번호" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500">
            </div>
            <div class="mb-4">
                <label for="reg_name" class="block text-sm font-medium text-gray-700 mb-1">이름(닉네임)</label>
                <input type="text" name="name" id="reg_name" placeholder="닉네임" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500">
            </div>
            <div class="mb-6">
                <label for="reg_email" class="block text-sm font-medium text-gray-700 mb-1">대학 이메일</label>
                <input type="email" name="email" id="reg_email" placeholder="student@univ.ac.kr" required
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500">
            </div>
            
            <input type="submit" value="인증 메일 발송" 
                   class="w-full px-4 py-3 bg-red-600 text-white font-bold rounded-lg hover:bg-red-700 cursor-pointer transition duration-150">
        </form>
    </div>
</body>
</html>