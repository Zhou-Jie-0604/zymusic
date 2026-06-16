package com.zjlymusic.util;

import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.Base64;
import java.util.UUID;

public final class FileUploadUtil {
    private static final long MAX_IMAGE_SIZE = 5 * 1024 * 1024;
    private static final long MAX_MUSIC_SIZE = 100 * 1024 * 1024;
    private static final long MAX_BACKGROUND_SIZE = 50 * 1024 * 1024;
    private static final String[] ALLOWED_MUSIC_EXTENSIONS = {".mp3", ".flac"};

    private FileUploadUtil() {
    }

    public static boolean isPngFile(Part part) {
        if (part == null || part.getSize() <= 0) {
            return false;
        }
        String contentType = part.getContentType();
        String fileName = getSubmittedFileName(part);
        if (fileName != null && fileName.toLowerCase().endsWith(".png")) {
            return true;
        }
        return contentType != null && contentType.equalsIgnoreCase("image/png");
    }

    public static boolean isImageFile(Part part) {
        if (part == null || part.getSize() <= 0) {
            return false;
        }
        String contentType = part.getContentType();
        String fileName = getSubmittedFileName(part);
        if (fileName != null) {
            String lower = fileName.toLowerCase();
            if (lower.endsWith(".png") || lower.endsWith(".jpg") || lower.endsWith(".jpeg") ||
                lower.endsWith(".gif") || lower.endsWith(".bmp") || lower.endsWith(".webp") ||
                lower.endsWith(".tiff") || lower.endsWith(".tif") || lower.endsWith(".svg") || lower.endsWith(".ico")) {
                return true;
            }
        }
        if (contentType != null) {
            String lower = contentType.toLowerCase();
            return lower.startsWith("image/") && (
                lower.equals("image/png") || lower.equals("image/jpeg") ||
                lower.equals("image/gif") || lower.equals("image/bmp") ||
                lower.equals("image/webp") || lower.equals("image/tiff") ||
                lower.equals("image/svg+xml") || lower.equals("image/x-icon"));
        }
        return false;
    }

    public static String saveAvatar(Part part, int userId) throws IOException {
        validatePng(part);
        File dir = AppPaths.getAvatarsDir();
        String originalFileName = getSubmittedFileName(part);
        String extension = ".png";
        if (originalFileName != null) {
            String lower = originalFileName.toLowerCase();
            if (lower.endsWith(".jpg")) {
                extension = ".jpg";
            } else if (lower.endsWith(".jpeg")) {
                extension = ".jpeg";
            }
        }
        File target = new File(dir, "user_" + userId + extension);
        writePart(part, target);
        return "avatars/user_" + userId + extension;
    }

    public static String saveAvatarDataUrl(String dataUrl, int userId) throws IOException {
        byte[] bytes = decodeAvatarDataUrl(dataUrl);
        if (bytes.length == 0) {
            throw new IOException("请选择头像图片并完成裁剪");
        }
        if (bytes.length > MAX_IMAGE_SIZE) {
            throw new IOException("头像图片大小不能超过 5MB");
        }
        File dir = AppPaths.getAvatarsDir();
        String extension = detectImageExtension(bytes);
        File target = new File(dir, "user_" + userId + extension);
        Files.write(target.toPath(), bytes);
        return "avatars/user_" + userId + extension;
    }

