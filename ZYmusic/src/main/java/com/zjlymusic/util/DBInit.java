package com.zjlymusic.util;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DBInit {
    public static void initialize() {
        try {
            Class.forName("org.sqlite.JDBC");
            try (Connection conn = DriverManager.getConnection("jdbc:sqlite:" + AppPaths.getDatabaseFile().getAbsolutePath());
                 Statement stmt = conn.createStatement()) {
                stmt.execute("PRAGMA journal_mode=WAL");
                stmt.execute("PRAGMA busy_timeout=5000");
                stmt.execute("PRAGMA synchronous=NORMAL");

                String createUsersTable = "CREATE TABLE IF NOT EXISTS users (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "username TEXT NOT NULL UNIQUE," +
                    "password TEXT NOT NULL," +
                    "avatar TEXT)";
                stmt.execute(createUsersTable);

                String createMusicTable = "CREATE TABLE IF NOT EXISTS music (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "name TEXT NOT NULL," +
                    "artist TEXT," +
                    "url TEXT NOT NULL," +
                    "type TEXT NOT NULL," +
                    "cover TEXT," +
                    "user_id INTEGER NOT NULL," +
                    "username TEXT NOT NULL," +
                    "upload_time TIMESTAMP NOT NULL," +
                    "FOREIGN KEY (user_id) REFERENCES users(id))";
                stmt.execute(createMusicTable);

                String createPostsTable = "CREATE TABLE IF NOT EXISTS posts (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "content TEXT NOT NULL," +
                    "user_id INTEGER NOT NULL," +
                    "username TEXT NOT NULL," +
                    "post_time TIMESTAMP NOT NULL," +
                    "FOREIGN KEY (user_id) REFERENCES users(id))";
                stmt.execute(createPostsTable);

                String createCommentsTable = "CREATE TABLE IF NOT EXISTS comments (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "content TEXT NOT NULL," +
                    "user_id INTEGER NOT NULL," +
                    "username TEXT NOT NULL," +
                    "music_id INTEGER NOT NULL," +
                    "comment_time TIMESTAMP NOT NULL," +
                    "FOREIGN KEY (user_id) REFERENCES users(id)," +
                    "FOREIGN KEY (music_id) REFERENCES music(id))";
                stmt.execute(createCommentsTable);

                ensureColumn(conn, "users", "avatar", "TEXT");
                ensureColumn(conn, "users", "background", "TEXT");
                ensureColumn(conn, "users", "bio", "TEXT");
                ensureColumn(conn, "users", "phone", "TEXT");
                ensureColumn(conn, "users", "nickname", "TEXT");
                ensureColumn(conn, "users", "background_opacity", "INTEGER DEFAULT 30");
                ensureColumn(conn, "music", "cover", "TEXT");
                ensureColumn(conn, "music", "artist", "TEXT");
                ensureColumn(conn, "music", "likes", "INTEGER DEFAULT 0");
                ensureColumn(conn, "music", "duration", "INTEGER DEFAULT 0");
                ensureColumn(conn, "comments", "post_id", "INTEGER");
                ensureColumn(conn, "comments", "parent_id", "INTEGER");
                ensureColumn(conn, "comments", "parent_username", "TEXT");

                String createMusicLikesTable = "CREATE TABLE IF NOT EXISTS music_likes (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "user_id INTEGER NOT NULL," +
                    "music_id INTEGER NOT NULL," +
                    "like_time TIMESTAMP NOT NULL," +
                    "FOREIGN KEY (user_id) REFERENCES users(id)," +
                    "FOREIGN KEY (music_id) REFERENCES music(id)," +
                    "UNIQUE(user_id, music_id))";
                stmt.execute(createMusicLikesTable);

                // Create playlists table
                String createPlaylistsTable = "CREATE TABLE IF NOT EXISTS playlists (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "name TEXT NOT NULL," +
                    "cover_url TEXT," +
                    "user_id INTEGER NOT NULL," +
                    "username TEXT NOT NULL," +
                    "create_time TIMESTAMP NOT NULL," +
                    "FOREIGN KEY (user_id) REFERENCES users(id))";
                stmt.execute(createPlaylistsTable);

                // Create playlist_songs table
                String createPlaylistSongsTable = "CREATE TABLE IF NOT EXISTS playlist_songs (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "playlist_id INTEGER NOT NULL," +
                    "music_id INTEGER NOT NULL," +
                    "position INTEGER NOT NULL," +
                    "add_time TIMESTAMP NOT NULL," +
                    "FOREIGN KEY (playlist_id) REFERENCES playlists(id)," +
                    "FOREIGN KEY (music_id) REFERENCES music(id))";
                stmt.execute(createPlaylistSongsTable);

                // Ensure position and add_time columns exist
                ensureColumn(conn, "playlist_songs", "position", "INTEGER NOT NULL DEFAULT 0");
                ensureColumn(conn, "playlist_songs", "add_time", "TIMESTAMP NOT NULL");

                // Create follows table
                String createFollowsTable = "CREATE TABLE IF NOT EXISTS follows (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "follower_id INTEGER NOT NULL," +
                    "following_id INTEGER NOT NULL," +
                    "follow_time TIMESTAMP NOT NULL," +
                    "FOREIGN KEY (follower_id) REFERENCES users(id)," +
                    "FOREIGN KEY (following_id) REFERENCES users(id)," +
                    "UNIQUE(follower_id, following_id))";
                stmt.execute(createFollowsTable);

                // Create messages table
                String createMessagesTable = "CREATE TABLE IF NOT EXISTS messages (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "sender_id INTEGER NOT NULL," +
                    "receiver_id INTEGER NOT NULL," +
                    "content TEXT NOT NULL," +
                    "send_time TIMESTAMP NOT NULL," +
                    "FOREIGN KEY (sender_id) REFERENCES users(id)," +
                    "FOREIGN KEY (receiver_id) REFERENCES users(id))";
                stmt.execute(createMessagesTable);

                // Create notifications table
                String createNotificationsTable = "CREATE TABLE IF NOT EXISTS notifications (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT," +
                    "user_id INTEGER NOT NULL," +
                    "type TEXT NOT NULL," +
                    "from_user_id INTEGER NOT NULL," +
                    "from_username TEXT NOT NULL," +
                    "content TEXT," +
                    "related_id INTEGER," +
                    "related_type TEXT," +
                    "create_time TIMESTAMP NOT NULL," +
                    "is_read INTEGER DEFAULT 0," +
                    "FOREIGN KEY (user_id) REFERENCES users(id))";
                stmt.execute(createNotificationsTable);
            }
            AppPaths.getUploadsDir();
        } catch (Exception e) {
            throw new RuntimeException("数据库初始化失败", e);
        }
    }

    private static void ensureColumn(Connection conn, String table, String column, String type) throws SQLException {
        DatabaseMetaData meta = conn.getMetaData();
        try (ResultSet rs = meta.getColumns(null, null, table, column)) {
            if (!rs.next()) {
                try (Statement stmt = conn.createStatement()) {
                    stmt.execute("ALTER TABLE " + table + " ADD COLUMN " + column + " " + type);
                }
            }
        }
    }

    public static void main(String[] args) {
        initialize();
        System.out.println("数据库初始化完成: " + AppPaths.getDatabaseFile().getAbsolutePath());
    }
}
