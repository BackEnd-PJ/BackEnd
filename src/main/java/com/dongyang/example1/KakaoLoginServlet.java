package com.dongyang.example1;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/kakao_login.do")
public class KakaoLoginServlet extends HttpServlet {

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String code = request.getParameter("code");
        String accessToken = getAccessToken(code);

        // 액세스 토큰을 이용하여 사용자 정보 가져오기
        JsonObject userInfo = getUserInfo(accessToken);
        
        // 사용자 정보 파싱
        long kakaoId = userInfo.get("id").getAsLong();
        String nickname = userInfo.getAsJsonObject("properties").get("nickname").getAsString();
        // (선택) 이메일 정보 파싱
        // String email = userInfo.getAsJsonObject("kakao_account").get("email").getAsString();

        // DB 연동하여 회원 정보 확인 및 자동 가입
        try {
            // DB 연결 정보
            String dbUrl = "jdbc:mysql://localhost:3306/testdb?serverTimezone=UTC";
            String dbId = "root";
            String dbPw = "qkdwnsgk";
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbUrl, dbId, dbPw);

            // 1. 카카오 ID로 기존 회원인지 확인
            String sql_select = "SELECT * FROM members WHERE id = ?";
            PreparedStatement pstmt_select = conn.prepareStatement(sql_select);
            pstmt_select.setString(1, String.valueOf(kakaoId));
            ResultSet rs = pstmt_select.executeQuery();

            if (!rs.next()) { // DB에 정보가 없으면, 자동 회원가입
                String sql_insert = "INSERT INTO members (id, password, name, role) VALUES (?, ?, ?, ?)";
                PreparedStatement pstmt_insert = conn.prepareStatement(sql_insert);
                pstmt_insert.setString(1, String.valueOf(kakaoId));
                pstmt_insert.setString(2, "kakao_login_password"); // 소셜 로그인은 비밀번호가 무의미하므로 임의값 저장
                pstmt_insert.setString(3, nickname);
                pstmt_insert.setString(4, "user");
                pstmt_insert.executeUpdate();
                pstmt_insert.close();
            }
            
            rs.close();
            pstmt_select.close();
            conn.close();
            
            // 2. 세션 생성 및 로그인 처리
            HttpSession session = request.getSession();
            session.setAttribute("loginUser", nickname);
            session.setAttribute("userRole", "user"); // 카카오 로그인 사용자는 모두 'user'로 설정
            
            response.sendRedirect("main.jsp");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp"); // 에러 발생 시 로그인 페이지로
        }
    }

    // 인증 코드로 액세스 토큰을 요청하는 메서드
    private String getAccessToken(String code) throws IOException {
        String accessToken = "";
        String reqURL = "https://kauth.kakao.com/oauth/token";
        
        URL url = new URL(reqURL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);

        // POST 요청에 필요한 파라미터 스트림을 통해 전송
        BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(conn.getOutputStream()));
        StringBuilder sb = new StringBuilder();
        sb.append("grant_type=authorization_code");
        sb.append("&client_id=f4ac314dd5c4525d19387589eb2da5ad"); // ❗️❗️ 본인의 REST API 키 ❗️❗️
        sb.append("&redirect_uri=http://localhost:8000/TestLogin/kakao_login.do"); // ❗️❗️ Redirect URI ❗️❗️
        sb.append("&code=" + code);
        bw.write(sb.toString());
        bw.flush();

        // 결과 코드가 200이라면 성공
        // int responseCode = conn.getResponseCode();
        
        // 요청을 통해 얻은 JSON 타입의 Response 메시지 읽어오기
        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        String line = "";
        String result = "";
        
        while ((line = br.readLine()) != null) {
            result += line;
        }

        // Gson 라이브러리로 JSON 파싱
        JsonElement element = JsonParser.parseString(result);
        accessToken = element.getAsJsonObject().get("access_token").getAsString();
        
        br.close();
        bw.close();
        
        return accessToken;
    }

    // 액세스 토큰으로 사용자 정보를 요청하는 메서드
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