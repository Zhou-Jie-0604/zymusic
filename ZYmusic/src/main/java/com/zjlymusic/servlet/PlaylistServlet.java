package com.zjlymusic.servlet;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.zjlymusic.entity.Music;
import com.zjlymusic.entity.Playlist;
import com.zjlymusic.entity.User;
import com.zjlymusic.service.PlaylistService;
import com.zjlymusic.util.AppPaths;
import com.zjlymusic.util.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.util.List;

public class PlaylistServlet extends HttpServlet {
    private PlaylistService playlistService = new PlaylistService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");

        if ("view".equals(action) && idStr != null) {
            int playlistId = Integer.parseInt(idStr);
            Playlist playlist = playlistService.getPlaylistById(playlistId);

            if (playlist == null) {
                response.sendRedirect("playlist");
                return;
            }

            String sort = request.getParameter("sort");
            List<Music> musics = playlistService.getPlaylistMusics(playlistId, sort);
            Music currentMusic = (Music) session.getAttribute("currentMusic");
            request.setAttribute("playlist", playlist);
            request.setAttribute("musics", musics);
            request.setAttribute("currentMusic", currentMusic);
            request.getRequestDispatcher("playlist.jsp").forward(request, response);
        } else {
            // List user's playlists
            List<Playlist> playlists = playlistService.getPlaylistsByUserId(user.getId());
            request.setAttribute("playlists", playlists);
            request.getRequestDispatcher("playlists.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");

        if ("create".equals(action)) {
            String name = request.getParameter("name");
            boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));
            if (name != null && !name.trim().isEmpty()) {
                String coverUrl = null;
                if (request.getContentType() != null && request.getContentType().startsWith("multipart/form-data")) {
                    if (request.getPart("cover") != null && request.getPart("cover").getSize() > 0) {
                        try {
                            coverUrl = FileUploadUtil.savePlaylistCover(request.getPart("cover"));
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    }
                }
                Playlist newPlaylist = playlistService.createPlaylist(name.trim(), coverUrl, user.getId(), user.getUsername());
                if (isAjax) {
                    response.setContentType("application/json;charset=UTF-8");
                    StringBuilder json = new StringBuilder();
                    json.append("{\"success\":true,");
                    json.append("\"id\":").append(newPlaylist != null ? newPlaylist.getId() : 0).append(",");
                    json.append("\"name\":\"").append(escapeJson(name.trim())).append("\",");
                    json.append("\"coverUrl\":\"").append(coverUrl != null ? escapeJson(coverUrl) : "").append("\"");
                    json.append("}");
                    response.getWriter().write(json.toString());
                    return;
                }
            } else if (isAjax) {
                response.setContentType("application/json");
                response.getWriter().write("{\"success\":false,\"error\":\"歌单名称不能为空\"}");
                return;
            }
            response.sendRedirect("playlist");

        } else if ("addMusic".equals(action)) {
            String playlistIdStr = request.getParameter("playlistId");
            String musicIdStr = request.getParameter("musicId");
            String ajaxHeader = request.getHeader("X-Requested-With");
            boolean isAjax = "XMLHttpRequest".equals(ajaxHeader);
            if (playlistIdStr != null && musicIdStr != null) {
                try {
                    int playlistId = Integer.parseInt(playlistIdStr);
                    int musicId = Integer.parseInt(musicIdStr);
                    playlistService.addMusicToPlaylist(playlistId, musicId);
                    if (isAjax) {
                        response.setContentType("application/json");
                        response.getWriter().write("{\"success\":true}");
                        return;
                    }
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect("playlist?action=view&id=" + playlistIdStr);

        } else if ("updateCover".equals(action)) {
            String playlistIdStr = request.getParameter("playlistId");
            if (playlistIdStr != null && request.getPart("cover") != null && request.getPart("cover").getSize() > 0) {
                try {
                    int playlistId = Integer.parseInt(playlistIdStr);
                    String coverUrl = FileUploadUtil.savePlaylistCover(request.getPart("cover"));
                    playlistService.updatePlaylistCover(playlistId, coverUrl);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect(request.getHeader("Referer"));

        } else if ("sort".equals(action)) {
            String playlistIdStr = request.getParameter("playlistId");
            if (playlistIdStr != null) {
                try {
                    BufferedReader reader = request.getReader();
                    StringBuilder sb = new StringBuilder();
                    String line;
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                    
                    Gson gson = new Gson();
                    JsonObject jsonObject = gson.fromJson(sb.toString(), JsonObject.class);
                    JsonArray positions = jsonObject.getAsJsonArray("positions");
                    
                    for (int i = 0; i < positions.size(); i++) {
                        JsonObject pos = positions.get(i).getAsJsonObject();
                        int musicId = pos.get("musicId").getAsInt();
                        int position = pos.get("position").getAsInt();
                        playlistService.updateMusicPosition(Integer.parseInt(playlistIdStr), musicId, position);
                    }
                    
                    response.setContentType("application/json");
                    response.getWriter().write("{\"success\":true}");
                    return;
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            response.sendRedirect("playlist?action=view&id=" + playlistIdStr);

        } else {
            response.sendRedirect("playlist");
        }
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "");
    }
}
