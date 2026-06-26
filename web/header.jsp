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
            Good morning, <span><%= headerName%>!</span>
            <span class="paw-accent">🐾</span>
        </h1>
        <p>Thank you for caring for our little friends. 🌿</p>
    </div>

    <div class="header-actions">

        <div class="header-date-box">
            <i class="fa-regular fa-calendar-days"></i>
            <div>
                <strong><%= currentDate%></strong>
                <span><%= currentTime%></span>
            </div>
        </div>

        <button class="header-bell-btn" id="headerBellBtn" onclick="toggleHeaderNotificationPanel(event)" type="button" title="View notification history">
            <i class="fa-regular fa-bell" id="headerBellIcon"></i>
            <span class="bell-dot"></span>
        </button>

        <button class="header-send-btn" id="headerSendBtn" onclick="triggerHeaderTelegramReport()" type="button">
            <i class="fa-solid fa-paper-plane"></i>
            <span>Send Report</span>
        </button>

    </div>
</header>
<div id="headerNotificationPanel" class="notification-panel">
    <div class="notification-panel-header">
        <div>
            <h3>Notifications 🐾</h3>
            <p>Latest Telegram history</p>
        </div>

        <button type="button" onclick="toggleHeaderNotificationPanel(event)">
            <i class="fa-solid fa-xmark"></i>
        </button>
    </div>

    <div id="headerNotificationList" class="notification-list">
        <div class="notification-empty">
            Fetching latest notification history...
        </div>
    </div>
</div>

<div id="headerStatusModal" class="modal">
    <div class="modal-content cute-status-modal" id="headerStatusModalContent">
        <button class="modal-x-btn" type="button" onclick="closeHeaderStatusModal()">
            <i class="fa-solid fa-xmark"></i>
        </button>

        <span class="modal-deco modal-strawberry">🍓</span>
        <span class="modal-deco modal-paw">🐾</span>

        <div class="modal-cat-bubble">
            <i id="headerStatusIcon" class="fa-solid fa-circle-check"></i>
        </div>

        <h3 id="headerStatusTitle">Report Sent!</h3>
        <p id="headerStatusMsg">The latest report has been sent successfully.</p>

        <div class="modal-mini-note">
            <i class="fa-solid fa-shield-heart"></i>
            HiroSumi notification module is active.
        </div>

        <button class="btn-close-modal" type="button" onclick="closeHeaderStatusModal()">
            Acknowledge <span>✨</span>
        </button>
    </div>
</div>

