package com.dongyang.dto;

import java.sql.Timestamp;

public class EmailVerifyDTO {
    private String email;
    private String code; 
    private Timestamp expiresAt;
    
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }
    public Timestamp getExpiresAt() { return expiresAt; }
    public void setExpiresAt(Timestamp expiresAt) { this.expiresAt = expiresAt; }
}