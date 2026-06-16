package com.zjlymusic.service;

import com.zjlymusic.dao.PostDAO;
import com.zjlymusic.entity.Post;

import java.util.Date;
import java.util.List;

public class PostService {
    private PostDAO postDAO = new PostDAO();
    
    public boolean createPost(String content, int userId, String username) {
        if (content == null || content.trim().isEmpty()) {
            return false;
        }
        Post post = new Post();
        post.setContent(content);
        post.setUserId(userId);
        post.setUsername(username);
        post.setPostTime(new Date());
        postDAO.addPost(post);
        return true;
    }
    
    public List<Post> getAllPosts() {
        return postDAO.getAllPosts();
    }
    
    public List<Post> getPostsByUserId(int userId) {
        return postDAO.getPostsByUserId(userId);
    }

}