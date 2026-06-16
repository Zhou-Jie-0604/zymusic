package com.zjlymusic.servlet;

import com.zjlymusic.entity.User;
import com.zjlymusic.service.MusicService;
import com.zjlymusic.util.FileUploadUtil;
import com.zjlymusic.util.AudioConverter;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;

@MultipartConfig(maxFileSize = 50 * 1024 * 1024, maxRequestSize = 60 * 1024 * 1024)
public class UploadMusicServlet extends HttpServlet {
    private MusicService musicService = new MusicService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // CRITICAL: getPart() must be called BEFORE getParameter() for multipart requests
        Part musicPart = request.getPart("music");
        Part coverPart = request.getPart("cover");
        String name = request.getParameter("name");
        String artist = request.getParameter("artist");
        String type = request.getParameter("type");

        try {
            // Save original uploaded file
            String origPath = FileUploadUtil.saveMusic(musicPart);

            if (coverPart != null && coverPart.getSize() > 0) {
                if (!FileUploadUtil.isImageFile(coverPart)) {
                    request.setAttribute("error", "请上传 PNG 或 JPG 格式的歌曲封面");
                    request.getRequestDispatcher("upload.jsp").forward(request, response);
                    return;
                }
            }

            // Convert to MP3 (uses FFmpeg if available, falls back to WAV for FLAC)
            String musicPath = origPath;
            int duration = 0;
            try {
                File origFile = FileUploadUtil.resolveStoredFile(origPath);
                if (origFile != null) {
                    File converted = AudioConverter.ensurePlayable(origFile);
                    if (converted != null && converted != origFile) {
                        String convertedName = converted.getName();
                        musicPath = "music/" + convertedName;
                        if (convertedName.toLowerCase().endsWith(".mp3")) {
                            duration = AudioConverter.getMp3DurationSeconds(converted);
                        } else {
                            duration = com.zjlymusic.util.FlacTranscoder.getDurationSeconds(converted);
                        }
                    } else if (origFile.getName().toLowerCase().endsWith(".mp3")) {
                        duration = AudioConverter.getMp3DurationSeconds(origFile);
                    } else {
                        duration = com.zjlymusic.util.FlacTranscoder.getDurationSeconds(origFile);
                    }
                }
            } catch (Exception ex) {
                System.err.println("Audio conversion warning: " + ex.getMessage());
            }

            String coverPath = null;
            if (coverPart != null && coverPart.getSize() > 0) {
                coverPath = FileUploadUtil.saveCover(coverPart);
            }

            boolean success = musicService.uploadMusic(name, artist, musicPath, type, coverPath, user.getId(), user.getUsername(), duration);

            if (success) {
                request.setAttribute("success", "音乐上传成功");
            } else {
                request.setAttribute("error", "音乐上传失败，请填写完整信息");
            }
        } catch (IOException ex) {
            request.setAttribute("error", ex.getMessage());
        }

        request.getRequestDispatcher("upload.jsp").forward(request, response);
    }
}
