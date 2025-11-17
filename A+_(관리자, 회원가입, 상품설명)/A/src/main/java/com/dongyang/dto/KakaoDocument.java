package com.dongyang.dto;

import com.google.gson.annotations.SerializedName;

//주소 정보 객체 (우리가 필요한 위도/경도 포함)
public class KakaoDocument {

 // "y" 키가 위도(latitude)
 @SerializedName("y")
 private double latitude;

 // "x" 키가 경도(longitude)
 @SerializedName("x")
 private double longitude;

 public double getLatitude() {
     return latitude;
 }

 public void setLatitude(double latitude) {
     this.latitude = latitude;
 }

 public double getLongitude() {
     return longitude;
 }

 public void setLongitude(double longitude) {
     this.longitude = longitude;
 }
}