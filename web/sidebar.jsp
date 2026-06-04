<%@page import="com.hirosumi.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");

    String userRole = "User";
    String userName = "User";
    String profileImage = "default-profile.jpg";

    if (currentUser != null) {
        if (currentUser.getRole() != null && !currentUser.getRole().trim().isEmpty()) {
            userRole = currentUser.getRole().trim();
        }

        if (currentUser.getFullName() != null && !currentUser.getFullName().trim().isEmpty()) {
            userName = currentUser.getFullName().trim();
        } else if (currentUser.getUsername() != null && !currentUser.getUsername().trim().isEmpty()) {
            userName = currentUser.getUsername().trim();
        }

        if (currentUser.getProfileImage() != null && !currentUser.getProfileImage().trim().isEmpty()) {
            profileImage = currentUser.getProfileImage().trim();
        }
    }

    String currentUri = request.getRequestURI().toLowerCase();
    String activePage = (String) request.getAttribute("activePage");

    boolean isDashboardActive = false;
    boolean isAnalyticsActive = false;
    boolean isLogsActive = false;
    boolean isTechActive = false;
    boolean isThresholdActive = false;
    boolean isProfileActive = false;

    if (activePage != null) {
        isDashboardActive = "dashboard".equalsIgnoreCase(activePage);
        isAnalyticsActive = "analytics".equalsIgnoreCase(activePage);
        isLogsActive = "logs".equalsIgnoreCase(activePage);
        isTechActive = "tech".equalsIgnoreCase(activePage);
        isThresholdActive = "threshold".equalsIgnoreCase(activePage);
        isProfileActive = "profile".equalsIgnoreCase(activePage);
    } else {
        isDashboardActive = currentUri.contains("dashboard");
        isAnalyticsActive = currentUri.contains("analytics");
        isLogsActive = currentUri.contains("systemlog") || currentUri.contains("systemlogs");
        isTechActive = currentUri.contains("techthreshold") || currentUri.contains("tech_threshold");
        isThresholdActive = currentUri.contains("threshold") && !currentUri.contains("tech");
        isProfileActive = currentUri.contains("profile");
    }
%>

<aside class="sidebar" id="mySidebar">

    <!-- Logo Section -->
    <div class="sidebar-logo-box">
        <img
            src="${pageContext.request.contextPath}/images/hirosumi_logo.png"
            alt="HiroSumi Logo"
            class="sidebar-logo-img"
        >
    </div>

    <!-- Navigation Menu -->
    <nav class="sidebar-nav">

        <a href="DashboardServlet"
           class="sidebar-link <%= isDashboardActive ? "active" : ""%>">
            <i class="fa-solid fa-house"></i>
            <span>Dashboard</span>
        </a>

        <a href="AnalyticsServlet"
           class="sidebar-link <%= isAnalyticsActive ? "active" : ""%>">
            <i class="fa-solid fa-chart-line"></i>
            <span>Analytics</span>
        </a>

        <a href="SystemLogServlet"
           class="sidebar-link <%= isLogsActive ? "active" : ""%>">
            <i class="fa-solid fa-clipboard-list"></i>
            <span>System Logs</span>
        </a>

        <% if ("Technician".equalsIgnoreCase(userRole)) { %>
            <a href="TechThresholdServlet"
               class="sidebar-link <%= isTechActive ? "active" : ""%>">
                <i class="fa-solid fa-screwdriver-wrench"></i>
                <span>Tech Panel</span>
            </a>
        <% } else { %>
            <a href="ThresholdServlet"
               class="sidebar-link <%= isThresholdActive ? "active" : ""%>">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <span>Threshold</span>
            </a>
        <% } %>

    </nav>

    <!-- Clickable User Card -->
    <a href="ProfileServlet" class="sidebar-user-card <%= isProfileActive ? "active-profile" : "" %>">
        <div class="sidebar-avatar">
            <img
                src="${pageContext.request.contextPath}/images/<%= profileImage%>"
                alt="User Avatar"
                onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/default-profile.jpg';"
            >
        </div>

        <div class="sidebar-user-info">
            <h4><%= userName%></h4>
            <p><%= userRole%></p>
        </div>

        <span class="sidebar-online-dot"></span>
    </a>

    <!-- Quote Card -->
    <div class="sidebar-quote-card">
        <img
            src="${pageContext.request.contextPath}/images/quote-sparkle.png"
            alt="Sparkle"
            class="quote-sparkle"
        >

        <p>“Every purr<br>makes a difference.”</p>

        <img
            src="${pageContext.request.contextPath}/images/cat-sidebar-quote.png"
            alt="Cute Cat"
            class="quote-cat"
        >
    </div>

    <!-- Logout -->
    <a href="logout.jsp" class="sidebar-logout">
        <i class="fa-solid fa-right-from-bracket"></i>
        <span>Log Out</span>
    </a>

    <!-- Bottom Field Decoration -->
    <img
        src="${pageContext.request.contextPath}/images/sidebar-field.png"
        alt="Field Decoration"
        class="sidebar-field"
    >

</aside>