<%@page import="com.hirosumi.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String mode = request.getParameter("mode");
    boolean isEditMode = "edit".equals(mode);

    String avatarUrl = (currentUser.getProfileImage() != null && !currentUser.getProfileImage().trim().isEmpty())
            ? request.getContextPath() + "/images/" + currentUser.getProfileImage().trim()
            : request.getContextPath() + "/images/default-profile.jpg";
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Settings</title>

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard-custom.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/profile.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    </head>

    <body class="profile-page">

        <button class="sidebar-open-btn" onclick="toggleSidebar()">
            <i class="fa-solid fa-bars"></i>
        </button>

        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">

            <% request.setAttribute("activePage", "profile"); %>
            <jsp:include page="sidebar.jsp" />

            <div class="main-content">
                <jsp:include page="header.jsp" />

                <div class="profile-wrapper">

                    <div class="profile-header-area">
                        <div class="profile-page-title">
                            <div class="profile-title-icon">
                                <i class="fa-solid fa-user-gear"></i>
                            </div>

                            <div>
                                <h1>Account Settings</h1>
                                <p>Manage your HiroSumi profile and account details 🐾</p>
                            </div>
                        </div>

                        <% if (!isEditMode) { %>
                        <a href="ProfileServlet?mode=edit" class="edit-profile-btn">
                            <i class="fa-solid fa-user-pen"></i>
                            Edit Profile
                        </a>
                        <% }%>
                    </div>

                    <div class="profile-grid">

                        <!-- LEFT: CAREGIVER PASSPORT -->
                        <div class="profile-card">

                            <form action="ProfileServlet" method="POST" enctype="multipart/form-data">
                                <input type="hidden" name="action" value="update">

                                <div class="profile-avatar-section">
                                    <div class="profile-avatar-wrap">
                                        <img
                                            src="<%= avatarUrl%>"
                                            class="profile-avatar-img"
                                            alt="Profile picture"
                                            onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/default-profile.jpg';"
                                            >

                                        <% if (isEditMode) { %>
                                        <label class="profile-camera-btn">
                                            <i class="fa-solid fa-camera"></i>
                                            <input type="file" name="profileImage" style="display:none;" accept="image/*">
                                        </label>
                                        <% }%>
                                    </div>

                                    <div class="profile-name">
                                        <h3><%= currentUser.getFullName()%></h3>
                                        <p>
                                            <i class="fa-solid fa-user-nurse"></i>
                                            <%= currentUser.getRole()%> Account
                                        </p>
                                    </div>
                                </div>

                                <div class="profile-fields">

                                    <div class="profile-form-row">
                                        <label class="profile-label">
                                            <i class="fa-regular fa-user"></i>
                                            Full Name
                                        </label>

                                        <input
                                            type="text"
                                            name="fullname"
                                            class="profile-input"
                                            value="<%= currentUser.getFullName()%>"
                                            <%= isEditMode ? "" : "disabled"%>
                                            >

                                        <span class="profile-edit-dot">
                                            <i class="fa-solid fa-pen"></i>
                                        </span>
                                    </div>

                                    <div class="profile-form-row">
                                        <label class="profile-label">
                                            <i class="fa-solid fa-at"></i>
                                            Username
                                        </label>

                                        <input
                                            type="text"
                                            name="username"
                                            class="profile-input"
                                            value="<%= currentUser.getUsername()%>"
                                            <%= isEditMode ? "" : "disabled"%>
                                            >

                                        <span class="profile-edit-dot">
                                            <i class="fa-solid fa-pen"></i>
                                        </span>
                                    </div>

                                    <div class="profile-form-row">
                                        <label class="profile-label">
                                            <i class="fa-regular fa-envelope"></i>
                                            Email Address
                                        </label>

                                        <input
                                            type="email"
                                            name="email"
                                            class="profile-input"
                                            value="<%= currentUser.getEmail()%>"
                                            <%= isEditMode ? "" : "disabled"%>
                                            >

                                        <span class="profile-edit-dot">
                                            <i class="fa-solid fa-pen"></i>
                                        </span>
                                    </div>

                                    <div class="profile-form-row">
                                        <label class="profile-label">
                                            <i class="fa-solid fa-lock"></i>
                                            Password
                                        </label>

                                        <input type="password" value="*********" class="profile-input" disabled>

                                        <span class="profile-edit-dot">
                                            <i class="fa-solid fa-pen"></i>
                                        </span>
                                    </div>

                                </div>

                                <button
                                    type="button"
                                    onclick="requestPasswordReset('<%= currentUser.getEmail()%>')"
                                    class="pw-btn"
                                    >
                                    <i class="fa-solid fa-key"></i>
                                    Request Password Change?
                                </button>

                                <% if (isEditMode) { %>
                                <div class="profile-action-row">
                                    <a href="ProfileServlet" class="cancel-link">Cancel</a>

                                    <button type="submit" class="save-profile-btn">
                                        Save Changes
                                        <i class="fa-solid fa-paw" style="margin-left: 5px;"></i>
                                    </button>
                                </div>
                                <% }%>
                            </form>
                            <img
                                src="${pageContext.request.contextPath}/images/wave-cat.png"
                                alt="Cute waving cat"
                                class="passport-cat-outside"
                                >
                        </div>

                        <!-- RIGHT: STATUS + TIPS -->
                        <div class="stats-area">

                            <div class="stats-card">
                                <img
                                    src="${pageContext.request.contextPath}/images/side-berry.png"
                                    alt=""
                                    class="status-berry"
                                    >

                                <h3>🌿 System Status</h3>

                                <div class="stats-row">
                                    <div class="stat-item">
                                        <i class="fa-solid fa-medal"></i>
                                        <div>
                                            <div style="font-weight: bold;">Level</div>
                                            <div style="font-size: 0.8rem; opacity: 0.85;"><%= currentUser.getRole()%></div>
                                        </div>
                                    </div>

                                    <div class="stat-item">
                                        <i class="fa-solid fa-circle-check"></i>
                                        <div>
                                            <div style="font-weight: bold;">Status</div>
                                            <div style="font-size: 0.8rem; opacity: 0.85;">Verified</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <h3 class="tips-title">Shelter Care Tips 🐾</h3>

                            <div class="tips-grid">

                                <div class="tip-box tip-photo">
                                    <div class="tip-icon">
                                        <i class="fa-solid fa-camera"></i>
                                    </div>

                                    <h5>Photos</h5>
                                    <p>Clear profile photos help identify you during busy shifts!</p>

                                    <img
                                        src="${pageContext.request.contextPath}/images/cat-polaroid.png"
                                        alt=""
                                        class="tip-art tip-polaroid"
                                        >
                                </div>

                                <div class="tip-box tip-early">
                                    <div class="tip-icon">
                                        <i class="fa-solid fa-clock"></i>
                                    </div>

                                    <h5>Be Early</h5>
                                    <p>Arrive 5 mins early to check your daily duty list.</p>

                                    <img
                                        src="${pageContext.request.contextPath}/images/wave-cat.png"
                                        alt=""
                                        class="tip-art tip-cat"
                                        >
                                </div>

                                <div class="tip-box tip-diet">
                                    <div class="tip-icon">
                                        <i class="fa-solid fa-bone"></i>
                                    </div>

                                    <h5>Diet Safety</h5>
                                    <p>Double-check food labels for pets with allergies!</p>

                                    <img
                                        src="${pageContext.request.contextPath}/images/cat-food.png"
                                        alt=""
                                        class="tip-art tip-food"
                                        >
                                </div>

                                <div class="tip-box tip-hydration">
                                    <div class="tip-icon">
                                        <i class="fa-solid fa-droplet"></i>
                                    </div>

                                    <h5>Hydration</h5>
                                    <p>Stay hydrated! Take water breaks between tasks.</p>

                                    <img
                                        src="${pageContext.request.contextPath}/images/cat-water.png"
                                        alt=""
                                        class="tip-art tip-water"
                                        >
                                </div>

                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <script>
            function toggleSidebar() {
                const sidebar = document.getElementById('mySidebar');
                const overlay = document.querySelector('.sidebar-overlay');

                if (sidebar && overlay) {
                    sidebar.classList.toggle('active');
                    overlay.classList.toggle('active');
                }
            }

            function requestPasswordReset(email) {
                Swal.fire({
                    title: 'Sending Request...',
                    text: 'Please wait while we process your request.',
                    allowOutsideClick: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });

                fetch('ProfileServlet?action=resetPassword&email=' + encodeURIComponent(email), {
                    method: 'POST'
                })
                        .then(response => response.json())
                        .then(data => {
                            if (data.status === "success") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Email Sent!',
                                    text: 'A password reset link has been sent to ' + email,
                                    confirmButtonColor: '#557159'
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error',
                                    text: 'Could not send email.'
                                });
                            }
                        })
                        .catch(() => {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error',
                                text: 'Could not send email.'
                            });
                        });
            }
        </script>
    </body>
</html>