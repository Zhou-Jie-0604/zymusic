package com.zjlymusic.dao;

import com.zjlymusic.entity.Notification;
import com.zjlymusic.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public void addNotification(Notification n) {
        String sql = "INSERT INTO notifications (user_id, type, from_user_id, from_username, content, related_id, related_type, create_time, is_read) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, n.getUserId());
            stmt.setString(2, n.getType());
            stmt.setInt(3, n.getFromUserId());
            stmt.setString(4, n.getFromUsername());
            stmt.setString(5, n.getContent());
            stmt.setInt(6, n.getRelatedId());
            stmt.setString(7, n.getRelatedType());
            stmt.setTimestamp(8, new java.sql.Timestamp(n.getCreateTime().getTime()));
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Notification> getNotifications(int userId, int limit) {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT n.*, u.avatar as from_avatar " +
            "FROM notifications n " +
            "LEFT JOIN users u ON n.from_user_id = u.id " +
            "WHERE n.user_id = ? " +
            "ORDER BY n.create_time DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapNotification(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void markAsRead(int notificationId) {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, notificationId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    private Notification mapNotification(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setType(rs.getString("type"));
        n.setFromUserId(rs.getInt("from_user_id"));
        n.setFromUsername(rs.getString("from_username"));
        n.setContent(rs.getString("content"));
        n.setRelatedId(rs.getInt("related_id"));
        n.setRelatedType(rs.getString("related_type"));
        n.setCreateTime(rs.getTimestamp("create_time"));
        n.setRead(rs.getInt("is_read") != 0);
        n.setFromUserAvatar(rs.getString("from_avatar"));
        return n;
    }
}
