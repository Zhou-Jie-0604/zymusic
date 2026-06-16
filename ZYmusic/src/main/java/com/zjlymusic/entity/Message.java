package com.zjlymusic.entity;

import java.util.Date;

public class Message {
    private int id;
    private int senderId;
    private int receiverId;
    private String content;
    private Date sendTime;

    // Joined from users table for display
    private String senderUsername;
    private String senderAvatar;
    private String receiverUsername;
    private String receiverAvatar;

    public Message() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getSenderId() { return senderId; }
    public void setSenderId(int senderId) { this.senderId = senderId; }

    public int getReceiverId() { return receiverId; }
    public void setReceiverId(int receiverId) { this.receiverId = receiverId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Date getSendTime() { return sendTime; }
    public void setSendTime(Date sendTime) { this.sendTime = sendTime; }

    public String getSenderUsername() { return senderUsername; }
    public void setSenderUsername(String senderUsername) { this.senderUsername = senderUsername; }

    public String getSenderAvatar() { return senderAvatar; }
    public void setSenderAvatar(String senderAvatar) { this.senderAvatar = senderAvatar; }

    public String getSenderAvatarUrl() {
        if (senderAvatar == null || senderAvatar.trim().isEmpty()) return null;
        return "files/" + senderAvatar;
    }

    public String getReceiverUsername() { return receiverUsername; }
    public void setReceiverUsername(String receiverUsername) { this.receiverUsername = receiverUsername; }

    public String getReceiverAvatar() { return receiverAvatar; }
    public void setReceiverAvatar(String receiverAvatar) { this.receiverAvatar = receiverAvatar; }

    public String getReceiverAvatarUrl() {
        if (receiverAvatar == null || receiverAvatar.trim().isEmpty()) return null;
        return "files/" + receiverAvatar;
    }
}
