<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - CMS</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
    <div class="auth-wrapper">
        <div class="auth-card">
            <h2>Create Account</h2>
            
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <form action="register" method="post">
                <div class="form-group">
                    <label for="name">Full Name</label>
                    <input type="text" id="name" name="name" class="form-control" placeholder="John Doe" required>
                </div>
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" placeholder="you@example.com" required>
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required>
                </div>
                
                <div class="form-group">
                    <label for="role">Account Type</label>
                    <select id="role" name="role" class="form-control" required>
                        <option value="USER">User (Submit Complaints)</option>
                        <option value="TECHNICIAN">Technician (Resolve Complaints)</option>
                    </select>
                </div>

                <button type="submit" class="btn">Sign Up</button>
            </form>
            <div class="auth-links">
                Already have an account? <a href="login">Sign In</a>
            </div>
        </div>
    </div>
</body>
</html>
