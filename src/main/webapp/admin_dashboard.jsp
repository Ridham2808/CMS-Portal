<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - CMS</title>
    <link rel="stylesheet" href="../css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <nav class="navbar">
        <a href="dashboard" class="logo" style="color: #6ee7b7;">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="9" y1="3" x2="9" y2="21"/></svg>
            Admin Panel
        </a>
        <div class="nav-links">
            <span>Admin: ${sessionScope.user.name}</span>
            <a href="../logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="dashboard-header">
            <div>
                <h1>Global Analytics & Oversight</h1>
                <p>Monitor system complaints, analytics heatmaps and assignments in real-time.</p>
            </div>
        </div>
        
        <!-- Phase 2: Analytics Charts -->
        <div class="charts-grid">
            <div class="chart-container">
                <canvas id="categoryChart"></canvas>
            </div>
            <div class="chart-container">
                <canvas id="techChart"></canvas>
            </div>
        </div>

        <c:if test="${param.success == 'assigned'}">
            <div class="alert alert-success">Technician assigned successfully!</div>
        </c:if>
        <c:if test="${param.success == 'updated'}">
            <div class="alert alert-success">Status updated successfully!</div>
        </c:if>

        <div class="table-wrapper">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>User</th>
                        <th>Category</th>
                        <th>Title</th>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Technician</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${empty complaints}">
                            <tr><td colspan="8" style="text-align:center; padding: 2rem;">No complaints found in the system.</td></tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="c" items="${complaints}">
                                <tr>
                                    <td>#${c.id}</td>
                                    <td>${c.userName}</td>
                                    <td><span style="color:var(--text-muted); font-size:0.8rem;">${c.category}</span></td>
                                    <td><strong>${c.title}</strong></td>
                                    <td><fmt:formatDate value="${c.createdAt}" pattern="MMM dd, yyyy"/></td>
                                    <td><span class="badge ${c.status}">${c.status}</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${empty c.technicianName}">
                                                <span style="color: var(--danger);">Unassigned</span>
                                            </c:when>
                                            <c:otherwise>
                                                ${c.technicianName}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:if test="${c.status == 'PENDING'}">
                                            <form action="../action/update-complaint" method="post" class="action-form">
                                                <input type="hidden" name="action" value="assign">
                                                <input type="hidden" name="complaintId" value="${c.id}">
                                                <select name="technicianId" required>
                                                    <option value="" disabled selected>Assign Tech...</option>
                                                    <c:forEach var="t" items="${technicians}">
                                                        <option value="${t.id}">${t.name}</option>
                                                    </c:forEach>
                                                </select>
                                                <button type="submit" class="btn-sm">Save</button>
                                            </form>
                                        </c:if>
                                        <c:if test="${c.status != 'PENDING'}">
                                           <span style="font-size: 0.8rem; color: var(--text-muted);">
                                                <c:if test="${c.status == 'RESOLVED'}">Resolved on <fmt:formatDate value="${c.resolvedAt}" pattern="MMM dd"/></c:if>
                                                <c:if test="${c.status != 'RESOLVED'}">In Progress / Rejected</c:if>
                                           </span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <div id="toast-container"></div>

    <script>
        // WebSockets Notification Client
        const protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
        const wsUrl = protocol + window.location.host + "/ws/notifications/ADMIN/admin";
        const ws = new WebSocket(wsUrl);
        
        ws.onmessage = function(event) {
            showToast(event.data);
            setTimeout(() => window.location.reload(), 2000);
        };
        
        function showToast(msg) {
            const container = document.getElementById('toast-container');
            const toast = document.createElement('div');
            toast.className = 'toast';
            toast.innerText = msg;
            container.appendChild(toast);
            setTimeout(() => { toast.remove(); }, 5000);
        }

        // --- Chart.js Analytics logic ---
        // Cleanse attributes passed from servlet strings (e.g. "[Hardware, Network]" -> "Hardware","Network")
        function parseArrayStr(str) {
            if(!str || str === '[]') return [];
            return str.replace('[', '').replace(']', '').split(',').map(s => s.trim());
        }
        
        const catLabelsRaw = "${categoryLabels}";
        const catValuesRaw = "${categoryValues}";
        const techLabelsRaw = "${techLabels}";
        const techValuesRaw = "${techValues}";

        const catLabels = parseArrayStr(catLabelsRaw);
        const catValues = parseArrayStr(catValuesRaw).map(Number);
        const techLabels = parseArrayStr(techLabelsRaw);
        const techValues = parseArrayStr(techValuesRaw).map(Number);

        // Chart defaults
        Chart.defaults.color = '#8b95a5';
        Chart.defaults.font.family = "'Space Grotesk', sans-serif";

        // Category Doughnut Chart
        new Chart(document.getElementById('categoryChart'), {
            type: 'doughnut',
            data: {
                labels: (catLabels.length > 0) ? catLabels : ['No Data'],
                datasets: [{
                    data: (catValues.length > 0) ? catValues : [1],
                    backgroundColor: ['#00F0FF', '#FF003C', '#7000FF', '#FFB800'],
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: { display: true, text: 'Complaints Heatmap by Category', color: '#fff', font: {size: 16} }
                }
            }
        });

        // Technician Performance Chart
        new Chart(document.getElementById('techChart'), {
            type: 'bar',
            data: {
                labels: (techLabels.length > 0) ? techLabels : ['No Data'],
                datasets: [{
                    label: 'Resolved Complaints',
                    data: (techValues.length > 0) ? techValues : [0],
                    backgroundColor: 'rgba(0, 240, 255, 0.5)',
                    borderColor: '#00F0FF',
                    borderWidth: 1,
                    borderRadius: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    title: { display: true, text: 'Technician Speed & Performance', color: '#fff', font: {size: 16} }
                },
                scales: {
                    y: { beginAtZero: true, grid: { color: 'rgba(255,255,255,0.05)' } },
                    x: { grid: { display: false } }
                }
            }
        });
    </script>
</body>
</html>
