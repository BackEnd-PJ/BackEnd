package com.dongyang.dao;

import java.sql.*;
import java.util.*;

import com.dongyang.dto.MemberDTO;
import com.dongyang.util.JdbcConnectUtil;

public class MemberDAO {
	// ✅ 로그인 체크 메서드 (SELECT)
	public MemberDTO loginCheck(String memberid, String password) {
		
			Connection con=null;
			PreparedStatement pstmt=null;
			ResultSet rs=null;
			MemberDTO loginCheck=null;
			try {
				con=JdbcConnectUtil.getConnection();
				// ⭐️ SQL: ID와 PW가 일치하는 회원을 찾습니다.
				pstmt=con.prepareStatement("select * from membertbl where memberid=? and password=?;");
				pstmt.setString(1, memberid);
				pstmt.setString(2, password);		
				
				rs=pstmt.executeQuery();
				if (rs.next()) {
		            // 결과가 있으면 (로그인 성공) DTO 객체에 DB에서 가져온 정보를 설정합니다.
					loginCheck = new MemberDTO();
					loginCheck.setMemberid(rs.getString("memberid"));
					loginCheck.setPassword(rs.getString("password"));
		            
		            // ⭐️ DB에서 읽어온 실제 역할(Role)을 설정합니다.
					loginCheck.setRole(rs.getString("role")); 
					loginCheck.setName(rs.getString("name"));
					loginCheck.setEmail(rs.getString("email"));
					loginCheck.setVerified(rs.getBoolean("is_verified"));
		        }
				
			} catch (SQLException e) {
				e.printStackTrace();
			} finally {
				JdbcConnectUtil.close(con, pstmt, rs);
			}
			return loginCheck;
	}
	
	// ✅ 회원가입 메서드 (INSERT)
	public int registerMember(MemberDTO mdto) {
	    int result = 0;
	    Connection con = null;
	    PreparedStatement pstmt = null;

	    String id = mdto.getMemberid();
	    String pw = mdto.getPassword();
	    String name = mdto.getName();
	    String email = mdto.getEmail();

	    // ⭐️ SQL: 회원 정보를 DB에 삽입합니다.
	    String sql = "INSERT INTO memberTbl (memberid, password, name, email, role, is_verified) VALUES (?, ?, ?, ?, 'user', 0)";
	    
	    try {
	        con = JdbcConnectUtil.getConnection();
	        
	        pstmt = con.prepareStatement(sql);
	        pstmt.setString(1, id); 
	        pstmt.setString(2, pw); 
	        pstmt.setString(3, name); 
	        pstmt.setString(4, email); 
	        
	        result = pstmt.executeUpdate(); // 1이 반환되면 성공

	    } catch (SQLException e) {
	        System.out.println("!! 회원가입 DB 처리 중 에러");
	        e.printStackTrace();
	    } finally {
	    	JdbcConnectUtil.close(con, pstmt); 
	    }
	    
	    return result;
	}
	
	/**
     *  회원 상태를 '인증됨'으로 업데이트
     */
    public boolean activateMember(String email) {
        String sql = "UPDATE memberTbl SET is_verified = 1 WHERE email = ?";
        Connection con = null;
        PreparedStatement pstmt = null;
        int result = 0;

        try {
            con = JdbcConnectUtil.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, email);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JdbcConnectUtil.close(con, pstmt);
        }
        return result > 0;
    }
    
	
	/**
     * [관리자] 모든 회원 목록을 조회합니다.
     */
	public List<MemberDTO> getAllMembers() {
        List<MemberDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM membertbl ORDER BY role DESC, memberid ASC";
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            con = JdbcConnectUtil.getConnection();
            pstmt = con.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                MemberDTO dto = new MemberDTO();
                dto.setMemberid(rs.getString("memberid"));
                dto.setName(rs.getString("name"));
                dto.setEmail(rs.getString("email"));
                dto.setRole(rs.getString("role"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JdbcConnectUtil.close(con, pstmt, rs);
        }
        return list;
    }
	
	/**
     * [관리자] ID로 회원을 삭제합니다.
     * (카카오 사용자는 memberid가 숫자 문자열입니다)
     */
    public boolean deleteMember(String memberId) {
        String sql = "DELETE FROM membertbl WHERE memberid = ?";
        Connection con = null;
        PreparedStatement pstmt = null;
        int result = 0;

        try {
            con = JdbcConnectUtil.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, memberId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JdbcConnectUtil.close(con, pstmt);
        }
        return result > 0;
    }
    
	/**
     * 카카오 ID로 회원을 조회하고, 없으면 새로 가입시키는 메서드
     * @param kakaoUser (카카오에서 받은 id, nickname, email이 담긴 DTO)
     * @return DB에 저장된 최종 회원 정보가 담긴 MemberDTO 객체
     */
    public MemberDTO findOrCreateKakaoUser(MemberDTO kakaoUser) {
        // 1. 먼저 카카오 ID로 기존 회원이 있는지 조회합니다.
        String selectSql = "SELECT * FROM membertbl WHERE memberid = ?";
        MemberDTO existingUser = null;

        try (Connection conn = JdbcConnectUtil.getConnection();
             PreparedStatement pstmtSelect = conn.prepareStatement(selectSql)) {
            
            pstmtSelect.setString(1, kakaoUser.getMemberid());
            try (ResultSet rs = pstmtSelect.executeQuery()) {
                if (rs.next()) { // 이미 가입된 회원이라면
                    existingUser = new MemberDTO();
                    existingUser.setMemberid(rs.getString("memberid"));
                    existingUser.setPassword(rs.getString("password"));
                    existingUser.setName(rs.getString("name"));
                    existingUser.setRole(rs.getString("role"));
                    existingUser.setEmail(rs.getString("email"));
                    existingUser.setVerified(rs.getBoolean("is_verified"));
                    return existingUser; // 기존 회원 정보를 반환하고 종료
                }
            }

            // 2. 여기에 도달했다면 가입된 회원이 없다는 의미이므로, 새로 INSERT 합니다.
            String insertSql = "INSERT INTO memberTbl (memberid, password, name, email, role, is_verified) VALUES (?, ?, ?, ?, 'user', 0)";
            try (PreparedStatement pstmtInsert = conn.prepareStatement(insertSql)) {
                pstmtInsert.setString(1, kakaoUser.getMemberid());
                pstmtInsert.setString(2, "kakao_login_password"); // 소셜 로그인용 임시 비밀번호
                pstmtInsert.setString(3, kakaoUser.getName());
                pstmtInsert.setString(4, kakaoUser.getEmail()); // 이메일 정보도 함께 저장
                
                if (pstmtInsert.executeUpdate() > 0) {
                    // INSERT 성공 시, 방금 가입시킨 회원 정보를 그대로 반환
                	kakaoUser.setVerified(false); // ⭐️ DTO에도 '미인증' 상태 반영
                    return kakaoUser;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null; // 모든 과정에서 실패 시 null 반환
    }
    
    /**
     * ⭐️ [신규] 사용자의 이메일 주소를 업데이트합니다.
     * (카카오 로그인 사용자가 대학생 이메일을 나중에 입력할 때 사용)
     */
    public boolean updateEmail(String memberId, String email) {
        String sql = "UPDATE memberTbl SET email = ? WHERE memberid = ?";
        Connection con = null;
        PreparedStatement pstmt = null;
        int result = 0;

        try {
            con = JdbcConnectUtil.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, memberId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JdbcConnectUtil.close(con, pstmt);
        }
        return result > 0;
    }

}