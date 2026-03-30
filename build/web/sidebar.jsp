<%@page import="com.hirosumi.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // 1. Fetch the current logged-in user from the session
    User currentUser = (User) session.getAttribute("currentUser");
    
    // 2. Safely get their role, trim spaces, and default to Volunteer
    String userRole = "Volunteer"; 
    if (currentUser != null && currentUser.getRole() != null) {
        userRole = currentUser.getRole().trim();
    }

    // 3. 🐾 THE FIX: Grab the current URL and force it to lowercase for bulletproof matching
    String currentUri = request.getRequestURI().toLowerCase();
%>

<div class="sidebar-overlay" onclick="toggleSidebar()"></div>

<div class="sidebar" id="mySidebar">
    <img src="${pageContext.request.contextPath}/images/logo_dark.png" class="sidebar-logo" 
         style="padding: 30px 0; display: block; margin: auto; width: 140px;">
    
    <div style="text-align: right; padding-right: 20px;">
        <i class="fa-solid fa-xmark" onclick="toggleSidebar()" style="cursor: pointer; font-size: 1.5rem; color: #880E4F;"></i>
    </div>
    
    <div class="nav-menu">
        <a href="DashboardServlet" class="nav-item <%= currentUri.contains("dashboard") ? "active" : "" %>">
            <i class="fa-solid fa-table-columns"></i> <span>Dashboard</span>
        </a>
        
        <a href="AnalyticsServlet" class="nav-item <%= currentUri.contains("analytics") ? "active" : "" %>">
            <i class="fa-solid fa-chart-line"></i> <span>Analytics</span>
        </a>
        
        <a href="SystemLogServlet" class="nav-item <%= currentUri.contains("systemlog") ? "active" : "" %>">
            <i class="fa-solid fa-file-lines"></i> <span>System Logs</span>
        </a>

        <% if ("Technician".equalsIgnoreCase(userRole)) { %>
            <a href="TechThresholdServlet" class="nav-item <%= currentUri.contains("techthreshold") ? "active" : "" %>">
                <i class="fa-solid fa-wrench"></i> <span>Tech Panel</span>
            </a>
        <% } else { %>
            <a href="ThresholdServlet" class="nav-item <%= currentUri.contains("threshold") && !currentUri.contains("tech") ? "active" : "" %>">
                <i class="fa-solid fa-triangle-exclamation"></i> <span>Threshold</span>
            </a>
        <% } %>

        <a href="ProfileServlet" class="nav-item <%= currentUri.contains("profile") ? "active" : "" %>">
            <i class="fa-solid fa-gear"></i> <span>Settings</span>
        </a>
    </div>
    
    <div class="bottom-menu">
        <a href="logout.jsp" class="nav-item"><i class="fa-solid fa-right-from-bracket"></i> <span>Log Out</span></a>
    </div>
</div>

<script>
    function toggleSidebar() { 
        document.getElementById('mySidebar').classList.toggle('active'); 
        document.querySelector('.sidebar-overlay').classList.toggle('active'); 
    }
</script>