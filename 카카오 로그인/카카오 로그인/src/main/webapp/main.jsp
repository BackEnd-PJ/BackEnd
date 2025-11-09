<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>메인 페이지</title>
</head>
<body>
    <h1>메인 페이지</h1>
    <h3>${sessionScope.loginUser}님, 환영합니다! (일반 사용자)</h3>
    <br>
    <form action="logout.do" method="post">
        <input type="submit" value="로그아웃">
    </form>
</body>
</html>