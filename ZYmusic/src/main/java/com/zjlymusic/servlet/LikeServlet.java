package com.zjlymusic.servlet;

import com.zjlymusic.entity.User;
import com.zjlymusic.service.MusicService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LikeServlet extends HttpServlet {
    private MusicService musicService = new MusicService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        String musicIdStr = request.getParameter("musicId");
        if (musicIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int musicId = Integer.parseInt(musicIdStr);
        boolean liked = musicService.toggleLike(musicId, user.getId());
        int count = musicService.getLikeCount(musicId);

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"liked\":" + liked + ",\"count\":" + count + "}");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String musicIdStr = request.getParameter("musicId");
        if (musicIdStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        int musicId = Integer.parseInt(musicIdStr);
        int count = musicService.getLikeCount(musicId);
        boolean liked = false;

        User user = (User) request.getSession().getAttribute("user");
        if (user != null) {
            liked = musicService.hasUserLiked(musicId, user.getId());
        }

        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"liked\":" + liked + ",\"count\":" + count + "}");
    }
}
