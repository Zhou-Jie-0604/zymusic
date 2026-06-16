package com.zjlymusic.entity;

import java.util.Date;

public class Playlist {
    private int id;
    private String name;
    private String coverUrl;
    private int userId;
    private String username;
    private Date createTime;

    public Playlist() {}

    public Playlist(int id, String name, String coverUrl, int userId, String username, Date createTime) {
        this.id = id;
        this.name = name;
        this.coverUrl = coverUrl;
        this.userId = userId;
        this.username = username;
        this.createTime = createTime;
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

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
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

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }
}
