<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%@ page import="com.zjlymusic.entity.Playlist" %>
<%@ page import="java.util.List" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String userBg = (sessionUser != null && sessionUser.getBackgroundUrl() != null) ? sessionUser.getBackgroundUrl() : null;
    int bgOpacity = (sessionUser != null) ? sessionUser.getBackgroundOpacity() : 80;
    List<Playlist> playlists = (List<Playlist>) request.getAttribute("playlists");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - 我的歌单</title>
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
        .custom-bg-video {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
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
        .playlists-container, .header, .footer {
            position: relative;
            z-index: 10;
        }
        .playlists-container {
            max-width: 2400px;
            margin: 0 auto;
            padding: 20px;
        }
        .playlist-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            padding-top: 20px;
        }
        .playlist-header h2 {
            color: #fff;
            text-align: left;
            margin: 0;
        }
        .create-playlist-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 14px;
        }
        .playlist-card {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 15px;
            padding: 20px;
            text-align: center;
            transition: transform 0.3s;
        }
        .playlist-card:hover {
            transform: translateY(-5px);
        }
        .playlist-cover {
            width: 150px;
            height: 150px;
            border-radius: 10px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0 auto 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            cursor: pointer;
        }
        .playlist-cover img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }
        .playlist-cover-placeholder {
            font-size: 48px;
            color: white;
        }
        .playlist-name {
            color: #fff;
            font-size: 16px;
            margin-bottom: 5px;
        }
        .playlist-actions {
            margin-top: 10px;
        }
        .playlist-actions a {
            color: #667eea;
            margin: 0 5px;
            cursor: pointer;
        }
        .modal {
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
        .modal.active {
            display: flex;
        }
        .modal-content {
            background: #1a1a2e;
            padding: 30px;
            border-radius: 15px;
            width: 400px;
            max-width: 90%;
        }
        .modal-content h3 {
            color: #fff;
            margin-bottom: 20px;
        }
        .modal-content input[type="text"] {
            width: 100%;
            padding: 12px;
            border: none;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            margin-bottom: 15px;
        }
        .modal-content input[type="file"] {
            display: none;
        }
        .cover-upload-label {
            display: inline-block;
            padding: 10px 20px;
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
            border-radius: 10px;
            cursor: pointer;
            margin-bottom: 15px;
        }
        .modal-buttons {
            display: flex;
            gap: 10px;
            justify-content: flex-end;
        }
        .modal-buttons button {
            padding: 10px 20px;
            border: none;
            border-radius: 10px;
            cursor: pointer;
        }
        .btn-cancel {
            background: rgba(255, 255, 255, 0.1);
            color: #fff;
        }
        .btn-submit {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
    </style>
</head>
<body class="has-player-bar">
    <% if (userBg != null) { %>
        <% if (userBg.toLowerCase().endsWith(".mp4")) { %>
            <video class="custom-bg-video" id="bgVideo" autoplay loop muted>
                <source src="<%= userBg %>" type="video/mp4">
            </video>
        <% } else { %>
            <div class="custom-background-overlay" style="background-image: url('<%= userBg %>');"></div>
        <% } %>
        <div class="custom-bg-overlay" id="bgOverlay" style="background-color: rgba(26, 26, 46, <%= bgOpacity / 100.0 %>);"></div>
    <% } else { %>
        <div class="background-animation"></div>
    <% } %>

    <% if (sessionUser != null) { %>
    <div class="bg-upload-container" style="position:fixed;top:70px;right:20px;z-index:1001;">
        <button class="bg-upload-btn" onclick="toggleBgUpload()" style="background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;border:none;padding:10px 20px;border-radius:25px;cursor:pointer;font-size:14px;box-shadow:0 4px 15px rgba(102,126,234,0.4);">更换背景</button>
        <form class="bg-upload-form" id="bgUploadForm" action="updateProfile" method="post" enctype="multipart/form-data" style="display:none;margin-top:10px;">
            <input type="hidden" name="action" value="background">
            <label for="bgInput" style="display:inline-block;background:rgba(255,255,255,0.2);color:white;padding:8px 16px;border-radius:20px;cursor:pointer;font-size:12px;">选择图片（PNG/JPG)</label>
            <input type="file" name="background" id="bgInput" accept="image/png,image/jpeg,.png,.jpg,.jpeg" onchange="submitBgForm(this)" style="display:none;">
        </form>
    </div>
    <div class="bg-opacity-control" id="bgOpacityControl" style="position:fixed;top:70px;right:220px;z-index:1002;display:none;background:rgba(26,26,46,0.9);padding:10px 15px;border-radius:10px;color:white;font-size:12px;">
        <span id="opacityValue"><%= bgOpacity %>%</span>
        <input type="range" id="bgOpacitySlider" min="0" max="100" value="<%= bgOpacity %>" oninput="updateBgOpacity(this.value)" style="width:100px;margin-left:10px;">
        <button class="bg-confirm-btn" onclick="confirmBgOpacity()" style="background:linear-gradient(135deg,#11998e 0%,#38ef7d 100%);color:white;border:none;padding:5px 12px;border-radius:15px;cursor:pointer;font-size:12px;margin-left:10px;">确认</button>
    </div>
    <style>
        .bg-upload-form.active { display: block !important; }
        .bg-opacity-control.active { display: block !important; }
    </style>
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

    <main class="playlists-container">
        <div class="playlist-header">
            <h2>我的歌单</h2>
            <button class="create-playlist-btn" onclick="openCreateModal()">+ 创建歌单</button>
        </div>

        <% if (playlists != null && !playlists.isEmpty()) { %>
            <div class="playlist-grid">
                <% for (Playlist playlist : playlists) { %>
                    <div class="playlist-card">
                        <a href="playlist?action=view&id=<%= playlist.getId() %>" style="text-decoration: none;">
                            <div class="playlist-cover">
                                <% if (playlist.getCoverUrl() != null) { %>
                                    <img src="<%= playlist.getCoverUrl() %>" alt="cover">
                                <% } else { %>
                                    <span class="playlist-cover-placeholder">&#9835;</span>
                                <% } %>
                            </div>
                        </a>
                        <div class="playlist-name"><%= playlist.getName() %></div>
                        <div class="playlist-actions">
                            <a href="playlist?action=view&id=<%= playlist.getId() %>">播放</a>
                            <a href="playlist?action=delete&id=<%= playlist.getId() %>" onclick="return confirm('确定删除？')">删除</a>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } else { %>
            <p style="color: #fff; text-align: center;">暂无歌单，快来创建第一个吧！</p>
        <% } %>
    </main>

    <!-- Create Playlist Modal -->
    <div class="modal" id="createModal">
        <div class="modal-content">
            <h3>创建歌单</h3>
            <form action="playlist" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="create">
                <input type="text" name="name" placeholder="歌单名称（必填）" required>
                <label for="coverInput" class="cover-upload-label">+ 添加封面图片（可选）</label>
                <input type="file" name="cover" id="coverInput" accept="image/png,image/jpeg,image/gif,image/bmp,image/webp,image/tiff,image/svg+xml,image/x-icon,.png,.jpg,.jpeg,.gif,.bmp,.webp,.tiff,.tif,.svg,.ico">
                <div id="fileNameDisplay" style="color: #888; font-size: 12px; margin-bottom: 15px;"></div>
                <div class="modal-buttons">
                    <button type="button" class="btn-cancel" onclick="closeCreateModal()">取消</button>
                    <button type="submit" class="btn-submit">创建</button>
                </div>
            </form>
        </div>
    </div>

    <script>
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
            fetch('updateProfile?action=opacity&opacity=' + opacity, { method: 'POST' })
                .then(function() { location.reload(); });
        }
        function submitBgForm(input) {
            if (input.files && input.files[0]) {
                input.form.submit();
            }
        }
        function openCreateModal() {
            document.getElementById('createModal').classList.add('active');
        }
        function closeCreateModal() {
            document.getElementById('createModal').classList.remove('active');
        }
        document.getElementById('coverInput').addEventListener('change', function(e) {
            var fileName = e.target.files[0] ? e.target.files[0].name : '';
            document.getElementById('fileNameDisplay').textContent = fileName;
        });
        window.onclick = function(e) {
            if (e.target.id === 'createModal') {
                closeCreateModal();
            }
        }
    </script>
  <%@ include file="notify-bar.jsp" %>
</body>
</html>
