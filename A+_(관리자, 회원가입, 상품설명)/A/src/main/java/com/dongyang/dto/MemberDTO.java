package com.dongyang.dto;

public class MemberDTO {
	private String memberid;
	private String password;
	private String name;
	private String email;
	private String role;
	private boolean isVerified;
	
	// ✅ Getter 및 Setter 메서드들 (생략)
	public String getMemberid() {
		return memberid;
	}
	public void setMemberid(String memberid) {
		this.memberid = memberid;
	}
	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getEmail() {
		return email;
	}
	public void setEmail(String email) {
		this.email = email;
	}
	 public String getRole() {
			return role;
	}
	public void setRole(String role) {
		this.role = role;
	}
	public boolean isVerified() {
        return isVerified;
    }
    public void setVerified(boolean isVerified) {
        this.isVerified = isVerified;
    }
}