package com.dongyang.dto;

import java.util.List;
import com.google.gson.annotations.SerializedName;

/**
 * 공공 API 응답의 전체 JSON 구조를 매핑하는 DTO
 */
public class ApiResponse {

    // JSON 키 "data"를 List<PoliceStation> 타입의 'data' 변수에 매핑
    @SerializedName("data")
    private List<PoliceStation> data;

    @SerializedName("currentCount")
    private int currentCount;

    @SerializedName("totalCount")
    private int totalCount;

    @SerializedName("page")
    private int page;

    @SerializedName("perPage")
    private int perPage;

    // --- Getters and Setters ---
    // (Eclipse/STS 단축키: Alt + Shift + S -> Generate Getters and Setters)

    public List<PoliceStation> getData() {
        return data;
    }

    public void setData(List<PoliceStation> data) {
        this.data = data;
    }

    public int getCurrentCount() {
        return currentCount;
    }

    public void setCurrentCount(int currentCount) {
        this.currentCount = currentCount;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }

    public int getPage() {
        return page;
    }

    public void setPage(int page) {
        this.page = page;
    }

    public int getPerPage() {
        return perPage;
    }

    public void setPerPage(int perPage) {
        this.perPage = perPage;
    }
}