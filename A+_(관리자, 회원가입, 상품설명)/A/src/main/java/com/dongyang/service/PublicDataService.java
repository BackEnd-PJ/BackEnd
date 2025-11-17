package com.dongyang.service; // 👈 서비스 패키지

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import com.dongyang.dao.SafeZoneDAO; // 👈 DAO 임포트
import com.dongyang.dto.ApiResponse; // 👈 DTO 임포트
import com.dongyang.dto.KakaoAddressResponse; // 👈 (신규) 카카오 DTO 임포트
import com.dongyang.dto.KakaoDocument;      // 👈 (신규) 카카오 DTO 임포트
import com.dongyang.dto.PoliceStation; // 👈 DTO 임포트
import com.google.gson.Gson;

public class PublicDataService {

    // 🚨 [필수] 카카오 개발자 사이트의 "REST API 키"
    private static final String KAKAO_API_KEY = "86491ca04fc14069f8701a512734f839"; // 👈 [필수] 카카오 REST API 키 입력

    
    /**
     * 메인 로직: 공공 API 호출 -> 카카오 API로 좌표 변환 -> DAO로 DB 저장
     */
    public int setupSafeZoneData() throws Exception {
        
        // 🐞 [버그 수정 1] API 키 끝의 \r\n (줄바꿈) 제거
        String apiKey = "46010b20c66bcb47e5346a886bda43ebd62748d8b42d68fb3cbb7dd57387843f";
        String apiUrl = "https://api.odcloud.kr/api/15124966/v1/uddi:345a2432-5fee-4c49-a353-80b62496a43b?page=1&perPage=1000&returnType=JSON";

        String encodedKey = URLEncoder.encode(apiKey, StandardCharsets.UTF_8);
        
        // 🐞 [버그 수정 2] URL 파라미터 연결을 '?'가 아닌 '&'로 수정
        String fullUrl = String.format(
            "%s&serviceKey=%s", // 👈 '?'가 아닌 '&'로 serviceKey를 추가
            apiUrl, 
            encodedKey
        );
        
        // --- 1. 공공 API 호출 ---
        // (API 호출 로직을 callApi 헬퍼 메소드로 분리)
        String jsonResponse = this.callApi(fullUrl, null);
        
        if (jsonResponse == null) {
            throw new RuntimeException("공공 API 호출 실패");
        }

        // --- 2. Gson 파싱 (경찰서 리스트) ---
        Gson gson = new Gson();
        ApiResponse apiResponseDto = gson.fromJson(jsonResponse, ApiResponse.class);
        List<PoliceStation> stations = apiResponseDto.getData();

        // --- 3. DAO 준비 ---
        SafeZoneDAO dao = new SafeZoneDAO();
        int successCount = 0;
        
        System.out.println("--- [A+ DB 저장 작업 시작] ---");

        // --- 4. (핵심) 반복문 ---
        for (PoliceStation station : stations) {
            String name = station.getStationName();
            String address = station.getAddress();

            // -----------------------------------------------------------------
            // ✅ [TODO 1] 카카오 Geocoder API 호출
            // -----------------------------------------------------------------
            KakaoDocument coords = this.getCoordinatesFromAddress(address);
            
            double latitude = 0.0;
            double longitude = 0.0;

            if (coords != null) {
                latitude = coords.getLatitude();
                longitude = coords.getLongitude();
                System.out.println("DAO 호출: " + name + " / " + address);
                System.out.println(" -> 좌표 변환 성공: " + latitude + ", " + longitude);
            } else {
                System.out.println("DAO 호출: " + name + " / " + address);
                System.out.println(" -> ❗️좌표 변환 실패. (주소 불명확) -> DB 저장 건너뜀");
                continue; // 좌표 없으면 DB에 저장하지 않음
            }
            
            // -----------------------------------------------------------------
            // ✅ [TODO 2] MySQL DB에 INSERT
            // -----------------------------------------------------------------
            int result = dao.insertSafeZone(name, address, latitude, longitude);
            
            if(result > 0) {
                 successCount++;
                 System.out.println(" -> DB 저장 완료.");
            } else {
                 System.out.println(" -> ❗️DB 저장 실패. (DAO 로직 확인)");
            }
            
            // -----------------------------------------------------------------
            // ⚠️ [필수] 카카오 API 속도 제한 (Rate Limit) 방지
            // -----------------------------------------------------------------
            Thread.sleep(200); // 0.2초 대기
        }
        
        System.out.println("--- [A+ DB 저장 작업 완료] (총 " + successCount + "건) ---");
        return successCount; // 컨트롤러에게 성공 건수 반환
    }

    
    /**
     * [헬퍼 메소드 1] (신규 추가)
     * 주소(String)를 받아서 카카오 API를 호출하고 좌표(KakaoDocument)를 반환
     */
    private KakaoDocument getCoordinatesFromAddress(String address) throws IOException {
        String kakaoApiUrl = "https://dapi.kakao.com/v2/local/search/address.json";
        String encodedAddress = URLEncoder.encode(address, StandardCharsets.UTF_8);
        String fullUrl = String.format("%s?query=%s", kakaoApiUrl, encodedAddress);
        
        // 카카오 API는 'Authorization' 헤더가 필수
        String authHeader = "KakaoAK " + KAKAO_API_KEY; 

        // --- 1. 카카오 API 호출 ---
        String jsonResponse = this.callApi(fullUrl, authHeader);
        if (jsonResponse == null) {
            return null;
        }

        // --- 2. Gson 파싱 (카카오 응답) ---
        Gson gson = new Gson();
        KakaoAddressResponse kakaoResponse = gson.fromJson(jsonResponse, KakaoAddressResponse.class);
        
        // --- 3. 좌표 추출 ---
        if (kakaoResponse != null && kakaoResponse.getDocuments() != null && !kakaoResponse.getDocuments().isEmpty()) {
            // 검색 결과 중 첫 번째 결과의 좌표를 반환
            return kakaoResponse.getDocuments().get(0); 
        }
        
        return null; // 변환 실패
    }

    
    /**
     * [헬퍼 메소드 2] (신규 추가 - 코드 중복 제거)
     * URL과 인증 헤더(선택)를 받아 API를 호출하고, 응답 문자열을 반환
     */
    private String callApi(String fullUrl, String authorizationHeader) throws IOException {
        URL url = new URL(fullUrl);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        
        // (필요한 경우 인증 헤더 추가)
        if (authorizationHeader != null && !authorizationHeader.isEmpty()) {
            conn.setRequestProperty("Authorization", authorizationHeader);
        }
        
        conn.setRequestProperty("Accept", "application/json");

        if (conn.getResponseCode() != 200) {
            System.err.println("API 호출 실패: " + conn.getResponseCode() + " (URL: " + fullUrl + ")");
            return null; // 실패 시 null 반환
        }

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        String line;
        while ((line = br.readLine()) != null) {
            sb.append(line);
        }
        br.close();
        conn.disconnect();
        
        return sb.toString();
    }
}