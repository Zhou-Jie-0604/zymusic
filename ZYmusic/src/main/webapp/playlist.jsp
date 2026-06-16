<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%@ page import="com.zjlymusic.entity.Playlist" %>
<%@ page import="com.zjlymusic.entity.Music" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String userBg = (sessionUser != null && sessionUser.getBackgroundUrl() != null) ? sessionUser.getBackgroundUrl() : null;
    int bgOpacity = (sessionUser != null) ? sessionUser.getBackgroundOpacity() : 80;
    Playlist playlist = (Playlist) request.getAttribute("playlist");
    List<Music> musics = (List<Music>) request.getAttribute("musics");
    Music currentMusic = (Music) request.getAttribute("currentMusic");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - <%= playlist != null ? playlist.getName() : "歌单" %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="manifest" href="manifest.json">
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/app.css">
    <style>
        .custom-background-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            z-index: 0;
            pointer-events: none;
        }
        .custom-bg-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(26, 26, 46, 0.8);
            z-index: 1;
            pointer-events: none;
        }
        .bg-upload-container {
            position: fixed;
            top: 70px;
            right: 20px;
            z-index: 1001;
        }
        .bg-opacity-control {
            position: fixed;
            top: 70px;
            right: 220px;
            z-index: 1002;
            display: none;
            background: rgba(26, 26, 46, 0.9);
            padding: 10px 15px;
            border-radius: 10px;
            color: white;
            font-size: 12px;
        }
        .bg-opacity-control.active {
            display: block;
        }
        .bg-opacity-control input[type="range"] {
            width: 100px;
            margin-left: 10px;
        }
        .bg-confirm-btn {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
            border: none;
            padding: 5px 12px;
            border-radius: 15px;
            cursor: pointer;
            font-size: 12px;
            margin-left: 10px;
        }
        .bg-upload-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 14px;
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
            transition: all 0.3s ease;
        }
        .bg-upload-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(102, 126, 234, 0.6);
        }
        .bg-upload-form {
            display: none;
            margin-top: 10px;
        }
        .bg-upload-form.active {
            display: block;
        }
        .bg-upload-form input[type="file"] {
            display: none;
        }
        .bg-upload-form label {
            display: inline-block;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 12px;
        }
        .bg-upload-form button {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 12px;
            margin-left: 10px;
        }
        .playlist-view-container, .header, .footer {
            position: relative;
            z-index: 10;
        }
        .playlist-info {
            display: flex;
            align-items: center;
            gap: 30px;
            margin-bottom: 30px;
            max-width: 1200px;
        }
        .playlist-cover-large {
            width: 200px;
            height: 200px;
            border-radius: 15px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            overflow: hidden;
            position: relative;
            flex-shrink: 0;
        }
        .playlist-cover-large img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .playlist-cover-placeholder {
            width: 100%;
            height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 72px;
            color: white;
        }
        .cover-update-form {
            position: absolute;
            bottom: 0;
            left: 0;
            right: 0;
            background: rgba(0,0,0,0.5);
            padding: 5px;
            text-align: center;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .playlist-cover-large:hover .cover-update-form {
            opacity: 1;
        }
        .cover-update-form input[type="file"] {
            display: none;
        }
        .cover-update-form label {
            color: white;
            font-size: 12px;
            cursor: pointer;
        }
        .playlist-details h2 {
            color: #fff;
            margin-bottom: 10px;
        }
        .playlist-details p {
            color: #aaa;
            margin-bottom: 5px;
        }
        .music-list {
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            padding: 20px;
        }
        .music-item {
            display: flex;
            align-items: center;
            padding: 15px;
            border-radius: 10px;
            transition: background 0.3s;
            position: relative;
        }
        .music-item:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        .music-item.playing {
            background: rgba(255, 255, 255, 0.1);
        }
        .music-item .music-cover {
            width: 50px;
            height: 50px;
            border-radius: 8px;
            overflow: hidden;
            margin-right: 15px;
            flex-shrink: 0;
        }
        .music-item .music-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .music-item .music-cover-placeholder {
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
        }
        .music-item .music-info {
            flex: 1;
            min-width: 0;
        }
        .music-item .music-name {
            color: #fff;
            font-size: 14px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .music-item .music-author {
            color: #888;
            font-size: 12px;
        }
        .music-item .music-actions {
            display: flex;
            gap: 10px;
            align-items: center;
            margin-left: 15px;
        }
        .music-item .play-link {
            color: #667eea;
            font-size: 20px;
            text-decoration: none;
        }
        .music-item .remove-link {
            color: #ff6b6b;
            font-size: 12px;
        }
        .playing-indicator {
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            right: 0;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            pointer-events: none;
        }
        .back-link {
            display: inline-block;
            color: #667eea;
            margin-bottom: 20px;
            text-decoration: none;
        }
        .back-link:hover {
            text-decoration: underline;
        }
        .empty-message {
            color: #aaa;
            text-align: center;
            padding: 40px;
        }
        .sort-options {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .sort-btn {
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            border: none;
            padding: 8px 16px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            transition: background 0.3s;
        }
        .sort-btn:hover, .sort-btn.active {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        .music-item.dragging {
            opacity: 0.5;
        }
        .music-item.drag-over {
            border-top: 2px solid #667eea;
        }
        .drag-handle {
            cursor: grab;
            margin-right: 10px;
            color: #888;
            font-size: 20px;
        }
        .drag-handle:active {
            cursor: grabbing;
        }
    </style>
</head>
<body class="has-player-bar">
    <% if (userBg != null) { %>
            <div class="custom-background-overlay" style="background-image: url('<%= userBg %>');"></div>
        <div class="custom-bg-overlay" id="bgOverlay" style="background-color: rgba(26, 26, 46, <%= bgOpacity / 100.0 %>);"></div>
    <% } else { %>
        <div class="background-animation"></div>
    <% } %>
    
    <% if (sessionUser != null) { %>
    <div class="bg-upload-container">
        <button class="bg-upload-btn" onclick="toggleBgUpload()">更换背景</button>
        <form class="bg-upload-form" id="bgUploadForm" action="updateProfile" method="post" enctype="multipart/form-data">
            <input type="hidden" name="action" value="background">
            <label for="bgInput">选择图片（PNG/JPG)</label>
            <input type="file" name="background" id="bgInput" accept="image/png,image/jpeg,.png,.jpg,.jpeg" onchange="submitBgForm(this)">
        </form>
    </div>
    <div class="bg-opacity-control" id="bgOpacityControl">
        <span id="opacityValue"><%= bgOpacity %>%</span>
        <input type="range" id="bgOpacitySlider" min="0" max="100" value="<%= bgOpacity %>" oninput="updateBgOpacity(this.value)">
        <button class="bg-confirm-btn" onclick="confirmBgOpacity()">确认</button>
    </div>
    <% } %>

    <header class="header">
        <h1 class="title">ZY音乐</h1>
        <nav class="nav">
            <a href="index.jsp">首页</a>
            <a href="community">社区</a>
            <a href="upload.jsp">上传歌曲</a>
            <a href="profile">个人主页</a>
            <a href="playlist">我的歌单</a>
            <% if (sessionUser != null) { %>
                    <a href="logout">退出登录</a>
            <% } else { %>
                    <a href="login.jsp">登录</a>
            <% } %>
        </nav>
    </header>

    <main class="playlist-view-container" style="max-width: 2400px; margin: 0 auto; padding: 20px;">
        <a href="profile" class="back-link">&larr; 返回我的主页</a>

        <% if (playlist != null) { %>
            <div class="playlist-info">
                <div class="playlist-cover-large">
                    <% if (playlist.getCoverUrl() != null) { %>
                        <img src="<%= playlist.getCoverUrl() %>" alt="cover">
                    <% } else { %>
                        <div class="playlist-cover-placeholder">&#9835;</div>
                    <% } %>
                    <% if (sessionUser != null && sessionUser.getId() == playlist.getUserId()) { %>
                    <form class="cover-update-form" action="playlist" method="post" enctype="multipart/form-data" id="coverForm">
                        <input type="hidden" name="action" value="updateCover">
                        <input type="hidden" name="playlistId" value="<%= playlist.getId() %>">
                        <label for="coverInput">更换封面</label>
                        <input type="file" name="cover" id="coverInput" accept="image/png,image/jpeg,image/gif,image/bmp,image/webp,image/tiff,image/svg+xml,image/x-icon,.png,.jpg,.jpeg,.gif,.bmp,.webp,.tiff,.tif,.svg,.ico" onchange="document.getElementById('coverForm').submit();">
                    </form>
                    <% } %>
                </div>
                <div class="playlist-details">
                    <h2><%= playlist.getName() %></h2>
                    <p>创建者: <%= playlist.getUsername() %></p>
                    <p>歌曲数: <%= musics != null ? musics.size() : 0 %></p>
                </div>
            </div>

            <div class="music-list">
                <% if (sessionUser != null && sessionUser.getId() == playlist.getUserId()) { %>
                <div class="sort-options">
                    <button class="sort-btn active" onclick="setSortMode('manual')">☰ 手动排序</button>
                    <button class="sort-btn" onclick="setSortMode('time')">⏰ 按时间排序</button>
                    <button class="sort-btn" onclick="setSortMode('name')">🔤 按名称排序</button>
                </div>
                <% } %>
                <div id="musicListContainer">
                    <% if (musics != null && !musics.isEmpty()) {
                        int index = 0;
                        for (Music music : musics) {
                            boolean isPlaying = currentMusic != null && currentMusic.getId() == music.getId();
                    %>
                        <div class="music-item <%= isPlaying ? "playing" : "" %>" data-music-id="<%= music.getId() %>" data-position="<%= index %>" draggable="true">
                            <% if (sessionUser != null && sessionUser.getId() == playlist.getUserId()) { %>
                            <span class="drag-handle" title="拖动排序">☰</span>
                            <% } %>
                            <% if (isPlaying) { %>
                            <div class="playing-indicator"></div>
                            <% } %>
                            <a href="playMusic?id=<%= music.getId() %>&playlistId=<%= playlist.getId() %>" class="music-cover">
                                <% if (music.getCoverUrl() != null && !music.getCoverUrl().isEmpty()) { %>
                                    <img src="<%= music.getCoverUrl() %>" alt="cover">
                                <% } else { %>
                                    <div class="music-cover-placeholder">&#9835;</div>
                                <% } %>
                            </a>
                            <div class="music-info">
                                <a href="playMusic?id=<%= music.getId() %>&playlistId=<%= playlist.getId() %>" class="music-name"><%= music.getName() %></a>
                                <div class="music-author"><%= music.getArtist() != null && !music.getArtist().isEmpty() ? music.getArtist() : music.getUsername() %></div>
                            </div>
                            <div class="music-actions">
                            </div>
                        </div>
                    <% 
                            index++;
                        }
                    } else {
                    %>
                    <div class="empty-message">歌单暂无歌曲，快去添加吧！</div>
                    <% } %>
                </div>
        <% } else { %>
            <p>歌单不存在</p>
        <% } %>
    </main>

    <script>
        var currentSortMode = 'manual';
        var playlistId = <%= playlist != null ? playlist.getId() : 0 %>;
        var draggedItem = null;

        function setSortMode(mode) {
            currentSortMode = mode;
            document.querySelectorAll('.sort-btn').forEach(function(btn) {
                btn.classList.remove('active');
            });
            event.target.classList.add('active');

            if (mode !== 'manual') {
                // 通过URL参数排序
                window.location.href = 'playlist?action=view&id=' + playlistId + '&sort=' + mode;
            } else {
                // 手动排序模式下启用拖拽
                initDragAndDrop();
            }
        }

        function initDragAndDrop() {
            var items = document.querySelectorAll('.music-item[draggable="true"]');
            items.forEach(function(item) {
                item.addEventListener('dragstart', handleDragStart);
                item.addEventListener('dragend', handleDragEnd);
                item.addEventListener('dragover', handleDragOver);
                item.addEventListener('drop', handleDrop);
                item.addEventListener('dragleave', handleDragLeave);
            });
        }

        function handleDragStart(e) {
            draggedItem = this;
            this.classList.add('dragging');
            e.dataTransfer.effectAllowed = 'move';
            e.dataTransfer.setData('text/html', this.innerHTML);
        }

        function handleDragEnd(e) {
            this.classList.remove('dragging');
            document.querySelectorAll('.music-item').forEach(function(item) {
                item.classList.remove('drag-over');
            });
        }

        function handleDragOver(e) {
            if (e.preventDefault) {
                e.preventDefault();
            }
            e.dataTransfer.dropEffect = 'move';
            return false;
        }

        function handleDragLeave(e) {
            this.classList.remove('drag-over');
        }

        function handleDrop(e) {
            if (e.stopPropagation) {
                e.stopPropagation();
            }

            if (draggedItem !== this) {
                // 保存新的顺序
                var container = document.getElementById('musicListContainer');
                var items = Array.from(container.querySelectorAll('.music-item'));
                var draggedIndex = items.indexOf(draggedItem);
                var droppedIndex = items.indexOf(this);

                if (draggedIndex < droppedIndex) {
                    container.insertBefore(draggedItem, this.nextSibling);
                } else {
                    container.insertBefore(draggedItem, this);
                }

                // 更新数据库中的顺序
                updatePositions();
            }
            return false;
        }

        function updatePositions() {
            var items = document.querySelectorAll('.music-item');
            var positions = [];
            items.forEach(function(item, index) {
                var musicId = item.getAttribute('data-music-id');
                positions.push({musicId: musicId, position: index});
            });

            // 发送更新请求
            fetch('playlist?action=sort&playlistId=' + playlistId, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: JSON.stringify({positions: positions})
            })
            .then(function(response) {
                if (response.ok) {
                    console.log('顺序已保存');
                }
            })
            .catch(function(err) {
                console.error(err);
            });
        }

        // 初始化拖拽
        if (currentSortMode === 'manual') {
            initDragAndDrop();
        }
        
        function toggleBgUpload() {
            var form = document.getElementById('bgUploadForm');
            form.classList.toggle('active');
            var opacityControl = document.getElementById('bgOpacityControl');
            opacityControl.classList.add('active');
        }
        function updateBgOpacity(value) {
            var bgOverlay = document.getElementById('bgOverlay');
            if (bgOverlay) {
                bgOverlay.style.backgroundColor = 'rgba(26, 26, 46, ' + (value / 100) + ')';
            }
            document.getElementById('opacityValue').textContent = value + '%';
        }
        function confirmBgOpacity() {
            var opacity = document.getElementById('bgOpacitySlider').value;
            var form = document.getElementById('bgUploadForm');
            form.classList.remove('active');
            var opacityControl = document.getElementById('bgOpacityControl');
            opacityControl.classList.remove('active');
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'updateProfile?action=opacity&opacity=' + opacity, true);
            xhr.send();
        }
        function submitBgForm(input) {
            if (input.files && input.files[0]) {
                input.form.submit();
            }
        }
    </script>
  <%@ include file="notify-bar.jsp" %>
</body>
</html>
