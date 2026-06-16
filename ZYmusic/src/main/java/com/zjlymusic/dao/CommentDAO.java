package com.zjlymusic.dao;

import com.zjlymusic.entity.Comment;
import com.zjlymusic.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {
    public int addComment(Comment comment) {
        String sql = "INSERT INTO comments (content, user_id, username, music_id, post_id, parent_id, parent_username, comment_time) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, comment.getContent());
            stmt.setInt(2, comment.getUserId());
            stmt.setString(3, comment.getUsername());
            if (comment.getMusicId() > 0) {
                stmt.setInt(4, comment.getMusicId());
            } else {
                stmt.setNull(4, java.sql.Types.INTEGER);
            }
            if (comment.getPostId() > 0) {
                stmt.setInt(5, comment.getPostId());
            } else {
                stmt.setNull(5, java.sql.Types.INTEGER);
            }
            if (comment.getParentId() > 0) {
                stmt.setInt(6, comment.getParentId());
            } else {
                stmt.setNull(6, java.sql.Types.INTEGER);
            }
            stmt.setString(7, comment.getParentUsername());
            stmt.setTimestamp(8, new java.sql.Timestamp(comment.getCommentTime().getTime()));
            stmt.executeUpdate();
            ResultSet keys = stmt.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Comment> getCommentsByMusicId(int musicId) {
        List<Comment> list = new ArrayList<>();
        String sql = "SELECT * FROM comments WHERE music_id = ? ORDER BY comment_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, musicId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapComment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Comment> getCommentsByPostId(int postId) {
        List<Comment> list = new ArrayList<>();
        String sql = "SELECT * FROM comments WHERE post_id = ? ORDER BY comment_time ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapComment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Comment mapComment(ResultSet rs) throws SQLException {
        Comment comment = new Comment(
            rs.getInt("id"),
            rs.getString("content"),
            rs.getInt("user_id"),
            rs.getString("username"),
            rs.getInt("music_id"),
            rs.getTimestamp("comment_time")
        );
        try { comment.setPostId(rs.getInt("post_id")); } catch (SQLException e) { }
        try { comment.setParentId(rs.getInt("parent_id")); } catch (SQLException e) { }
        try { comment.setParentUsername(rs.getString("parent_username")); } catch (SQLException e) { }
        return comment;
    }

    public List<Comment> getCommentsByUserId(int userId) {
        List<Comment> list = new ArrayList<>();
        String sql = "SELECT * FROM comments WHERE user_id = ? ORDER BY comment_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapComment(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void updateUsernameByUserId(int userId, String newUsername) {
        String sql = "UPDATE comments SET username = ? WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newUsername);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
