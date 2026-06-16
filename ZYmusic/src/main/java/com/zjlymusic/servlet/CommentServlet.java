package com.zjlymusic.servlet;

import com.zjlymusic.dao.MusicDAO;
import com.zjlymusic.dao.NotificationDAO;
import com.zjlymusic.dao.PostDAO;
import com.zjlymusic.entity.Comment;
import com.zjlymusic.entity.Music;
import com.zjlymusic.entity.Notification;
import com.zjlymusic.entity.Post;
import com.zjlymusic.entity.User;
import com.zjlymusic.service.CommentService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class CommentServlet extends HttpServlet {
    private CommentService commentService = new CommentService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String musicIdStr = request.getParameter("musicId");
        String postIdStr = request.getParameter("postId");

        response.setContentType("application/json;charset=UTF-8");
        StringBuilder json = new StringBuilder();
        json.append("[");

        List<Comment> comments = null;
        if (musicIdStr != null && !musicIdStr.isEmpty()) {
            comments = commentService.getCommentsByMusicId(Integer.parseInt(musicIdStr));
        } else if (postIdStr != null && !postIdStr.isEmpty()) {
            comments = commentService.getCommentsByPostId(Integer.parseInt(postIdStr));
        }

        if (comments != null) {
            SimpleDateFormat sdf = new SimpleDateFormat("MM-dd HH:mm");
            boolean first = true;
            for (Comment c : comments) {
                if (!first) json.append(",");
                first = false;
                json.append("{");
                json.append("\"id\":").append(c.getId()).append(",");
                json.append("\"userId\":").append(c.getUserId()).append(",");
                json.append("\"username\":\"").append(escapeJson(c.getUsername())).append("\",");
                json.append("\"content\":\"").append(escapeJson(c.getContent())).append("\",");
                json.append("\"time\":\"").append(sdf.format(c.getCommentTime())).append("\",");
                json.append("\"parentId\":").append(c.getParentId()).append(",");
                json.append("\"parentUsername\":\"").append(escapeJson(c.getParentUsername() != null ? c.getParentUsername() : "")).append("\",");
                json.append("\"musicId\":").append(c.getMusicId()).append(",");
                json.append("\"postId\":").append(c.getPostId());
                json.append("}");
            }
        }
        json.append("]");
        response.getWriter().write(json.toString());
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

        if (user == null) {
            if (isAjax) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"error\":\"请先登录\"}");
            } else {
                response.sendRedirect("login.jsp");
            }
            return;
        }

        String content = request.getParameter("content");
        String musicIdStr = request.getParameter("musicId");
        String postIdStr = request.getParameter("postId");

        if (content != null && !content.trim().isEmpty()) {
            String trimmedContent = content.trim();
            String parentIdStr = request.getParameter("parentId");
            String parentUsername = request.getParameter("parentUsername");
            int parentId = 0;
            if (parentIdStr != null && !parentIdStr.isEmpty()) {
                parentId = Integer.parseInt(parentIdStr);
            }

            if (musicIdStr != null && !musicIdStr.isEmpty()) {
                int newId = 0;
                try {
                    int musicId = Integer.parseInt(musicIdStr);
                    newId = commentService.addMusicComment(trimmedContent, user.getId(), user.getUsername(), musicId, parentId, parentUsername);
                    Music music = new MusicDAO().getMusicById(musicId);
                    if (music != null && music.getUserId() != user.getId()) {
                        Notification n = new Notification();
                        n.setUserId(music.getUserId());
                        n.setType("reply");
                        n.setFromUserId(user.getId());
                        n.setFromUsername(user.getUsername());
                        n.setContent(trimmedContent);
                        n.setRelatedId(musicId);
                        n.setRelatedType("music_reply");
                        n.setCreateTime(new Date());
                        new NotificationDAO().addNotification(n);
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
                if (isAjax) {
                    writeJsonResponse(response, user, trimmedContent, parentId, parentUsername, newId);
                } else {
                    response.sendRedirect("playMusic?id=" + musicIdStr);
                }
                return;
            }

            if (postIdStr != null && !postIdStr.isEmpty()) {
                int newId = 0;
                try {
                    int postId = Integer.parseInt(postIdStr);
                    newId = commentService.addPostComment(trimmedContent, user.getId(), user.getUsername(), postId, parentId, parentUsername);
                    Post post = new PostDAO().getPostById(postId);
                    if (post != null && post.getUserId() != user.getId()) {
                        Notification n = new Notification();
                        n.setUserId(post.getUserId());
                        n.setType("reply");
                        n.setFromUserId(user.getId());
                        n.setFromUsername(user.getUsername());
                        n.setContent(trimmedContent);
                        n.setRelatedId(postId);
                        n.setRelatedType("post_reply");
                        n.setCreateTime(new Date());
                        new NotificationDAO().addNotification(n);
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
                if (isAjax) {
                    writeJsonResponse(response, user, trimmedContent, parentId, parentUsername, newId);
                } else {
                    response.sendRedirect("community");
                }
                return;
            }
        }

        response.sendRedirect("community");
    }

    private void writeJsonResponse(HttpServletResponse response, User user, String content, int parentId, String parentUsername, int newCommentId) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        String now = new SimpleDateFormat("MM-dd HH:mm").format(new Date());
        String avatarUrl = user.getAvatarUrl() != null ? user.getAvatarUrl() : "";
        StringBuilder json = new StringBuilder();
        json.append("{\"success\":true,");
        json.append("\"id\":").append(newCommentId).append(",");
        json.append("\"userId\":").append(user.getId()).append(",");
        json.append("\"username\":\"").append(escapeJson(user.getUsername())).append("\",");
        json.append("\"content\":\"").append(escapeJson(content)).append("\",");
        json.append("\"time\":\"").append(now).append("\",");
        json.append("\"avatarUrl\":\"").append(escapeJson(avatarUrl)).append("\",");
        json.append("\"parentId\":").append(parentId).append(",");
        json.append("\"parentUsername\":\"").append(escapeJson(parentUsername != null ? parentUsername : "")).append("\"");
        json.append("}");
        response.getWriter().write(json.toString());
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
