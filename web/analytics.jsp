<%@page import="com.hirosumi.model.User"%>
<%@page import="java.util.List"%>
<%@page import="com.hirosumi.model.SensorData"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String userRole = currentUser.getRole();
    boolean isTechnician = userRole != null && userRole.equalsIgnoreCase("Technician");

    Double avgTemp = request.getAttribute("avgTemp") != null ? (Double) request.getAttribute("avgTemp") : 0.0;
    Double avgHum = request.getAttribute("avgHum") != null ? (Double) request.getAttribute("avgHum") : 0.0;
    String fanRuntime = request.getAttribute("fanRuntime") != null ? (String) request.getAttribute("fanRuntime") : "0h 0m";

    Integer comfortScore = request.getAttribute("comfortScore") != null ? (Integer) request.getAttribute("comfortScore") : 0;

    String heatRiskLevel = request.getAttribute("heatRiskLevel") != null
            ? (String) request.getAttribute("heatRiskLevel")
            : "Waiting for data";

    String heatPatternInsight = request.getAttribute("heatPatternInsight") != null
            ? (String) request.getAttribute("heatPatternInsight")
            : "HiroSumi is still collecting enough data to detect heat patterns.";

    String fanEffectivenessInsight = request.getAttribute("fanEffectivenessInsight") != null
            ? (String) request.getAttribute("fanEffectivenessInsight")
            : "Fan effectiveness analysis will appear once enough readings are available.";

    Integer hotDays7Days = request.getAttribute("hotDays7Days") != null ? (Integer) request.getAttribute("hotDays7Days") : 0;

    String peakHeatPeriod = request.getAttribute("peakHeatPeriod") != null
            ? (String) request.getAttribute("peakHeatPeriod")
            : "Not enough data";

    // We don't need 'alertData' anymore since we removed that chart!
    List<SensorData> dataList = (List<SensorData>) request.getAttribute("dataList");

    String aiInsight = request.getAttribute("aiInsight") != null
            ? (String) request.getAttribute("aiInsight")
            : "HiroSumi is preparing the AI summary insight...";

    String heatRiskData = request.getAttribute("heatRiskData") != null
            ? (String) request.getAttribute("heatRiskData")
            : "0,0,0,0,0,0,0";

%>

