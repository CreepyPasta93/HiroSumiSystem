package com.hirosumi.service;

import java.io.IOException;
import java.io.InputStream;
import java.util.Date;
import java.util.Properties;
import javax.mail.Authenticator;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletContext;

public class EmailService {

    private static final String CONFIG_PATH = "/WEB-INF/config.properties";

    /*
     * Reads email settings from WEB-INF/config.properties.
     */
    private static Properties loadConfig(ServletContext context) throws IOException {
        Properties config = new Properties();

        try (InputStream input = context.getResourceAsStream(CONFIG_PATH)) {
            if (input == null) {
                throw new IOException("Cannot find " + CONFIG_PATH);
            }

            config.load(input);
        }

        return config;
    }

    /*
     * Creates Gmail SMTP session.
     */
    private static Session createMailSession(final String fromEmail, final String appPassword) {
        Properties props = new Properties();

        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.ssl.trust", "smtp.gmail.com");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(fromEmail, appPassword);
            }
        });
    }

    /*
     * Main reusable HTML email sender.
     */
    private static void sendHtmlEmail(
            ServletContext context,
            String toEmail,
            String subject,
            String htmlContent
    ) throws MessagingException {

        try {
            Properties config = loadConfig(context);

            String fromEmail = config.getProperty("HIROSUMI_EMAIL_FROM");
            String appPassword = config.getProperty("HIROSUMI_EMAIL_APP_PASSWORD");

            if (fromEmail == null || fromEmail.trim().isEmpty()) {
                throw new MessagingException("HIROSUMI_EMAIL_FROM is missing in config.properties");
            }

            if (appPassword == null || appPassword.trim().isEmpty()) {
                throw new MessagingException("HIROSUMI_EMAIL_APP_PASSWORD is missing in config.properties");
            }

            fromEmail = fromEmail.trim();
            appPassword = appPassword.trim().replace(" ", "");

            Session session = createMailSession(fromEmail, appPassword);

            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(fromEmail));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setSentDate(new Date());
            message.setContent(htmlContent, "text/html; charset=UTF-8");

            Transport.send(message);

        } catch (IOException e) {
            throw new MessagingException("Failed to read email config.properties", e);
        }
    }

    /*
     * Verification email.
     */
    public static void sendVerificationEmail(
            String toEmail,
            String fullName,
            String token,
            String appUrl,
            ServletContext context
    ) throws MessagingException {

        String verifyLink = appUrl + "/VerifyEmailServlet?token=" + token;

        System.out.println("EMAIL SERVICE REACHED");
        System.out.println("Sending verification email to: " + toEmail);
        System.out.println("Verification link: " + verifyLink);

        String subject = "Verify Your HiroSumi Account";
        String content = buildVerificationEmail(fullName, verifyLink);

        sendHtmlEmail(context, toEmail, subject, content);
    }

    /*
     * Password reset email.
     */
    public static void sendPasswordResetEmail(
            String toEmail,
            String resetLink,
            ServletContext context
    ) throws MessagingException {

        System.out.println("EMAIL SERVICE REACHED");
        System.out.println("Sending password reset email to: " + toEmail);
        System.out.println("Reset link: " + resetLink);

        String subject = "Reset Your HiroSumi Password";
        String content = buildPasswordResetEmail(resetLink);

        sendHtmlEmail(context, toEmail, subject, content);
    }

    /*
     * Verification email template.
     */
    private static String buildVerificationEmail(String fullName, String verifyLink) {
        String safeName = escapeHtml(fullName);
        String safeLink = escapeHtml(verifyLink);

        return ""
                + "<!DOCTYPE html>"
                + "<html>"
                + "<body style='margin:0; padding:0; background:#fff7fb; font-family:Arial, Helvetica, sans-serif; color:#3E2723;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#fff7fb; padding:34px 12px;'>"
                + "<tr><td align='center'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='max-width:560px; background:#fffdfa; border:1px solid #ffd1dc; border-radius:24px; overflow:hidden;'>"
                + "<tr>"
                + "<td style='background:linear-gradient(135deg,#ffe1eb 0%,#f7fbf2 100%); padding:32px 28px; text-align:center;'>"
                + "<div style='width:66px; height:66px; line-height:66px; margin:0 auto 14px; border-radius:20px; background:#ffffff; color:#d85c7d; font-size:30px;'>🌿</div>"
                + "<h1 style='margin:0; color:#3E2723; font-size:28px;'>Verify Your Account</h1>"
                + "<p style='margin:10px 0 0; color:#557159; font-size:15px; font-weight:bold;'>HiroSumi Smart Stray Cat Shelter</p>"
                + "</td>"
                + "</tr>"
                + "<tr>"
                + "<td style='padding:32px;'>"
                + "<p style='margin:0 0 16px; font-size:16px;'>Hello, " + safeName + ",</p>"
                + "<p style='margin:0 0 16px; color:#5d4037; font-size:15px; line-height:1.7;'>Thank you for registering with HiroSumi. Please verify your email address by clicking the button below.</p>"
                + "<table cellpadding='0' cellspacing='0' width='100%' style='margin:28px 0;'>"
                + "<tr><td align='center'>"
                + "<a href='" + safeLink + "' style='display:inline-block; background:linear-gradient(135deg,#f58aaa 0%,#d85c7d 100%); color:#ffffff; text-decoration:none; padding:14px 32px; border-radius:999px; font-size:15px; font-weight:bold;'>Verify My Account</a>"
                + "</td></tr>"
                + "</table>"
                + "<p style='margin:0 0 10px; color:#7b6b65; font-size:13px;'>If the button does not work, copy and paste this link into your browser:</p>"
                + "<p style='margin:0; word-break:break-all; font-size:13px;'><a href='" + safeLink + "' style='color:#557159;'>" + safeLink + "</a></p>"
                + "</td>"
                + "</tr>"
                + "<tr>"
                + "<td style='background:#f7fbf2; padding:18px 28px; text-align:center; border-top:1px solid #edf3e8;'>"
                + "<p style='margin:0; color:#7b8b73; font-size:12px;'>Sent automatically by HiroSumi. Please do not reply to this email.</p>"
                + "</td>"
                + "</tr>"
                + "</table>"
                + "</td></tr>"
                + "</table>"
                + "</body>"
                + "</html>";
    }

    /*
     * Password reset email template.
     */
    private static String buildPasswordResetEmail(String resetLink) {
        String safeLink = escapeHtml(resetLink);

        return ""
                + "<!DOCTYPE html>"
                + "<html>"
                + "<body style='margin:0; padding:0; background:#fff7fb; font-family:Arial, Helvetica, sans-serif; color:#3E2723;'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='background:#fff7fb; padding:34px 12px;'>"
                + "<tr><td align='center'>"
                + "<table width='100%' cellpadding='0' cellspacing='0' style='max-width:560px; background:#fffdfa; border:1px solid #ffd1dc; border-radius:24px; overflow:hidden;'>"
                + "<tr>"
                + "<td style='background:linear-gradient(135deg,#ffe1eb 0%,#f7fbf2 100%); padding:32px 28px; text-align:center;'>"
                + "<div style='width:66px; height:66px; line-height:66px; margin:0 auto 14px; border-radius:20px; background:#ffffff; color:#d85c7d; font-size:30px;'>🔐</div>"
                + "<h1 style='margin:0; color:#3E2723; font-size:28px;'>Password Reset</h1>"
                + "<p style='margin:10px 0 0; color:#557159; font-size:15px; font-weight:bold;'>HiroSumi Smart Stray Cat Shelter</p>"
                + "</td>"
                + "</tr>"
                + "<tr>"
                + "<td style='padding:32px;'>"
                + "<p style='margin:0 0 16px; font-size:16px;'>Hello,</p>"
                + "<p style='margin:0 0 16px; color:#5d4037; font-size:15px; line-height:1.7;'>We received a request to reset the password for your HiroSumi account. Click the button below to create a new password.</p>"
                + "<div style='background:#fff3f6; border:1px dashed #f8b8ca; border-radius:16px; padding:14px 16px; margin:22px 0; color:#8b5e5e; font-size:14px;'>This reset link will expire in <strong>15 minutes</strong>. If you did not request this, you can safely ignore this email.</div>"
                + "<table cellpadding='0' cellspacing='0' width='100%' style='margin:28px 0;'>"
                + "<tr><td align='center'>"
                + "<a href='" + safeLink + "' style='display:inline-block; background:linear-gradient(135deg,#f58aaa 0%,#d85c7d 100%); color:#ffffff; text-decoration:none; padding:14px 32px; border-radius:999px; font-size:15px; font-weight:bold;'>Reset My Password</a>"
                + "</td></tr>"
                + "</table>"
                + "<p style='margin:0 0 10px; color:#7b6b65; font-size:13px;'>If the button does not work, copy and paste this link into your browser:</p>"
                + "<p style='margin:0; word-break:break-all; font-size:13px;'><a href='" + safeLink + "' style='color:#557159;'>" + safeLink + "</a></p>"
                + "</td>"
                + "</tr>"
                + "<tr>"
                + "<td style='background:#f7fbf2; padding:18px 28px; text-align:center; border-top:1px solid #edf3e8;'>"
                + "<p style='margin:0; color:#7b8b73; font-size:12px;'>Sent automatically by HiroSumi. Please do not reply to this email.</p>"
                + "</td>"
                + "</tr>"
                + "</table>"
                + "</td></tr>"
                + "</table>"
                + "</body>"
                + "</html>";
    }

    /*
     * Simple HTML escaping.
     */
    private static String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value
                .replace("&", "&amp;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;")
                .replace("<", "&lt;")
                .replace(">", "&gt;");
    }
}
