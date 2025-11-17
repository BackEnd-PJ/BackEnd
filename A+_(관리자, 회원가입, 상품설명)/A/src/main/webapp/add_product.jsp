<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.dongyang.dto.MemberDTO" %> <%-- MemberDTO 임포트 --%>
<%
    // --- 1. 로그인 확인 ---
    // 로그인하지 않은 사용자는 이 페이지에 접근할 수 없습니다.
    MemberDTO loginUser = (MemberDTO) session.getAttribute("memberId");

    if (loginUser == null) {
        // 로그인 페이지로 리다이렉트
        response.sendRedirect("login.jsp");
        return; // 현재 페이지 실행 중단
    }
 	// 이메일 인증 확인
    if (!loginUser.isVerified()) {
        // 인증하지 않은 사용자는 메인 페이지로 리다이렉트
        response.sendRedirect("main.jsp?error=not_verified"); // "인증 필요" 에러
        return;
    }
    // 폼 전송 실패 시 에러 메시지 표시
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>A+ 마켓 - 상품 등록</title>
    <!-- Tailwind CSS 로드 -->
    <script src="https://cdn.tailwindcss.com"></script>
    
    <!-- 🌟 [추가 1] 카카오 지도 API (services 라이브러리 포함) - index.jsp의 키를 사용 -->
    <!-- ⚠️ 본인의 카카오 JS 키(91e7...)가 맞는지 확인하세요. -->
    <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=91e7ce40b4650e8a8c4f5fe947b382bb&libraries=services"></script>
    
    <!-- 🌟 [추가 2] 카카오 주소 검색(Postcode) 스크립트 -->
    <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

    <style>
        body {
            font-family: 'Inter', 'Arimo', 'Noto Sans KR', sans-serif;
        }
    </style>
