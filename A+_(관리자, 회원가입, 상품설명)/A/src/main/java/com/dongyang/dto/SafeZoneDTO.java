package com.dongyang.dto;

// 1단계에서 DB에 저장한 'safe_zones' 테이블의 데이터를 담을 DTO
public class SafeZoneDTO {

    private String name;     // 'zone_name' (경찰서명칭 등)
    private String addr;     // 'address' (주소)
    private double lat;      // 'latitude' (위도)
    private double lng;      // 'longitude' (경도)
    
    // (JavaScript에서 이 DTO를 '상품'처럼 임시로 쓰기 위해)
    // (상품 DTO와 구조를 맞춥니다.)
    private long price = 0; // 가격 (임시 0)
    private String imageUrl = ""; // 이미지 (임시 "")
    private String category = "안전구역"; // 카테고리 (임시)

    // --- (필수) Getters & Setters ---
    // ... (모든 필드의 Getter/Setter를 생성) ...
    
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getAddr() { return addr; }
    public void setAddr(String addr) { this.addr = addr; }
    public double getLat() { return lat; }
    public void setLat(double lat) { this.lat = lat; }
    public double getLng() { return lng; }
    public void setLng(double lng) { this.lng = lng; }
    public long getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
}