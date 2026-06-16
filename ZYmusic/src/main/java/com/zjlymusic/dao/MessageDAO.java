package com.zjlymusic.dao;

import com.zjlymusic.entity.Message;
import com.zjlymusic.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MessageDAO {

    public void addMessage(Message msg) {
        String sql = "INSERT INTO messages (sender_id, receiver_id, content, send_time) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, msg.getSenderId());
            stmt.setInt(2, msg.getReceiverId());
            stmt.setString(3, msg.getContent());
            stmt.setTimestamp(4, new java.sql.Timestamp(msg.getSendTime().getTime()));
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Message> getMessagesBetweenUsers(int userId1, int userId2, int limit) {
        List<Message> list = new ArrayList<>();
        String sql = "SELECT m.*, " +
            "s.username as sender_username, s.avatar as sender_avatar, " +
            "r.username as receiver_username, r.avatar as receiver_avatar " +
            "FROM messages m " +
            "LEFT JOIN users s ON m.sender_id = s.id " +
            "LEFT JOIN users r ON m.receiver_id = r.id " +
            "WHERE (m.sender_id = ? AND m.receiver_id = ?) " +
            "   OR (m.sender_id = ? AND m.receiver_id = ?) " +
            "ORDER BY m.send_time ASC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId1);
            stmt.setInt(2, userId2);
            stmt.setInt(3, userId2);
            stmt.setInt(4, userId1);
            stmt.setInt(5, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapMessage(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Message mapMessage(ResultSet rs) throws SQLException {
        Message m = new Message();
        m.setId(rs.getInt("id"));
        m.setSenderId(rs.getInt("sender_id"));
        m.setReceiverId(rs.getInt("receiver_id"));
        m.setContent(rs.getString("content"));
        m.setSendTime(rs.getTimestamp("send_time"));
        m.setSenderUsername(rs.getString("sender_username"));
        m.setSenderAvatar(rs.getString("sender_avatar"));
        m.setReceiverUsername(rs.getString("receiver_username"));
        m.setReceiverAvatar(rs.getString("receiver_avatar"));
        return m;
    }
}
