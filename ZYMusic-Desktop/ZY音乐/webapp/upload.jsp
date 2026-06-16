<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String userBg = (sessionUser != null && sessionUser.getBackgroundUrl() != null) ? sessionUser.getBackgroundUrl() : null;
    int bgOpacity = (sessionUser != null) ? sessionUser.getBackgroundOpacity() : 80;
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - 上传歌曲</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="pwa-head.jsp" %>
    <link rel="manifest" href="manifest.json">
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/app.css">
    <style>
        .hidden {
            display: none !important;
        }

        .cover-preview {
            margin-top: 10px;
            text-align: center;
        }

        .cover-preview img {
            max-width: 200px;
            max-height: 200px;
            border-radius: 10px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
        }

        .music-preview {
            margin-top: 10px;
            padding: 10px;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            text-align: center;
        }

        .music-preview span {
            color: #fff;
            font-size: 1em;
        }
        
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
        .upload-container, .header, .footer {
            position: relative;
            z-index: 10;
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
            <% 
                if (sessionUser != null) {
            %>
                    <a href="logout">退出登录</a>
            <% } else { %>
                    <a href="login.jsp">登录</a>
            <% } %>
        </nav>
    </header>
    
    <main class="upload-container">
        <h2>上传歌曲</h2>
        <form action="uploadMusic" method="post" enctype="multipart/form-data" class="upload-form">
            <div class="form-group">
                <label>歌曲名称</label>
                <input type="text" name="name" required placeholder="请输入歌曲名称">
            </div>
            <div class="form-group">
                <label>歌手</label>
                <input type="text" name="artist" required placeholder="请输入歌手姓名">
            </div>
            <div class="form-group">
                <label>歌曲文件（必选）</label>
                <input type="file" name="music" accept=".mp3,.flac" required>
                <small>支持格式：MP3、FLAC（FLAC 将自动转为 MP3）</small>
                <div id="musicPreview" class="music-preview hidden">
                    <span id="musicFileName"></span>
                </div>
            </div>
            <div class="form-group">
                <label>歌曲类型</label>
                <select name="type" required style="color: #000;">
                    <option value="" style="color: #000;">请选择类型</option>
                    <option value="流行" style="color: #000;">流行</option>
                    <option value="摇滚" style="color: #000;">摇滚</option>
                    <option value="电子音乐" style="color: #000;">电子音乐</option>
                    <option value="说唱" style="color: #000;">说唱</option>
                    <option value="古典" style="color: #000;">古典</option>
                    <option value="乡村" style="color: #000;">乡村</option>
                    <option value="民谣" style="color: #000;">民谣</option>
                    <option value="金属" style="color: #000;">金属</option>
                    <option value="R&B" style="color: #000;">R&B</option>
                </select>
            </div>
            <div class="form-group">
                <label>歌曲封面（必选，PNG 或 JPG 图片）</label>
                <input type="file" name="cover" accept="image/png,image/jpeg,image/gif,image/bmp,image/webp,image/tiff,image/svg+xml,image/x-icon,.png,.jpg,.jpeg,.gif,.bmp,.webp,.tiff,.tif,.svg,.ico" required>
                <small>支持 PNG、JPG 格式</small>
                <div id="coverPreview" class="cover-preview hidden"></div>
            </div>
            <button type="submit" class="upload-btn">上传歌曲</button>
            <% 
                String success = (String) request.getAttribute("success");
                String error = (String) request.getAttribute("error");
                if (success != null) {
            %>
                    <p class="success-message"><%= success %></p>
            <% } else if (error != null) { %>
                    <p class="error-message"><%= error %></p>
            <% } %>
        </form>
    </main>
    
    <footer class="footer">
        <p>© 2026 ZY音乐 畅享世界</p>
    </footer>
    
    <script src="js/animation.js"></script>
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
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var coverInput = document.querySelector('input[name="cover"]');
            var preview = document.getElementById('coverPreview');

            if (coverInput && preview) {
                coverInput.addEventListener('change', function() {
                    var file = coverInput.files && coverInput.files[0];
                    if (!file) {
                        preview.classList.add('hidden');
                        preview.innerHTML = '';
                        return;
                    }

                    var reader = new FileReader();
                    reader.onload = function(event) {
                        preview.innerHTML = '<img src="' + event.target.result + '" alt="封面预览">';
                        preview.classList.remove('hidden');
                    };
                    reader.readAsDataURL(file);
                });
            }

            var musicInput = document.querySelector('input[name="music"]');
            var musicPreview = document.getElementById('musicPreview');
            var musicFileName = document.getElementById('musicFileName');

            if (musicInput && musicPreview && musicFileName) {
                musicInput.addEventListener('change', function() {
                    var file = musicInput.files && musicInput.files[0];
                    if (!file) {
                        musicPreview.classList.add('hidden');
                        musicFileName.textContent = '';
                        return;
                    }

                    musicFileName.textContent = '已选择: ' + file.name;
                    musicPreview.classList.remove('hidden');
                });
            }
        });
        
        function toggleBgUpload() {
            var form = document.getElementById('bgUploadForm');
            form.classList.toggle('active');
            var opacityControl = document.getElementById('bgOpacityControl');
            opacityControl.classList.add('active');
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
