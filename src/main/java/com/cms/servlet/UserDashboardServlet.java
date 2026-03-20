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
import java.util.List;

@WebServlet("/user/dashboard")
public class UserDashboardServlet extends HttpServlet {
    private ComplaintDao complaintDao;

    public void init() {
        complaintDao = new ComplaintDao();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        List<Complaint> myComplaints = complaintDao.getComplaintsByUserId(user.getId());
        request.setAttribute("complaints", myComplaints);
        request.getRequestDispatcher("/user_dashboard.jsp").forward(request, response);
    }
}
