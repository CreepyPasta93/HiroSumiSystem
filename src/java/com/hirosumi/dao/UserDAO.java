package com.hirosumi.dao;

import java.util.ArrayList;
import java.util.List;
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
                dbHash = rs.getString("password_hash");
                String dbRole = rs.getString("role");
                boolean verified = rs.getBoolean("is_verified");

                if (!verified) {
                    return null;
                }

                if (BCrypt.checkpw(password, dbHash)) {
                    if (dbRole.equalsIgnoreCase(selectedRole)) {
                        user = new User();
                        user.setUserId(rs.getInt("userId"));
                        user.setUsername(rs.getString("username"));
                        user.setFullName(rs.getString("fullName"));
                        user.setRole(dbRole);
                        user.setEmail(rs.getString("email"));
                        user.setProfileImage(rs.getString("profile_image"));
                        user.setMustChangePassword(rs.getBoolean("must_change_password"));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return user;
    }

    public boolean registerUser(User user, String password, String token, LocalDateTime expiry) {
        boolean isSuccess = false;

        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

        String sql = "INSERT INTO user (username, password_hash, fullName, email, role, is_verified, verification_token, token_expiry) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, user.getUsername());
            ps.setString(2, hashedPassword);
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, "Volunteer");
            ps.setBoolean(6, false);
            ps.setString(7, token);
            ps.setTimestamp(8, Timestamp.valueOf(expiry));

            int rows = ps.executeUpdate();
            if (rows > 0) {
                isSuccess = true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    public boolean isUsernameExists(String username) {
        String sql = "SELECT userId FROM user WHERE username = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean isEmailExists(String email) {
        String sql = "SELECT userId FROM user WHERE email = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    public boolean isUserVerified(String username) {
        String sql = "SELECT is_verified FROM user WHERE username = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getBoolean("is_verified");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    //Verify User
    public boolean verifyUserByToken(String token) {
        String sql = "UPDATE user SET is_verified = 1, verification_token = NULL, token_expiry = NULL "
                + "WHERE verification_token = ? AND token_expiry > NOW()";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, token);
            int rows = ps.executeUpdate();
            return rows > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
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

    public boolean updatePasswordByUserId(int userId, String newPassword) {
        boolean isSuccess = false;

        String hashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

        String sql = "UPDATE user SET password_hash = ?, must_change_password = 0 WHERE userId = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, hashedPassword);
            ps.setInt(2, userId);

            int rows = ps.executeUpdate();
            if (rows > 0) {
                isSuccess = true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    // GET ALL USERS FOR TECHNICIAN ROLE MANAGEMENT
    public List<User> getAllUsers() {
        List<User> users = new ArrayList<>();

        String sql = "SELECT userId, username, fullName, role, email, profile_image, must_change_password "
                + "FROM user "
                + "ORDER BY role ASC, fullName ASC";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                User user = new User();
                user.setUserId(rs.getInt("userId"));
                user.setUsername(rs.getString("username"));
                user.setFullName(rs.getString("fullName"));
                user.setRole(rs.getString("role"));
                user.setEmail(rs.getString("email"));
                user.setProfileImage(rs.getString("profile_image"));
                user.setMustChangePassword(rs.getBoolean("must_change_password"));

                users.add(user);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return users;
    }

// UPDATE USER ROLE - ONLY ALLOW VOLUNTEER OR TECHNICIAN
    public boolean updateUserRole(int userId, String newRole) {
        if (newRole == null) {
            return false;
        }

        if (!newRole.equalsIgnoreCase("Volunteer") && !newRole.equalsIgnoreCase("Technician")) {
            return false;
        }

        String normalizedRole = newRole.equalsIgnoreCase("Technician") ? "Technician" : "Volunteer";

        String sql = "UPDATE user SET role = ? WHERE userId = ?";

        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, normalizedRole);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

}
