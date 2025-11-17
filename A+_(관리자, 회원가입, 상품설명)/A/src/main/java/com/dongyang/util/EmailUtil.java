package com.dongyang.util;

import java.util.Properties;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class EmailUtil {

    // ⭐️ [필수] 본인의 이메일 SMTP 정보로 변경
    private static final String SMTP_HOST = "smtp.gmail.com"; // 예: Gmail
    private static final String SMTP_USER = "backendprojecta@gmail.com"; // ⭐️ 본인 계정
    private static final String SMTP_PASS = "ebdu jvbh vhai oubu"; // ⭐️ 본인 앱 비밀번호

    public static void sendEmail(String toEmail, String subject, String body) throws MessagingException {
        
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", SMTP_HOST);
        props.put("mail.smtp.port", 587);
        props.put("mail.smtp.ssl.trust", SMTP_HOST);

        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SMTP_USER));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(body, "text/html; charset=utf-8");
        Transport.send(message);
        
        System.out.println("이메일 발송 성공: " + toEmail);
    }
}