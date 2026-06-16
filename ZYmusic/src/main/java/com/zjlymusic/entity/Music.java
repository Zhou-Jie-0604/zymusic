package com.zjlymusic.entity;

import java.util.Date;

public class Music {
    private int id;
    private String name;
    private String artist;
    private String url;
    private String type;
    private String cover;
    private int userId;
    private String username;
    private Date uploadTime;
    private int likes;
    private int duration;

    public Music() {}

    public Music(int id, String name, String url, String type, int userId, String username, Date uploadTime) {
        this(id, name, url, type, null, userId, username, uploadTime);
    }

    public Music(int id, String name, String url, String type, String cover, int userId, String username, Date uploadTime) {
        this.id = id;
        this.name = name;
        this.url = url;
        this.type = type;
        this.cover = cover;
        this.userId = userId;
        this.username = username;
        this.uploadTime = uploadTime;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getCover() {
        return cover;
    }

    public void setCover(String cover) {
        this.cover = cover;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Date getUploadTime() {
        return uploadTime;
    }

    public void setUploadTime(Date uploadTime) {
        this.uploadTime = uploadTime;
    }

    public String getCoverUrl() {
        if (cover == null || cover.trim().isEmpty()) {
            return null;
        }
        return "files/" + cover;
    }

    public int getLikes() {
        return likes;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }

    public int getDuration() {
        return duration;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }
}
