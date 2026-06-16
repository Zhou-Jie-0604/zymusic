package com.zjlymusic.entity;

public class PlaylistSong {
    private int id;
    private int playlistId;
    private int musicId;
    private int position;

    public PlaylistSong() {}

    public PlaylistSong(int id, int playlistId, int musicId, int position) {
        this.id = id;
        this.playlistId = playlistId;
        this.musicId = musicId;
        this.position = position;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getPlaylistId() {
        return playlistId;
    }

    public void setPlaylistId(int playlistId) {
        this.playlistId = playlistId;
    }

    public int getMusicId() {
        return musicId;
    }

    public void setMusicId(int musicId) {
        this.musicId = musicId;
    }

    public int getPosition() {
        return position;
    }

    public void setPosition(int position) {
        this.position = position;
    }
}
