package com.cms.servlet;

import com.cms.dao.ComplaintDao;
import com.cms.model.User;
import com.cms.model.Complaint;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import com.cms.websocket.NotificationServer;

@WebServlet("/action/update-complaint")
public class UpdateComplaintServlet extends HttpServlet {
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
        String action = request.getParameter("action");
        int complaintId = Integer.parseInt(request.getParameter("complaintId"));

        if ("ADMIN".equals(user.getRole()) && "assign".equals(action)) {
            int technicianId = Integer.parseInt(request.getParameter("technicianId"));
            complaintDao.assignTechnician(complaintId, technicianId);
            
            // Notify Technician and User
            NotificationServer.sendToUser(String.valueOf(technicianId), "You have been assigned to Complaint #" + complaintId);
            
            response.sendRedirect("../admin/dashboard?success=assigned");
            return;
        }

        if ("TECHNICIAN".equals(user.getRole()) && "status".equals(action)) {
            String newStatus = request.getParameter("status"); // IN_PROGRESS, RESOLVED, REJECTED
            complaintDao.updateStatus(complaintId, newStatus);
            
            // Notify Admin
            NotificationServer.sendToRole("ADMIN", "Complaint #" + complaintId + " status changed to " + newStatus);
            // Notify User (since we don't have user_id easily here, we could add it. Or just broadcast if we fetch the complaint first).
            // Actually, ComplaintDao.updateStatus doesn't return the complaint. For simplicity right now, notifying ADMIN is enough, user can track on dashboard. 
            // Better: update UpdateComplaintServlet to fetch the complaint first. Let's do it quick.
            for(Complaint c : complaintDao.getAllComplaints()) {
                if(c.getId() == complaintId) {
                    NotificationServer.sendToUser(String.valueOf(c.getUserId()), "Your Complaint #" + complaintId + " is now " + newStatus);
                    break;
                }
            }
            
            response.sendRedirect("../technician/dashboard?success=updated");
            return;
        }
        
        if ("ADMIN".equals(user.getRole()) && "status".equals(action)) {
            String newStatus = request.getParameter("status"); 
            complaintDao.updateStatus(complaintId, newStatus);
            response.sendRedirect("../admin/dashboard?success=updated");
            return;
        }

        response.sendRedirect("../login"); // fallback
    }
}
