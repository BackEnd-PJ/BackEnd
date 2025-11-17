package com.dongyang.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part; // ❗️ 파일 처리를 위한 Part 임포트
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import com.dongyang.dao.ProductDAO;
import com.dongyang.dto.MemberDTO;
import com.dongyang.dto.ProductDTO;

/**
 * 🌟 중요: @MultipartConfig 어노테이션
 * - 이 서블릿이 'multipart/form-data' (파일 업로드 포함) 요청을
 * 처리할 수 있음을 Tomcat 서버에 알립니다. 이게 없으면 request.getPart()가 작동하지 않습니다.
 */
@WebServlet("/addproduct.do")
@MultipartConfig 
public class AddProductServlet extends HttpServlet {

	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// GET 요청은 등록 폼으로 보냅니다. (권장)
		response.sendRedirect("add_product.jsp");
	}


	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		
		// ⭐️ [신규] 1. 로그인 및 이메일 인증 확인 (보안)
        HttpSession session = request.getSession(false);
        MemberDTO loginUser = null;

        if (session != null) {
            loginUser = (MemberDTO) session.getAttribute("memberId");
        }

        // 1-A: 로그아웃 상태이거나, 1-B: 인증을 안 했으면
        if (loginUser == null || !loginUser.isVerified()) {
            response.sendRedirect("main.jsp"); // 메인으로 리다이렉트
            return;
        }
        
		// 1. 폼 데이터 받기 (텍스트)
		request.setCharacterEncoding("UTF-8"); // 한글 깨짐 방지
		
		String name = request.getParameter("name");
		long price = Long.parseLong(request.getParameter("price"));
		String addr = request.getParameter("addr");
		String category = request.getParameter("category");
		double lat = Double.parseDouble(request.getParameter("lat"));
		double lng = Double.parseDouble(request.getParameter("lng"));
		String description = request.getParameter("description");
		
		// 2. 폼 데이터 받기 (이미지 파일)
		Part filePart = request.getPart("image"); // <input type="file" name="image">
		String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString(); // IE 호환성 및 경로 문제 방지

		// 3. 파일 저장 로직
		
		// 3-1. 서버에 저장될 *상대 경로* (이 경로를 DB에 저장합니다)
		//     (예: "uploads/products/my_image.jpg")
		String dbImageUrl = "images/products/" + fileName;

		// 3-2. 파일이 저장될 서버의 *절대 물리 경로*
		//     getServletContext().getRealPath("")는 현재 웹 애플리케이션의 루트 경로를 반환합니다.
		//     (예: C:\apache-tomcat\webapps\MyProject\ uploads\products)
		
		String uploadPath = getServletContext().getRealPath("") + "images" + File.separator + "products";
		
		// 3-3. (중요) 실제 저장 경로(디렉터리)가 존재하지 않으면 생성합니다.
		File uploadDir = new File(uploadPath);
		if (!uploadDir.exists()) {
			uploadDir.mkdirs(); // 하위 디렉터리까지 모두 생성
		}
		
		// 3-4. 파일을 서버의 지정된 경로에 저장합니다.
		try (InputStream fileContent = filePart.getInputStream()) {
			File targetFile = new File(uploadPath + File.separator + fileName);
			// 동일한 이름의 파일이 있으면 덮어쓰기(REPLACE_EXISTING)
			Files.copy(fileContent, targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
		} catch (IOException e) {
			e.printStackTrace();
			// 파일 저장 실패 시 에러 페이지로 리다이렉트
			response.sendRedirect("add_product.jsp?error=true");
			return;
		}

		// 4. ProductDTO 객체 생성 및 데이터 설정
		ProductDTO pdto = new ProductDTO();
		pdto.setName(name);
		pdto.setPrice(price);
		pdto.setAddr(addr);
		pdto.setCategory(category);
		pdto.setLat(lat);
		pdto.setLng(lng);
		pdto.setImageUrl(dbImageUrl); // ❗️ DB에는 상대 경로(dbImageUrl)를 저장
		pdto.setDescription(description);
		
		// 5. ProductDAO를 통해 DB에 삽입
		ProductDAO pdao = new ProductDAO();
		boolean success = pdao.addProduct(pdto);
		
		// 6. 결과에 따라 리다이렉트
		if (success) {
			// 성공 시, 새 상품이 추가된 지도 페이지(index.jsp)로 이동
			response.sendRedirect("index.jsp");
		} else {
			// 실패 시, 다시 등록 폼으로
			response.sendRedirect("add_product.jsp?error=true");
		}
	}

}