<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%@ page import="com.zjlymusic.entity.Music" %>
<%@ page import="com.zjlymusic.entity.Post" %>
<%@ page import="com.zjlymusic.entity.Comment" %>
<%@ page import="com.zjlymusic.entity.Playlist" %>
<%@ page import="com.zjlymusic.service.PlaylistService" %>
<%@ page import="com.zjlymusic.servlet.ProfileServlet.ActivityItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    User profileUser = (User) request.getAttribute("profileUser");
    Boolean isOwnProfile = (Boolean) request.getAttribute("isOwnProfile");
    if (profileUser == null) profileUser = sessionUser;
    if (isOwnProfile == null) isOwnProfile = true;
    String profileSuccess = (String) session.getAttribute("profileSuccess");
    String profileError = (String) session.getAttribute("profileError");
    session.removeAttribute("profileSuccess");
    session.removeAttribute("profileError");
    String userBg = (profileUser != null && profileUser.getBackgroundUrl() != null) ? profileUser.getBackgroundUrl() : null;
    int bgOpacity = (profileUser != null) ? profileUser.getBackgroundOpacity() : 30;
    List<Playlist> userPlaylists = null;
    if (isOwnProfile && sessionUser != null) {
        userPlaylists = new PlaylistService().getPlaylistsByUserId(sessionUser.getId());
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - 个人主页</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="pwa-head.jsp" %>
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
        .bg-opacity-control {
            position: fixed;
            top: 70px;
            right: 20px;
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
        .bg-upload-container {
            position: fixed;
            top: 70px;
            right: 20px;
            z-index: 1001;
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
        .profile-container, .header, .footer {
            position: relative;
            z-index: 10;
        }
        .playlists-section {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .playlists-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        .playlists-header h3 {
            color: #fff;
            margin: 0;
        }
        .playlists-header .create-playlist-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
        }
        .playlists-list {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
        }
        .playlist-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }
        .playlist-cover-link {
            display: block;
        }
        .playlist-cover-img {
            width: 80px;
            height: 80px;
            border-radius: 10px;
            object-fit: cover;
        }
        .playlist-cover-placeholder {
            width: 80px;
            height: 80px;
            border-radius: 10px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 30px;
            color: white;
        }
        .playlist-name-link {
            color: #fff;
            text-decoration: none;
            font-size: 14px;
            text-align: center;
        }
        .playlist-name-link:hover {
            color: #667eea;
        }
        .delete-playlist-btn {
            position: absolute;
            top: 5px;
            right: 5px;
            width: 22px;
            height: 22px;
            background: rgba(255,80,80,0.8);
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 12px;
            opacity: 0;
            transition: opacity 0.3s;
        }
        .playlist-item:hover .delete-playlist-btn {
            opacity: 1;
        }
        .playlist-item {
            position: relative;
        }
        .bio-text {
            color: #ccc;
            font-size: 14px;
            cursor: pointer;
            margin: 10px 0;
            text-align: center;
        }
        .bio-text:hover {
            color: #667eea;
        }
        .follow-stats {
            display: flex;
            gap: 20px;
            justify-content: center;
            margin: 10px 0;
        }
        .stat-link {
            color: #ccc;
            text-decoration: none;
            font-size: 14px;
        }
        .stat-link:hover {
            color: #667eea;
        }
        .follow-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 10px 30px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 14px;
            margin-top: 10px;
        }
        .follow-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
        }
        .follow-btn.following {
            background: #555;
        }
        .user-list-modal {
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
        .user-list-modal.active {
            display: flex;
        }
        .user-list-content {
            background: #1a1a2e;
            padding: 25px;
            border-radius: 15px;
            width: 500px;
            max-width: 90%;
            max-height: 80vh;
            overflow-y: auto;
        }
        .user-list-content h3 {
            color: #fff;
            margin-bottom: 15px;
        }
        .user-list-item {
            display: flex;
            align-items: center;
            padding: 10px;
            border-radius: 8px;
            margin-bottom: 10px;
            background: rgba(255, 255, 255, 0.05);
        }
        .user-list-item:hover {
            background: rgba(255, 255, 255, 0.1);
        }
        .user-list-avatar {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            margin-right: 15px;
            object-fit: cover;
        }
        .user-list-info {
            flex: 1;
        }
        .user-list-name {
            color: #fff;
            font-size: 16px;
            text-decoration: none;
        }
        .user-list-name:hover {
            color: #667eea;
        }
        .user-list-bio {
            color: #888;
            font-size: 12px;
            margin-top: 5px;
        }
        .modal-cancel {
            color: #888;
            cursor: pointer;
            margin-top: 15px;
            text-align: center;
            display: block;
        }
        .delete-song-btn, .delete-activity-btn {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            width: 24px;
            height: 24px;
            background: rgba(255,80,80,0.8);
            color: #fff;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-size: 14px;
            opacity: 0;
            transition: opacity 0.3s;
            z-index: 15;
        }
        .music-activity:hover .delete-song-btn,
        .post-activity:hover .delete-activity-btn,
        .comment-activity:hover .delete-activity-btn {
            opacity: 1;
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
    
    <% if (isOwnProfile && sessionUser != null) { %>
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
            <% if (sessionUser != null) { %>
                <a href="logout">退出登录</a>
            <% } else { %>
                <a href="login.jsp">登录</a>
            <% } %>
        </nav>
    </header>
    
    <main class="profile-container">
        <div class="profile-header">
            <div class="avatar <%= isOwnProfile ? "clickable-avatar" : "" %>" <%= isOwnProfile ? "id=\"avatarBtn\" title=\"点击更改头像\"" : "" %>>
                <% if (profileUser != null && profileUser.getAvatarUrl() != null) {
                    String avatarUrl = profileUser.getAvatarUrl();
                    String cacheBuster = "_t=" + System.currentTimeMillis();
                    avatarUrl = avatarUrl + (avatarUrl.contains("?") ? "&" : "?") + cacheBuster;
                %>
                    <img src="<%= avatarUrl %>" alt="头像">
                <% } else { %>
                    <img src="files/avatars/default.png" alt="默认头像">
                <% } %>
            </div>
            <h2 class="<%= isOwnProfile ? "clickable-nickname" : "" %>" <%= isOwnProfile ? "id=\"nicknameBtn\" title=\"点击更改昵称\"" : "" %>>
                <%= profileUser != null ? profileUser.getUsername() : "请登录" %>
            </h2>
            <% if (isOwnProfile && sessionUser != null) { %>
                <p class="bio-text" id="bioText" onclick="showBioModal()">
                    <%= profileUser.getBio() != null && !profileUser.getBio().isEmpty() ? profileUser.getBio() : "点击添加个性签名" %>
                </p>
            <% } else { %>
                <p class="bio-text">
                    <%= profileUser.getBio() != null && !profileUser.getBio().isEmpty() ? profileUser.getBio() : "暂无个性签名" %>
                </p>
            <% } %>
            <div class="follow-stats">
                <a href="javascript:void(0)" onclick="showFollowingList()" class="stat-link">关注: <span id="followingCount"><%= request.getAttribute("followingCount") != null ? request.getAttribute("followingCount") : 0 %></span></a>
                <a href="javascript:void(0)" onclick="showFollowersList()" class="stat-link">粉丝: <span id="followersCount"><%= request.getAttribute("followersCount") != null ? request.getAttribute("followersCount") : 0 %></span></a>
            </div>
            <% if (!isOwnProfile && sessionUser != null) { %>
                <button id="followBtn" class="follow-btn" onclick="toggleFollow()">
                    <%= request.getAttribute("isFollowing") != null && (Boolean)request.getAttribute("isFollowing") ? "已关注" : "关注" %>
                </button>
                <button class="follow-btn" style="background:linear-gradient(135deg,#11998e 0%,#38ef7d 100%);margin-left:10px;" onclick="location.href='messages?userId=<%= profileUser.getId() %>'">私信</button>
            <% } %>
        </div>

        <% if (profileSuccess != null) { %>
            <p class="success-message profile-message"><%= profileSuccess %></p>
        <% } else if (profileError != null) { %>
            <p class="error-message profile-message"><%= profileError %></p>
        <% } %>

        <% if (isOwnProfile && sessionUser != null) { %>
        <div class="playlists-section">
            <div class="playlists-header">
                <h3>我的歌单</h3>
                <button class="create-playlist-btn" onclick="openCreatePlaylistModal()">+ 创建歌单</button>
            </div>
            <div class="playlists-list">
                <% if (userPlaylists != null && !userPlaylists.isEmpty()) { %>
                    <% for (Playlist playlist : userPlaylists) { %>
                        <div class="playlist-item" id="playlist<%= playlist.getId() %>">
                            <a href="playlist?action=view&id=<%= playlist.getId() %>" class="playlist-cover-link">
                                <% if (playlist.getCoverUrl() != null) { %>
                                    <img src="<%= playlist.getCoverUrl() %>" alt="cover" class="playlist-cover-img">
                                <% } else { %>
                                    <div class="playlist-cover-placeholder">&#9835;</div>
                                <% } %>
                            </a>
                            <a href="playlist?action=view&id=<%= playlist.getId() %>" class="playlist-name-link"><%= playlist.getName() %></a>
                            <span class="delete-playlist-btn" onclick="event.preventDefault(); deletePlaylist(<%= playlist.getId() %>)" title="删除歌单">✕</span>
                        </div>
                    <% } %>
                <% } else { %>
                    <p class="empty-tip">暂无歌单，快去创建吧！</p>
                <% } %>
            </div>
        </div>
        <% } %>
        
        <div class="activities-section">
            <h3><%= isOwnProfile ? "我的动态" : profileUser.getUsername() + "的动态" %></h3>
            <div class="activities-list">
                <% 
                    List<Object> activities = (List<Object>) request.getAttribute("activities");
                    if (activities != null && !activities.isEmpty()) {
                        for (Object obj : activities) {
                            ActivityItem item = (ActivityItem) obj;
                            if ("music".equals(item.type)) {
                                Music music = (Music) item.item;
                %>
                    <div class="activity-item music-activity" style="position:relative;">
                        <span class="activity-icon" style="cursor:pointer;" onclick="location.href='playMusic?id=<%= music.getId() %>'">&#9835;</span>
                        <div class="activity-content" style="cursor:pointer;" onclick="location.href='playMusic?id=<%= music.getId() %>'">
                            <span class="activity-title">上传了歌曲：</span>
                            <span class="activity-name"><%= music.getName() %></span>
                        </div>
                        <span class="activity-time" style="cursor:pointer;" onclick="location.href='playMusic?id=<%= music.getId() %>'"><%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.date) %></span>
                        <% if (isOwnProfile) { %>
                        <button class="delete-song-btn" onclick="deleteSong(<%= music.getId() %>)" title="删除歌曲" style="border:none;background:rgba(255,80,80,0.8);color:#fff;border-radius:50%;width:24px;height:24px;cursor:pointer;font-size:14px;opacity:0;transition:opacity 0.3s;z-index:15;position:absolute;right:10px;top:50%;transform:translateY(-50%);">×</button>
                        <% } %>
                    </div>
                <%
                            } else if ("post".equals(item.type)) {
                                Post post = (Post) item.item;
                %>
                    <div class="activity-item post-activity" style="position:relative;">
                        <span class="activity-icon" style="cursor:pointer;" onclick="location.href='community?postId=<%= post.getId() %>'">&#9998;</span>
                        <div class="activity-content" style="cursor:pointer;" onclick="location.href='community?postId=<%= post.getId() %>'">
                            <span class="activity-title">发表了帖子：</span>
                            <p><%= post.getContent() %></p>
                        </div>
                        <span class="activity-time" style="cursor:pointer;" onclick="location.href='community?postId=<%= post.getId() %>'"><%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.date) %></span>
                        <% if (isOwnProfile) { %>
                        <button class="delete-activity-btn" onclick="deletePost(<%= post.getId() %>)" title="删除帖子" style="border:none;background:rgba(255,80,80,0.8);color:#fff;border-radius:50%;width:24px;height:24px;cursor:pointer;font-size:14px;opacity:0;transition:opacity 0.3s;z-index:15;position:absolute;right:10px;top:50%;transform:translateY(-50%);">×</button>
                        <% } %>
                    </div>
                <%
                            } else if ("comment".equals(item.type)) {
                                Comment comment = (Comment) item.item;
                                String targetUrl = comment.getMusicId() > 0 ? "playMusic?id=" + comment.getMusicId() : "community?postId=" + comment.getPostId();
                %>
                    <div class="activity-item comment-activity" style="position:relative;">
                        <span class="activity-icon" style="cursor:pointer;" onclick="location.href='<%= targetUrl %>'">&#9993;</span>
                        <div class="activity-content" style="cursor:pointer;" onclick="location.href='<%= targetUrl %>'">
                            <span class="activity-title">发表了评论：</span>
                            <p><%= comment.getContent() %></p>
                        </div>
                        <span class="activity-time" style="cursor:pointer;" onclick="location.href='<%= targetUrl %>'"><%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(item.date) %></span>
                        <% if (isOwnProfile) { %>
                        <button class="delete-activity-btn" onclick="deleteComment(<%= comment.getId() %>)" title="删除评论" style="border:none;background:rgba(255,80,80,0.8);color:#fff;border-radius:50%;width:24px;height:24px;cursor:pointer;font-size:14px;opacity:0;transition:opacity 0.3s;z-index:15;position:absolute;right:10px;top:50%;transform:translateY(-50%);">×</button>
                        <% } %>
                    </div>
                <%
                            }
                        }
                    } else {
                %>
                    <p>暂无动态，快去上传音乐或发表帖子吧！</p>
                <% } %>
            </div>
        </div>
    </main>

    <div id="createPlaylistModal" class="modal hidden">
        <div class="modal-content" style="width:420px;">
            <h3>创建歌单</h3>
            <div style="margin-bottom:15px;">
                <input type="text" id="newPlaylistName" placeholder="歌单名称（必填）" style="width:100%;padding:12px;border:none;border-radius:10px;background:rgba(255,255,255,0.1);color:#fff;font-size:14px;">
            </div>
            <label for="playlistCoverInput" style="display:inline-block;padding:10px 20px;background:rgba(255,255,255,0.1);color:#fff;border-radius:10px;cursor:pointer;margin-bottom:15px;">+ 添加封面图片（可选）</label>
            <input type="file" id="playlistCoverInput" accept="image/png,image/jpeg,.png,.jpg,.jpeg" style="display:none;">
            <div id="playlistCoverName" style="color:#888;font-size:12px;margin-bottom:15px;"></div>
            <div class="modal-actions" style="display:flex;gap:10px;justify-content:flex-end;">
                <button onclick="closeCreatePlaylistModal()" style="padding:10px 20px;border:none;border-radius:10px;background:rgba(255,255,255,0.1);color:#fff;cursor:pointer;">取消</button>
                <button id="confirmCreatePlaylist" onclick="createPlaylist()" style="padding:10px 20px;border:none;border-radius:10px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:#fff;cursor:pointer;">确定</button>
            </div>
        </div>
    </div>

    <div id="avatarModal" class="modal hidden">
        <div class="modal-content">
            <h3>更改头像</h3>
            <p>选择 PNG 图片后可拖动位置、缩放，并裁剪成圆形头像</p>
            <form id="avatarForm" action="updateProfile" method="post" enctype="multipart/form-data">
                <input type="hidden" name="action" value="avatar">
                <input type="hidden" name="avatarData" id="avatarData">
                <button type="button" class="option-btn" id="chooseAvatarBtn">更改头像</button>
                <input type="file" name="avatar" id="avatarInput" accept="image/png,image/jpeg,image/gif,image/bmp,image/webp,image/tiff,image/svg+xml,image/x-icon,.png,.jpg,.jpeg,.gif,.bmp,.webp,.tiff,.tif,.svg,.ico" required class="visually-hidden">
                <div id="avatarCropArea" class="avatar-crop-area hidden">
                    <canvas id="avatarCanvas" width="260" height="260" aria-label="头像裁剪预览"></canvas>
                    <label class="range-label" for="avatarZoom">缩放</label>
                    <input type="range" id="avatarZoom" min="1" max="3" step="0.01" value="1">
                </div>
                <div class="modal-actions">
                    <button type="button" class="modal-btn cancel-btn" data-close="avatarModal">取消</button>
                    <button type="submit" class="modal-btn confirm-btn">确认更改</button>
                </div>
            </form>
        </div>
    </div>

    <div id="nicknameModal" class="modal hidden">
        <div class="modal-content">
            <h3>更改昵称</h3>
            <form action="updateProfile" method="post">
                <input type="hidden" name="action" value="nickname">
                <input type="text" name="nickname" maxlength="30" required placeholder="请输入新昵称" value="<%= sessionUser != null ? sessionUser.getUsername() : "" %>">
                <div class="modal-actions">
                    <button type="button" class="modal-btn cancel-btn" data-close="nicknameModal">取消</button>
                    <button type="submit" class="modal-btn confirm-btn">确认更改</button>
                </div>
            </form>
        </div>
    </div>

    <div id="bioModal" class="modal hidden">
        <div class="modal-content">
            <h3><%= profileUser != null && profileUser.getBio() != null && !profileUser.getBio().isEmpty() ? "修改个性签名" : "添加个性签名" %></h3>
            <form action="updateProfile" method="post">
                <input type="hidden" name="action" value="bio">
                <input type="text" name="bio" maxlength="100" placeholder="请输入个性签名" value="<%= profileUser != null && profileUser.getBio() != null ? profileUser.getBio() : "" %>">
                <div class="modal-actions">
                    <button type="button" class="modal-btn cancel-btn" data-close="bioModal">取消</button>
                    <button type="submit" class="modal-btn confirm-btn">确认</button>
                </div>
            </form>
        </div>
    </div>

    <div id="followingModal" class="user-list-modal">
        <div class="user-list-content">
            <h3>关注列表</h3>
            <div id="followingListContent">
                <% 
                    java.util.List<User> followingList = (java.util.List<User>) request.getAttribute("followingList");
                    if (followingList != null && !followingList.isEmpty()) {
                        for (User user : followingList) {
                %>
                    <div class="user-list-item">
                        <a href="profile?userId=<%= user.getId() %>">
                            <% if (user.getAvatarUrl() != null) { %>
                                <img src="<%= user.getAvatarUrl() %>" alt="avatar" class="user-list-avatar">
                            <% } else { %>
                                <img src="files/avatars/default.png" alt="avatar" class="user-list-avatar">
                            <% } %>
                        </a>
                        <div class="user-list-info">
                            <a href="profile?userId=<%= user.getId() %>" class="user-list-name"><%= user.getUsername() %></a>
                            <p class="user-list-bio"><%= user.getBio() != null && !user.getBio().isEmpty() ? user.getBio() : "暂无个性签名" %></p>
                        </div>
                    </div>
                <% 
                        }
                    } else {
                %>
                    <p style="color: #888; text-align: center;">暂无关注</p>
                <% } %>
            </div>
            <span class="modal-cancel" onclick="closeFollowingModal()">关闭</span>
        </div>
    </div>

    <div id="followersModal" class="user-list-modal">
        <div class="user-list-content">
            <h3>粉丝列表</h3>
            <div id="followersListContent">
                <% 
                    java.util.List<User> followersList = (java.util.List<User>) request.getAttribute("followersList");
                    if (followersList != null && !followersList.isEmpty()) {
                        for (User user : followersList) {
                %>
                    <div class="user-list-item">
                        <a href="profile?userId=<%= user.getId() %>">
                            <% if (user.getAvatarUrl() != null) { %>
                                <img src="<%= user.getAvatarUrl() %>" alt="avatar" class="user-list-avatar">
                            <% } else { %>
                                <img src="files/avatars/default.png" alt="avatar" class="user-list-avatar">
                            <% } %>
                        </a>
                        <div class="user-list-info">
                            <a href="profile?userId=<%= user.getId() %>" class="user-list-name"><%= user.getUsername() %></a>
                            <p class="user-list-bio"><%= user.getBio() != null && !user.getBio().isEmpty() ? user.getBio() : "暂无个性签名" %></p>
                        </div>
                    </div>
                <% 
                        }
                    } else {
                %>
                    <p style="color: #888; text-align: center;">暂无粉丝</p>
                <% } %>
            </div>
            <span class="modal-cancel" onclick="closeFollowersModal()">关闭</span>
        </div>
    </div>
    
    <footer class="footer">
        <p>© 2026 ZY音乐 畅享世界</p>
    </footer>
    
    <script src="js/animation.js"></script>
    <script src="js/profile.js"></script>
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
            // Submit opacity to server
            var xhr = new XMLHttpRequest();
            xhr.open('POST', 'updateProfile?action=opacity&opacity=' + opacity, true);
            xhr.send();
        }
        function submitBgForm(input) {
            if (input.files && input.files[0]) {
                input.form.submit();
            }
        }
        function deleteSong(musicId) {
            if (!confirm('确定要删除这首歌吗？此操作不可恢复。')) return false;
            location.href = 'deleteMusic?id=' + musicId;
            return false;
        }
        function deletePost(postId) {
            if (!confirm('确定要删除这条帖子吗？')) return false;
            location.href = 'post?action=delete&postId=' + postId;
            return false;
        }
        function deleteComment(commentId) {
            if (!confirm('确定要删除这条评论吗？')) return false;
            location.href = 'comment?action=delete&commentId=' + commentId;
            return false;
        }
        function showBioModal() {
            document.getElementById('bioModal').classList.remove('hidden');
        }
        function deletePlaylist(id) {
            if (!confirm('确定要删除这个歌单吗？')) return;
            fetch('playlist?action=delete&id=' + id, {
                method: 'POST',
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
            .then(function(r) {
                if (r.ok) {
                    var el = document.getElementById('playlist' + id);
                    if (el) el.remove();
                }
            })
            .catch(function(err) { console.error(err); });
        }

        function openCreatePlaylistModal() {
            document.getElementById('createPlaylistModal').classList.remove('hidden');
        }
        function closeCreatePlaylistModal() {
            document.getElementById('createPlaylistModal').classList.add('hidden');
        }
        document.getElementById('playlistCoverInput').addEventListener('change', function(e) {
            var name = e.target.files[0] ? e.target.files[0].name : '';
            document.getElementById('playlistCoverName').textContent = name;
        });
        function createPlaylist() {
            var name = document.getElementById('newPlaylistName').value.trim();
            if (!name) { alert('请输入歌单名称'); return; }
            var formData = new FormData();
            formData.append('action', 'create');
            formData.append('name', name);
            var coverFile = document.getElementById('playlistCoverInput').files[0];
            if (coverFile) formData.append('cover', coverFile);
            fetch('playlist', {
                method: 'POST',
                headers: { 'X-Requested-With': 'XMLHttpRequest' },
                body: formData
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    alert('歌单创建成功');
                    closeCreatePlaylistModal();
                    document.getElementById('newPlaylistName').value = '';
                    document.getElementById('playlistCoverName').textContent = '';
                    document.getElementById('playlistCoverInput').value = '';
                    // Add to playlist list in UI
                    var list = document.querySelector('.playlists-list');
                    var empty = list.querySelector('.empty-tip');
                    if (empty) empty.remove();
                    var coverHtml = data.coverUrl ? '<img src="' + data.coverUrl + '" alt="cover" class="playlist-cover-img">' : '<div class="playlist-cover-placeholder">&#9835;</div>';
                    var html = '<div class="playlist-item">' +
                        '<a href="playlist?action=view&id=' + data.id + '" class="playlist-cover-link">' + coverHtml + '</a>' +
                        '<a href="playlist?action=view&id=' + data.id + '" class="playlist-name-link">' + data.name + '</a>' +
                        '</div>';
                    list.insertAdjacentHTML('beforeend', html);
                } else {
                    alert(data.error || '创建失败');
                }
            })
            .catch(function(err) { console.error(err); });
        }

        function showFollowingList() {
            document.getElementById('followingModal').classList.add('active');
        }
        function closeFollowingModal() {
            document.getElementById('followingModal').classList.remove('active');
        }
        function showFollowersList() {
            document.getElementById('followersModal').classList.add('active');
        }
        function closeFollowersModal() {
            document.getElementById('followersModal').classList.remove('active');
        }
        function toggleFollow() {
            var profileUserId = <%= profileUser != null ? profileUser.getId() : 0 %>;
            var sessionUserId = <%= sessionUser != null ? sessionUser.getId() : 0 %>;
            var followBtn = document.getElementById('followBtn');
            var isCurrentlyFollowing = followBtn.textContent.trim() === '已关注';
            
            var action = isCurrentlyFollowing ? 'unfollow' : 'follow';
            
            fetch('profile?action=' + action + '&userId=' + profileUserId, {
                method: 'POST',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            })
            .then(function(response) {
                if (response.ok) {
                    if (isCurrentlyFollowing) {
                        followBtn.textContent = '关注';
                        followBtn.classList.remove('following');
                        var fc = parseInt(document.getElementById('followersCount').textContent);
                        document.getElementById('followersCount').textContent = Math.max(0, fc - 1);
                    } else {
                        followBtn.textContent = '已关注';
                        followBtn.classList.add('following');
                        var fc = parseInt(document.getElementById('followersCount').textContent);
                        document.getElementById('followersCount').textContent = fc + 1;
                        alert('关注成功');
                    }
                }
            })
            .catch(function(err) {
                console.error(err);
            });
        }
        window.onclick = function(e) {
            if (e.target.id === 'followingModal') {
                closeFollowingModal();
            }
            if (e.target.id === 'followersModal') {
                closeFollowersModal();
            }
        }
    </script>
  <%@ include file="notify-bar.jsp" %>
</body>
</html>
