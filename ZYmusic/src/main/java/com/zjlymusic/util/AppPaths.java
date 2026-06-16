package com.zjlymusic.util;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;

public final class AppPaths {
    private static final String APP_DIR_NAME = ".zymusic";
    private static File dataDir;
    private static File tempDir;
    private static File webappDir;
    private static File warFile;

    private AppPaths() {
    }

    public static synchronized File getDataDir() {
        if (dataDir == null) {
            // 1. System property (command-line -D)
            String override = System.getProperty("zymusic.data.dir");
            // 2. Environment variable (cloud platforms)
            if (override == null || override.trim().isEmpty()) {
                override = System.getenv("ZYMUSIC_DATA_DIR");
            }
            if (override != null && !override.trim().isEmpty()) {
                dataDir = new File(override.trim());
            } else {
                dataDir = new File(new File(findProjectRoot(), "target"), "runtime");
            }
            if (!dataDir.exists()) {
                dataDir.mkdirs();
            }
        }
        return dataDir;
    }

    public static File getDatabaseFile() {
        return new File(getDataDir(), "music.db");
    }

    public static File getTempDir() {
        if (tempDir == null) {
            tempDir = new File(getDataDir(), "tmp-" + System.currentTimeMillis());
        }
        return tempDir;
    }

    public static File getUploadsDir() {
        File uploadsDir = new File(getDataDir(), "uploads");
        if (!uploadsDir.exists()) {
            uploadsDir.mkdirs();
        }
        return uploadsDir;
    }

    public static File getAvatarsDir() {
        File dir = new File(getUploadsDir(), "avatars");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir;
    }

    public static File getCoversDir() {
        File dir = new File(getUploadsDir(), "covers");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir;
    }

    public static File getMusicDir() {
        File dir = new File(getUploadsDir(), "music");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir;
    }

    public static File getBackgroundsDir() {
        File dir = new File(getUploadsDir(), "backgrounds");
        if (!dir.exists()) {
            dir.mkdirs();
        }
        return dir;
    }

    public static synchronized File getWarFile() throws IOException {
        if (warFile != null && warFile.exists()) {
            return warFile;
        }

        File packagedWar = new File("target/ZYMusic.war");
        if (packagedWar.exists()) {
            warFile = packagedWar;
            return warFile;
        }

        File localWar = new File("ZYMusic.war");
        if (localWar.exists()) {
            warFile = localWar;
            return warFile;
        }

        InputStream stream = AppPaths.class.getResourceAsStream("/ZYMusic.war");
        if (stream != null) {
            File extractedWar = new File(getDataDir(), "ZYMusic.war");
            Files.copy(stream, extractedWar.toPath(), StandardCopyOption.REPLACE_EXISTING);
            stream.close();
            warFile = extractedWar;
            return warFile;
        }

        throw new IOException("找不到 Web 应用包，请先执行 mvn package 生成 ZYMusic.war");
    }

    public static synchronized File getWebappDir() throws IOException {
        if (webappDir != null && webappDir.exists()) {
            return webappDir;
        }

        File devWebapp = new File("src/main/webapp");
        if (devWebapp.exists()) {
            webappDir = devWebapp;
            return webappDir;
        }

        try {
            File war = getWarFile();
            File extracted = new File(getDataDir(), "webapp");
            if (!extracted.exists()) {
                extracted.mkdirs();
            }
            webappDir = extracted;
            return webappDir;
        } catch (IOException ignored) {
            // fall through
        }

        throw new IOException("找不到 Web 资源目录");
    }

    public static File resolveWebResourceRoot() throws IOException {
        File devWebapp = findProjectFile("src/main/webapp");
        if (devWebapp.exists()) {
            return devWebapp;
        }

        // Check for webapp directory next to the application (production)
        File localWebapp = new File("webapp");
        if (localWebapp.exists() && new File(localWebapp, "index.jsp").exists()) {
            return localWebapp.getAbsoluteFile();
        }
        // Check in parent directory (jpackage EXE runs from app/ subdir)
        File parentWebapp = new File("../webapp");
        if (parentWebapp.exists() && new File(parentWebapp, "index.jsp").exists()) {
            return parentWebapp.getAbsoluteFile();
        }

        try {
            return getWarFile();
        } catch (IOException e) {
            return localWebapp;
        }
    }

    private static File findProjectFile(String relativePath) {
        File projectRoot = findProjectRoot();
        File candidateFromRoot = new File(projectRoot, relativePath);
        if (candidateFromRoot.exists()) {
            return candidateFromRoot;
        }
        return new File(relativePath);
    }

    private static File findProjectRoot() {
        File current = new File(System.getProperty("user.dir")).getAbsoluteFile();
        while (current != null) {
            if (new File(current, "pom.xml").exists() && new File(current, "src/main/webapp").exists()) {
                return current;
            }
            current = current.getParentFile();
        }
        return new File(System.getProperty("user.dir")).getAbsoluteFile();
    }
}
