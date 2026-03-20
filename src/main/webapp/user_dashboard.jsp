<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - CMS</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <nav class="navbar">
        <a href="dashboard" class="logo">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/></svg>
            CMS Portal
        </a>
        <div class="nav-links">
            <span>Welcome, ${sessionScope.user.name}</span>
            <a href="../logout" class="btn-logout">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div class="dashboard-header">
            <div>
                <h1>My Complaints</h1>
                <p>Track your submitted complaints in real-time</p>
            </div>
            <button class="btn" style="width: auto; padding: 0.75rem 1.5rem;" onclick="document.getElementById('newComplaint').scrollIntoView({behavior:'smooth'})">
                + New Complaint
            </button>
        </div>

        <c:if test="${param.success == 'created'}">
            <div class="alert alert-success">Complaint successfully submitted!</div>
        </c:if>

        <div class="grid">
            <c:choose>
                <c:when test="${empty complaints}">
                    <div class="card" style="grid-column: 1 / -1; text-align: center; padding: 3rem;">
                        <p>You haven't submitted any complaints yet.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="c" items="${complaints}">
                        <div class="card">
                            <div class="card-header">
                                <div>
                                    <h3 class="card-title">${c.title}</h3>
                                    <span class="card-date"><fmt:formatDate value="${c.createdAt}" pattern="MMM dd, yyyy HH:mm"/> | ${c.category}</span>
                                </div>
                                <span class="badge ${c.status}">${c.status}</span>
                            </div>
                            <div class="card-body">
                                ${c.description}
                                
                                <!-- Live Status Tracker Timeline -->
                                <div class="tracker-container">
                                    <div class="tracker-step active">
                                        <div class="tracker-dot"></div>
                                        <span class="tracker-label">Logged</span>
                                    </div>
                                    <div class="tracker-step ${not empty c.technicianName ? 'active' : ''}">
                                        <div class="tracker-dot"></div>
                                        <span class="tracker-label">Assigned</span>
                                    </div>
                                    <div class="tracker-step ${(c.status == 'IN_PROGRESS' || c.status == 'RESOLVED') ? 'active' : ''}">
                                        <div class="tracker-dot"></div>
                                        <span class="tracker-label">Progress</span>
                                    </div>
                                    <div class="tracker-step ${(c.status == 'RESOLVED' || c.status == 'REJECTED') ? 'active' : ''}">
                                        <div class="tracker-dot"></div>
                                        <span class="tracker-label">${c.status == 'REJECTED' ? 'Rejected' : 'Resolved'}</span>
                                    </div>
                                </div>
                                
                            </div>
                            <div class="card-footer">
                                <span>Tech: ${not empty c.technicianName ? c.technicianName : 'Unassigned'}</span>
                                <c:if test="${c.status == 'RESOLVED' || c.status == 'REJECTED'}">
                                    <span>Closed: <fmt:formatDate value="${c.resolvedAt}" pattern="MMM dd"/></span>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <div id="newComplaint" class="new-complaint-section">
            <h3>Submit a New Complaint</h3>
            <form action="submit-complaint" method="post">
                <div class="form-group">
                    <label for="category">Category</label>
                    <select id="category" name="category" class="form-control" required>
                        <option value="Hardware">Hardware Issues</option>
                        <option value="Software">Software & OS</option>
                        <option value="Network">Network & Internet</option>
                        <option value="General" selected>General Inquiry</option>
                    </select>
                </div>
                <!-- FAQ Overlay logic -->
                <div class="form-group" style="position:relative;">
                    <label for="title">Complaint Title</label>
                    <input type="text" id="title" name="title" class="form-control" required placeholder="Brief summary of the issue" onkeyup="checkFAQ(this.value)">
                    <div id="faqPopup" class="faq-overlay"></div>
                </div>
                <div class="form-group">
                    <label for="description">Detailed Description</label>
                    <textarea id="description" name="description" class="form-control" required placeholder="Please describe the issue in detail..."></textarea>
                </div>
                <button type="submit" class="btn" style="max-width: 200px;">Submit Complaint</button>
            </form>
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
            // Auto reload after 2 seconds to show timeline updates
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

        // Smart Auto-Suggest (FAQ Deflection)
        const faqs = [
            { keywords: ['password', 'login', 'access'], title: 'Password Reset', desc: 'Try clicking "Forgot Password" on the login screen. Or try clearing your browser cache.' },
            { keywords: ['internet', 'wifi', 'network', 'connection'], title: 'Network Down?', desc: 'Check if your router lights are green. Restart your router, wait 60 seconds, and try again.' },
            { keywords: ['printer', 'print', 'paper'], title: 'Printer Issues', desc: 'Ensure the printer is turned on and selected as the default device. Check for paper jams.' },
            { keywords: ['slow', 'lag', 'freeze'], title: 'System Lag', desc: 'Restart your computer. Ensure no heavy updates are running in the background.' }
        ];

        function checkFAQ(val) {
            const popup = document.getElementById('faqPopup');
            if(val.length < 3) {
                popup.style.display = 'none';
                return;
            }
            
            const lowerVal = val.toLowerCase();
            let matches = [];
            
            for(let faq of faqs) {
                for(let k of faq.keywords) {
                    if(lowerVal.includes(k)) {
                        matches.push(faq);
                        break;
                    }
                }
            }
            
            if(matches.length > 0) {
                let html = '<div><span style="font-size:0.75rem; color:var(--text-muted); text-transform:uppercase;">Try these DIY fixes before submitting:</span></div>';
                matches.forEach(m => {
                    html += '<div class="faq-item"><h4>' + m.title + '</h4><p>' + m.desc + '</p></div>';
                });
                popup.innerHTML = html;
                popup.style.display = 'block';
            } else {
                popup.style.display = 'none';
            }
        }
    </script>
</body>
</html>
