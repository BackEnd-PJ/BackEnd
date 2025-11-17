<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Map" %>
<%@ page import="com.dongyang.dto.MemberDTO" %>
<%@ page import="com.dongyang.dto.ProductDTO" %> 
<%@ page import="com.dongyang.dao.ProductDAO" %> 

<%
    // ▼▼▼ [수정] JavaScript와 이미지 경로에서 사용할 '절대 경로' 변수 ▼▼▼
    String contextPath = request.getContextPath();

    // ❗️ 세션에서 "memberId" 키로 MemberDTO 객체를 가져옵니다.
    MemberDTO loginUser = (MemberDTO)session.getAttribute("memberId");
    
    // ❗️ 모달에서 사용할 표시 이름을 '로그인 아이디'로 고정
    String displayName = "사용자";
    if (loginUser != null) {
        displayName = loginUser.getName(); // 이름(getName) 대신 아이디(getMemberid)를 사용
    }
	
    // ▼▼▼ [수정] Mock 데이터 -> DB 찜 목록 로직으로 교체 ▼▼▼
    System.out.println("--- main.jsp 찜 목록 디버깅 시작 ---");
    List<ProductDTO> wishlist = new ArrayList<>();

    if (loginUser != null) { // ❗️ 로그인한 상태일 때만 DB 조회
        System.out.println("로그인 ID: " + loginUser.getMemberid());
        try {
            String userId = loginUser.getMemberid(); // 로그인한 사용자 ID
            ProductDAO dao = new ProductDAO(); // DAO 객체 생성
            wishlist = dao.getBookMarkByUserId(userId); 
            System.out.println("DB 조회 완료. 찜 개수: " + wishlist.size());
        } catch (Exception e) {
        	System.err.println("!!! main.jsp 찜 목록 조회 중 예외 발생 !!!");
            e.printStackTrace(); 
        }
    }
    else{
        System.out.println("로그인 상태 아님 (loginUser is null)");
    }
    System.out.println("--- main.jsp 찜 목록 디버깅 종료 ---");
    // --- 찜 목록 로직 끝 ---
