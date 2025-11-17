package com.dongyang.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.time.LocalDateTime;

import com.dongyang.dto.EmailVerifyDTO;
import com.dongyang.util.JdbcConnectUtil;

public class EmailVerifyDAO {

    /**
     * (Step 2) 인증 코드를 DB에 저장 (트랜잭션 사용)
     * (기존 코드를 삭제하고 새 코드를 삽입)
     */
    public boolean insertOrUpdateCode(String email, String code) {
        String deleteSql = "DELETE FROM email_verifications WHERE email = ?";
        String insertSql = "INSERT INTO email_verifications (email, code, expires_at) VALUES (?, ?, ?)";
        
        Connection con = null;
        PreparedStatement pstmtDelete = null;
        PreparedStatement pstmtInsert = null;
        int insertResult = 0;
        
        Timestamp expiresAt = Timestamp.valueOf(LocalDateTime.now().plusMinutes(5)); // 5분 후 만료

        try {
            con = JdbcConnectUtil.getConnection();
            con.setAutoCommit(false); // 트랜잭션 시작

            // 1. 기존 코드 삭제
            pstmtDelete = con.prepareStatement(deleteSql);
            pstmtDelete.setString(1, email);
            pstmtDelete.executeUpdate();

            // 2. 새 코드 삽입
            pstmtInsert = con.prepareStatement(insertSql);
            pstmtInsert.setString(1, email);
            pstmtInsert.setString(2, code);
            pstmtInsert.setTimestamp(3, expiresAt);
            insertResult = pstmtInsert.executeUpdate();
            
            con.commit(); // 트랜잭션 커밋
            
        } catch (Exception e) {
            try {
                if (con != null) con.rollback(); // 오류 시 롤백
            } catch (Exception se) { se.printStackTrace(); }
            e.printStackTrace();
        } finally {
            // 자원 해제
            try {
                if (pstmtDelete != null) pstmtDelete.close();
                if (pstmtInsert != null) pstmtInsert.close();
                if (con != null) con.close();
            } catch (Exception e) { e.printStackTrace(); }
        }
        return insertResult > 0;
    }

    /**
     * (Step 4/5) 이메일, 코드, 만료 시간을 검증
     */
    public EmailVerifyDTO getValidCode(String email, String code) {
        // ⭐️ SQL 컬럼명 'code'로 수정, 만료 시간 검증
        String sql = "SELECT * FROM email_verifications WHERE email = ? AND code = ? AND expires_at > NOW()";
        
        Connection con = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        EmailVerifyDTO dto = null;

        try {
            con = JdbcConnectUtil.getConnection();
            pstmt = con.prepareStatement(sql);
            pstmt.setString(1, email);
            pstmt.setString(2, code);
            rs = pstmt.executeQuery();

            if (rs.next()) { // 유효한 코드
                dto = new EmailVerifyDTO();
                dto.setEmail(rs.getString("email"));
                dto.setCode(rs.getString("code"));
                dto.setExpiresAt(rs.getTimestamp("expires_at"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            JdbcConnectUtil.close(con, pstmt, rs);
        }
        return dto; // 유효하면 DTO, 아니면 null
    }
}