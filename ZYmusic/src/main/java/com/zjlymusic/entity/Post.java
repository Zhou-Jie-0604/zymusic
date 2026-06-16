package com.zjlymusic.entity;

import java.util.Date;

public class Post {
    private int id;
    private String content;
    private int userId;
    private String username;
    private Date postTime;
    
    public Post() {}
    
    public Post(int id, String content, int userId, String username, Date postTime) {
        this.id = id;
        this.content = content;
        this.userId = userId;
        this.username = username;
        this.postTime = postTime;
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
    
    public Date getPostTime() {
        return postTime;
    }
    
    public void setPostTime(Date postTime) {
        this.postTime = postTime;
    }
}