package com.zjlymusic.service;

import com.zjlymusic.dao.CommentDAO;
import com.zjlymusic.entity.Comment;

import java.util.Date;
import java.util.List;

public class CommentService {
    private CommentDAO commentDAO = new CommentDAO();

    public void addComment(String content, int userId, String username, int musicId) {
        addMusicComment(content, userId, username, musicId, 0, null);
    }

    public int addMusicComment(String content, int userId, String username, int musicId, int parentId, String parentUsername) {
        Comment comment = new Comment();
        comment.setContent(content);
        comment.setUserId(userId);
        comment.setUsername(username);
        comment.setMusicId(musicId);
        comment.setParentId(parentId);
        comment.setParentUsername(parentUsername);
        comment.setCommentTime(new Date());
        return commentDAO.addComment(comment);
    }

    public List<Comment> getCommentsByMusicId(int musicId) {
        return commentDAO.getCommentsByMusicId(musicId);
    }

    public List<Comment> getCommentsByPostId(int postId) {
        return commentDAO.getCommentsByPostId(postId);
    }

    public int addPostComment(String content, int userId, String username, int postId, int parentId, String parentUsername) {
        Comment comment = new Comment();
        comment.setContent(content);
        comment.setUserId(userId);
        comment.setUsername(username);
        comment.setPostId(postId);
        comment.setParentId(parentId);
        comment.setParentUsername(parentUsername);
        comment.setCommentTime(new Date());
        return commentDAO.addComment(comment);
    }

    public List<Comment> getCommentsByUserId(int userId) {
        return commentDAO.getCommentsByUserId(userId);
    }

    public void updateUsernameByUserId(int userId, String newUsername) {
        commentDAO.updateUsernameByUserId(userId, newUsername);
    }
}
