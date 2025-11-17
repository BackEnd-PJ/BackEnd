<%-- (파일 상단 스크립틀릿 <% ... %> 수정) --%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.dongyang.dto.MemberDTO" %>

<%
    MemberDTO loginUser = (MemberDTO)session.getAttribute("memberId");
    String displayName = null;
    if (loginUser != null) {
        displayName = loginUser.getName() != null && !loginUser.getName().isEmpty() 
                      ? loginUser.getName() 
                      : loginUser.getMemberid();
    }

    String REST_API_KEY = "e6f843146e41aaf81175b7973ef2827b";
    String REDIRECT_URI = "http://localhost:8080/A/kakao_login.do";
    String kakaoLoginUrl = "https://kauth.kakao.com/oauth/authorize"
            + "?client_id=" + REST_API_KEY
            + "&redirect_uri=" + REDIRECT_URI
            + "&response_type=code"
    		+ "&prompt=login";

    // ⭐️ [추가] 메시지 처리
    String verified = request.getParameter("verified");
    String loginError = request.getParameter("login_error");

    String errorMsg = "";
    if ("true".equals(loginError)) {
        errorMsg = "아이디 또는 비밀번호가 일치하지 않습니다.";
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>A+ 로그인</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style> body { font-family: 'Inter', 'Arimo', 'Noto Sans KR', sans-serif; } </style>
</head>
<body class="bg-gray-50 flex items-center justify-center min-h-screen">

    <div class="w-full max-w-md bg-white rounded-2xl shadow-xl p-8">
        <header class="flex justify-between items-center pb-4 border-b border-gray-200">
            <%-- (로고 ...) --%>
            <div class="flex items-center gap-2">
                <div class="w-8 h-8">
                    <svg width="32" height="32" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M20 38C29.9411 38 38 29.9411 38 20C38 10.0589 29.9411 2 20 2C10.0589 2 2 10.0589 2 20C2 29.9411 10.0589 38 20 38Z" fill="url(#paint0_linear)"/>
                        <path d="M20 12L28 26H24.8L23.2 22.4H16.8L15.2 26H12L20 12Z" fill="white" fill-opacity="0.95"/>
                        <path d="M22.4 20.8H17.6V23.2H22.4V20.8Z" fill="url(#paint1_linear)"/>
                        <path d="M20 30C20.6627 30 21.2 29.4627 21.2 28.8C21.2 28.1373 20.6627 27.6 20 27.6C19.3372 27.6 18.8 28.1373 18.8 28.8C18.8 29.4627 19.3372 30 20 30Z" fill="white" fill-opacity="0.9"/>
                        <defs>
                        <linearGradient id="paint0_linear" x1="2" y1="2" x2="3602" y2="3602" gradientUnits="userSpaceOnUse">
                        <stop stop-color="#DC2626"/>
                        <stop offset="1" stop-color="#EF4444"/>
                        </linearGradient>
                        <linearGradient id="paint1_linear" x1="17.6" y1="20.8" x2="209.6" y2="404.8" gradientUnits="userSpaceOnUse">
                        <stop stop-color="#DC2626"/>
                        <stop offset="1" stop-color="#EF4444"/>
                        </linearGradient>
                        </defs>
                    </svg>
                </div>
                <span class="text-2xl font-bold text-red-600">A+</span>
            </div>
            <%-- (닫기 버튼) --%>
            <button class="text-gray-400 hover:text-gray-600" onclick="history.back();">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
                </svg>
            </button>
        </header>

        <%-- ⭐️ [추가] 메시지 표시 영역 --%>
        <% if ("true".equals(verified)) { %>
            <div class="mt-8 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded-lg text-center" role="alert">
                <strong class="font-bold">인증 성공!</strong>
                <span class="block sm:inline">로그인하여 A+ 마켓을 이용해보세요.</span>
            </div>
        <% } %>
        <% if (!errorMsg.isEmpty()) { %>
            <div class="mt-8 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg text-center" role="alert">
                <span class="block sm:inline"><%= errorMsg %></span>
            </div>
        <% } %>

        <%-- (로그인 상태 분기) --%>
        <% if(loginUser != null){ %>
            <main class="mt-8">
                <div class="text-center">
                    <h2 class="text-2xl font-bold text-gray-900 mb-4">환영합니다, <%= displayName %>님!</h2>
                    <p class="text-gray-600 mb-8">현재 로그인 중입니다.</p>
                    <form action="logout.do" method="post" class="space-y-4">
                        <input type="submit" value="로그아웃" 
                               class="w-full px-4 py-3 bg-red-500 text-white font-bold text-lg rounded-full hover:bg-red-600 cursor-pointer transition duration-150">
                        <a href="main.jsp" 
                           class="block w-full px-4 py-3 bg-gray-100 text-gray-800 font-bold text-lg rounded-full hover:bg-gray-200 cursor-pointer transition duration-150">
                           메인으로 이동
                        </a>
                    </form>
                </div>
            </main>
        <% } else { %>	
            <main class="mt-8">
                <h2 class="text-2xl font-bold text-center text-gray-800 mb-8">로그인</h2>
    
                <%-- (일반 로그인 폼) --%>
                <form action="login.do" method="post">
                    <div class="space-y-4">
                        <div>
                            <label for="user_id" class="text-sm font-bold text-gray-700">아이디</label>
                            <input type="text" id="user_id" name="id" placeholder="아이디를 입력하세요" required
                                   class="mt-2 w-full px-4 py-3 border border-gray-300 rounded-lg text-base focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500">
                        </div>
                        <div>
                            <label for="user_pw" class="text-sm font-bold text-gray-700">비밀번호</label>
                            <input type="password" id="user_pw" name="pw" placeholder="비밀번호를 입력하세요" required
                                   class="mt-2 w-full px-4 py-3 border border-gray-300 rounded-lg text-base focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500">
                        </div>
                    </div>
                    <button type="submit" class="w-full bg-red-600 text-white font-bold py-3 px-4 rounded-full text-lg hover:bg-red-700 transition-colors mt-8">
                        로그인
                    </button>
                </form>
    
                <div class="text-center text-sm font-bold text-gray-600 mt-6">
                    <a href="register.jsp" class="hover:underline">회원가입</a>
                    <span class="mx-2 text-gray-300">|</span>
                    <a href="#" class="hover:underline">비밀번호 찾기</a>
                </div>
    
                <div class="flex items-center my-6">
                    <span class="flex-grow border-t border-gray-300"></span>
                    <span class="mx-4 text-sm font-bold text-gray-500">또는</span>
                    <span class="flex-grow border-t border-gray-300"></span>
                </div>
    
                <%-- (카카오 로그인 버튼) --%>
                <a href="<%= kakaoLoginUrl %>" 
                   class="w-full flex items-center justify-center gap-2.5 py-3 px-4 border border-gray-300 rounded-full hover:bg-gray-50 transition-colors">
                    <svg class="w-6 h-6" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path fill-rule="evenodd" clip-rule="evenodd" d="M24 4C12.9543 4 4 12.9543 4 24C4 35.0457 12.9543 44 24 44C35.0457 44 44 35.0457 44 24C44 12.9543 35.0457 4 24 4Z" fill="#FEE500"/>
                        <path fill-rule="evenodd" clip-rule="evenodd" d="M24.089 12.0001C17.91 12.0001 12.8711 16.0381 12.8711 21.0351C12.8711 24.0861 14.7391 26.6851 17.1851 28.3241L15.9371 33.1591C15.8451 33.5851 16.3531 33.9211 16.7111 33.6821L21.3701 30.6381C22.2151 30.7911 23.0981 30.8751 24.0041 30.8751C30.1831 30.8751 35.1381 26.8361 35.1381 21.8391C35.1381 16.8421 30.1831 12.8031 24.089 12.8031V12.0001Z" fill="#191919"/>
                    </svg>
                    <span class="text-base font-bold text-gray-700">카카오 로그인</span>
                </a>
            </main>
        <% } %>
    </div>
</body>
</html>