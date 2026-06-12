<%@page import="com.hirosumi.model.User"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String mode = request.getParameter("mode");
    boolean isEditMode = "edit".equals(mode);

    boolean isTechnician = currentUser.getRole() != null
            && currentUser.getRole().equalsIgnoreCase("Technician");

    List<User> userList = (List<User>) request.getAttribute("userList");

    String avatarUrl = (currentUser.getProfileImage() != null && !currentUser.getProfileImage().trim().isEmpty())
            ? request.getContextPath() + "/images/" + currentUser.getProfileImage().trim()
            : request.getContextPath() + "/images/default-profile.jpg";

    String roleSuccess = request.getParameter("roleSuccess");
    String roleError = request.getParameter("roleError");
%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Settings</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

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

            <% request.setAttribute("activePage", "profile");%>
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
                                            <div style="font-size: 0.8rem; opacity: 0.85;">
                                                <%= currentUser.getRole()%>
                                            </div>
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

                    <!-- TECHNICIAN ONLY: USER ROLE MANAGEMENT -->
                    <% if (isTechnician && userList != null) { %>
                    <div class="role-management-card">
                        <div class="role-management-header">
                            <div>
                                <h3>
                                    <i class="fa-solid fa-user-shield"></i>
                                    User Role Management
                                </h3>
                                <p>
                                    Manage shelter access gently and safely by changing user roles between Volunteer and Technician only 🐾
                                </p>
                            </div>
                        </div>

                        <div class="role-table-wrapper">
                            <table class="role-table">
                                <thead>
                                    <tr>
                                        <th>Full Name</th>
                                        <th>Username</th>
                                        <th>Email</th>
                                        <th>Current Role</th>
                                        <th>Change Role</th>
                                    </tr>
                                </thead>

                                <tbody>
                                    <% if (!userList.isEmpty()) { %>
                                    <% for (User u : userList) {%>
                                    <tr>
                                        <td><%= u.getFullName()%></td>
                                        <td><%= u.getUsername()%></td>
                                        <td><%= u.getEmail()%></td>
                                        <td>
                                            <span class="role-pill <%= u.getRole() != null && u.getRole().equalsIgnoreCase("Technician") ? "role-tech" : "role-volunteer"%>">
                                                <%= u.getRole()%>
                                            </span>
                                        </td>
                                        <td>
                                            <% if (u.getUserId() != currentUser.getUserId()) {%>
                                            <form action="UpdateUserRoleServlet" method="post" class="role-update-form">
                                                <input type="hidden" name="userId" value="<%= u.getUserId()%>">

                                                <select name="newRole" class="role-select">
                                                    <option value="Volunteer" <%= u.getRole() != null && u.getRole().equalsIgnoreCase("Volunteer") ? "selected" : ""%>>
                                                        Volunteer
                                                    </option>
                                                    <option value="Technician" <%= u.getRole() != null && u.getRole().equalsIgnoreCase("Technician") ? "selected" : ""%>>
                                                        Technician
                                                    </option>
                                                </select>

                                                <button type="submit" class="role-update-btn">
                                                    Update
                                                </button>
                                            </form>
                                            <% } else { %>
                                            <span class="role-self-note">
                                                Current user
                                            </span>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <% } %>
                                    <% } else { %>
                                    <tr>
                                        <td colspan="5" style="text-align:center; padding:25px; color:#888;">
                                            No users found.
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <% } %>

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

            <% if ("updated".equals(roleSuccess)) { %>
            Swal.fire({
                icon: 'success',
                title: 'Role Updated!',
                text: 'The user role has been updated successfully.',
                confirmButtonColor: '#557159'
            });
            <% } %>

            <% if ("unauthorized".equals(roleError)) { %>
            Swal.fire({
                icon: 'error',
                title: 'Access Denied',
                text: 'Only technicians can update user roles.',
                confirmButtonColor: '#d85c7d'
            });
            <% } else if ("self".equals(roleError)) { %>
            Swal.fire({
                icon: 'warning',
                title: 'Action Not Allowed',
                text: 'You cannot change your own role from this section.',
                confirmButtonColor: '#d85c7d'
            });
            <% } else if ("failed".equals(roleError)) { %>
            Swal.fire({
                icon: 'error',
                title: 'Update Failed',
                text: 'The role could not be updated. Please try again.',
                confirmButtonColor: '#d85c7d'
            });
            <% } else if ("invalid".equals(roleError)) { %>
            Swal.fire({
                icon: 'error',
                title: 'Invalid Request',
                text: 'The submitted role update request is invalid.',
                confirmButtonColor: '#d85c7d'
            });
            <% }%>
        </script>
    </body>
</html>