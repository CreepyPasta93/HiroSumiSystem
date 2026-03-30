<%@page import="com.hirosumi.model.User"%>
<%
    // 1. Get current user
    User headerUser = (User) session.getAttribute("currentUser");

    // 2. Avatar Logic
    String headerAvatarUrl = "https://i.pravatar.cc/150?u=default"; 
    if (headerUser != null) {
        if (headerUser.getProfileImage() != null && !headerUser.getProfileImage().isEmpty()) {
            headerAvatarUrl = "images/" + headerUser.getProfileImage();
        } else {
            headerAvatarUrl = "https://i.pravatar.cc/150?u=" + headerUser.getUsername();
        }
    }
%>

<div class="top-bar" style="background-color: #FFF8F0; border-bottom: 3px solid #FFCDD2;">
    
    <div style="display: flex; align-items: center; gap: 20px;">
        <i class="fa-solid fa-bars" onclick="toggleSidebar()" style="font-size: 1.5rem; color: #D81B60; cursor: pointer; transition: transform 0.2s;"></i>
        
        <img src="${pageContext.request.contextPath}/images/logo_text.png" class="header-logo-text" alt="HiroSumi Logo" style="height: 40px;">
    </div>
    
    <div class="user-profile">
        <% if (headerUser != null) { %>
            <div class="user-info">
                <div style="font-weight:bold; color:#3E2723;"><%= headerUser.getFullName() %></div>
                <div style="font-size:0.8rem; color:#888;"><%= headerUser.getRole() %></div>
            </div>
            
            <div class="avatar-circle" style="border: 2px solid #FFCDD2;">
                 <img src="<%= headerAvatarUrl %>" class="avatar-img">
            </div>
        <% } %>
    </div>
</div>