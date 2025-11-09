<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
</head>
<body>
    <h1>회원가입</h1>
    <form action="register.do" method="post">
        아이디: <input type="text" name="id" required><br>
        비밀번호: <input type="password" name="pw" required><br>
        이름: <input type="text" name="name" required><br>
        <input type="submit" value="가입하기">
        <input type="reset" value="다시작성">
    </form>
    <br>
    <a href="index.jsp">로그인하러 가기</a>

    <%-- 회원가입 실패 시 에러 메시지 표시 --%>
    <%
        String errorMsg = (String) request.getAttribute("errorMsg");
        if (errorMsg != null) {
    %>
        <p style="color:red;"><%= errorMsg %></p>
    <%
        }
    %>
</body>
</html>