    public static String saveCover(Part part) throws IOException {
        validateImage(part);
        File dir = AppPaths.getCoversDir();
        String originalFileName = getSubmittedFileName(part);
        String extension = ".png";
        if (originalFileName != null) {
            String lower = originalFileName.toLowerCase();
            if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
                extension = lower.endsWith(".jpg") ? ".jpg" : ".jpeg";
            }
        }
        String fileName = "cover_" + UUID.randomUUID().toString().replace("-", "") + extension;
        File target = new File(dir, fileName);
        writePart(part, target);
        return "covers/" + fileName;
    }

    public static String saveBackground(Part part, int userId) throws IOException {
        validateBackgroundFile(part);
        File dir = AppPaths.getBackgroundsDir();
        String originalFileName = getSubmittedFileName(part);
        String extension = ".png";
        if (originalFileName != null) {
            String lower = originalFileName.toLowerCase();
            if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
                extension = ".jpg";
            }
        }
        String fileName = "bg_user_" + userId + extension;
        File target = new File(dir, fileName);
        writePart(part, target);
        return "backgrounds/" + fileName;
    }

    private static void validateBackgroundFile(Part part) throws IOException {
        if (part == null || part.getSize() <= 0) {
            throw new IOException("请选择 PNG 或 JPG 格式图片");
        }
        if (part.getSize() > MAX_BACKGROUND_SIZE) {
            throw new IOException("背景文件大小不能超过 50MB");
        }
        if (!isImageFile(part)) {
            throw new IOException("不支持的背景文件格式，请选择 PNG 或 JPG 格式");
        }
    }

    public static String savePlaylistCover(Part part) throws IOException {
        validateImage(part);
        File dir = new File(AppPaths.getUploadsDir(), "playlists");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        String originalFileName = getSubmittedFileName(part);
        String extension = ".png";
        if (originalFileName != null) {
            String lower = originalFileName.toLowerCase();
            if (lower.endsWith(".jpg") || lower.endsWith(".jpeg")) {
                extension = lower.endsWith(".jpg") ? ".jpg" : ".jpeg";
            }
        }
        String fileName = "playlist_" + UUID.randomUUID().toString().replace("-", "") + extension;
        File target = new File(dir, fileName);
        writePart(part, target);
        return "files/playlists/" + fileName;
    }

    public static String saveMusic(Part part) throws IOException {
        validateMusic(part);
        String originalFileName = getSubmittedFileName(part);
        String extension = getFileExtension(originalFileName);
        String newFileName = "music_" + UUID.randomUUID().toString().replace("-", "") + extension;
        File dir = AppPaths.getMusicDir();
        File target = new File(dir, newFileName);
        writePart(part, target);
        return "music/" + newFileName;
    }

    private static void validateMusic(Part part) throws IOException {
        if (part == null || part.getSize() <= 0) {
            throw new IOException("请选择音乐文件");
        }
        if (part.getSize() > MAX_MUSIC_SIZE) {
            throw new IOException("音乐文件大小不能超过 100MB");
        }
        String fileName = getSubmittedFileName(part);
        if (!isAllowedMusicFile(fileName)) {
            throw new IOException("不支持的音乐文件格式，仅支持 MP3 和 FLAC");
        }
    }

    private static boolean isAllowedMusicFile(String fileName) {
        if (fileName == null) return false;
        String lower = fileName.toLowerCase();
        for (String ext : ALLOWED_MUSIC_EXTENSIONS) {
            if (lower.endsWith(ext)) {
                return true;
            }
        }
        return false;
    }

    private static String getFileExtension(String fileName) {
        if (fileName == null) return ".mp3";
        int lastDot = fileName.lastIndexOf('.');
        if (lastDot > 0) {
            return fileName.substring(lastDot).toLowerCase();
        }
        return ".mp3";
    }

    public static File resolveStoredFile(String relativePath) {
        if (relativePath == null || relativePath.trim().isEmpty()) {
            return null;
        }
        String normalized = relativePath.replace("\\", "/");
        if (normalized.contains("..")) {
            return null;
        }
        File file = new File(AppPaths.getUploadsDir(), normalized);
        if (!file.exists() || !file.isFile()) {
            return null;
        }
        return file;
    }

    private static void validatePng(Part part) throws IOException {
        if (part == null || part.getSize() <= 0) {
            throw new IOException("请选择 PNG 或 JPG 格式图片");
        }
        if (part.getSize() > MAX_IMAGE_SIZE) {
            throw new IOException("图片大小不能超过 5MB");
        }
        if (!isPngFile(part) && !isJpgFile(part)) {
            throw new IOException("仅支持 PNG 或 JPG 格式图片");
        }
    }

    private static boolean isJpgFile(Part part) {
        if (part == null || part.getSize() <= 0) {
            return false;
        }
        String contentType = part.getContentType();
        String fileName = getSubmittedFileName(part);
        if (fileName != null && (fileName.toLowerCase().endsWith(".jpg") || fileName.toLowerCase().endsWith(".jpeg"))) {
            return true;
        }
        return contentType != null && (contentType.equalsIgnoreCase("image/jpeg") || contentType.equalsIgnoreCase("image/jpg"));
    }

    private static void validateImage(Part part) throws IOException {
        if (part == null || part.getSize() <= 0) {
            throw new IOException("请选择图片");
        }
        if (part.getSize() > MAX_IMAGE_SIZE) {
            throw new IOException("图片大小不能超过 5MB");
        }
        if (!isImageFile(part)) {
            throw new IOException("不支持的图片格式，请选择 PNG、JPG、JPEG、GIF、BMP、WebP、TIFF、SVG 或 ICO 格式");
        }
    }

    private static byte[] decodeAvatarDataUrl(String dataUrl) throws IOException {
        if (dataUrl == null || dataUrl.trim().isEmpty()) {
            throw new IOException("请选择头像图片并完成裁剪");
        }
        // Find the base64 payload after the comma
        int commaIdx = dataUrl.indexOf(",");
        if (commaIdx < 0 || commaIdx >= dataUrl.length() - 1) {
            throw new IOException("头像裁剪数据无效");
        }
        String header = dataUrl.substring(0, commaIdx).toLowerCase();
        if (!header.contains("image/png") && !header.contains("image/jpeg") && !header.contains("image/jpg")) {
            throw new IOException("头像仅支持 PNG 或 JPG 格式");
        }
        String base64 = dataUrl.substring(commaIdx + 1);
        // Handle URL-safe base64 or whitespace
        base64 = base64.replaceAll("\\s+", "");
        try {
            byte[] decoded = Base64.getDecoder().decode(base64.getBytes(StandardCharsets.UTF_8));
            if (decoded.length < 8) {
                throw new IOException("头像图片数据无效");
            }
            return decoded;
        } catch (IllegalArgumentException ex) {
            throw new IOException("头像裁剪数据无效");
        }
    }

    private static String detectImageExtension(byte[] bytes) {
        if (bytes.length >= 3 && bytes[0] == (byte) 0xFF && bytes[1] == (byte) 0xD8 && bytes[2] == (byte) 0xFF) {
            return ".jpg";
        }
        if (bytes.length >= 8 && bytes[0] == (byte) 0x89 && bytes[1] == 0x50 && bytes[2] == 0x4E && bytes[3] == 0x47) {
            return ".png";
        }
        return ".png";
    }

    private static void writePart(Part part, File target) throws IOException {
        File parent = target.getParentFile();
        if (parent != null && !parent.exists()) {
            parent.mkdirs();
        }
        try (InputStream input = part.getInputStream()) {
            Files.copy(input, target.toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
    }

    private static String getSubmittedFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header == null) {
            return null;
        }
        for (String token : header.split(";")) {
            token = token.trim();
            if (token.startsWith("filename=")) {
                String name = token.substring("filename=".length()).replace("\"", "");
                if (name.contains("\\")) {
                    name = name.substring(name.lastIndexOf('\\') + 1);
                }
                if (name.contains("/")) {
                    name = name.substring(name.lastIndexOf('/') + 1);
                }
                return name;
            }
        }
        return null;
    }
}