%>
	
	<!DOCTYPE html>
	<html lang="ko">
	<head>
	    <meta charset="UTF-8">
	    <meta name="viewport" content="width=device-width, initial-scale=1.0">
	    <title>A+ 마켓</title>
	    
	    <script src="https://cdn.tailwindcss.com"></script>
	    
	    <style>
	        /* A+ 마켓의 기본 폰트 스택 */
	        body {
	            font-family: 'Inter', 'Arimo', 'Noto Sans KR', sans-serif;
	            background-color: #FFFFFF; /* 전체 배경 흰색 */
	        }
	    </style>
	</head>
	<body class="bg-white">
	
	    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
	
	        <header class="relative flex justify-center items-center h-16 border-b border-gray-200">
	            
	            <div class="absolute left-0">
	                <a href="main.jsp" class="text-base font-semibold text-gray-700 hover:text-red-600">메인</a>
	            </div>
	            
	            <a href="main.jsp" class="flex items-center gap-2">
	                <div class="w-10 h-10">
	                    <svg width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
	                        <path d="M20 38C29.9411 38 38 29.9411 38 20C38 10.0589 29.9411 2 20 2C10.0589 2 2 10.0589 2 20C2 29.9411 10.0589 38 20 38Z" fill="url(#paint0_linear_10_176)"/>
	                        <path d="M20 12L28 26H24.8L23.2 22.4H16.8L15.2 26H12L20 12Z" fill="white" fill-opacity="0.95"/>
	                        <path d="M22.4 20.8H17.6V23.2H22.4V20.8Z" fill="url(#paint1_linear_10_176)"/>
	                        <path d="M20 30C20.6627 30 21.2 29.4627 21.2 28.8C21.2 28.1373 20.6627 27.6 20 27.6C19.3372 27.6 18.8 28.1373 18.8 28.8C18.8 29.4627 19.3372 30 20 30Z" fill="white" fill-opacity="0.9"/>
	                        <defs>
	                        <linearGradient id="paint0_linear_10_176" x1="2" y1="2" x2="3602" y2="3602" gradientUnits="userSpaceOnUse">
	                        <stop stop-color="#DC2626"/>
	                        <stop offset="1" stop-color="#EF4444"/>
	                        </linearGradient>
	                        <linearGradient id="paint1_linear_10_176" x1="17.6" y1="20.8" x2="209.6" y2="404.8" gradientUnits="userSpaceOnUse">
	                        <stop stop-color="#DC2626"/>
	                        <stop offset="1" stop-color="#EF4444"/>
	                        </linearGradient>
	                        </defs>
	                    </svg>
	                </div>
	                <span class="text-3xl font-bold text-red-600">A+</span>
	            </a>
	            
	            <div class="absolute right-0 flex items-center gap-2">
	                <% if (loginUser != null) { %>
	                
	                    <%-- ⭐️ [수정] 인증된 사용자에게만 '상품 등록' 버튼이 보이도록 수정 --%>
	                    <% if (loginUser.isVerified()) { %>
	                        <a href="add_product.jsp" 
	                           class="bg-white text-red-600 font-bold px-5 py-2 rounded-full text-sm border border-red-600 hover:bg-red-50 transition-colors">
	                            상품 등록
	                        </a>
	                    <% } %>
	                
	                    <button id="my-page-button" onclick="toggleUserMenu()" 
	                            class="bg-red-600 text-white font-bold px-5 py-2 rounded-full text-sm hover:bg-red-700 transition-colors focus:outline-none">
	                        마이페이지
	                    </button>
	                    
	                    <%-- ⭐️ 미인증 사용자일 경우 '대학생 인증' 버튼 표시 --%>
                        <% if (!loginUser.isVerified()) { %>
                            <button type="button" onclick="openEmailModal()"
                               class="bg-yellow-500 text-white font-bold px-5 py-2 rounded-full text-sm hover:bg-yellow-600 transition-colors">
                                대학생 인증
                            </button>
                        <% } %>
	                <% } else { %>
	                    <a href="login.jsp" class="bg-red-600 text-white font-bold px-5 py-2 rounded-full text-sm hover:bg-red-700 transition-colors">
	                        로그인
	                    </a>
	                <% } %>
	            </div>
	        </header>
	
	        <% if (loginUser != null) { %>
	        <div id="user-menu-modal" 
	             class="hidden absolute top-16 right-0 z-50 w-60 bg-white rounded-lg shadow-xl border border-gray-200 mr-4 sm:mr-6 lg:mr-8">
	            <div class="p-4 border-b border-gray-100">
	                    <p class="text-sm text-gray-500">닉네임:</p>
	                    <p class="font-bold text-gray-900 truncate" title="<%= displayName %>">
	                        <%= displayName %>
	                    </p>
	                    <%-- ⭐️ [신규] 모달 내부에도 인증 상태 표시 --%>
	                    <div class="mt-2">
	                    <% if (!loginUser.isVerified()) { %>
	                        <%-- (JS) 마이페이지 모달을 닫고, 이메일 모달을 엶 --%>
	                        <a href="#" onclick="openEmailModal(); toggleUserMenu(); return false;" class="text-xs font-bold text-yellow-600 hover:underline">
	                            (이메일 미인증 - 인증하기)
	                        </a>
	                    <% } else { %>
	                         <span class="text-xs font-bold text-green-600">(대학생 인증 완료)</span>
	                    <% } %>
	                    </div>
	            </div>
	            <nav class="p-2">
	                <a href="myPage.jsp" 
	                   class="block w-full text-left px-3 py-2 text-sm text-gray-700 rounded-md hover:bg-gray-100 font-medium">
	                    내 정보 보기
	                </a>
	                <form action="logout.do" method="POST" class="w-full mt-1">
	                    <button type="submit" 
	                            class="block w-full text-left px-3 py-2 text-sm text-red-600 rounded-md hover:bg-red-50 hover:text-red-700 font-medium">
	                        로그아웃
	                    </button>
	                </form>
	            </nav>
	        </div>
	        <% } %>
			
	        <main class="w-full mx-auto py-8">
	            
	            <%-- ⭐️ [수정] 각종 에러 메시지 표시 영역 (기존 인증 배너 삭제) --%>
                <% 
                    String loginError = request.getParameter("login_error");
                    String emailError = request.getParameter("error");
                    String verified = request.getParameter("verified");
                    if ("true".equals(verified)) { // ⭐️ [추가]
                %>
                    	<div class="mt-4 mb-4 p-4 bg-green-100 border border-green-400 text-green-700 rounded-lg text-center shadow-sm">
                        	<strong class="font-bold">인증 성공!</strong> A+ 마켓의 모든 기능을 이용할 수 있습니다.
                        </div>
                <%
                    }
                    if ("true".equals(loginError)) {
                %>
                     <div class="mt-4 mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg text-center shadow-sm">
                        아이디 또는 비밀번호가 일치하지 않습니다.
                    </div>
                <%
                    }
                    if ("email_fail".equals(emailError)) {
                %>
                     <div class="mt-4 mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg text-center shadow-sm">
                        인증 이메일 발송에 실패했습니다. 잠시 후 다시 시도해주세요.
                    </div>
                <%
                    }
                    if ("domain".equals(emailError)) {
                %>
                     <div class="mt-4 mb-4 p-4 bg-red-100 border border-red-400 text-red-700 rounded-lg text-center shadow-sm">
                        대학교 이메일(@ac.kr, @edu)만 인증할 수 있습니다.
                    </div>
                <%
                    }
                %>
                
	            <div class="flex justify-center items-center gap-2 text-lg font-bold text-gray-800 mb-6 relative">
	                <div class="flex items-center gap-2">
	                    <span>📍</span>
	                    <span><strong class="text-red-600">대방동</strong>에서 물건 찾고 계신가요?</span>
	                </div>
	                <a href="index.jsp" class="absolute right-0 flex items-center gap-1.5 text-sm font-semibold text-blue-600 hover:text-blue-800 transition-colors">
	                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
	                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
	                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
	                    </svg>
	                    <span>지도로 보기</span>
	                </a>
	            </div>
	
	            <form id="search-form" action="search" method="get" class="flex flex-col sm:flex-row items-center gap-2 mb-8">
	                <button type="button" class="flex items-center justify-center gap-1.5 bg-red-600 text-white font-bold px-5 rounded-full shadow-sm hover:bg-red-700 transition-colors w-full sm:w-auto flex-shrink-0 h-14">
	                    <span>대방동</span>
	                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
	                </button>
	                
	                <div class="flex-grow flex items-center border border-gray-300 rounded-lg overflow-hidden w-full h-14">
	                    
	                    <div class="flex items-center justify-center gap-2 px-5 h-full border-r border-gray-300 bg-white cursor-pointer">
	                        <span class="text-sm font-semibold text-gray-700 whitespace-nowrap">중고거래</span>
	                        <svg class="w-4 h-4 text-gray-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path></svg>
	                    </div>
	                    
	                    <div class="relative flex-grow h-full">
	                    
	                        <input id="search-input-box" type="text" name="keyword" placeholder="검색어를 입력해주세요" 
	                               class="w-full h-full px-4 text-sm outline-none font-medium text-gray-900">
	                        
	                        <section id="search-results-section" 
	                                 class="absolute top-full left-0 right-0 z-10 mt-1 bg-white border border-gray-300 rounded-lg shadow-lg overflow-hidden hidden">
	                            </section>
	                        
	                    </div>
	                    
	                    <button type="submit" class="bg-red-600 text-white w-14 h-full flex-shrink-0 flex items-center justify-center hover:bg-red-700 transition-colors">
	                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
	                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 7l5 5-5 5M6 12h12"></path>
	                        </svg>
	                    </button>
	                    
	                </div> 
	            </form>
	            <section>
	                <div class="flex justify-between items-center mb-4">
	                    <h2 class="text-xl font-bold flex items-center gap-1.5 text-gray-900">
	                        <span>⭐</span>
	                        찜한 상품
	                    </h2>
	                    <button class="font-bold text-sm text-red-600 hover:text-red-700">
	                        접기 ↑
	                    </button>
	                </div>
	
	                <div class="grid grid-cols-2 md:grid-cols-4 gap-4 sm:gap-6">
	                    
	                    <%-- ▼▼▼ [수정] Mock data 'products' -> DB data 'wishlist'로 변경 ▼▼▼ --%>
	                    <% for (ProductDTO item : wishlist) { %>
	                    <div class="border border-gray-200 rounded-lg shadow-sm overflow-hidden transition-all duration-300 hover:shadow-md">
	                        <div class="relative w-full aspect-square bg-gray-100">
	                            
	                            <%-- ▼▼▼ [수정] DTO getter 사용 + contextPath 추가 (이미지 깨짐 방지) ▼▼▼ --%>
	                            <img src="<%= contextPath + "/" + item.getImageUrl() %>" alt="<%= item.getName() %>" class="w-full h-full object-cover"
	                                 onerror="this.src='https://placehold.co/300x300/f3f4f6/ccc?text=Image+Error';">
	                            
	                            <button class="absolute top-3 right-3 text-red-500" aria-label="찜하기">
	                                <svg class="w-6 h-6" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg">
	                                    <path d="M12.001 4.52853C10.3429 2.5413 7.7121 2.22234 5.4853C3.25813 5.73473 2.92209 8.78314 4.70817 10.9995L11.5309 19.1678C11.792 19.4828 12.2102 19.4828 12.4713 19.1678L19.294 10.9995C21.0801 8.78314 20.7441 5.73473 18.5171 3.97853C16.2901 2.22234 13.6593 2.5413 12.001 4.52853Z" fill="#EF4444"/>
	                                </svg>
	                            </button>
	                        </div>
	                        <div class="p-4">
	                            <%-- ▼▼▼ [수정] DTO getter 사용 ▼▼▼ --%>
	                            <h3 class="font-semibold text-gray-800 truncate" title="<%= item.getName() %>">
	                                <%= item.getName() %>
	                            </h3>
	                            <p class="font-bold text-red-600 text-lg mt-1">
	                                <%= item.getPrice() %> 원
	                            </p>
	                        </div>
	                    </div>
	                    <% } %> <%-- 루프 종료 --%>
	
	                    <%-- ▼▼▼ [수정] wishlist가 비었는지 확인 ▼▼▼ --%>
	                    <% if (wishlist.isEmpty()) { %>
	                        <p class="col-span-2 md:col-span-4 text-center text-gray-500 py-8">
	                            찜한 상품이 없습니다.
	                        </p>
	                    <% } %>
	                </div>
	            </section>
	
	        </main>
	    
	    </div>
	    
	     <%-- ⭐️ [신규] 이메일 인증 모달 (페이지 하단에 추가) --%>
        <% if (loginUser != null) { %>
        <div id="emailVerifyModal" class="hidden fixed inset-0 bg-gray-900 bg-opacity-75 flex items-center justify-center z-50 transition-opacity duration-300" 
             onclick="closeEmailModal()"> <%-- ⭐️ 바깥 클릭 시 닫기 --%>
            
            <div class="bg-white p-8 rounded-xl shadow-2xl w-full max-w-md border border-gray-100 relative"
                 onclick="event.stopPropagation()"> <%-- ⭐️ 모달 클릭은 닫기 방지 --%>
                
                <button onclick="closeEmailModal()" class="absolute top-4 right-4 text-gray-500 hover:text-gray-700">
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" /></svg>
                </button>
        
                <form action="send_verify.do" method="POST">
                    <h2 class="text-2xl font-bold text-gray-900 mb-4 text-center">대학생 이메일 인증</h2>
                    <p class="text-center text-gray-600 mb-6">
                        인증 코드를 받을 대학생 이메일 주소를 입력해주세요.<br>
                    </p>
                    
                    <div class="mb-6">
                        <label for="modal_email" class="block text-sm font-medium text-gray-700 mb-1">대학 이메일</label>
                        <%-- ⭐️ [수정] 현재 이메일이 있으면 기본값으로 표시 --%>
                        <input type="email" name="email" id="modal_email" placeholder="student@univ.ac.kr" required
                               value="<%= (loginUser.getEmail() != null) ? loginUser.getEmail() : "" %>"
                               class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-red-500">
                    </div>
                    
                    <input type="submit" value="인증 메일 발송" 
                           class="w-full px-4 py-3 bg-red-600 text-white font-bold rounded-lg hover:bg-red-700 cursor-pointer transition duration-150">
                </form>
            </div>
        </div>
        <% } %>
	     <script>
	        // JSP 변수(contextPath)를 JavaScript 변수로 받음
	        const CONTEXT_PATH = '<%= contextPath %>'; 
	    
	        // --- 모달 관련 ---
	        const myPageButton = document.getElementById('my-page-button');
	        const userMenuModal = document.getElementById('user-menu-modal');

	        function toggleUserMenu() {
	            if (userMenuModal) {
	                userMenuModal.classList.toggle('hidden');
	            }
	        }
	        
	        // --- 검색 관련 ---
	        const searchForm = document.getElementById('search-form');
	        const searchInput = searchForm.querySelector('input[name="keyword"]'); 
	        const resultsContainer = document.getElementById('search-results-section');
	        const searchInputBox = document.getElementById('search-input-box'); // 너비 계산 기준
	        let debounceTimer; 

	        // (검색 실행 함수)
	        function performSearch(keyword) {
	            if (keyword.trim() === '') {
	                resultsContainer.innerHTML = ''; 
	                resultsContainer.classList.add('hidden'); 
	                return;
	            }
	            // [!] contextPath를 사용하는 fetch (먹통 방지)
	            fetch(CONTEXT_PATH + '/search?keyword=' + encodeURIComponent(keyword), {
	                method: 'GET'
	            })
	            .then(response => {
	                if (response.ok) return response.text();
	                throw new Error('검색 서버 응답 오류');
	            })
	            .then(html => {
	                resultsContainer.innerHTML = html;
	                resultsContainer.classList.remove('hidden'); 
	            })
	            .catch(error => {
	                console.error('Fetch 오류:', error);
	                resultsContainer.innerHTML = '<p class="p-3 text-sm text-center text-red-500">검색 중 오류가 발생했습니다.</p>';
	                resultsContainer.classList.remove('hidden'); 
	            });
	        }

	        // (너비/위치 맞춤 함수)
	        function alignDropdown() {
	            if (!searchInputBox || !resultsContainer || !searchForm) return;
	            const leftOffset = searchInputBox.getBoundingClientRect().left - searchForm.getBoundingClientRect().left;
	            resultsContainer.style.left = `${leftOffset}px`;
	            resultsContainer.style.width = `${searchInputBox.offsetWidth}px`;
	        }
	        
	     	// ⭐️ [신규] 이메일 인증 모달 JS
            const emailModal = document.getElementById('emailVerifyModal');
            
            function openEmailModal() {
                if(emailModal) emailModal.classList.remove('hidden');
                // (선택) 마이페이지 모달이 열려있다면 닫기
                if (userMenuModal && !userMenuModal.classList.contains('hidden')) {
	                toggleUserMenu();
	            }
            }
            
            function closeEmailModal() {
                if(emailModal) emailModal.classList.add('hidden');
            }
            
	        // --- 이벤트 리스너 ---
	        
	        // (검색 이벤트)
	        searchInput.addEventListener('input', function(event) {
	            clearTimeout(debounceTimer); 
	            const keyword = event.target.value; 
	            debounceTimer = setTimeout(() => { performSearch(keyword); }, 300);
	        });
	        
	        searchForm.addEventListener('submit', function(event) {
	            event.preventDefault(); 
	            clearTimeout(debounceTimer); 
	            performSearch(searchInput.value); 
	        });
	        
	        searchInput.addEventListener('focus', function() {
	            if (searchInput.value.trim() !== '' && resultsContainer.innerHTML.trim() !== '') {
	                resultsContainer.classList.remove('hidden');
	            }
	        });
	        
	        // (너비 맞춤 이벤트)
	        document.addEventListener('DOMContentLoaded', alignDropdown);
	        window.addEventListener('resize', alignDropdown);
	        
	        // (전역 클릭 리스너 - 모달과 검색창 동시 제어)
	        window.addEventListener('click', function(e) {
	            // 모달 숨기기
	            if (userMenuModal && !userMenuModal.classList.contains('hidden')) {
	                if (myPageButton && !myPageButton.contains(e.target) && !userMenuModal.contains(e.target)) {
	                    userMenuModal.classList.add('hidden');
	                }
	            }
	            
	            // 검색 드롭다운 숨기기
	            if (searchForm && !searchForm.contains(e.target)) {
	                resultsContainer.classList.add('hidden'); 
	            }
	        });
	        
	    </script>
	
	</body>
	</html>