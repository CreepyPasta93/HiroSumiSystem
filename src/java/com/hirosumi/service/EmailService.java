package com.hirosumi.service;

import java.util.Properties;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailService {

    // CHANGE THESE
    private static final String FROM_EMAIL = "hirosumi.official@gmail.com";
    private static final String APP_PASSWORD = "iymw cndf vacf ldhg";

    public static void sendVerificationEmail(String toEmail, String fullName, String token, String appUrl)
            throws MessagingException {

        String verifyLink = appUrl + "/VerifyEmailServlet?token=" + token;
        System.out.println("EMAIL SERVICE REACHED");
        System.out.println("Sending verification email to: " + toEmail);
        System.out.println("Verification link: " + verifyLink);

        String subject = "HiroSumi Account Verification";
        String content = "<h2>Hello, " + fullName + " 🐾</h2>"
                + "<p>Thank you for registering with <strong>HiroSumi Smart Cat Shelter</strong>.</p>"
                + "<p>Please click the link below to verify your account:</p>"
                + "<p><a href='" + verifyLink + "'>" + verifyLink + "</a></p>"
                + "<p>This link will expire in 24 hours.</p>"
                + "<br><p>With love,<br>HiroSumi Team</p>";

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new javax.mail.Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(FROM_EMAIL));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
        message.setSubject(subject);
        message.setContent(content, "text/html; charset=utf-8");

        Transport.send(message);
    }
}
