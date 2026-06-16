package com.zjlymusic.entity;

import java.util.Date;

public class Notification {
    private int id;
    private int userId;
    private String type;
    private int fromUserId;
    private String fromUsername;
    private String content;
    private int relatedId;
    private String relatedType;
    private Date createTime;
    private boolean isRead;

    // Joined from users table
    private String fromUserAvatar;

    public Notification() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public int getFromUserId() { return fromUserId; }
    public void setFromUserId(int fromUserId) { this.fromUserId = fromUserId; }

    public String getFromUsername() { return fromUsername; }
    public void setFromUsername(String fromUsername) { this.fromUsername = fromUsername; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getRelatedId() { return relatedId; }
    public void setRelatedId(int relatedId) { this.relatedId = relatedId; }

    public String getRelatedType() { return relatedType; }
    public void setRelatedType(String relatedType) { this.relatedType = relatedType; }

    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public String getFromUserAvatar() { return fromUserAvatar; }
    public void setFromUserAvatar(String fromUserAvatar) { this.fromUserAvatar = fromUserAvatar; }

    public String getFromUserAvatarUrl() {
        if (fromUserAvatar == null || fromUserAvatar.trim().isEmpty()) return null;
        return "files/" + fromUserAvatar;
    }

    public String getDisplayText() {
        if (content != null && !content.isEmpty()) return fromUsername + ": " + content;
        switch (type != null ? type : "") {
            case "follow": return fromUsername + " 关注了你";
            case "like": return fromUsername + " 赞了你的歌曲";
            case "reply": return fromUsername + " 回复了你";
            case "message": return fromUsername + " 给你发了一条私信";
            default: return fromUsername + " 与你互动了";
        }
    }

    public String getTargetUrl() {
        switch (relatedType != null ? relatedType : "") {
            case "music":
            case "music_reply":
                return "playMusic?id=" + relatedId;
            case "post":
            case "post_reply":
                return "community?postId=" + relatedId;
            case "message":
                return "messages?userId=" + fromUserId;
            case "follow":
                return "profile?userId=" + fromUserId;
            default:
                return "javascript:void(0)";
        }
    }
}
