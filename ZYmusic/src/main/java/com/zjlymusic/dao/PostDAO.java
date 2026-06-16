package com.zjlymusic.dao;

import com.zjlymusic.entity.Post;
import com.zjlymusic.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PostDAO {
    public void addPost(Post post) {
        String sql = "INSERT INTO posts (content, user_id, username, post_time) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, post.getContent());
            stmt.setInt(2, post.getUserId());
            stmt.setString(3, post.getUsername());
            stmt.setTimestamp(4, new java.sql.Timestamp(post.getPostTime().getTime()));
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public List<Post> getAllPosts() {
        List<Post> list = new ArrayList<>();
        String sql = "SELECT * FROM posts ORDER BY post_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(new Post(
                    rs.getInt("id"),
                    rs.getString("content"),
                    rs.getInt("user_id"),
                    rs.getString("username"),
                    rs.getTimestamp("post_time")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    
    public Post getPostById(int postId) {
        String sql = "SELECT * FROM posts WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, postId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return new Post(
                    rs.getInt("id"),
                    rs.getString("content"),
                    rs.getInt("user_id"),
                    rs.getString("username"),
                    rs.getTimestamp("post_time")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Post> getPostsByUserId(int userId) {
        List<Post> list = new ArrayList<>();
        String sql = "SELECT * FROM posts WHERE user_id = ? ORDER BY post_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(new Post(
                    rs.getInt("id"),
                    rs.getString("content"),
                    rs.getInt("user_id"),
                    rs.getString("username"),
                    rs.getTimestamp("post_time")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void updateUsernameByUserId(int userId, String newUsername) {
        String sql = "UPDATE posts SET username = ? WHERE user_id = ?";
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