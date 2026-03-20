package com.cms.servlet;

import com.cms.dao.ComplaintDao;
import com.cms.dao.UserDao;
import com.cms.model.Complaint;
import com.cms.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private ComplaintDao complaintDao;
    private UserDao userDao;

    public void init() {
        complaintDao = new ComplaintDao();
        userDao = new UserDao();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("../login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (!"ADMIN".equals(user.getRole())) {
            response.sendRedirect("../login");
            return;
        }

        List<Complaint> allComplaints = complaintDao.getAllComplaints();
        List<User> technicians = userDao.getUsersByRole("TECHNICIAN");
        
        // Analytics
        Map<String, Integer> categoryData = complaintDao.getComplaintsByCategory();
        Map<String, Integer> techData = complaintDao.getResolvedByTechnician();

        // Convert Maps to JSON Strings for JSP usage directly mapping to ChartJS
        request.setAttribute("complaints", allComplaints);
        request.setAttribute("technicians", technicians);
        
        request.setAttribute("categoryLabels", categoryData.keySet().toString());
        request.setAttribute("categoryValues", categoryData.values().toString());
        
        request.setAttribute("techLabels", techData.keySet().toString());
        request.setAttribute("techValues", techData.values().toString());
        
        request.getRequestDispatcher("/admin_dashboard.jsp").forward(request, response);
    }
}
