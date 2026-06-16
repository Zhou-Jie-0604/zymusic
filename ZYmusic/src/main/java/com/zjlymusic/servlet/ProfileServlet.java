package com.zjlymusic.servlet;

import com.zjlymusic.dao.NotificationDAO;
import com.zjlymusic.dao.UserDAO;
import com.zjlymusic.entity.Comment;
import com.zjlymusic.entity.Music;
import com.zjlymusic.entity.Notification;
import com.zjlymusic.entity.Post;
import com.zjlymusic.entity.User;
import com.zjlymusic.service.CommentService;
import com.zjlymusic.service.MusicService;
import com.zjlymusic.service.PostService;
import com.zjlymusic.service.UserService;

import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class ProfileServlet extends HttpServlet {
    private MusicService musicService = new MusicService();
    private PostService postService = new PostService();
    private CommentService commentService = new CommentService();
    private UserService userService = new UserService();
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");
        
        String action = request.getParameter("action");
        if (action != null) {
            // 处理关注/取关操作
            if (currentUser == null) {
                response.sendRedirect("login.jsp");
                return;
            }
            
            int targetUserId = Integer.parseInt(request.getParameter("userId"));
            
            if ("follow".equals(action)) {
                userDAO.follow(currentUser.getId(), targetUserId);
            } else if ("unfollow".equals(action)) {
                userDAO.unfollow(currentUser.getId(), targetUserId);
            }
            
            response.setContentType("text/plain");
            response.getWriter().write("success");
            return;
        }
        
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String userIdParam = request.getParameter("userId");
        User profileUser;
        
        if (userIdParam != null && !userIdParam.isEmpty()) {
            int profileUserId = Integer.parseInt(userIdParam);
            profileUser = userService.getUserById(profileUserId);
            if (profileUser == null) {
                response.sendRedirect("profile");
                return;
            }
        } else {
            profileUser = currentUser;
        }
        
        session.setAttribute("user", currentUser);

        List<Music> musics = musicService.getMusicByUserId(profileUser.getId());
        List<Post> posts = postService.getPostsByUserId(profileUser.getId());
        List<Comment> comments = commentService.getCommentsByUserId(profileUser.getId());

        List<Object> activities = new ArrayList<>();
        for (Music m : musics) {
            activities.add(new ActivityItem(m.getUploadTime(), "music", m));
        }
        for (Post p : posts) {
            activities.add(new ActivityItem(p.getPostTime(), "post", p));
        }
        for (Comment c : comments) {
            activities.add(new ActivityItem(c.getCommentTime(), "comment", c));
        }
        
        Collections.sort(activities, new Comparator<Object>() {
            @Override
            public int compare(Object o1, Object o2) {
                return ((ActivityItem) o2).date.compareTo(((ActivityItem) o1).date);
            }
        });
        
        // 获取关注数和粉丝数
        int followingCount = userDAO.getFollowingCount(profileUser.getId());
        int followersCount = userDAO.getFollowersCount(profileUser.getId());
        
        // 获取关注列表和粉丝列表
        List<User> followingList = userDAO.getFollowing(profileUser.getId());
        List<User> followersList = userDAO.getFollowers(profileUser.getId());
        
        // 检查当前用户是否已关注该用户
        boolean isFollowing = userDAO.isFollowing(currentUser.getId(), profileUser.getId());
        
        request.setAttribute("profileUser", profileUser);
        request.setAttribute("isOwnProfile", profileUser.getId() == currentUser.getId());
        request.setAttribute("activities", activities);
        request.setAttribute("followingCount", followingCount);
        request.setAttribute("followersCount", followersCount);
        request.setAttribute("followingList", followingList);
        request.setAttribute("followersList", followersList);
        request.setAttribute("isFollowing", isFollowing);
        request.getRequestDispatcher("profile.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String userIdStr = request.getParameter("userId");

        if (action != null && userIdStr != null) {
            int targetUserId = Integer.parseInt(userIdStr);

            if ("follow".equals(action)) {
                userDAO.follow(currentUser.getId(), targetUserId);
                Notification n = new Notification();
                n.setUserId(targetUserId);
                n.setType("follow");
                n.setFromUserId(currentUser.getId());
                n.setFromUsername(currentUser.getUsername());
                n.setContent("");
                n.setRelatedId(currentUser.getId());
                n.setRelatedType("follow");
                n.setCreateTime(new Date());
                new NotificationDAO().addNotification(n);
            } else if ("unfollow".equals(action)) {
                userDAO.unfollow(currentUser.getId(), targetUserId);
            }
        }

        response.setContentType("text/plain;charset=UTF-8");
        response.getWriter().write("success");
    }

    public static class ActivityItem {
        public java.util.Date date;
        public String type;
        public Object item;
        
        public ActivityItem(java.util.Date date, String type, Object item) {
            this.date = date;
            this.type = type;
            this.item = item;
        }
    }
}
