package com.zjlymusic.util;

import java.io.*;

public final class AudioConverter {
    private AudioConverter() {}

    // Convert any uploaded audio to MP3 (or WAV fallback for FLAC without FFmpeg)
    // MP3 files are kept as-is
    public static File ensurePlayable(File audioFile) throws Exception {
        String name = audioFile.getName().toLowerCase();
        // Already MP3 - nothing to do
        if (name.endsWith(".mp3")) {
            return audioFile;
        }
        // Try FFmpeg MP3 conversion (produces compact, universally playable MP3)
        File mp3 = convertToMp3(audioFile);
        if (mp3 != null && mp3.exists() && mp3.length() > 0) {
            return mp3;
        }
        // Fallback: FLAC→WAV via jflac
        if (FlacTranscoder.isFlacFile(name)) {
            File cachedWav = FlacTranscoder.getCachedWavFile(audioFile);
            if (!cachedWav.exists()) {
                byte[] wavBytes = FlacTranscoder.transcodeToWav(audioFile);
                FlacTranscoder.cacheWav(audioFile, wavBytes);
            }
            return cachedWav;
        }
        return audioFile;
    }

    public static File convertToMp3(File audioFile) throws Exception {
        File ffmpeg = findFfmpeg();
        if (ffmpeg == null) return null;

        File mp3File = new File(audioFile.getParentFile(),
            audioFile.getName().replaceFirst("\\.[^.]+$", "") + ".mp3");

        if (mp3File.exists() && mp3File.length() > 0) {
            return mp3File;
        }

        ProcessBuilder pb = new ProcessBuilder(
            ffmpeg.getAbsolutePath(),
            "-y", "-i", audioFile.getAbsolutePath(),
            "-b:a", "320k",
            "-write_xing", "1",
            mp3File.getAbsolutePath()
        );
        pb.redirectErrorStream(true);
        Process p = pb.start();
        // Drain stdout/stderr in background to prevent pipe-buffer deadlock
        Thread drainer = new Thread(() -> {
            try {
                byte[] buf = new byte[8192];
                InputStream in = p.getInputStream();
                while (in.read(buf) != -1) {}
            } catch (IOException ignored) {}
        }, "ffmpeg-drain");
        drainer.setDaemon(true);
        drainer.start();
        p.waitFor();

        if (p.exitValue() == 0 && mp3File.exists() && mp3File.length() > 0) {
            return mp3File;
        }
        return null;
    }

    public static int getMp3DurationSeconds(File mp3File) {
        File ffmpeg = findFfmpeg();
        if (ffmpeg == null) return 0;
        try {
            ProcessBuilder pb = new ProcessBuilder(
                ffmpeg.getAbsolutePath(),
                "-i", mp3File.getAbsolutePath()
            );
            pb.redirectErrorStream(true);
            Process p = pb.start();
            String output = new String(p.getInputStream().readAllBytes());
            p.waitFor();
            for (String line : output.split("\n")) {
                if (line.contains("Duration:")) {
                    int durIndex = line.indexOf("Duration:");
                    String timePart = line.substring(durIndex + 9).trim();
                    int commaIndex = timePart.indexOf(',');
                    if (commaIndex > 0) {
                        timePart = timePart.substring(0, commaIndex);
                    }
                    String[] parts = timePart.split("[:.]");
                    if (parts.length >= 3) {
                        try {
                            int h = Integer.parseInt(parts[0].trim());
                            int m = Integer.parseInt(parts[1].trim());
                            int s = Integer.parseInt(parts[2].trim());
                            int totalSeconds = h * 3600 + m * 60 + s;
                            if (totalSeconds > 0) return totalSeconds;
                        } catch (NumberFormatException e) {
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("FFmpeg duration parse error: " + e.getMessage());
        }
        return 0;
    }

    private static File findFfmpeg() {
        // Check PATH
        String[] paths = System.getenv("PATH").split(File.pathSeparator);
        for (String p : paths) {
            File f = new File(p, "ffmpeg.exe");
            if (f.exists()) return f;
            f = new File(p, "ffmpeg");
            if (f.exists()) return f;
        }
        // Check winget install location
        File wingetDir = new File(System.getenv("LOCALAPPDATA"),
            "Microsoft/WinGet/Packages");
        File[] wingetPkgs = wingetDir.listFiles(f ->
            f.isDirectory() && f.getName().toLowerCase().contains("ffmpeg"));
        if (wingetPkgs != null) {
            for (File pkg : wingetPkgs) {
                File[] bins = pkg.listFiles(f ->
                    f.isDirectory() && f.getName().toLowerCase().contains("build"));
                if (bins != null) {
                    for (File build : bins) {
                        File ff = new File(new File(build, "bin"), "ffmpeg.exe");
                        if (ff.exists()) return ff;
                    }
                }
            }
        }
        // Check app tools directory
        File appDir = new File(System.getProperty("user.dir"), "tools");
        File f = new File(appDir, "ffmpeg.exe");
        if (f.exists()) return f;
        return null;
    }
}
