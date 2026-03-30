package com.hirosumi.dao;

import static com.hirosumi.dao.DBConnection.getConnection;
import com.hirosumi.model.User;
import java.sql.*;
import java.time.LocalDateTime;
import org.mindrot.jbcrypt.BCrypt;

public class UserDAO {

    public User authenticateUser(String username, String password, String selectedRole) {
        User user = null;
        String dbHash = null;

        // 1. Find user by username ONLY first
        String sql = "SELECT * FROM user WHERE username = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                // User exists, now retrieve the stored hash
                dbHash = rs.getString("password_hash");
                String dbRole = rs.getString("role");

                // 2. VERIFY PASSWORD using BCrypt
                // BCrypt.checkpw(plain_text, stored_hash) returns true if they match
                if (BCrypt.checkpw(password, dbHash)) {

                    // 3. VERIFY ROLE
                    // Ensure the user is logging in with the correct role
                    if (dbRole.equalsIgnoreCase(selectedRole)) {
                        user = new User();
                        user.setUserId(rs.getInt("userId"));
                        user.setUsername(rs.getString("username"));
                        user.setFullName(rs.getString("fullName"));
                        user.setRole(dbRole);
                        user.setEmail(rs.getString("email"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    public boolean registerUser(User user, String password) {
        boolean isSuccess = false;

        // 1. HASH THE PASSWORD using BCrypt
        // gensalt() creates a random salt every time
        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        String sql = "INSERT INTO user (username, password_hash, fullName, email, role) VALUES (?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, hashedPassword); // SAVE THE HASH, NOT THE PLAIN TEXT
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, "Volunteer");

            int rows = ps.executeUpdate();
            if (rows > 0) {
                isSuccess = true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return isSuccess;
    }

    // UPDATE USER DETAILS
    public boolean updateUser(User user) {
        boolean isSuccess = false;

        // SQL now updates profile_image column too
        String sql = "UPDATE user SET fullName = ?, email = ?, username = ?, profile_image = ? WHERE userId = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getUsername());

            // If image is null/empty, keep the old one (logic should be handled in Servlet, but safe here)
            ps.setString(4, user.getProfileImage());

            ps.setInt(5, user.getUserId());

            int rows = ps.executeUpdate();
            if (rows > 0) {
                isSuccess = true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return isSuccess;
    }

    // DELETE ACCOUNT
    public boolean deleteUser(int userId) {
        boolean isSuccess = false;
        String sql = "DELETE FROM user WHERE userId = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                isSuccess = true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return isSuccess;
    }

    public void saveResetToken(String email, String token, LocalDateTime expiry) {
        String sql = "INSERT INTO password_reset_tokens (email, token, expiry) VALUES (?, ?, ?)";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setString(2, token);
            ps.setTimestamp(3, Timestamp.valueOf(expiry));
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public String validateResetToken(String token) {
        String sql
                = "SELECT email FROM password_reset_tokens "
                + "WHERE token = ? AND expiry > NOW()";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, token);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getString("email"); // valid token
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null; // invalid or expired
    }

    // 1. UPDATE THE ACTUAL PASSWORD IN THE USER TABLE
    public boolean updatePasswordByEmail(String email, String newPassword) {
        boolean isSuccess = false;

        // Hash the new password before saving!
        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        String sql = "UPDATE user SET password_hash = ? WHERE email = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, hashedPassword);
            ps.setString(2, email);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                isSuccess = true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return isSuccess;
    }

    // 2. DELETE THE TOKEN AFTER SUCCESSFUL RESET (Security best practice)
    public void deleteResetToken(String token) {
        String sql = "DELETE FROM password_reset_tokens WHERE token = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}
