package com.dongyang.dto;

/**
 * productstbl 테이블의 데이터를 담는 DTO 클래스입니다.
 * (기존 LocationDTO에서 price와 imageUrl이 추가되었습니다.)
 */
public class ProductDTO {
	private int id;
	private String name;
	private long price; // ❗️ [추가] 가격
	private String addr;
	private double lat;
	private double lng;
	private String category;
	private String imageUrl; // ❗️ [추가] 이미지 경로
	private String description;
	
	// --- Getters and Setters ---
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public long getPrice() {
		return price;
	}
	public void setPrice(long price) {
		this.price = price;
	}
	public String getAddr() {
		return addr;
	}
	public void setAddr(String addr) {
		this.addr = addr;
	}
	public double getLat() {
		return lat;
	}
	public void setLat(double lat) {
		this.lat = lat;
	}
	public double getLng() {
		return lng;
	}
	public void setLng(double lng) {
		this.lng = lng;
	}
	public String getCategory() {
		return category;
	}
	public void setCategory(String category) {
		this.category = category;
	}
	public String getImageUrl() {
		return imageUrl;
	}
	public void setImageUrl(String imageUrl) {
		this.imageUrl = imageUrl;
	}
	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}
}