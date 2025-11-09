<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지</title>
</head>
<body>
    <h1>관리자 페이지</h1>
    <h3>${sessionScope.loginUser}님, 환영합니다! (관리자)</h3>
    <p>이곳에서 관리자 기능을 수행할 수 있습니다.</p>
    <br>
    <form action="logout.do" method="post">
        <input type="submit" value="로그아웃">
    </form>
</body>
</html>