<!DOCTYPE html>
<html>
    <head>
        <title>HiroSumi - Analytics</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard-custom.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/analytics.css">   
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/favicon.png">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>


    </head>
    <body class="analytics-page">

        <button class="sidebar-open-btn" onclick="toggleSidebar()">
            <i class="fa-solid fa-bars"></i>
        </button>

        <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

        <div class="dashboard-container">
            <% request.setAttribute("activePage", "analytics");%>
            <jsp:include page="sidebar.jsp" />

            <div class="main-content">
                <jsp:include page="header.jsp" />

                <div class="analytics-layout">

                    <div class="analytics-header-block">
                        <div class="analytics-title-wrap">
                            <div class="analytics-title-icon">
                                <i class="fa-solid fa-chart-line"></i>
                            </div>

                            <div>
                                <h2 class="analytics-page-title">System Analytics</h2>
                                <p class="analytics-page-subtitle">
                                    Historical data, smart insights & shelter performance metrics
                                </p>
                            </div>
                        </div>

                        <img 
                            src="${pageContext.request.contextPath}/images/cat-box.png" 
                            alt="Cute cat in box" 
                            class="analytics-box-cat"
                            >
                    </div>

                    <div class="analytics-main-grid">

                        <div class="analytics-column">

                            <div class="analytics-stat-card analytics-stat-card-pink">
                                <div class="analytics-stat-content">
                                    <div class="analytics-stat-label">Average Shelter Temp</div>

                                    <div class="analytics-stat-value">
                                        <%= String.format("%.1f", avgTemp)%>°C
                                    </div>

                                    <div class="analytics-stat-tag">
                                        <i class="fa-solid fa-square-check"></i>
                                        Overall Stability
                                    </div>
                                </div>
                            </div>

                            <div class="analytics-insight-card">
                                <div class="analytics-badge">Verified</div>

                                <div class="analytics-insight-title pink-text">
                                    <i class="fa-solid fa-snowflake"></i>
                                    Cooling Power
                                </div>

                                <div class="analytics-insight-text">
                                    The shelter stays <span class="highlight-green">2.4°C cooler</span> than outside.
                                    This helps prevent heat stress and keeps the cats comfortable.
                                </div>

                                <span class="analytics-strawberry">🍓</span>
                            </div>

                        </div>

                        <div class="analytics-column">

                            <div class="analytics-stat-card analytics-stat-card-green">
                                <div class="analytics-stat-content">
                                    <div class="analytics-stat-label">Average Air Freshness</div>

                                    <div class="analytics-stat-value">
                                        <%= String.format("%.1f", avgHum)%>%
                                    </div>

                                    <div class="analytics-stat-tag green-tag">
                                        <i class="fa-solid fa-wind"></i>
                                        Optimized Humidity
                                    </div>
                                </div>
                            </div>

                            <div class="analytics-insight-card green">
                                <div class="analytics-badge green-badge">Eco-Friendly</div>

                                <div class="analytics-insight-title green-text">
                                    <i class="fa-solid fa-leaf"></i>
                                    Energy Smart
                                </div>

                                <div class="analytics-insight-text">
                                    Smart logic reduces unnecessary fan usage while keeping the shelter fresh and breathable for long stays.
                                </div>

                                <span class="analytics-strawberry">🍓</span>
                            </div>

                        </div>

                    </div>

                    <%
                        String tempAnalysis = "";
                        if (avgTemp == 0.0) {
                            tempAnalysis = "Gathering sensor data to determine environmental stability...";
                        } else if (avgTemp < 24.0) {
                            tempAnalysis = String.format("The current average of <b style='color:#d65a68;'>%.1f°C</b> indicates a cooler environment. The system's smart heater will automatically engage to bring it up to a cozy thermal level.", avgTemp);
                        } else if (avgTemp <= 28.0) {
                            tempAnalysis = String.format("The temperature is perfectly stabilized at <b style='color:#557159;'>%.1f°C</b>. HiroSumi is successfully maintaining an ideal, stress-free thermal zone for the cats.", avgTemp);
                        } else {
                            tempAnalysis = String.format("At <b style='color:#d65a68;'>%.1f°C</b>, the shelter is retaining heat. The automated ventilation fans are actively cycling in fresh, cooler air to prevent heat exhaustion.", avgTemp);
                        }

                        String humAnalysis = "";
                        if (avgHum > 0.0) {
                            if (avgHum > 75.0) {
                                humAnalysis = String.format(" Meanwhile, the humidity is tracking slightly high at <b style='color:#d65a68;'>%.1f%%</b>, triggering our exhaust system to prevent any risk of mold or dampness.", avgHum);
                            } else {
                                humAnalysis = String.format(" Furthermore, the humidity is excellently controlled at <b style='color:#557159;'>%.1f%%</b>, ensuring the air remains crisp and breathable.", avgHum);
                            }
                        }
                    %>

                    <div class="ai-summary-card">

                        <div class="ai-summary-left">
                            <div class="ai-summary-icon">
                                <i class="fa-solid fa-wand-magic-sparkles"></i>
                            </div>

                            <div class="ai-summary-copy">
                                <h3>AI Shelter Health Analysis</h3>
                                <p><%= aiInsight%></p>
                            </div>
                        </div>

                        <div class="ai-summary-badge">
                            <i class="fa-solid fa-clover"></i>
                            Local Smart Analysis
                        </div>

                        <div class="ai-summary-right">
                            <img 
                                src="${pageContext.request.contextPath}/images/cat-sleep.png"
                                alt="Sleeping cat"
                                class="ai-sleep-cat"
                                >
                        </div>

                    </div>

                    <div class="heat-risk-chart-card">
                        <div class="heat-risk-chart-header">
                            <div>
                                <h3>
                                    <i class="fa-solid fa-chart-column"></i>
                                    7-Day Heat Risk Pattern
                                </h3>
                                <p>
                                    Shows how many hot temperature readings were recorded each day.
                                    This helps decide whether the shelter needs stronger ventilation or another fan.
                                </p>
                            </div>

                            <div class="heat-risk-chart-badge">
                                <i class="fa-solid fa-fire"></i>
                                Historical Risk Graph
                            </div>
                        </div>

                        <div class="heat-risk-chart-wrapper">
                            <canvas id="heatRiskChart"></canvas>
                        </div>
                    </div>

                    <div class="decision-support-grid">

                        <div class="decision-card comfort-decision-card">
                            <div class="decision-card-top">
                                <div class="decision-icon pink-icon">
                                    <i class="fa-solid fa-heart-pulse"></i>
                                </div>
                                <span class="decision-label">Comfort Score</span>
                            </div>

                            <div class="comfort-score-row">
                                <div class="comfort-score-number"><%= comfortScore%></div>
                                <div>
                                    <div class="comfort-score-max">/100</div>
                                    <div class="risk-pill"><%= heatRiskLevel%></div>
                                </div>
                            </div>

                            <p>
                                This score converts sensor readings into an easy comfort indicator so caretakers can quickly understand whether the shelter is safe, warm, or needs improvement.
                            </p>
                        </div>

                        <div class="decision-card">
                            <div class="decision-card-top">
                                <div class="decision-icon green-icon">
                                    <i class="fa-solid fa-temperature-high"></i>
                                </div>
                                <span class="decision-label">Heat Pattern Detection</span>
                            </div>

                            <div class="mini-metric-row">
                                <span><strong><%= hotDays7Days%></strong> hot day(s)</span>
                                <span><strong><%= peakHeatPeriod%></strong> peak period</span>
                            </div>

                            <p><%= heatPatternInsight%></p>
                        </div>

                        <div class="decision-card">
                            <div class="decision-card-top">
                                <div class="decision-icon yellow-icon">
                                    <i class="fa-solid fa-fan"></i>
                                </div>
                                <span class="decision-label">Fan Effectiveness</span>
                            </div>

                            <div class="mini-metric-row">
                                <span><strong><%= fanRuntime%></strong> fan runtime</span>
                            </div>

                            <p><%= fanEffectivenessInsight%></p>
                        </div>

                    </div>

                    <div class="crud-section">
                        <div class="table-header">
                            <div>
                                <h3 style="margin:0; color:#3E2723; font-family:'Georgia',serif;">
                                    <i class="fa-solid fa-database" style="color:#557159; margin-right:8px;"></i>
                                    Sensor Data Archive
                                </h3>
                                <span style="font-size:0.8rem; color:#888;">
                                    View sensor history, readings, and cleanup records
                                </span>

                                <% if (!isTechnician) { %>
                                <div class="archive-role-note">
                                    <i class="fa-solid fa-lock"></i>
                                    Cleanup tools are only available for technicians.
                                </div>
                                <% } %>
                            </div>



                            <% if (isTechnician) { %>
                            <button 
                                type="button" 
                                class="btn-delete archive-prune-btn" 
                                onclick="openDeleteModal('prune', null)">
                                <i class="fa-solid fa-broom"></i> Prune Oldest 10
                            </button>
                            <% } %>
                        </div>

                        <div class="table-scroll-wrapper">
                            <table class="crud-table">
                                <thead>
                                    <tr>
                                        <th>Timestamp</th>
                                        <th>Temp (°C)</th>
                                        <th>Hum (%)</th>
                                        <th>Pres (kPa)</th>
                                            <% if (isTechnician) { %>
                                        <th>Actions</th>
                                            <% } %>
                                    </tr>
                                </thead>

                                <tbody>
                                    <%
                                        if (dataList != null && !dataList.isEmpty()) {
                                            for (SensorData s : dataList) {
                                    %>
                                    <tr>
                                        <td><%= s.getTimestamp().toString().substring(0, 16)%></td>
                                        <td><strong><%= String.format("%.2f", s.getTemperature())%></strong></td>
                                        <td><%= String.format("%.2f", s.getHumidity())%></td>
                                        <td><%= String.format("%.2f", s.getPressure())%></td>
                                        <% if (isTechnician) {%>
                                        <td>
                                            <button 
                                                type="button" 
                                                class="btn-action btn-delete" 
                                                title="Delete this Record"
                                                onclick="openDeleteModal('delete', '<%= s.getId()%>')">
                                                <i class="fa-solid fa-trash"></i>
                                            </button>
                                        </td>
                                        <% } %>
                                    </tr>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <tr>
                                        <td colspan="<%= isTechnician ? 5 : 4%>" style="text-align:center; padding:30px; color:#999;">
                                            No data found.
                                        </td>
                                    </tr>
                                    <% }%>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <div id="deleteModal" class="modal">
            <div class="modal-content modal-danger" style="text-align:center;">
                <i class="fa-solid fa-triangle-exclamation" style="font-size:3rem; color:#D32F2F; margin-bottom:15px;"></i>
                <h3 style="margin:0; color:#3E2723; margin-bottom:10px;">Are you sure?</h3>
                <p id="deleteMessage" style="color:#666; margin-bottom:25px;">This action cannot be undone.</p>
                <form action="AnalyticsServlet" method="post">
                    <input type="hidden" name="action" id="modalAction">
                    <input type="hidden" name="id" id="modalId">
                    <div style="display:flex; justify-content:center; gap:10px;">
                        <button type="button" class="btn-cancel" onclick="closeModal('deleteModal')">Cancel</button>
                        <button type="submit" class="btn-confirm-delete">Yes, Delete It</button>
                    </div>
                </form>
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
            function closeModal(id) {
                document.getElementById(id).style.display = "none";
            }
            function openDeleteModal(actionType, id) {
                document.getElementById('modalAction').value = actionType;
                document.getElementById('modalId').value = id || "";
                const msgElement = document.getElementById('deleteMessage');
                msgElement.innerText = (actionType === 'prune') ? "This will permanently delete the 10 oldest records." : "You are about to delete this single record permanently.";
                document.getElementById('deleteModal').style.display = "flex";
            }

            const heatRiskRawData = "<%= heatRiskData%>";
            const heatRiskValues = heatRiskRawData.split(",").map(Number);

            const dayLabels = [];
            const today = new Date();

            for (let i = 6; i >= 0; i--) {
                const date = new Date();
                date.setDate(today.getDate() - i);

                const label = date.toLocaleDateString("en-US", {
                    month: "short",
                    day: "numeric"
                });

                dayLabels.push(label);
            }

            const heatRiskCanvas = document.getElementById("heatRiskChart");

            if (heatRiskCanvas) {
                new Chart(heatRiskCanvas, {
                    type: "bar",
                    data: {
                        labels: dayLabels,
                        datasets: [{
                                label: "Hot readings",
                                data: heatRiskValues,
                                backgroundColor: "rgba(236, 93, 143, 0.55)",
                                borderColor: "rgba(236, 93, 143, 1)",
                                borderWidth: 2,
                                borderRadius: 12,
                                maxBarThickness: 58
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                labels: {
                                    font: {
                                        family: "Quicksand",
                                        weight: "bold"
                                    },
                                    color: "#557159"
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function (context) {
                                        return context.raw + " hot reading(s)";
                                    }
                                }
                            }
                        },
                        scales: {
                            x: {
                                grid: {
                                    display: false
                                },
                                ticks: {
                                    color: "#6d5a52",
                                    font: {
                                        family: "Quicksand",
                                        weight: "bold"
                                    }
                                }
                            },
                            y: {
                                beginAtZero: true,
                                precision: 0,
                                ticks: {
                                    stepSize: 1,
                                    color: "#6d5a52",
                                    font: {
                                        family: "Quicksand",
                                        weight: "bold"
                                    }
                                },
                                grid: {
                                    color: "rgba(85, 113, 89, 0.12)"
                                }
                            }
                        }
                    }
                });
            }
        </script>
    </body>
</html>