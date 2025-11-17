package com.dongyang.util;

import java.util.Random;

public class RandomCodeUtil {
    // 6자리 숫자 인증 코드 생성
    public static String createCode() {
        Random rand = new Random();
        int num = rand.nextInt(900000) + 100000; // 100000 ~ 999999
        return String.valueOf(num);
    }
}