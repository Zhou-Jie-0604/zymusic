<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%@ page import="com.zjlymusic.entity.Music" %>
<%@ page import="com.zjlymusic.entity.Comment" %>
<%@ page import="com.zjlymusic.entity.Playlist" %>
<%@ page import="com.zjlymusic.service.PlaylistService" %>
<%@ page import="com.zjlymusic.service.MusicService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Music currentMusic = (Music) request.getAttribute("music");
    List<Music> musics = (List<Music>) request.getAttribute("musics");
    List<Comment> comments = (List<Comment>) request.getAttribute("comments");
    User user = (User) session.getAttribute("user");
    List<Playlist> userPlaylists = null;
    if (user != null) {
        userPlaylists = new PlaylistService().getPlaylistsByUserId(user.getId());
    }
    MusicService musicService = new MusicService();
    int currentMusicLikes = 0;
    boolean currentMusicLiked = false;
    if (currentMusic != null) {
        currentMusicLikes = musicService.getLikeCount(currentMusic.getId());
        if (user != null) {
            currentMusicLiked = musicService.hasUserLiked(currentMusic.getId(), user.getId());
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - 播放音乐</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="pwa-head.jsp" %>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/app.css">
    <style>
        .player-container, .header, .footer {
            position: relative;
            z-index: 10;
        }
    </style>
</head>
<body class="has-player-bar">
    <div class="background-animation"></div>

    <header class="header">
        <h1 class="title">ZY音乐</h1>
        <nav class="nav">
            <a href="index.jsp">首页</a>
            <a href="community">社区</a>
            <a href="upload.jsp">上传歌曲</a>
            <a href="profile">个人主页</a>
            <% 
                if (user != null) {
            %>
                    <a href="logout">退出登录</a>
            <% } else { %>
                    <a href="login.jsp">登录</a>
            <% } %>
        </nav>
    </header>
    
    <main class="player-container" style="max-width: 1600px;">
        <div class="player-section">
            <div class="vinyl-record" id="vinylRecord" style="width: 140px; height: 140px; border-radius: 50%; overflow: hidden; margin: 0 auto 30px;">
                <% 
                    String coverUrl = "files/covers/default-cover.svg";
                    if (currentMusic != null && currentMusic.getCoverUrl() != null && !currentMusic.getCoverUrl().isEmpty()) {
                        coverUrl = currentMusic.getCoverUrl();
                    }
                %>
                <img id="coverImage" src="<%= coverUrl %>" alt="歌曲封面" style="width: 100%; height: 100%; object-fit: cover; object-position: center;">
            </div>
            <div class="player-info">
                <h2 id="currentSong">
                    <% 
                        if (currentMusic != null) {
                    %>
                        <%= currentMusic.getName() %>
                    <% } else { %>
                        选择歌曲开始播放
                    <% } %>
                </h2>
                <p id="currentArtist">
                    <% 
                        if (currentMusic != null) {
                            String artist = currentMusic.getArtist();
                            if (artist != null && !artist.isEmpty()) {
                    %>
                        <%= artist %>
                    <% 
                            } else {
                    %>
                        <%= currentMusic.getUsername() %>
                    <% 
                            }
                        }
                    %>
                </p>
            </div>
            
            <div class="player-controls">
                <button class="control-btn like-btn" id="likeBtn" onclick="toggleLike()">
                    <span id="likeIcon"><%= currentMusicLiked ? "&#10084;" : "&#9825;" %></span>
                    <span class="like-count" id="likeCount"><%= currentMusicLikes > 0 ? currentMusicLikes : "" %></span>
                </button>
                <button class="control-btn" id="prevBtn">⏮</button>
                <button class="control-btn play-btn" id="playBtn">||</button>
                <button class="control-btn" id="nextBtn">⏭</button>
                <button class="control-btn play-mode-btn" id="playModeBtn" onclick="togglePlayMode()">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 12a9 9 0 0 1-9 9"/>
                        <path d="M3 12a9 9 0 0 1 9-9"/>
                        <polyline points="15 9 18 12 15 15"/>
                        <polyline points="9 15 6 12 9 9"/>
                        <text x="12" y="17" text-anchor="middle" fill="currentColor" font-size="12" font-weight="bold" stroke="none">1</text>
                    </svg>
                </button>
            </div>
            
            <div class="progress-section">
                <span id="currentTime">0:00</span>
                <input type="range" id="progressBar" min="0" max="100" value="0">
                <span id="totalTime">0:00</span>
            </div>
            
            <div class="volume-control">
                <span id="volumeIcon" style="color:#fff;font-size:18px;cursor:pointer;user-select:none;">🔊</span>
                <input type="range" id="volumeBar" min="0" max="100" value="70">
            </div>
        </div>
        
        <div class="playlist-section">
            <h3>播放列表</h3>
            <div class="playlist">
                <% 
                    if (musics != null && !musics.isEmpty()) {
                        int index = 0;
                        for (Music music : musics) {
                %>
                        <div class="playlist-item" onclick="playSong('<%= index %>')">
                            <span class="playlist-index"><%= index + 1 %></span>
                            <span class="playlist-name"><%= music.getName() %></span>
                            <span class="playlist-author"><%= music.getUsername() %></span>
                            <% if (user != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
                                <span class="add-to-playlist-btn" onclick="event.stopPropagation(); showPlaylistModal(<%= music.getId() %>)">+</span>
                            <% } %>
                        </div>
                <% 
                            index++;
                        }
                    }
                %>
            </div>
        </div>

        <div class="comments-section">
            <h3>评论区</h3>
            <% if (user != null) { %>
            <div class="comment-form" id="musicCommentForm">
                <input type="hidden" id="musicCommentMusicId" value="<%= currentMusic != null ? currentMusic.getId() : 0 %>">
                <textarea id="musicCommentContent" placeholder="发表你的评论..." rows="3"></textarea>
                <button onclick="submitMusicComment()">发表评论</button>
            </div>
            <% } else { %>
            <p class="login-hint">登录后可发表评论</p>
            <% } %>

            <div class="comments-list" id="musicCommentsList">
                <p class="no-comments">加载中...</p>
            </div>
            <div id="musicNestedReplyForm" class="post-reply-form"></div>
        </div>
    </main>
    
    <footer class="footer">
        <p>© 2026 ZY音乐 畅享世界</p>
    </footer>

    <style>
        .add-to-playlist-btn {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            width: 24px;
            height: 24px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            opacity: 0;
            transition: opacity 0.3s;
            font-size: 16px;
            line-height: 1;
        }
        .playlist-item:hover .add-to-playlist-btn {
            opacity: 1;
        }
        .playlist-item {
            position: relative;
        }
        .playlist-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            z-index: 2000;
            justify-content: center;
            align-items: center;
        }
        .playlist-modal.active {
            display: flex;
        }
        .playlist-modal-content {
            background: #1a1a2e;
            padding: 25px;
            border-radius: 15px;
            width: 350px;
            max-width: 90%;
        }
        .playlist-modal-content h3 {
            color: #fff;
            margin-bottom: 15px;
        }
        .playlist-option {
            display: block;
            padding: 12px 15px;
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 5px;
            transition: background 0.3s;
        }
        .playlist-option:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        .modal-close {
            color: #888;
            cursor: pointer;
            margin-top: 15px;
            text-align: center;
            display: block;
        }
        .play-btn {
            border-radius: 50% !important;
            aspect-ratio: 1 / 1 !important;
            min-width: 40px !important;
            min-height: 40px !important;
        }
        .btn-spinner {
            display: inline-block;
            width: 18px;
            height: 18px;
            border: 2px solid rgba(255,255,255,0.3);
            border-top-color: #fff;
            border-radius: 50%;
            animation: spin 0.6s linear infinite;
            vertical-align: middle;
        }
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        .control-btn.loading {
            pointer-events: none;
            opacity: 0.8;
        }
        .like-btn {
            position: relative;
            font-size: 24px !important;
            border-radius: 50% !important;
            aspect-ratio: 1 / 1 !important;
            min-width: 40px !important;
            min-height: 40px !important;
            padding: 0 !important;
            display: flex !important;
            align-items: center;
            justify-content: center;
        }
        .like-count {
            position: absolute;
            top: -6px;
            right: -6px;
            background: #e74c3c;
            color: #fff;
            font-size: 10px;
            min-width: 16px;
            height: 16px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
            font-weight: bold;
            line-height: 1;
            pointer-events: none;
        }
        .play-mode-btn {
            font-size: 20px !important;
        }
        .add-to-playlist-modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.7);
            z-index: 2000;
            justify-content: center;
            align-items: center;
        }
        .add-to-playlist-modal.active {
            display: flex;
        }
        .add-to-playlist-content {
            background: #1a1a2e;
            padding: 25px;
            border-radius: 15px;
            width: 350px;
            max-width: 90%;
        }
        .add-to-playlist-content h3 {
            color: #fff;
            margin-bottom: 15px;
        }
        .add-to-playlist-option {
            display: block;
            padding: 12px 15px;
            color: #fff;
            text-decoration: none;
            border-radius: 8px;
            margin-bottom: 5px;
            transition: background 0.3s;
            cursor: pointer;
        }
        .add-to-playlist-option:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        .modal-cancel {
            color: #888;
            cursor: pointer;
            margin-top: 15px;
            text-align: center;
            display: block;
        }
        .music-nested-reply {
            padding-left: 20px;
            margin-top: 6px;
            border-left: 1px solid rgba(255,255,255,0.08);
            font-size: 13px;
        }
        .reply-prefix {
            color: #999;
            font-size: 12px;
        }
        .reply-btn {
            color: #888;
            font-size: 12px;
            cursor: pointer;
            margin-left: 8px;
        }
        .reply-btn:hover {
            color: #667eea;
        }
        .post-reply-form {
            display: none;
            margin-top: 10px;
            margin-left: 20px;
        }
        .post-reply-form.active {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        .post-reply-form input {
            flex: 1;
            background: rgba(255,255,255,0.1);
            border: 1px solid rgba(255,255,255,0.2);
            color: #fff;
            padding: 6px 10px;
            border-radius: 15px;
            font-size: 13px;
            outline: none;
        }
        .post-reply-form button {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 6px 14px;
            border-radius: 15px;
            cursor: pointer;
            font-size: 12px;
            white-space: nowrap;
        }
    </style>
    <% if (user != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
    <div class="playlist-modal" id="playlistModal">
        <div class="playlist-modal-content">
            <h3>添加到歌单</h3>
            <div id="playlistOptions">
                <% for (Playlist p : userPlaylists) { %>
                    <a class="playlist-option" href="javascript:void(0)" onclick="addToPlaylist(<%= p.getId() %>)"><%= p.getName() %></a>
                <% } %>
            </div>
            <a href="playlist" class="modal-close">管理歌单</a>
            <span class="modal-close" onclick="closePlaylistModal()">取消</span>
        </div>
    </div>
    <% } %>

    <script>
        window.playlistData = [
            <% 
                if (musics != null && !musics.isEmpty()) {
                    int idx = 0;
                    for (Music music : musics) {
                        String safeName = music.getName().replace("\\", "\\\\").replace("\"", "\\\"");
                        String safeArtist = music.getUsername().replace("\\", "\\\\").replace("\"", "\\\"");
                        int duration = music.getDuration();
                        String safeUrl = music.getUrl().replace("\\", "\\\\").replace("\"", "\\\"");
                        String safeCoverUrl = "";
                        if (music.getCoverUrl() != null) {
                            safeCoverUrl = music.getCoverUrl().replace("\\", "\\\\").replace("\"", "\\\"");
                        }
            %>
            { id: <%= music.getId() %>, name: "<%= safeName %>", artist: "<%= safeArtist %>", url: "<%= safeUrl %>", cover: "<%= safeCoverUrl %>", duration: <%= duration %> }<%= (++idx < musics.size()) ? "," : "" %>
            <% 
                    }
                }
            %>
        ];
        <% 
            if (currentMusic != null && musics != null) {
                int initialIndex = 0;
                for (Music music : musics) {
                    if (music.getId() == currentMusic.getId()) {
                        break;
                    }
                    initialIndex++;
                }
        %>
        window.initialSongIndex = <%= initialIndex %>;
        <% } else { %>
        window.initialSongIndex = 0;
        <% } %>
    </script>
    <script>
        window.currentMusicId = <%= currentMusic != null ? currentMusic.getId() : 0 %>;
        window.currentMusicLiked = <%= currentMusicLiked %>;
        window.currentMusicLikes = <%= currentMusicLikes %>;
        window.currentUserId = <%= user != null ? user.getId() : 0 %>;

        function toggleLike() {
            if (!window.currentUserId) {
                alert('请先登录');
                return;
            }
            var musicId = window.currentMusicId;
            if (!musicId) return;
            fetch('like', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: 'musicId=' + musicId
            })
            .then(function(response) { return response.json(); })
            .then(function(data) {
                window.currentMusicLiked = data.liked;
                window.currentMusicLikes = data.count;
                updateLikeButton();
            })
            .catch(function(err) { console.error(err); });
        }

        function updateLikeButton() {
            var icon = document.getElementById('likeIcon');
            var count = document.getElementById('likeCount');
            if (icon) {
                icon.innerHTML = window.currentMusicLiked ? '&#10084;' : '&#9825;';
            }
            if (count) {
                count.textContent = window.currentMusicLikes > 0 ? window.currentMusicLikes : '';
            }
        }

        function showMusicReply(musicId, parentId, parentUsername) {
            var container = document.getElementById('musicNestedReplyForm');
            container.innerHTML = '<div style="display:flex;gap:8px;align-items:center;">' +
                '<input type="hidden" id="nestedMusicId" value="' + musicId + '">' +
                '<input type="hidden" id="nestedParentId" value="' + parentId + '">' +
                '<input type="hidden" id="nestedParentUsername" value="' + parentUsername + '">' +
                '<input type="text" id="nestedMusicContent" placeholder="回复 ' + parentUsername + '..." style="flex:1;background:rgba(255,255,255,0.1);border:1px solid rgba(255,255,255,0.2);color:#fff;padding:6px 10px;border-radius:15px;font-size:13px;outline:none;">' +
                '<button onclick="submitMusicNestedComment()" style="background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;border:none;padding:6px 14px;border-radius:15px;cursor:pointer;font-size:12px;">发送</button>' +
                '</div>';
            container.classList.add('active');
        }

        // Load comments for current music
        function loadMusicComments(musicId) {
            if (!musicId) return;
            document.getElementById('musicCommentMusicId').value = musicId;
            fetch('comment?musicId=' + musicId)
                .then(function(r) { return r.json(); })
                .then(function(comments) {
                    renderMusicComments(comments, musicId);
                })
                .catch(function(err) { console.error(err); });
        }

        function renderMusicComments(comments, musicId) {
            var list = document.getElementById('musicCommentsList');
            if (!comments || comments.length === 0) {
                list.innerHTML = '<p class="no-comments">暂无评论，快来发表第一个吧！</p>';
                return;
            }
            var html = '';
            // Top-level comments (parentId == 0)
            for (var i = 0; i < comments.length; i++) {
                var c = comments[i];
                if (c.parentId === 0) {
                    html += '<div class="comment-item" data-comment-id="' + c.id + '">';
                    html += '<div class="comment-header">';
                    html += '<a href="profile?userId=' + c.userId + '" class="comment-author">' + c.username + '</a> ';
                    html += '<span class="comment-time">' + c.time + '</span> ';
                    html += '<span class="reply-btn" onclick="showMusicReply(' + musicId + ', ' + c.id + ', \'' + c.username + '\')">回复</span>';
                    html += '</div>';
                    html += '<p class="comment-content">' + c.content + '</p>';
                    // Nested replies
                    for (var j = 0; j < comments.length; j++) {
                        var nested = comments[j];
                        if (nested.parentId === c.id) {
                            html += '<div class="music-nested-reply">';
                            html += '<span class="reply-prefix">回复（' + (nested.parentUsername || '') + '）：</span>';
                            html += '<a href="profile?userId=' + nested.userId + '" class="comment-author">' + nested.username + '</a> ';
                            html += '<span class="comment-content">' + nested.content + '</span> ';
                            html += '<span class="comment-time">' + nested.time + '</span> ';
                            html += '<span class="reply-btn" onclick="showMusicReply(' + musicId + ', ' + nested.id + ', \'' + nested.username + '\')">回复</span>';
                            html += '</div>';
                        }
                    }
                    html += '</div>';
                }
            }
            list.innerHTML = html;
        }

        function submitMusicComment() {
            var musicId = document.getElementById('musicCommentMusicId').value;
            var content = document.getElementById('musicCommentContent').value.trim();
            if (!content) return;
            fetch('comment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: 'musicId=' + encodeURIComponent(musicId) + '&content=' + encodeURIComponent(content)
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    alert('回复成功');
                    document.getElementById('musicCommentContent').value = '';
                    loadMusicComments(musicId);
                }
            })
            .catch(function(err) { console.error(err); });
        }

        function submitMusicNestedComment() {
            var musicId = document.getElementById('nestedMusicId').value;
            var parentId = document.getElementById('nestedParentId').value;
            var parentUsername = document.getElementById('nestedParentUsername').value;
            var content = document.getElementById('nestedMusicContent').value.trim();
            if (!content) return;
            fetch('comment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: 'musicId=' + encodeURIComponent(musicId) +
                    '&parentId=' + encodeURIComponent(parentId) +
                    '&parentUsername=' + encodeURIComponent(parentUsername) +
                    '&content=' + encodeURIComponent(content)
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    alert('回复成功');
                    document.getElementById('musicNestedReplyForm').classList.remove('active');
                    loadMusicComments(musicId);
                }
            })
            .catch(function(err) { console.error(err); });
        }

        // Initial load
        <% if (currentMusic != null) { %>
        loadMusicComments(<%= currentMusic.getId() %>);
        <% } %>

        function updateLikeForSong(musicId) {
            if (!musicId) return;
            window.currentMusicId = musicId;
            fetch('like?musicId=' + musicId, {
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
            .then(function(response) { return response.json(); })
            .then(function(data) {
                window.currentMusicLiked = data.liked;
                window.currentMusicLikes = data.count;
                updateLikeButton();
            })
            .catch(function(err) { console.error(err); });
        }
    </script>
    <script src="js/player.js"></script>
    <% if (user != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
    <div class="add-to-playlist-modal" id="addToPlaylistModal">
        <div class="add-to-playlist-content">
            <h3>添加到歌单</h3>
            <div id="addToPlaylistOptions">
                <% for (Playlist p : userPlaylists) { %>
                    <div class="add-to-playlist-option" onclick="addCurrentSongToPlaylist(<%= p.getId() %>)"><%= p.getName() %></div>
                <% } %>
            </div>
            <a href="playlist" class="modal-cancel">管理歌单</a>
            <span class="modal-cancel" onclick="closeAddToPlaylistModal()">取消</span>
        </div>
    </div>
    <script>
        function showPlaylistModal(musicId) {
            window.currentMusicIdForPlaylist = musicId;
            document.getElementById('playlistModal').classList.add('active');
        }
        function closePlaylistModal() {
            document.getElementById('playlistModal').classList.remove('active');
        }
        function addToPlaylist(playlistId) {
            var musicId = window.currentMusicIdForPlaylist;
            if (!musicId) return;
            fetch('playlist?action=addMusic&playlistId=' + playlistId + '&musicId=' + musicId, {
                method: 'POST',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
                .then(function(response) {
                    if (response.ok) {
                        closePlaylistModal();
                        alert('已添加到歌单');
                    }
                })
                .catch(function(err) {
                    console.error(err);
                    closePlaylistModal();
                });
        }
        function showAddToPlaylistModal() {
            var currentSong = window.playlistData[window.currentSongIndex];
            if (currentSong) {
                window.currentMusicIdForPlaylist = currentSong.id;
                document.getElementById('addToPlaylistModal').classList.add('active');
            }
        }
        function closeAddToPlaylistModal() {
            document.getElementById('addToPlaylistModal').classList.remove('active');
        }
        function addCurrentSongToPlaylist(playlistId) {
            var musicId = window.currentMusicIdForPlaylist;
            if (!musicId) return;
            fetch('playlist?action=addMusic&playlistId=' + playlistId + '&musicId=' + musicId, {
                method: 'POST',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
                .then(function(response) {
                    if (response.ok) {
                        closeAddToPlaylistModal();
                        alert('已添加到歌单');
                    }
                })
                .catch(function(err) {
                    console.error(err);
                    closeAddToPlaylistModal();
                });
        }
        window.onclick = function(e) {
            if (e.target.id === 'playlistModal') {
                closePlaylistModal();
            }
            if (e.target.id === 'addToPlaylistModal') {
                closeAddToPlaylistModal();
            }
        }
    </script>
    <% } %>
  <%@ include file="notify-bar.jsp" %>
</body>
</html>
