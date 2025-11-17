package com.dongyang.controller; // 👈 컨트롤러 패키지

import java.io.IOException;

import com.dongyang.service.PublicDataService; // 👈 Service 임포트

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/setupSafeZones")
public class DataSetupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // 1. Service 객체 생성
        PublicDataService service = new PublicDataService();
        String message = "";
        int count = 0;

        try {
            // 2. [지시] Service에게 데이터 셋업 작업을 지시
            count = service.setupSafeZoneData(); // (핵심 로직은 Service가 다 함)
            
            message = "성공: 총 " + count + "개의 안전 구역 DB 저장 완료!";
            
        } catch (Exception e) {
            e.printStackTrace();
            message = "실패: " + e.getMessage();
        }
        
        // 3. [결과 전달] View(JSP)로 전달할 데이터를 request에 저장
        request.setAttribute("setupMessage", message);
        request.setAttribute("setupCount", count);

        // 4. [포워딩] View(JSP)로 화면을 넘김
        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/setupResult.jsp"); // 👈 JSP 경로
        dispatcher.forward(request, response);
    }
}