</head>
<body class="bg-white">

    <!-- 🌟 전체 레이아웃 컨테이너 -->
    <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">

        <!-- 1. 헤더 (Header) -->
        <!-- 'bg-white'를 제거하여 body의 배경색(bg-gray-50)과 동일하게 만듭니다. -->
        <header class="relative flex justify-center items-center h-16 border-b border-gray-200">
            
            <!-- "메인" 링크 -->
            <div class="absolute left-0">
                <a href="main.jsp" class="text-base font-semibold text-gray-700 hover:text-red-600">메인</a>
            </div>
            
            <!-- "A+" 로고 -->
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
        </header>
        
        <!-- 2. 상품 등록 폼 -->
        <main class="w-full max-w-2xl mx-auto py-12">
            <div class="bg-white p-8 rounded-2xl shadow-lg border border-gray-200 bg-white">
                
                <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">상품 등록하기</h2>

                <% if ("true".equals(error)) { %>
                    <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg relative mb-6" role="alert">
                        <strong class="font-bold">등록 실패!</strong>
                        <span class="block sm:inline">모든 항목을 올바르게 입력했는지 확인해 주세요.</span>
                    </div>
                <% } %>
                
                <!-- 폼: AddProductServlet으로 POST 전송, 파일 포함(enctype) -->
                <form action="addproduct.do" method="POST" enctype="multipart/form-data">

                    <!-- 🌟 [수정] 1단계: 기본 정보 -->
                    <div id="form-step-1" class="space-y-6">
                        <!-- 상품명 -->
                        <div>
                            <label for="name" class="block text-sm font-bold text-gray-700">상품명</label>
                            <input type="text" name="name" id="name" required placeholder="상품 제목을 입력하세요"
                                   class="mt-1 block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500">
                        </div>

                        <!-- 가격 -->
                        <div>
                            <label for="price" class="block text-sm font-bold text-gray-700">가격</label>
                            <div class="relative mt-1">
                                <input type="number" name="price" id="price" required placeholder="0" min="0"
                                       class="block w-full px-4 py-3 pl-10 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500">
                                <span class="absolute left-4 top-3.5 text-gray-500 font-bold">₩</span>
                            </div>
                        </div>

                        <!-- 거래 희망 주소 -->
                        <div>
                            <label class="block text-sm font-bold text-gray-700">거래 희망 주소</label>
                            <div class="flex gap-2 mt-1">
                                <input type="text" name="addr" id="addr" required placeholder="[주소 검색] 버튼을 눌러주세요" readonly
                                       class="block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500 bg-gray-50">
                                <button type="button" onclick="execDaumPostcode()" 
                                        class="flex-shrink-0 px-4 py-3 bg-red-600 text-white font-bold rounded-lg hover:bg-red-700 transition-colors">
                                    주소 검색
                                </button>
                            </div>
                            <input type="text" id="full_addr" placeholder="상세 주소 (참고)" readonly
                                   class="mt-2 block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm bg-gray-50 text-sm">
                        </div>

                        <!-- 카테고리 -->
                        <div>
                            <label for="category" class="block text-sm font-bold text-gray-700">카테고리</label>
                            <select name="category" id="category" required
                                    class="mt-1 block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500 bg-white">
                                <option value="전자기기">전자기기</option>
                                <option value="전공책">전공책</option>
                                <option value="의류/신발">의류/신발</option>
                                <option value="가구/인테리어">가구/인테리어</option>
                            </select>
                        </div>

                        <!-- 상품 이미지 -->
                        <div>
                            <label for="image" class="block text-sm font-bold text-gray-700">상품 이미지</label>
                            <input type="file" name="image" id="image" accept="image/png, image/jpeg, image/gif" required
                                   class="mt-1 block w-full text-sm text-gray-500
                                          file:mr-4 file:py-2 file:px-4
                                          file:rounded-full file:border-0
                                          file:text-sm file:font-semibold
                                          file:bg-red-50 file:text-red-700
                                          hover:file:bg-red-100">
                        </div>

                        <!-- 🌟 [수정] 1단계 버튼: 다음 -->
                        <button type="button" id="next-btn"
                                class="w-full bg-red-600 text-white font-bold py-3 px-4 rounded-full text-lg hover:bg-red-700 transition-colors mt-8">
                            다음
                        </button>
                    </div>

                    <!-- 🌟 [신규] 2단계: 상품 설명 -->
                    <div id="form-step-2" class="hidden space-y-6">
                        <div>
                            <label for="description" class="block text-sm font-bold text-gray-700">상품 설명</label>
                            <textarea name="description" id="description" rows="10"
                                      placeholder="상품에 대한 설명을 입력해주세요. (구매 시기, 사용감, 특징 등)"
                                      class="mt-1 block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500"></textarea>
                        </div>
                        
                        <!-- 🌟 [신규] 2단계 버튼: 이전, 등록하기 -->
                        <div class="flex gap-4 mt-8">
                            <button type="button" id="prev-btn"
                                    class="w-1/3 bg-gray-500 text-white font-bold py-3 px-4 rounded-full text-lg hover:bg-gray-600 transition-colors">
                                이전
                            </button>
                            <button type="submit"
                                    class="w-2/3 bg-red-600 text-white font-bold py-3 px-4 rounded-full text-lg hover:bg-red-700 transition-colors">
                                등록하기
                            </button>
                        </div>
                    </div>
                    
                    <!-- 위도(lat), 경도(lng) hidden input -->
                    <input type="hidden" name="lat" id="product_lat" value="">
                    <input type="hidden" name="lng" id="product_lng" value="">
                    
                </form>
            </div>
        </main>

    </div> <!-- 🌟 전체 레이아웃 컨테이너 종료 -->

    <!-- 🌟 [추가] 주소 검색 및 지오코딩을 위한 JavaScript -->
    <script>
		 // 1단계, 2단계 폼과 버튼 요소 가져오기
	    const step1 = document.getElementById('form-step-1');
	    const step2 = document.getElementById('form-step-2');
	    const nextBtn = document.getElementById('next-btn');
	    const prevBtn = document.getElementById('prev-btn');
	
	    // '다음' 버튼 클릭 시
	    nextBtn.addEventListener('click', function() {
	        // 1단계의 모든 필수 입력 필드 유효성 검사
	        const inputsToValidate = step1.querySelectorAll('input[required], select[required]');
	        let allValid = true;
	
	        inputsToValidate.forEach(input => {
	            // 파일 입력이거나(files.length > 0) 일반 입력(value)인지 확인
	            let isValid = (input.type === 'file') ? (input.files.length > 0) : (input.value.trim() !== '');
	            
	            if (!isValid) {
	                allValid = false;
	                // 유효하지 않은 필드에 시각적 표시 (예: 빨간색 테두리)
	                input.classList.add('border-red-500', 'ring-red-500');
	            } else {
	                 input.classList.remove('border-red-500', 'ring-red-500');
	            }
	        });
	
	        if (allValid) {
	            // 모든 필드가 유효하면 1단계 숨기고 2단계 표시
	            step1.classList.add('hidden');
	            step2.classList.remove('hidden');
	        } else {
	            // 유효하지 않으면 사용자에게 알림
	            alert('1단계의 모든 필수 항목을 입력해주세요.');
	        }
	    });
	
	    // '이전' 버튼 클릭 시
	    prevBtn.addEventListener('click', function() {
	        // 2단계 숨기고 1단계 표시
	        step2.classList.add('hidden');
	        step1.classList.remove('hidden');
	    });
    
        // 카카오 지도 API의 '주소-좌표 변환 객체'를 생성합니다
        var geocoder = new kakao.maps.services.Geocoder();

        /**
         * '주소 검색' 버튼 클릭 시 카카오 주소 검색 팝업을 엽니다.
         */
        function execDaumPostcode() {
            new daum.Postcode({
                oncomplete: function(data) {
                    // 1. 사용자가 주소를 선택하면 (e.g., "서울 성동구 행당동 123-45")
                    
                    var addr = data.roadAddress || data.jibunAddress; // 도로명 주소 또는 지번 주소
                    var dong = data.bname; // 법정동 이름 (e.g., "행당동")

                    // 2. 폼의 '주소' 필드를 채웁니다.
                    //    - 지도에 표시될 '동' 이름을 name="addr" 필드에 저장
                    //    - 참고용 상세 주소도 표시
                    document.getElementById("addr").value = dong; 
                    document.getElementById("full_addr").value = "(" + data.zonecode + ") " + addr;

                    // 3. (중요) 선택된 주소를 '좌표'로 변환합니다.
                    geocoder.addressSearch(addr, function(result, status) {
                        
                        // 4. 좌표 변환에 성공하면
                        if (status === kakao.maps.services.Status.OK) {
                            var coords = new kakao.maps.LatLng(result[0].y, result[0].x);

                            // 5. hidden input 필드에 위도(lat)와 경도(lng) 값을 채워넣습니다.
                            document.getElementById("product_lat").value = coords.getLat();
                            document.getElementById("product_lng").value = coords.getLng();
                            
                        } else {
                            // 좌표 변환 실패 시
                            alert("주소로 좌표를 찾는 데 실패했습니다. 주소를 다시 검색해주세요.");
                            document.getElementById("addr").value = ""; 
                            document.getElementById("full_addr").value = "";
                            document.getElementById("product_lat").value = "";
                            document.getElementById("product_lng").value = "";
                        }
                    });
                }
            }).open();
        }
    </script>
</body>
</html>