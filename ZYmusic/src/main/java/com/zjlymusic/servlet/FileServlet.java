package com.zjlymusic.servlet;

import com.zjlymusic.util.FileUploadUtil;
import com.zjlymusic.util.FlacTranscoder;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.nio.file.Files;

public class FileServlet extends HttpServlet {
    private static final int BUFFER_SIZE = 8192;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 1) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String relativePath = pathInfo.substring(1);
        File file = FileUploadUtil.resolveStoredFile(relativePath);
        if (file == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String lower = relativePath.toLowerCase();
        if (FlacTranscoder.isFlacFile(lower)) {
            String userAgent = request.getHeader("User-Agent");
            String transcodeParam = request.getParameter("transcode");
            boolean shouldTranscode = FlacTranscoder.isDesktopClient(userAgent) || "1".equals(transcodeParam);

            if (shouldTranscode) {
                serveFlacAsWav(file, request, response);
            } else {
                serveAudioFile(file, "audio/flac", request, response);
            }
            return;
        }

        String contentType = getContentType(relativePath);
        serveAudioFile(file, contentType, request, response);
    }

    private void serveFlacAsWav(File flacFile, HttpServletRequest request, HttpServletResponse response) throws IOException {
        File cachedWav = FlacTranscoder.getCachedWavFile(flacFile);

        // If cached WAV exists, serve immediately
        if (cachedWav.exists() && cachedWav.length() > 0) {
            serveAudioFile(cachedWav, "audio/wav", request, response);
            return;
        }

        // Stream transcode: calculate total size first, then stream with Content-Length
        response.setContentType("audio/wav");
        response.setHeader("Accept-Ranges", "bytes");

        long wavSize = -1;
        try { wavSize = FlacTranscoder.getWavSize(flacFile); } catch (Exception ignored) {}
        if (wavSize > 0) {
            response.setContentLengthLong(wavSize);
        }

        ByteArrayOutputStream cacheBuffer = new ByteArrayOutputStream(256 * 1024);
        OutputStream teeOut = new java.io.FilterOutputStream(response.getOutputStream()) {
            public void write(byte[] b, int off, int len) throws IOException {
                super.write(b, off, len);
                cacheBuffer.write(b, off, len);
            }
            public void write(int b) throws IOException {
                super.write(b);
                cacheBuffer.write(b);
            }
        };

        try {
            FlacTranscoder.streamTranscodeToWav(flacFile, teeOut);
            teeOut.flush();
            // Save cache for next time
            byte[] wavBytes = cacheBuffer.toByteArray();
            if (wavBytes.length > 0) {
                FlacTranscoder.cacheWav(flacFile, wavBytes);
            }
        } catch (Exception e) {
            // Fallback: serve original FLAC
            serveAudioFile(flacFile, "audio/flac", request, response);
        }
    }

    private void serveAudioFile(File audioFile, String contentType, HttpServletRequest request, HttpServletResponse response) throws IOException {
        long fileLength = audioFile.length();
        response.setContentType(contentType);
        response.setHeader("Accept-Ranges", "bytes");

        String rangeHeader = request.getHeader("Range");
        if (rangeHeader != null && rangeHeader.startsWith("bytes=")) {
            long start = 0;
            long end = fileLength - 1;
            String rangeValue = rangeHeader.substring(6);
            int dashIdx = rangeValue.indexOf('-');
            if (dashIdx > 0) start = Long.parseLong(rangeValue.substring(0, dashIdx));
            if (dashIdx < rangeValue.length() - 1) end = Long.parseLong(rangeValue.substring(dashIdx + 1));
            if (start >= fileLength || end >= fileLength || start > end) {
                response.setStatus(HttpServletResponse.SC_REQUESTED_RANGE_NOT_SATISFIABLE);
                response.setHeader("Content-Range", "bytes */" + fileLength);
                return;
            }
            long contentLength = end - start + 1;
            response.setStatus(HttpServletResponse.SC_PARTIAL_CONTENT);
            response.setHeader("Content-Range", "bytes " + start + "-" + end + "/" + fileLength);
            response.setContentLengthLong(contentLength);
            try (RandomAccessFile raf = new RandomAccessFile(audioFile, "r");
                 OutputStream out = response.getOutputStream()) {
                raf.seek(start);
                byte[] buffer = new byte[BUFFER_SIZE];
                long remaining = contentLength;
                while (remaining > 0) {
                    int read = raf.read(buffer, 0, (int) Math.min(BUFFER_SIZE, remaining));
                    if (read == -1) break;
                    out.write(buffer, 0, read);
                    remaining -= read;
                }
            }
        } else {
            response.setContentLengthLong(fileLength);
            response.setHeader("Cache-Control", "public, max-age=3600");
            try (OutputStream out = response.getOutputStream()) {
                Files.copy(audioFile.toPath(), out);
            }
        }
    }

    private String getContentType(String filePath) {
        if (filePath == null) return "application/octet-stream";
        String lower = filePath.toLowerCase();
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".mp3")) return "audio/mpeg";
        if (lower.endsWith(".aac")) return "audio/aac";
        if (lower.endsWith(".wma")) return "audio/x-ms-wma";
        if (lower.endsWith(".ogg")) return "audio/ogg";
        if (lower.endsWith(".flac")) return "audio/flac";
        if (lower.endsWith(".ape")) return "audio/x-ape";
        if (lower.endsWith(".wav")) return "audio/wav";
        if (lower.endsWith(".alac")) return "audio/mp4";
        if (lower.endsWith(".alff")) return "audio/aiff";
        if (lower.endsWith(".dsd")) return "audio/dsf";
        if (lower.endsWith(".mp4")) return "video/mp4";
        if (lower.endsWith(".webm")) return "video/webm";
        if (lower.endsWith(".mov")) return "video/quicktime";
        if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) return "image/jpeg";
        if (lower.endsWith(".gif")) return "image/gif";
        if (lower.endsWith(".bmp")) return "image/bmp";
        if (lower.endsWith(".webp")) return "image/webp";
        if (lower.endsWith(".svg")) return "image/svg+xml";
        if (lower.endsWith(".js")) return "application/javascript;charset=UTF-8";
        if (lower.endsWith(".css")) return "text/css;charset=UTF-8";
        if (lower.endsWith(".html") || lower.endsWith(".htm")) return "text/html;charset=UTF-8";
        if (lower.endsWith(".json")) return "application/json;charset=UTF-8";
        if (lower.endsWith(".xml")) return "application/xml;charset=UTF-8";
        if (lower.endsWith(".txt")) return "text/plain;charset=UTF-8";
        return "application/octet-stream";
    }
}
