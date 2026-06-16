package com.zjlymusic.servlet;

import com.google.gson.Gson;
import com.zjlymusic.entity.Music;
import com.zjlymusic.service.MusicService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    private MusicService musicService = new MusicService();
    private Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        response.setContentType("application/json;charset=UTF-8");
        
        if (keyword == null || keyword.trim().isEmpty()) {
            response.getWriter().write("[]");
            return;
        }

        List<Music> results = musicService.searchMusic(keyword.trim());
        
        // Convert to JSON-friendly format
        java.util.List<Map<String, Object>> jsonList = new java.util.ArrayList<>();
        for (Music music : results) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", music.getId());
            item.put("name", music.getName());
            item.put("artist", music.getArtist());
            item.put("username", music.getUsername());
            item.put("coverUrl", music.getCoverUrl());
            item.put("url", music.getUrl());
            jsonList.add(item);
        }
        
        response.getWriter().write(gson.toJson(jsonList));
    }
}
