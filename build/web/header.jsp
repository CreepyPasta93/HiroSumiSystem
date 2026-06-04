<%@page import="com.hirosumi.model.User"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User headerUser = (User) session.getAttribute("currentUser");

    String headerName = "User";

    if (headerUser != null) {
        if (headerUser.getFullName() != null && !headerUser.getFullName().trim().isEmpty()) {
            headerName = headerUser.getFullName().trim();
        } else if (headerUser.getUsername() != null && !headerUser.getUsername().trim().isEmpty()) {
            headerName = headerUser.getUsername().trim();
        }
    }

    String currentDate = new SimpleDateFormat("MMM dd, yyyy").format(new Date());
    String currentTime = new SimpleDateFormat("hh:mm a").format(new Date());
%>

<header class="dashboard-header">

    <div class="header-greeting">
        <h1>
            Good morning, <span><%= headerName %>!</span>
            <span class="paw-accent">🐾</span>
        </h1>
        <p>Thank you for caring for our little friends. 🌿</p>
    </div>

    <div class="header-actions">

        <div class="header-date-box">
            <i class="fa-regular fa-calendar-days"></i>
            <div>
                <strong><%= currentDate %></strong>
                <span><%= currentTime %></span>
            </div>
        </div>

        <button class="header-bell-btn" id="headerBellBtn" onclick="triggerTelegramReport()" title="Send status to Telegram">
            <i class="fa-regular fa-bell" id="headerBellIcon"></i>
            <span class="bell-dot"></span>
        </button>

        <button class="header-send-btn" onclick="triggerTelegramReport()">
            <i class="fa-solid fa-paper-plane"></i>
            <span>Send Report</span>
        </button>

    </div>

</header>