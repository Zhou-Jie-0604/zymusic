package com.zjlymusic.entity;

import java.util.Date;

public class Comment {
    private int id;
    private String content;
    private int userId;
    private String username;
    private int musicId;
    private int postId;
    private int parentId;
    private String parentUsername;
    private Date commentTime;

    public Comment() {}

    public Comment(int id, String content, int userId, String username, int musicId, Date commentTime) {
        this.id = id;
        this.content = content;
        this.userId = userId;
        this.username = username;
        this.musicId = musicId;
        this.commentTime = commentTime;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
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

    public int getMusicId() {
        return musicId;
    }

    public void setMusicId(int musicId) {
        this.musicId = musicId;
    }

    public Date getCommentTime() {
        return commentTime;
    }

    public void setCommentTime(Date commentTime) {
        this.commentTime = commentTime;
    }

    public int getPostId() {
        return postId;
    }

    public void setPostId(int postId) {
        this.postId = postId;
    }

    public int getParentId() {
        return parentId;
    }

    public void setParentId(int parentId) {
        this.parentId = parentId;
    }

    public String getParentUsername() {
        return parentUsername;
    }

    public void setParentUsername(String parentUsername) {
        this.parentUsername = parentUsername;
    }
}
