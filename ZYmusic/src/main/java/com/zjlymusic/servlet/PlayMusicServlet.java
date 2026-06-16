package com.zjlymusic.servlet;

import com.zjlymusic.entity.Comment;
import com.zjlymusic.entity.Music;
import com.zjlymusic.entity.Playlist;
import com.zjlymusic.service.CommentService;
import com.zjlymusic.service.MusicService;
import com.zjlymusic.service.PlaylistService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

public class PlayMusicServlet extends HttpServlet {
    private MusicService musicService = new MusicService();
    private CommentService commentService = new CommentService();
    private PlaylistService playlistService = new PlaylistService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            int id = Integer.parseInt(idStr);
            Music music = musicService.getMusicById(id);
            request.setAttribute("music", music);

            List<Comment> comments = commentService.getCommentsByMusicId(id);
            request.setAttribute("comments", comments);
        }

        String playlistIdStr = request.getParameter("playlistId");
        if (playlistIdStr != null) {
            int playlistId = Integer.parseInt(playlistIdStr);
            Playlist playlist = playlistService.getPlaylistById(playlistId);
            List<Music> playlistMusics = playlistService.getPlaylistMusics(playlistId, null);
            request.setAttribute("musics", playlistMusics);
            request.setAttribute("playlistContext", playlist);
        } else {
            request.setAttribute("musics", musicService.getAllMusic());
        }

        request.getRequestDispatcher("play.jsp").forward(request, response);
    }
}