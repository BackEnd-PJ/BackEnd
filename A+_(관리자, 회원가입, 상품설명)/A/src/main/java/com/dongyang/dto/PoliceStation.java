package com.dongyang.dto; // 👈 본인 프로젝트의 DTO 패키지 경로로 수정

import com.google.gson.annotations.SerializedName;

/**
 * 'data' 배열 내부의 경찰서 객체 정보를 매핑하는 DTO
 */
public class PoliceStation {

    // JSON 키 "경찰서명칭"을 Java 변수 'stationName'에 매핑
    @SerializedName("경찰서명칭")
    private String stationName;

    // JSON 키 "경찰서주소"를 Java 변수 'address'에 매핑
    @SerializedName("경찰서주소")
    private String address;

    @SerializedName("시도경찰청")
    private String regionalOffice;

    @SerializedName("위치")
    private String location;

    // --- Getters and Setters ---
    // (Eclipse/STS 단축키: Alt + Shift + S -> Generate Getters and Setters)

    public String getStationName() {
        return stationName;
    }

    public void setStationName(String stationName) {
        this.stationName = stationName;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getRegionalOffice() {
        return regionalOffice;
    }

    public void setRegionalOffice(String regionalOffice) {
        this.regionalOffice = regionalOffice;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}