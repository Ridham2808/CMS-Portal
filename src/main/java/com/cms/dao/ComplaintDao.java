package com.cms.dao;

import com.cms.model.Complaint;
import com.cms.util.DatabaseConfig;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ComplaintDao {

    public boolean createComplaint(Complaint complaint) {
        String query = "INSERT INTO complaints (title, description, category, user_id) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, complaint.getTitle());
            stmt.setString(2, complaint.getDescription());
            stmt.setString(3, complaint.getCategory() == null ? "General" : complaint.getCategory());
            stmt.setInt(4, complaint.getUserId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Complaint> getComplaintsByUserId(int userId) {
        List<Complaint> list = new ArrayList<>();
        String query = "SELECT c.*, t.name as technician_name FROM complaints c LEFT JOIN users t ON c.technician_id = t.id WHERE c.user_id = ? ORDER BY c.created_at DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapRowToComplaint(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Complaint> getComplaintsByTechnicianId(int technicianId) {
        List<Complaint> list = new ArrayList<>();
        String query = "SELECT c.*, u.name as user_name FROM complaints c JOIN users u ON c.user_id = u.id WHERE c.technician_id = ? ORDER BY c.created_at DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            stmt.setInt(1, technicianId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapRowToComplaintWithUser(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Complaint> getAllComplaints() {
        List<Complaint> list = new ArrayList<>();
        String query = "SELECT c.*, u.name as user_name, t.name as technician_name FROM complaints c JOIN users u ON c.user_id = u.id LEFT JOIN users t ON c.technician_id = t.id ORDER BY c.created_at DESC";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Complaint c = mapRowToComplaintWithUser(rs);
                c.setTechnicianName(rs.getString("technician_name"));
                list.add(c);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean assignTechnician(int complaintId, int technicianId) {
        String query = "UPDATE complaints SET technician_id = ?, status = 'IN_PROGRESS' WHERE id = ?";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setInt(1, technicianId);
            stmt.setInt(2, complaintId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStatus(int complaintId, String status) {
        String query = "UPDATE complaints SET status = ? WHERE id = ?";
        if ("RESOLVED".equals(status) || "REJECTED".equals(status)) {
             query = "UPDATE complaints SET status = ?, resolved_at = CURRENT_TIMESTAMP WHERE id = ?";
        }
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, complaintId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Complaint mapRowToComplaint(ResultSet rs) throws SQLException {
        Complaint c = new Complaint();
        c.setId(rs.getInt("id"));
        c.setTitle(rs.getString("title"));
        c.setDescription(rs.getString("description"));
        try { c.setCategory(rs.getString("category")); } catch (Exception ignored) { c.setCategory("General"); }
        c.setStatus(rs.getString("status"));
        c.setUserId(rs.getInt("user_id"));
        int techId = rs.getInt("technician_id");
        if (!rs.wasNull()) {
            c.setTechnicianId(techId);
        }
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setResolvedAt(rs.getTimestamp("resolved_at"));
        
        try { c.setTechnicianName(rs.getString("technician_name")); } catch(SQLException ignored) {}
        
        return c;
    }

    private Complaint mapRowToComplaintWithUser(ResultSet rs) throws SQLException {
        Complaint c = mapRowToComplaint(rs);
        c.setUserName(rs.getString("user_name"));
        return c;
    }

    // --- Analytics Methods ---

    public java.util.Map<String, Integer> getComplaintsByCategory() {
        java.util.Map<String, Integer> map = new java.util.HashMap<>();
        String query = "SELECT category, COUNT(*) as count FROM complaints GROUP BY category";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             ResultSet rs = stmt.executeQuery();
             while(rs.next()) {
                 map.put(rs.getString("category"), rs.getInt("count"));
             }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }

    public java.util.Map<String, Integer> getResolvedByTechnician() {
        java.util.Map<String, Integer> map = new java.util.HashMap<>();
        String query = "SELECT t.name, COUNT(c.id) as count FROM complaints c JOIN users t ON c.technician_id = t.id WHERE c.status = 'RESOLVED' GROUP BY t.name";
        try (Connection conn = DatabaseConfig.getConnection();
             PreparedStatement stmt = conn.prepareStatement(query)) {
             ResultSet rs = stmt.executeQuery();
             while(rs.next()) {
                 map.put(rs.getString("name"), rs.getInt("count"));
             }
        } catch (SQLException e) { e.printStackTrace(); }
        return map;
    }
}
