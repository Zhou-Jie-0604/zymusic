package com.zjlymusic.dao;

import com.zjlymusic.entity.Music;
import com.zjlymusic.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MusicDAO {
    public void addMusic(Music music) {
        String sql = "INSERT INTO music (name, artist, url, type, cover, user_id, username, upload_time, duration) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, music.getName());
            stmt.setString(2, music.getArtist());
            stmt.setString(3, music.getUrl());
            stmt.setString(4, music.getType());
            stmt.setString(5, music.getCover());
            stmt.setInt(6, music.getUserId());
            stmt.setString(7, music.getUsername());
            stmt.setTimestamp(8, new java.sql.Timestamp(music.getUploadTime().getTime()));
            stmt.setInt(9, music.getDuration());
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Music> getAllMusic() {
        List<Music> list = new ArrayList<>();
        String sql = "SELECT * FROM music ORDER BY upload_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapMusic(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Music> getLatestMusic(int limit) {
        List<Music> list = new ArrayList<>();
        String sql = "SELECT * FROM music ORDER BY upload_time DESC LIMIT ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapMusic(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Music> getMusicByUserId(int userId) {
        List<Music> list = new ArrayList<>();
        String sql = "SELECT * FROM music WHERE user_id = ? ORDER BY upload_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapMusic(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Music getMusicById(int id) {
        String sql = "SELECT * FROM music WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapMusic(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Music> searchMusic(String keyword) {
        List<Music> list = new ArrayList<>();
        String sql = "SELECT * FROM music WHERE name LIKE ? OR artist LIKE ? OR type LIKE ? OR username LIKE ? ORDER BY upload_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String pattern = "%" + keyword + "%";
            stmt.setString(1, pattern);
            stmt.setString(2, pattern);
            stmt.setString(3, pattern);
            stmt.setString(4, pattern);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapMusic(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void updateUsernameByUserId(int userId, String newUsername) {
        String sql = "UPDATE music SET username = ? WHERE user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newUsername);
            stmt.setInt(2, userId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public int getLikeCount(int musicId) {
        String sql = "SELECT COUNT(*) FROM music_likes WHERE music_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, musicId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public boolean hasUserLiked(int musicId, int userId) {
        String sql = "SELECT 1 FROM music_likes WHERE music_id = ? AND user_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, musicId);
            stmt.setInt(2, userId);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean toggleLike(int musicId, int userId) {
        String checkSql = "SELECT 1 FROM music_likes WHERE music_id = ? AND user_id = ?";
        String insertSql = "INSERT INTO music_likes (user_id, music_id, like_time) VALUES (?, ?, ?)";
        String deleteSql = "DELETE FROM music_likes WHERE music_id = ? AND user_id = ?";
        String incSql = "UPDATE music SET likes = COALESCE(likes, 0) + 1 WHERE id = ?";
        String decSql = "UPDATE music SET likes = MAX(0, COALESCE(likes, 0) - 1) WHERE id = ?";
        try (Connection conn = DBUtil.getConnection()) {
            boolean liked;
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setInt(1, musicId);
                checkStmt.setInt(2, userId);
                ResultSet rs = checkStmt.executeQuery();
                liked = rs.next();
            }
            if (liked) {
                try (PreparedStatement delStmt = conn.prepareStatement(deleteSql)) {
                    delStmt.setInt(1, musicId);
                    delStmt.setInt(2, userId);
                    delStmt.executeUpdate();
                }
                try (PreparedStatement decStmt = conn.prepareStatement(decSql)) {
                    decStmt.setInt(1, musicId);
                    decStmt.executeUpdate();
                }
                return false;
            } else {
                try (PreparedStatement insStmt = conn.prepareStatement(insertSql)) {
                    insStmt.setInt(1, userId);
                    insStmt.setInt(2, musicId);
                    insStmt.setTimestamp(3, new java.sql.Timestamp(System.currentTimeMillis()));
                    insStmt.executeUpdate();
                }
                try (PreparedStatement incStmt = conn.prepareStatement(incSql)) {
                    incStmt.setInt(1, musicId);
                    incStmt.executeUpdate();
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Music mapMusic(ResultSet rs) throws SQLException {
        Music music = new Music(
            rs.getInt("id"),
            rs.getString("name"),
            rs.getString("url"),
            rs.getString("type"),
            rs.getString("cover"),
            rs.getInt("user_id"),
            rs.getString("username"),
            rs.getTimestamp("upload_time")
        );
        music.setArtist(rs.getString("artist"));
        try {
            music.setLikes(rs.getInt("likes"));
        } catch (SQLException e) {
            music.setLikes(0);
        }
        try {
            music.setDuration(rs.getInt("duration"));
        } catch (SQLException e) {
            music.setDuration(0);
        }
        return music;
    }
}
