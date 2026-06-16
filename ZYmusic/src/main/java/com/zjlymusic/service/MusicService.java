package com.zjlymusic.service;

import com.zjlymusic.dao.MusicDAO;
import com.zjlymusic.entity.Music;

import java.util.Date;
import java.util.List;

public class MusicService {
    private MusicDAO musicDAO = new MusicDAO();

    public boolean uploadMusic(String name, String artist, String url, String type, String cover, int userId, String username, int duration) {
        if (name == null || name.trim().isEmpty() ||
            artist == null || artist.trim().isEmpty() ||
            url == null || url.trim().isEmpty() ||
            type == null || type.trim().isEmpty() ||
            cover == null || cover.trim().isEmpty()) {
            return false;
        }
        Music music = new Music();
        music.setName(name.trim());
        music.setArtist(artist.trim());
        music.setUrl(url.trim());
        music.setType(type.trim());
        music.setCover(cover.trim());
        music.setUserId(userId);
        music.setUsername(username);
        music.setUploadTime(new Date());
        music.setDuration(duration);
        musicDAO.addMusic(music);
        return true;
    }

    public List<Music> getAllMusic() {
        return musicDAO.getAllMusic();
    }

    public List<Music> getLatestMusic(int limit) {
        return musicDAO.getLatestMusic(limit);
    }

    public List<Music> getMusicByUserId(int userId) {
        return musicDAO.getMusicByUserId(userId);
    }

    public Music getMusicById(int id) {
        return musicDAO.getMusicById(id);
    }

    public List<Music> searchMusic(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllMusic();
        }
        return musicDAO.searchMusic(keyword);
    }

    public int getLikeCount(int musicId) {
        return musicDAO.getLikeCount(musicId);
    }

    public boolean hasUserLiked(int musicId, int userId) {
        return musicDAO.hasUserLiked(musicId, userId);
    }

    public boolean toggleLike(int musicId, int userId) {
        return musicDAO.toggleLike(musicId, userId);
    }
}
