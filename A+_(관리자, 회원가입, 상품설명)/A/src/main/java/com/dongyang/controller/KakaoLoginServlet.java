package com.dongyang.controller;

import com.dongyang.dao.MemberDAO;
import com.dongyang.dto.MemberDTO;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

@WebServlet("/kakao_login.do")
public class KakaoLoginServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");
        if (code == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        try {
            // 1. 액세스 토큰 받기
            String accessToken = getAccessToken(code);

            // 2. 사용자 정보 받기
            JsonObject userInfo = getUserInfo(accessToken);

            // 3. 받은 사용자 정보를 DTO에 담기
            MemberDTO kakaoUser = new MemberDTO();
            kakaoUser.setMemberid(userInfo.get("id").getAsString());
            kakaoUser.setName(userInfo.getAsJsonObject("properties").get("nickname").getAsString());
            
            // 이메일은 선택 동의 항목이므로, 정보가 있을 때만 가져오도록 처리
            if (userInfo.getAsJsonObject("kakao_account").has("email")) {
                kakaoUser.setEmail(userInfo.getAsJsonObject("kakao_account").get("email").getAsString());
            }

            // 4. DAO에 작업을 위임하여 DB 처리 및 최종 DTO 받기
            MemberDAO dao = new MemberDAO();
            MemberDTO loginMember = dao.findOrCreateKakaoUser(kakaoUser);

            // 5. 세션에 완전한 MemberDTO 객체를 저장 (ClassCastException 해결!)
            if (loginMember != null) {
                HttpSession session = request.getSession();
                session.setAttribute("loginCheck", "kakao"); 
                session.setAttribute("memberId", loginMember);
                response.sendRedirect("main.jsp");
            } else {
                request.setAttribute("errorMsg", "카카오 로그인에 실패했습니다.");
                request.getRequestDispatcher("main.jsp").forward(request, response);
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("main.jsp");
        }
    }

    // --- 아래의 두 메서드(getAccessToken, getUserInfo)는 그대로 유지합니다. ---
    // 단, 하드코딩된 API 키와 Redirect URI는 web.xml로 옮기는 것을 강력히 권장합니다.
    private String getAccessToken(String code) throws IOException {
        String accessToken = "";
        String reqURL = "https://kauth.kakao.com/oauth/token";
        
        // web.xml에서 설정값 가져오기 (권장)
        // String clientId = getServletContext().getInitParameter("KAKAO_REST_API_KEY");
        // String redirectUri = getServletContext().getInitParameter("KAKAO_REDIRECT_URI");

        URL url = new URL(reqURL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);

        BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(conn.getOutputStream()));
        StringBuilder sb = new StringBuilder();
        sb.append("grant_type=authorization_code");
        sb.append("&client_id=e6f843146e41aaf81175b7973ef2827b"); // ❗️❗️ 본인의 REST API 키 ❗️❗️
        sb.append("&redirect_uri=http://localhost:8080/A/kakao_login.do"); // ❗️❗️ Redirect URI (포트와 프로젝트 이름 확인) ❗️❗️
        sb.append("&code=" + code);
        bw.write(sb.toString());
        bw.flush();

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String line = "";
        String result = "";
        
        while ((line = br.readLine()) != null) {
            result += line;
        }

        JsonElement element = JsonParser.parseString(result);
        accessToken = element.getAsJsonObject().get("access_token").getAsString();
        
        br.close();
        bw.close();
        
        return accessToken;
    }

    private JsonObject getUserInfo(String accessToken) throws IOException {
        String reqURL = "https://kapi.kakao.com/v2/user/me";
        URL url = new URL(reqURL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);

        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String line = "";
        String result = "";

        while ((line = br.readLine()) != null) {
            result += line;
        }

        JsonElement element = JsonParser.parseString(result);
        return element.getAsJsonObject();
    }
}