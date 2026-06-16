package com.zjlymusic.servlet;

import com.zjlymusic.entity.Comment;
import com.zjlymusic.entity.Music;
import com.zjlymusic.entity.Post;
import com.zjlymusic.service.CommentService;
import com.zjlymusic.service.MusicService;
import com.zjlymusic.service.PostService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CommunityServlet extends HttpServlet {
    private MusicService musicService = new MusicService();
    private PostService postService = new PostService();
    private CommentService commentService = new CommentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");

        List<Music> musics;
        if (keyword != null && !keyword.trim().isEmpty()) {
            musics = musicService.searchMusic(keyword);
        } else {
            musics = musicService.getAllMusic();
        }

        List<Post> posts = postService.getAllPosts();

        // Load comments for each post
        Map<Integer, List<Comment>> postCommentsMap = new HashMap<>();
        for (Post post : posts) {
            List<Comment> comments = commentService.getCommentsByPostId(post.getId());
            postCommentsMap.put(post.getId(), comments);
        }

        String postIdStr = request.getParameter("postId");

        request.setAttribute("musics", musics);
        request.setAttribute("posts", posts);
        request.setAttribute("postCommentsMap", postCommentsMap);
        request.setAttribute("keyword", keyword);
        request.setAttribute("highlightPostId", postIdStr);
        request.getRequestDispatcher("community.jsp").forward(request, response);
    }
}