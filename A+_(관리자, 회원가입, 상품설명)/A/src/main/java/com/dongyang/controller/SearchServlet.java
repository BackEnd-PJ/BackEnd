package com.dongyang.controller; // ❗️ 본인의 컨트롤러 패키지

import java.io.IOException;
import java.util.List;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import com.dongyang.dao.ProductDAO;
import com.dongyang.dto.ProductDTO;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        // 1. "keyword" 파라미터 가져오기
        String keyword = request.getParameter("keyword");

        // 2. DAO를 이용해 DB에서 상품 검색
        ProductDAO dao = new ProductDAO();
        List<ProductDTO> productList = dao.searchProductsByName(keyword);
        
        // 3. 검색 결과(productList)와 검색어(keyword)를 request에 저장
        request.setAttribute("products", productList);
        request.setAttribute("keyword", keyword);
        
        // 4. 검색 결과 '조각' 페이지로 포워딩
        RequestDispatcher dispatcher = request.getRequestDispatcher("_searchResultsPartial.jsp");
        dispatcher.forward(request, response);
    }
}