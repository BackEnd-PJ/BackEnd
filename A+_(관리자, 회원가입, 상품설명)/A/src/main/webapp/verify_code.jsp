<%-- (신규 생성) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String email = (String) session.getAttribute("verify_email");
    if (email == null) {
        response.sendRedirect("register.jsp");
        return;
    }
    String error = request.getParameter("error");
    String status = request.getParameter("status");

    String message = "";
    if ("invalid".equals(error)) {
        message = "인증 코드가 틀리거나 만료되었습니다.";
    } else if ("not_verified".equals(error)) {
        message = "로그인을 위해 이메일 인증을 완료해주세요.";
    } else if ("resend".equals(status)) {
        message = "인증 코드를 다시 발송했습니다.";
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>A+ 이메일 인증</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen">

    <div class="bg-white p-8 rounded-xl shadow-2xl w-full max-w-md border border-gray-100 relative">
        
        <form action="check_code.do" method="post">
            <h2 class="text-2xl font-bold text-gray-900 mb-4 text-center">이메일 인증</h2>
            <p class="text-center text-gray-700 mb-6">
                <strong class="text-red-600"><%= email %></strong>(으)로<br>
                발송된 6자리 인증 코드를 입력해주세요.
            </p>
            
            <% if (!message.isEmpty()) { %>
                <div class_="<%= "invalid".equals(error) || "not_verified".equals(error) ? "bg-red-100 border-red-400 text-red-700" : "bg-green-100 border-green-400 text-green-700" %> px-4 py-3 rounded-lg relative mb-4" role="alert">
                    <span class="block sm:inline"><%= message %></span>
                </div>
            <% } %>

            <input type="hidden" name="email" value="<%= email %>">
            
            <div class="mb-6">
                <label for="auth_code" class="block text-sm font-medium text-gray-700 mb-1">인증 코드</label>
                <%-- ⭐️ name="code" (DB 스키마와 일치) --%>
                <input type="text" name="code" id="auth_code" placeholder="6자리 숫자" required maxlength="6"
                       class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500 text-center text-lg tracking-[.2em]">
            </div>
            
            <input type="submit" value="인증 완료하기" 
                   class="w-full px-4 py-3 bg-red-600 text-white font-bold rounded-lg hover:bg-red-700 cursor-pointer transition duration-150">
        </form>
    </div>
</body>
</html>