package com.zjlymusic.service;

import com.zjlymusic.dao.PlaylistDAO;
import com.zjlymusic.entity.Music;
import com.zjlymusic.entity.Playlist;

import java.util.Date;
import java.util.List;

public class PlaylistService {
    private PlaylistDAO playlistDAO = new PlaylistDAO();

    public Playlist createPlaylist(String name, String coverUrl, int userId, String username) {
        Playlist playlist = new Playlist();
        playlist.setName(name);
        playlist.setCoverUrl(coverUrl);
        playlist.setUserId(userId);
        playlist.setUsername(username);
        playlist.setCreateTime(new Date());
        playlistDAO.createPlaylist(playlist);
        return playlist;
    }

    public List<Playlist> getPlaylistsByUserId(int userId) {
        return playlistDAO.getPlaylistsByUserId(userId);
    }

    public Playlist getPlaylistById(int id) {
        return playlistDAO.getPlaylistById(id);
    }

    public void updatePlaylistCover(int playlistId, String coverUrl) {
        playlistDAO.updatePlaylistCover(playlistId, coverUrl);
    }

    public void addMusicToPlaylist(int playlistId, int musicId) {
        playlistDAO.addMusicToPlaylist(playlistId, musicId);
    }

    public List<Music> getPlaylistMusics(int playlistId) {
        return playlistDAO.getPlaylistMusics(playlistId);
    }

    public List<Music> getPlaylistMusics(int playlistId, String sort) {
        return playlistDAO.getPlaylistMusics(playlistId, sort);
    }

    public void updateMusicPosition(int playlistId, int musicId, int position) {
        playlistDAO.updateMusicPosition(playlistId, musicId, position);
    }

    public void updateUsernameByUserId(int userId, String newUsername) {
        playlistDAO.updateUsernameByUserId(userId, newUsername);
    }
}
