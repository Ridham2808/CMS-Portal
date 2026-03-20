package com.cms.servlet;

import com.cms.dao.ComplaintDao;
import com.cms.model.Complaint;
import com.cms.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import com.cms.websocket.NotificationServer;

@WebServlet("/user/submit-complaint")
public class SubmitComplaintServlet extends HttpServlet {
    private ComplaintDao complaintDao;

    public void init() {
        complaintDao = new ComplaintDao();
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("../login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"USER".equals(user.getRole())) {
            response.sendRedirect("../login");
            return;
        }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");

        Complaint complaint = new Complaint();
        complaint.setTitle(title);
        complaint.setDescription(description);
        complaint.setCategory(category != null ? category : "General");
        complaint.setUserId(user.getId());

        if (complaintDao.createComplaint(complaint)) {
            NotificationServer.sendToRole("ADMIN", "New Complaint via " + user.getName());
            response.sendRedirect("dashboard?success=created");
        } else {
            response.sendRedirect("dashboard?error=failed");
        }
    }
}
