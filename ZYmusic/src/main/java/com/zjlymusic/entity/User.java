package com.zjlymusic.entity;

public class User {
    private int id;
    private String username;
    private String password;
    private String avatar;
    private String background;
    private String bio;
    private String phone;
    private String nickname;
    private int backgroundOpacity = 80;

    public User() {}

    public User(int id, String username, String password) {
        this(id, username, password, null, null, null);
    }

    public User(int id, String username, String password, String avatar) {
        this(id, username, password, avatar, null, null);
    }

    public User(int id, String username, String password, String avatar, String background) {
        this(id, username, password, avatar, background, null);
    }

    public User(int id, String username, String password, String avatar, String background, String bio) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.avatar = avatar;
        this.background = background;
        this.bio = bio;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getAvatarUrl() {
        if (avatar == null || avatar.trim().isEmpty()) {
            return null;
        }
        return "files/" + avatar;
    }

    public String getBackground() {
        return background;
    }

    public void setBackground(String background) {
        this.background = background;
    }

    public String getBackgroundUrl() {
        if (background == null || background.trim().isEmpty()) {
            return null;
        }
        return "files/" + background;
    }

    public String getBio() {
        return bio;
    }

    public void setBio(String bio) {
        this.bio = bio;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getNickname() {
        return nickname;
    }

    public void setNickname(String nickname) {
        this.nickname = nickname;
    }

    public int getBackgroundOpacity() {
        return backgroundOpacity;
    }

    public void setBackgroundOpacity(int backgroundOpacity) {
        this.backgroundOpacity = backgroundOpacity;
    }
}
