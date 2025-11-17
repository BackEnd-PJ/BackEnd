<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.dongyang.dto.MemberDTO" %>
<%@ page import="com.dongyang.dto.ProductDTO" %>
<%@ page import="com.dongyang.dao.MemberDAO" %>
<%@ page import="com.dongyang.dao.ProductDAO" %>
<%@ page import="java.util.List" %>
<%
    // --- 1. 관리자 권한 확인 (기존 로직 유지) ---
    MemberDTO loginUser = (MemberDTO) session.getAttribute("memberId");

    if (loginUser == null || !"admin".equals(loginUser.getRole())) { 
        request.setAttribute("errorMsg", "접근 권한이 없습니다."); 
        RequestDispatcher dispatcher = request.getRequestDispatcher("index.jsp");
        dispatcher.forward(request, response); 
        return; 
    }
    
    // --- 2. [신규] 관리자용 데이터 조회 ---
    MemberDAO mdao = new MemberDAO();
    List<MemberDTO> memberList = mdao.getAllMembers(); // 1단계에서 추가한 메서드
    
    ProductDAO pdao = new ProductDAO();
    List<ProductDTO> productList = pdao.getAllProducts(); // 기존 메서드 
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>A+ 관리자 페이지</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { font-family: 'Inter', 'Noto Sans KR', sans-serif; }
    </style>
</head>
<body class="bg-gray-100">

    <header class="bg-white shadow-sm border-b border-gray-200">
        <div class="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex justify-between items-center h-16">
            <a href="main.jsp" class="flex items-center gap-2">
                <span class="text-3xl font-bold text-red-600">A+ (Admin)</span>
            </a>
            <div class="flex items-center gap-4">
                <span class="font-bold text-gray-700"><%= loginUser.getName() %>님 (관리자)</span>
                <form action="logout.do" method="post">
                    <input type="submit" value="로그아웃" 
                           class="cursor-pointer bg-red-600 text-white font-bold px-4 py-2 rounded-full text-sm hover:bg-red-700">
                </form>
            </div>
        </div>
    </header>

    <main class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
    
        <section class="mb-12">
            <h2 class="text-2xl font-bold text-gray-900 mb-4">
                회원 관리 (총 <%= memberList.size() %> 명)
            </h2>
            <div class="bg-white shadow-lg rounded-lg overflow-hidden border border-gray-200">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">아이디</th>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">이름</th>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">이메일</th>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">역할</th>
                            <th class="px-6 py-3 text-right text-xs font-bold text-gray-600 uppercase tracking-wider">관리</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <% for (MemberDTO member : memberList) { %>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= member.getMemberid() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= member.getName() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= member.getEmail() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-bold <%= "admin".equals(member.getRole()) ? "text-red-600" : "text-blue-600" %>">
                                <%= member.getRole() %>
                            </td>
                            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                <%-- 관리자 본인 계정은 삭제 버튼 비활성화 --%>
                                <% if (!"admin".equals(member.getRole())) { %>
                                    <form action="admin.do" method="POST" onsubmit="return confirm('정말 이 회원을 삭제하시겠습니까?');">
                                        <input type="hidden" name="action" value="deleteMember">
                                        <input type="hidden" name="memberId" value="<%= member.getMemberid() %>">
                                        <button type="submit" class="text-red-600 hover:text-red-800 font-bold">삭제</button>
                                    </form>
                                <% } else { %>
                                    <span class="text-gray-400 font-bold">(관리자)</span>
                                <% } %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>

        <section>
            <h2 class="text-2xl font-bold text-gray-900 mb-4">
                상품 관리 (총 <%= productList.size() %> 개)
            </h2>
            <div class="bg-white shadow-lg rounded-lg overflow-hidden border border-gray-200">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">ID</th>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">상품명</th>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">가격</th>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">카테고리</th>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">주소(동)</th>
                            <th class="px-6 py-3 text-right text-xs font-bold text-gray-600 uppercase tracking-wider">관리</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                        <% for (ProductDTO product : productList) { %>
                        <tr>
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= product.getId() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700 truncate" style="max-width: 200px;"><%= product.getName() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= product.getPrice() %> 원</td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= product.getCategory() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= product.getAddr() %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                <form action="admin.do" method="POST" onsubmit="return confirm('정말 이 상품을 삭제하시겠습니까?');">
                                    <input type="hidden" name="action" value="deleteProduct">
                                    <input type="hidden" name="productId" value="<%= product.getId() %>">
                                    <button type="submit" class="text-red-600 hover:text-red-800 font-bold">삭제</button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </section>

    </main>
    
</body>
</html>