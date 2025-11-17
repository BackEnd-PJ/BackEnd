<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page isELIgnored="true" %>
<%-- ❗️ [수정] ProductDAO와 DTO를 함께 임포트 --%>
<%@ page import="com.dongyang.dao.SafeZoneDAO" %>
<%@ page import="com.dongyang.dto.SafeZoneDTO" %>
<%@ page import="com.dongyang.dao.ProductDAO" %>
<%@ page import="com.dongyang.dto.ProductDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.Gson" %>
<%
    // --- [수정] 상품과 안전구역 데이터를 모두 불러와 합치는 로직 ---
    
    // 1. ProductDAO를 통해 '모든 상품' 정보를 가져옵니다.
    ProductDAO productDao = new ProductDAO();
    List<ProductDTO> combinedList = productDao.getAllProducts(); // (메서드명은 본인 DAO에 맞게)

    // 2. SafeZoneDAO를 통해 '모든 안전 구역' 정보를 가져옵니다.
    SafeZoneDAO safeZoneDao = new SafeZoneDAO();
    List<SafeZoneDTO> zones = safeZoneDao.getAllSafeZones();
    
    // 3. 'SafeZoneDTO'를 'ProductDTO' 형태로 변환하여 'combinedList'에 추가합니다.
    for (SafeZoneDTO zone : zones) {
        ProductDTO safeZoneAsProduct = new ProductDTO();
        
        // SafeZoneDTO의 정보를 ProductDTO 필드에 매핑
        safeZoneAsProduct.setName(zone.getName()); // 예: "서울종로경찰서"
        safeZoneAsProduct.setAddr(zone.getAddr()); // 주소
        safeZoneAsProduct.setLat(zone.getLat());   // 위도
        safeZoneAsProduct.setLng(zone.getLng());   // 경도
        
        // '상품' DTO에만 있는 필드들은 '안전구역'에 맞게 채워줍니다.
        safeZoneAsProduct.setCategory("안전구역"); // ❗️ 카테고리 지정
        safeZoneAsProduct.setPrice(0);             // ❗️ 가격은 0
        safeZoneAsProduct.setImageUrl(null);       // ❗️ 이미지는 없음 (null)
        
        combinedList.add(safeZoneAsProduct);
    }
    
    // 4. '상품' + '안전구역'이 모두 담긴 Java List를 JSON 문자열로 변환합니다.
    Gson gson = new Gson();
    String locationsJson = gson.toJson(combinedList);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>A+ 지도 - 내 주변 상품</title>
  <script src="https://cdn.tailwindcss.com"></script>

  <style>
    /* ... (CSS는 완벽하므로 그대로 유지) ... */
    html, body { height: 100%; margin: 0; padding: 0; overflow: hidden; font-family: 'Inter', 'Noto Sans KR', sans-serif; }
    ::-webkit-scrollbar { width: 6px; }
    ::-webkit-scrollbar-thumb { background-color: #E5E7EB; border-radius: 10px; }
    ::-webkit-scrollbar-track { background-color: #F9FAFB; }
    .custom-marker { position: relative; }
    .custom-marker::after {
        content: ''; position: absolute; bottom: -15px; left: 50%; transform: translateX(-50%);
        width: 0; height: 0; border-top: 15px solid currentColor; border-left: 8px solid transparent; border-right: 8px solid transparent;
    }
    .tag-button.active {
      background-color: #EF4444; color: white; border-color: #EF4444;
    }
    input[type="range"] {
        -webkit-appearance: none; appearance: none;
        background: transparent; cursor: pointer;
    }
    input[type="range"]::-webkit-slider-runnable-track {
        background: #E5E7EB; height: 0.25rem; border-radius: 0.5rem;
    }
    input[type="range"]::-webkit-slider-thumb {
        -webkit-appearance: none; appearance: none;
        margin-top: -5px; background-color: #EF4444;
        height: 1rem; width: 1rem;
        border-radius: 50%; border: 2px solid white;
    }
    input[type="range"]::-moz-range-track {
        background: #E5E7EB; height: 0.25rem; border-radius: 0.5rem;
    }
    input[type="range"]::-moz-range-thumb {
        background-color: #EF4444;
        height: 1rem; width: 1rem;
        border-radius: 50%; border: 2px solid white;
    }
    @keyframes spin {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }
    .loading-spinner {
      border: 3px solid #f3f3f3; border-top: 3px solid #EF4444;
      border-radius: 50%;
      width: 20px; height: 20px;
      animation: spin 1s linear infinite;
    }
  </style>

  <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=91e7ce40b4650e8a8c4f5fe947b382bb"></script>
</head>
<body>
<div class="flex flex-col h-screen">

  <header class="w-full h-16 px-4 sm:px-6 lg:px-8 bg-white border-b border-gray-200 flex items-center justify-between flex-shrink-0">
    <a href="main.jsp" class="p-2 rounded-full hover:bg-gray-100" aria-label="메인으로 돌아가기">
      <svg class="w-6 h-6 text-gray-700" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
      </svg>
    </a>
    <div class="flex items-center gap-2">
      <span class="text-3xl font-bold text-red-600">A+</span>
    </div>
    <div class="w-10"></div>
  </header>

  <div class="flex flex-1 overflow-hidden">
    
    <div class="w-80 bg-white border-r border-gray-200 flex flex-col flex-shrink-0">
      <div class="p-3 bg-red-600 text-white">
        <h2 class="text-lg font-bold">내 주변 상품</h2>
        <p class="text-sm font-bold">
          반경 <span id="radiusDisplay">1km</span> 이내 <span id="markerCount">0</span>개
        </p>
      </div>
      <div class="p-3 bg-gray-50 border-b border-gray-200">
        <h3 class="text-sm font-bold text-gray-700 mb-2">카테고리별 상품 개수</h3>
        <div class="flex flex-wrap gap-2">
          <button onclick="filterPlaces('전체')" data-category="전체"
                  class="tag-button active text-xs font-bold px-3 py-1.5 bg-white rounded-full border border-gray-300 hover:bg-gray-100 transition">전체</button>
          
          <button onclick="filterPlaces('전공책')" data-category="전공책"
                  class="tag-button text-xs font-bold px-3 py-1.5 bg-white rounded-full border border-gray-300 hover:bg-gray-100 transition">전공책</button>
          <button onclick="filterPlaces('전자기기')" data-category="전자기기"
                  class="tag-button text-xs font-bold px-3 py-1.5 bg-white rounded-full border border-gray-300 hover:bg-gray-100 transition">전자기기</button>
          <button onclick="filterPlaces('의류/신발')" data-category="의류/신발"
                  class="tag-button text-xs font-bold px-3 py-1.5 bg-white rounded-full border border-gray-300 hover:bg-gray-100 transition">의류/신발</button>
          <button onclick="filterPlaces('가구/인테리어')" data-category="가구/인테리어"
                  class="tag-button text-xs font-bold px-3 py-1.5 bg-white rounded-full border border-gray-300 hover:bg-gray-100 transition">가구/인테리어</button>
          
          <button onclick="filterPlaces('안전구역')" data-category="안전구역"
                  class="tag-button text-xs font-bold px-3 py-1.5 bg-white rounded-full border border-gray-300 hover:bg-gray-100 transition">안전구역</button>
          </div>
      </div>
      <div id="menu_wrap" class="flex-1 overflow-y-auto">
        <ul id="placesList" class="divide-y divide-gray-100">
          </ul>
      </div>
    </div>

    <div id="map" class="flex-1 relative">
      
      <div class="absolute top-4 left-4 z-10 w-80 space-y-2">
          
          <div class="flex items-center space-x-2 bg-white p-2 rounded-full shadow-lg h-10">
            <svg class="w-4 h-4 text-gray-400 mx-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
            <input type="text" id="keyword" placeholder="상품명, 동, 카테고리 검색"
                   class="flex-1 w-full outline-none text-sm font-bold text-gray-700 placeholder-gray-500">
            <button onclick="searchPlaces()" class="hidden">검색</button>
          </div>
          
          <div class="p-3 bg-white rounded-lg shadow-lg">
            <h3 class="text-sm font-bold text-gray-700 mb-2">반경 설정</h3>
            <div class="flex items-center gap-2">
              <input type="range" id="radiusSlider" min="0" max="7000" step="100" value="1000"
                     class="w-full h-0.5 bg-gray-200 rounded-lg appearance-none cursor-pointer range-lg">
              <span id="radiusValue" class="text-sm font-bold text-red-600 whitespace-nowrap">1km</span>
            </div>
            <div class="flex justify-between text-xs text-gray-500 mt-1">
              <span>0km</span>
              <span>7km</span>
            </div>
          </div>
          
      </div>

      <div class="absolute top-4 right-4 z-10">
        <button id="my-location-btn" onclick="showCurrentLocation()"
                class="bg-white p-2.5 rounded-full shadow-lg hover:bg-gray-100 transition w-10 h-10 flex items-center justify-center">
          <svg class="w-5 h-5 text-gray-700" id="my-location-icon" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg">
            <path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd" />
          </svg>
          <div id="my-location-spinner" class="loading-spinner hidden" style="width:20px; height:20px;"></div>
        </button>
      </div>

    </div>
  </div>
</div>

<script>
// --- 1. 데이터 정의 (Data Definition) ---

const MARKER_ICONS = {
  "전공책": { emoji: "📚", color: "bg-blue-500" },
  "전자기기": { emoji: "💻", color: "bg-gray-700" },
  "의류/신발": { emoji: "👕", color: "bg-green-500" },
  "가구/인테리어": { emoji: "🛋️", color: "bg-yellow-500" },
  "안전구역": { emoji: "👮‍♂️", color: "bg-blue-600" }, 
  "전체": { emoji: "📌", color: "bg-red-500" }
};

// JSP로부터 '상품' + '안전구역' 데이터 주입
const locations = <%= locationsJson %>;


// --- 2. 전역 변수 (Global Variables) ---
// ▼▼▼ [수정] 중복 선언된 변수들 통합 ▼▼▼
let map, circle, centerPosition;
let markers = [];
let safeZoneCircles = []; // 안전구역 원(Circle)들을 저장할 배열
let currentCategory = '전체';
let myLocationMarker = null;
// ▲▲▲ [수정] ▲▲▲


// --- 3. 핵심 함수 (Core Functions) ---

function calculateDistance(pos1, pos2) {
  const lat1 = pos1.getLat(), lon1 = pos1.getLng();
  const lat2 = pos2.getLat(), lon2 = pos2.getLng();
  const R = 6371000;
  const toRad = d => d * Math.PI / 180;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function renderPlaces(list) {
  // 마커와 '안전구역 원'들을 모두 제거
  markers.forEach(m => m.setMap(null));
  safeZoneCircles.forEach(c => c.setMap(null));
  markers = [];
  safeZoneCircles = [];

  const listEl = document.getElementById('placesList');
  listEl.innerHTML = "";
  const radius = parseInt(document.getElementById('radiusSlider').value, 10);
  let visibleCount = 0;

  list.forEach(loc => {
    const pos = new kakao.maps.LatLng(loc.lat, loc.lng);
    const dist = calculateDistance(centerPosition, pos);
    
    if (dist <= radius) {
      // 2. 지도에 마커(오버레이) 표시
      const category = loc.category || '전체';
      const iconData = MARKER_ICONS[category] || MARKER_ICONS['전체'];
      
      // ▼▼▼ [수정] 마커 content 변수 복원 ▼▼▼
      const content = 
        '<div class="custom-marker flex items-center justify-center p-2 rounded-full shadow-lg ' + iconData.color + ' border-4 border-white" style="width:36px;height:36px;">' +
          '<span style="font-size:16px;">' + iconData.emoji + '</span>' +
        '</div>';
      // ▲▲▲ [수정] ▲▲▲
      
      const customOverlay = new kakao.maps.CustomOverlay({ position: pos, content: content, yAnchor: 1.0, zIndex: 3 });
      customOverlay.setMap(map);
      markers.push(customOverlay); // 핀 마커는 markers 배열에 추가

      // '안전구역'일 경우, 200m 반경의 원을 함께 표시
      if (loc.category === '안전구역') {
          const safeCircle = new kakao.maps.Circle({
              center: pos,       // 원의 중심좌표 (마커와 동일)
              radius: 200,     // 200미터 반경
              strokeWeight: 1, // 선 두께
              strokeColor: '#007BFF', // 파란색 선
              strokeOpacity: 0.8,
              fillColor: '#007BFF',   // 파란색 채우기
              fillOpacity: 0.1,    // 10% 투명도
              zIndex: 1            // 마커보다 뒤에 표시
          });
          safeCircle.setMap(map);
          safeZoneCircles.push(safeCircle); // 원(Circle)은 safeZoneCircles 배열에 추가
      }

      // 3. 사이드바에 목록 아이템 추가
      const el = document.createElement('li');
      
      // ▼▼▼ [수정] 사이드바 <li> 내용(el.innerHTML) 복원 ▼▼▼
      el.className = 'flex items-start p-3 gap-3 hover:bg-gray-50 cursor-pointer';
      
      const distKm = (dist / 1000).toFixed(1);
      
      const priceFormatted = (loc.price && loc.price > 0) 
                           ? parseInt(loc.price).toLocaleString('ko-KR') + '원' 
                           : '안전 거래 구역'; 
      
      const imageUrl = loc.imageUrl || 'https://placehold.co/80x80/f3f4f6/ccc?text=No+Img';
      
      const categoryTagColor = (loc.category === '안전구역') 
                             ? "bg-blue-100 text-blue-600" 
                             : "bg-red-100 text-red-600"; 

      el.innerHTML = 
        '<img src="' + imageUrl + '" alt="' + loc.name + '" class="w-16 h-16 rounded-lg object-cover flex-shrink-0" onerror="this.src=\'https://placehold.co/80x80/f3f4f6/ccc?text=Error\';">' +
        '<div class="flex-1 min-w-0">' +
          '<h3 class="text-sm font-bold text-gray-800 truncate">' + loc.name + '</h3>' + 
          '<p class="text-base font-bold text-red-600 mt-0.5">' + priceFormatted + '</p>' + 
          '<div class="flex items-center gap-1.5 text-xs text-gray-500 mt-1">' +
            '<svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path></svg>' +
            '<span class="font-bold truncate">' + (loc.addr || '주소 없음') + ' · ' + distKm + 'km</span>' +
          '</div>' +
          '<div class="mt-2">' +
            '<span class="text-xs font-bold px-2 py-0.5 ' + categoryTagColor + ' rounded-full">' + category + '</span>' +
          '</div>' +
        '</div>';
        
      el.onclick = function() {
          map.setCenter(pos);
          map.setLevel(5);
      };
      listEl.appendChild(el);
      // ▲▲▲ [수정] ▲▲▲
      
      visibleCount++;
    }
  });
  
  document.getElementById('markerCount').innerText = visibleCount;
}

function filterPlaces(category) {
  // (기존 코드와 동일)
  currentCategory = category;
  document.querySelectorAll('.tag-button').forEach(btn => {
    if (btn.dataset.category === category) {
      btn.classList.add('active');
    } else {
      btn.classList.remove('active');
    }
  });
  searchPlaces();
}

function searchPlaces() {
  // (기존 코드와 동일)
  const keyword = document.getElementById('keyword').value.toLowerCase();
  
  const filtered = locations.filter(loc => {
    const categoryMatch = (currentCategory === '전체' || loc.category === currentCategory);
    
    const keywordMatch = (
        loc.name.toLowerCase().includes(keyword) ||
        (loc.addr && loc.addr.toLowerCase().includes(keyword)) ||
        loc.category.toLowerCase().includes(keyword)
    );
    
    return categoryMatch && keywordMatch;
  });
  
  renderPlaces(filtered);
}

function showCurrentLocation() {
  // (기존 코드와 동일)
  const icon = document.getElementById('my-location-icon');
  const spinner = document.getElementById('my-location-spinner');

  icon.classList.add('hidden');
  spinner.classList.remove('hidden');

  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(pos => {
      const lat = pos.coords.latitude;
      const lon = pos.coords.longitude;
      centerPosition = new kakao.maps.LatLng(lat, lon);
      
      map.panTo(centerPosition);
      circle.setPosition(centerPosition);
      
      if (myLocationMarker) {
        myLocationMarker.setPosition(centerPosition);
      } else {
        myLocationMarker = new kakao.maps.Marker({ 
            map: map, 
            position: centerPosition, 
            title: "현재 위치" 
        });
      }
      
      searchPlaces();
      
      icon.classList.remove('hidden');
      spinner.classList.add('hidden');
      
    }, () => {
      alert("위치 정보를 가져오는 데 실패했습니다. 위치 정보 접근을 허용했는지 확인해주세요.");
      icon.classList.remove('hidden');
      spinner.classList.add('hidden');
    });
  } else {
    alert("브라우저가 Geolocation을 지원하지 않습니다.");
    icon.classList.remove('hidden');
    spinner.classList.add('hidden');
  }
}

function initMap() {
  // (기존 코드와 동일)
  const container = document.getElementById('map');
  centerPosition = new kakao.maps.LatLng(37.5633, 127.0371); // 왕십리역 근처
  map = new kakao.maps.Map(container, { center: centerPosition, level: 7 });
  
  map.setMinLevel(1);
  map.setMaxLevel(13);

  circle = new kakao.maps.Circle({
    center: centerPosition, 
    radius: 1000, 
    strokeWeight: 2, 
    strokeColor: '#EF4444',
    strokeOpacity: 0.8, 
    fillColor: '#FEE2E2',
    fillOpacity: 0.3
  });
  circle.setMap(map);

  filterPlaces('전체');
}

// --- 4. 이벤트 리스너 (Event Listeners) ---
document.addEventListener("DOMContentLoaded", () => {
  
  // (기존 코드와 동일)
  const radiusSlider = document.getElementById('radiusSlider');
  const radiusValue = document.getElementById('radiusValue');
  const radiusDisplay = document.getElementById('radiusDisplay');
  
  radiusSlider.addEventListener('input', function() {
    const radius = parseInt(this.value, 10);
    const radiusText = radius >= 1000 ? (radius/1000).toFixed(1) + 'km' : radius + 'm';
    
    radiusValue.innerText = radiusText;
    radiusDisplay.innerText = radiusText;
    
    circle.setRadius(radius);
    searchPlaces(); 
  });

  document.getElementById('keyword').addEventListener('keyup', function(e) {
      if (e.key === 'Enter') {
          searchPlaces();
      }
  });

  // 지도 초기화 함수 호출
  initMap();
});
</script>
</body>
</html>