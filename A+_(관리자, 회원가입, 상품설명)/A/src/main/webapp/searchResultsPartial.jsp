<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.dongyang.dto.ProductDTO" %>

<%
    // 서블릿이 넘겨준 데이터를 받습니다.
    List<ProductDTO> products = (List<ProductDTO>) request.getAttribute("products");
%>

<% if (products != null && !products.isEmpty()) { %>
    <ul class="divide-y divide-gray-100">
        <% for (ProductDTO item : products) { %>
            <li class="p-3 flex items-center gap-3 hover:bg-gray-100 cursor-pointer">
                
                <svg class="w-4 h-4 text-gray-400 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                
                <span class="text-sm text-gray-900 font-medium"><%= item.getName() %></span>
            </li>
        <% } %>
    </ul>
<% } else { %>
    <%-- 검색 결과가 없는 경우 (스타일 적용) --%>
    <div class="p-3 text-sm text-gray-600 text-center font-medium">
        검색 결과가 없습니다.
    </div>
<% } %>