<script>
    const HIROSUMI_CONTEXT_PATH = '<%= request.getContextPath()%>';
    
    function triggerHeaderTelegramReport() {
        const sendBtn = document.getElementById('headerSendBtn');
        const bellIcon = document.getElementById('headerBellIcon');

        if (sendBtn) {
            sendBtn.disabled = true;
            sendBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i><span>Sending...</span>';
        }

        if (bellIcon) {
            bellIcon.className = 'fa-solid fa-spinner fa-spin';
        }

        fetch(HIROSUMI_CONTEXT_PATH + '/DashboardServlet?action=sendReport')
                .then(response => {
                    if (!response.ok) {
                        throw new Error("Server Error");
                    }
                    return response.text();
                })
                .then(result => {
                    if (result.trim() === 'success') {
                        showHeaderStatusModal(
                                "Report Sent!",
                                "The latest HiroSumi shelter report has been sent to Telegram.",
                                true
                                );
                    } else {
                        showHeaderStatusModal(
                                "Report Failed",
                                "Could not send report. Please check Telegram subscribers, bot token, or NetBeans output.",
                                false
                                );
                    }
                })
                .catch(error => {
                    console.error(error);
                    showHeaderStatusModal(
                            "System Error",
                            "Something went wrong while sending the report.",
                            false
                            );
                })
                .finally(() => {
                    if (sendBtn) {
                        sendBtn.disabled = false;
                        sendBtn.innerHTML = '<i class="fa-solid fa-paper-plane"></i><span>Send Report</span>';
                    }

                    if (bellIcon) {
                        bellIcon.className = 'fa-regular fa-bell';
                    }
                });
    }

    function toggleHeaderNotificationPanel(event) {
        if (event) {
            event.stopPropagation();
        }

        const panel = document.getElementById('headerNotificationPanel');

        if (!panel) {
            console.log("headerNotificationPanel not found");
            return;
        }

        panel.classList.toggle('active');

        if (panel.classList.contains('active')) {
            loadHeaderNotificationHistory();
        }
    }

    function loadHeaderNotificationHistory() {
        const list = document.getElementById('headerNotificationList');

        if (!list) {
            return;
        }

        list.innerHTML = '<div class="notification-empty">Fetching latest notification history...</div>';

        fetch(HIROSUMI_CONTEXT_PATH + '/DashboardServlet?action=getNotifications')
                .then(response => {
                    if (!response.ok) {
                        throw new Error("Failed to fetch notifications");
                    }
                    return response.json();
                })
                .then(data => {
                    if (!data || data.length === 0) {
                        list.innerHTML = '<div class="notification-empty">No notification history yet ✨</div>';
                        return;
                    }

                    list.innerHTML = "";

                    data.forEach(item => {
                        const status = (item.status || "UNKNOWN").trim().toUpperCase();
                        const platform = (item.platform || "Telegram").trim();
                        const time = item.sentTimestamp || "Unknown time";
                        const message = item.messageContent || "";

                        let statusClass = "partial";
                        let icon = "fa-triangle-exclamation";
                        let statusText = status;

                        if (status === "SENT") {
                            statusClass = "sent";
                            icon = "fa-circle-check";
                            statusText = "Sent";
                        } else if (status === "FAILED") {
                            statusClass = "failed";
                            icon = "fa-circle-xmark";
                            statusText = "Failed";
                        } else if (status === "PARTIAL_FAILED") {
                            statusClass = "partial";
                            icon = "fa-triangle-exclamation";
                            statusText = "Partial";
                        } else if (status === "PENDING") {
                            statusClass = "partial";
                            icon = "fa-triangle-exclamation";
                            statusText = "Pending";
                        }

                        const summary = getHeaderNotificationSummary(message);
                        const shortMessage = shortenHeaderNotification(message);

                        list.innerHTML +=
                                '<div class="notification-item ' + statusClass + '">' +
                                '<div class="notification-icon">' +
                                '<i class="fa-solid ' + icon + '"></i>' +
                                '</div>' +
                                '<div class="notification-info">' +
                                '<div class="notification-title">' +
                                '<span class="notification-main-title">' + escapeHeaderHtml(platform + ' ' + summary) + '</span>' +
                                '<span class="notification-status-pill">' + escapeHeaderHtml(statusText) + '</span>' +
                                '</div>' +
                                '<p>' + escapeHeaderHtml(shortMessage) + '</p>' +
                                '<small><i class="fa-regular fa-clock"></i> ' + escapeHeaderHtml(time) + '</small>' +
                                '</div>' +
                                '</div>';
                    });
                })
                .catch(error => {
                    console.error(error);
                    list.innerHTML = '<div class="notification-empty error">Could not load notifications.</div>';
                });
    }

    function getHeaderNotificationSummary(message) {
        if (!message) {
            return "Report";
        }

        let clean = cleanHeaderMessage(message);

        if (clean.includes("New Threshold Change Request") || clean.includes("threshold request")) {
            return "Threshold Report";
        }

        if (clean.includes("HiroSumi Shelter Report") || clean.includes("HiroSumi Status Report")) {
            return "Status Report";
        }

        if (clean.includes("Temperature") || clean.includes("Temp")) {
            return "Sensor Report";
        }

        if (clean.includes("Warning") || clean.includes("Warm") || clean.includes("Hot")) {
            return "Alert Report";
        }

        return "Report";
    }

    function shortenHeaderNotification(message) {
        if (!message || message.trim() === "") {
            return "No message content saved.";
        }

        let clean = cleanHeaderMessage(message);

        let temp = clean.match(/Temperature:\s*([0-9.]+°C)|Temp:\s*([0-9.]+°C)/i);
        let humidity = clean.match(/Humidity:\s*([0-9.]+%)/i);
        let motion = clean.match(/Cat Activity:\s*([^🌀]+)|Motion:\s*([^🕒]+)/i);

        let summaryParts = [];

        if (temp) {
            summaryParts.push("Temp " + (temp[1] || temp[2]));
        }

        if (humidity) {
            summaryParts.push("Humidity " + humidity[1]);
        }

        if (motion) {
            let motionText = (motion[1] || motion[2]).trim();

            if (motionText.length > 18) {
                motionText = motionText.substring(0, 18) + "...";
            }

            summaryParts.push("Motion " + motionText);
        }

        if (summaryParts.length > 0) {
            return summaryParts.join(" • ");
        }

        if (clean.length > 80) {
            clean = clean.substring(0, 80) + "...";
        }

        return clean;
    }

    function cleanHeaderMessage(message) {
        return String(message)
                .replace(/<[^>]*>/g, "")
                .replace(/\*/g, "")
                .replace(/_/g, "")
                .replace(/\n/g, " ")
                .replace(/\s+/g, " ")
                .trim();
    }

    function escapeHeaderHtml(value) {
        if (!value) {
            return "";
        }

        return String(value)
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
    }

    function showHeaderStatusModal(title, message, isSuccess) {
        const modal = document.getElementById('headerStatusModal');
        const content = document.getElementById('headerStatusModalContent');
        const icon = document.getElementById('headerStatusIcon');
        const titleEl = document.getElementById('headerStatusTitle');
        const msgEl = document.getElementById('headerStatusMsg');

        if (!modal || !content || !icon || !titleEl || !msgEl) {
            alert(message);
            return;
        }

        titleEl.innerText = title;
        msgEl.innerText = message;

        if (isSuccess) {
            content.classList.remove('error-mode');
            icon.className = "fa-solid fa-circle-check";
        } else {
            content.classList.add('error-mode');
            icon.className = "fa-solid fa-triangle-exclamation";
        }

        modal.style.display = 'flex';
    }

    function closeHeaderStatusModal() {
        const modal = document.getElementById('headerStatusModal');

        if (modal) {
            modal.style.display = 'none';
        }
    }

    document.addEventListener('click', function (event) {
        const panel = document.getElementById('headerNotificationPanel');

        if (!panel) {
            return;
        }

        if (!event.target.closest('#headerNotificationPanel') &&
                !event.target.closest('#headerBellBtn')) {
            panel.classList.remove('active');
        }
    });
</script>


