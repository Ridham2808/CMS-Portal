<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Technician Dashboard - CMS</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <nav class="navbar">
        <a href="dashboard" class="logo" style="color: #818cf8;">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M14.7 6.3a1 1 0 0 0 0 1.4l1.6 1.6a1 1 0 0 0 1.4 0l3.77-3.77a6 6 0 0 1-7.94 7.94l-6.91 6.91a2.12 2.12 0 0 1-3-3l6.91-6.91a6 6 0 0 1 7.94-7.94l-3.76 3.76z"/></svg>
            Tech Portal
        </a>
        <div class="nav-links">
            <span>Tech: ${sessionScope.user.name}</span>
            <a href="../logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="dashboard-header">
            <div>
                <h1>Assigned Tasks</h1>
                <p>Manage and resolve complaints assigned to you</p>
            </div>
        </div>

        <c:if test="${param.success == 'updated'}">
            <div class="alert alert-success">Status updated successfully!</div>
        </c:if>

        <div class="grid">
            <c:choose>
                <c:when test="${empty complaints}">
                    <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 3rem;">
                        <p>No complaints assigned to you currently. Good job!</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="c" items="${complaints}">
                        <div class="card">
                            <div class="card-header">
                                <div>
                                    <h3 class="card-title">#${c.id} - ${c.title}</h3>
                                    <span class="card-date">${c.category} | From: ${c.userName} on <fmt:formatDate value="${c.createdAt}" pattern="MMM dd, yyyy"/></span>
                                </div>
                                <span class="badge ${c.status}">${c.status}</span>
                            </div>
                            <div class="card-body">
                                <strong>Description:</strong><br>
                                ${c.description}
                            </div>
                            <div class="card-footer">
                                <c:if test="${c.status != 'RESOLVED' && c.status != 'REJECTED'}">
                                    <form action="../action/update-complaint" method="post" class="action-form">
                                        <input type="hidden" name="action" value="status">
                                        <input type="hidden" name="complaintId" value="${c.id}">
                                        <select name="status">
                                            <option value="IN_PROGRESS" ${c.status == 'IN_PROGRESS' ? 'selected' : ''}>In Progress</option>
                                            <option value="RESOLVED">Resolved</option>
                                            <option value="REJECTED">Rejected</option>
                                        </select>
                                        <button type="submit" class="btn-sm">Update</button>
                                    </form>
                                </c:if>
                                <c:if test="${c.status == 'RESOLVED' || c.status == 'REJECTED'}">
                                    <span>Closed at: <fmt:formatDate value="${c.resolvedAt}" pattern="MMM dd, yyyy HH:mm"/></span>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
    
    <div id="toast-container"></div>

    <script>
        // WebSockets Notification Client
        const userId = "${sessionScope.user.id}";
        const protocol = window.location.protocol === 'https:' ? 'wss://' : 'ws://';
        const wsUrl = protocol + window.location.host + "/ws/notifications/USER/" + userId;
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
    </script>
</body>
</html>
