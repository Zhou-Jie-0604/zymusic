package com.zjlymusic.dao;

import com.zjlymusic.entity.Playlist;
import com.zjlymusic.entity.Music;
import com.zjlymusic.util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PlaylistDAO {

    public void createPlaylist(Playlist playlist) {
        String sql = "INSERT INTO playlists (name, cover_url, user_id, username, create_time) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, playlist.getName());
            stmt.setString(2, playlist.getCoverUrl());
            stmt.setInt(3, playlist.getUserId());
            stmt.setString(4, playlist.getUsername());
            stmt.setTimestamp(5, new java.sql.Timestamp(playlist.getCreateTime().getTime()));
            stmt.executeUpdate();
            ResultSet keys = stmt.getGeneratedKeys();
            if (keys.next()) {
                playlist.setId(keys.getInt(1));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Playlist> getPlaylistsByUserId(int userId) {
        List<Playlist> list = new ArrayList<>();
        String sql = "SELECT * FROM playlists WHERE user_id = ? ORDER BY create_time DESC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Playlist p = new Playlist();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setCoverUrl(rs.getString("cover_url"));
                p.setUserId(rs.getInt("user_id"));
                p.setUsername(rs.getString("username"));
                p.setCreateTime(rs.getTimestamp("create_time"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Playlist getPlaylistById(int id) {
        String sql = "SELECT * FROM playlists WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                Playlist p = new Playlist();
                p.setId(rs.getInt("id"));
                p.setName(rs.getString("name"));
                p.setCoverUrl(rs.getString("cover_url"));
                p.setUserId(rs.getInt("user_id"));
                p.setUsername(rs.getString("username"));
                p.setCreateTime(rs.getTimestamp("create_time"));
                return p;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public void updatePlaylistCover(int playlistId, String coverUrl) {
        String sql = "UPDATE playlists SET cover_url = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, coverUrl);
            stmt.setInt(2, playlistId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void addMusicToPlaylist(int playlistId, int musicId) {
        // Check if already exists
        String checkSql = "SELECT * FROM playlist_songs WHERE playlist_id = ? AND music_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, playlistId);
            checkStmt.setInt(2, musicId);
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next()) {
                return; // Already exists
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Get max position
        int maxPos = 0;
        String posSql = "SELECT MAX(position) FROM playlist_songs WHERE playlist_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement posStmt = conn.prepareStatement(posSql)) {
            posStmt.setInt(1, playlistId);
            ResultSet rs = posStmt.executeQuery();
            if (rs.next()) {
                maxPos = rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        String sql = "INSERT INTO playlist_songs (playlist_id, music_id, position, add_time) VALUES (?, ?, ?, datetime('now'))";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistId);
            stmt.setInt(2, musicId);
            stmt.setInt(3, maxPos + 1);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<Music> getPlaylistMusics(int playlistId) {
        List<Music> list = new ArrayList<>();
        String sql = "SELECT m.* FROM music m " +
                     "JOIN playlist_songs ps ON m.id = ps.music_id " +
                     "WHERE ps.playlist_id = ? ORDER BY ps.position ASC";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistId);
            ResultSet rs = stmt.executeQuery();
            MusicDAO musicDAO = new MusicDAO();
            while (rs.next()) {
                Music music = musicDAO.mapMusic(rs);
                list.add(music);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Music> getPlaylistMusics(int playlistId, String sort) {
        List<Music> list = new ArrayList<>();
        String sql;
        if ("time".equals(sort)) {
            // 按加入歌单的时间排序
            sql = "SELECT m.* FROM music m " +
                  "JOIN playlist_songs ps ON m.id = ps.music_id " +
                  "WHERE ps.playlist_id = ? ORDER BY ps.add_time DESC";
        } else if ("name".equals(sort)) {
            // 按歌曲名排序
            sql = "SELECT m.* FROM music m " +
                  "JOIN playlist_songs ps ON m.id = ps.music_id " +
                  "WHERE ps.playlist_id = ? ORDER BY m.name ASC";
        } else {
            // 默认手动排序
            sql = "SELECT m.* FROM music m " +
                  "JOIN playlist_songs ps ON m.id = ps.music_id " +
                  "WHERE ps.playlist_id = ? ORDER BY ps.position ASC";
        }
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, playlistId);
            ResultSet rs = stmt.executeQuery();
            MusicDAO musicDAO = new MusicDAO();
            while (rs.next()) {
                Music music = musicDAO.mapMusic(rs);
                list.add(music);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public void updateMusicPosition(int playlistId, int musicId, int position) {
        String sql = "UPDATE playlist_songs SET position = ? WHERE playlist_id = ? AND music_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, position);
            stmt.setInt(2, playlistId);
            stmt.setInt(3, musicId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public void updateUsernameByUserId(int userId, String newUsername) {
        String sql = "UPDATE playlists SET username = ? WHERE user_id = ?";
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
