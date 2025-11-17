package com.dongyang.dto;

import java.util.List;

//카카오 주소 변환 API의 전체 응답
public class KakaoAddressResponse {
 
 // "documents" 키에 주소 정보 배열이 담겨 옴
 private List<KakaoDocument> documents;

 public List<KakaoDocument> getDocuments() {
     return documents;
 }

 public void setDocuments(List<KakaoDocument> documents) {
     this.documents = documents;
 }
}