<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%@ page import="com.zjlymusic.entity.Music" %>
<%@ page import="com.zjlymusic.entity.Post" %>
<%@ page import="com.zjlymusic.entity.Comment" %>
<%@ page import="com.zjlymusic.entity.Playlist" %>
<%@ page import="com.zjlymusic.service.PlaylistService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    String userBg = (sessionUser != null && sessionUser.getBackgroundUrl() != null) ? sessionUser.getBackgroundUrl() : null;
    int bgOpacity = (sessionUser != null) ? sessionUser.getBackgroundOpacity() : 80;
    List<Playlist> userPlaylists = null;
    if (sessionUser != null) {
        userPlaylists = new PlaylistService().getPlaylistsByUserId(sessionUser.getId());
    }
    Map<Integer, List<Comment>> postCommentsMap = (Map<Integer, List<Comment>>) request.getAttribute("postCommentsMap");
    if (postCommentsMap == null) postCommentsMap = new java.util.HashMap<>();
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - 社区</title>
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
        .community-container, .header, .footer {
            position: relative;
            z-index: 10;
        }
        .community-container {
            max-width: 2400px;
        }
        .search-bar input {
            width: 400px;
        }
        .post-form textarea {
            width: 500px;
        }
        .post-comments-section {
            margin-top: 10px;
            padding-left: 20px;
            border-left: 2px solid rgba(255,255,255,0.1);
        }
        .post-comment-item {
            padding: 8px 0;
            position: relative;
        }
        .post-comment-item .comment-author {
            color: #667eea;
            font-size: 13px;
            text-decoration: none;
        }
        .post-comment-item .comment-content {
            color: #ccc;
            font-size: 13px;
            margin: 3px 0;
        }
        .post-comment-item .comment-time {
            color: #666;
            font-size: 11px;
        }
        .post-comment-item .reply-btn {
            color: #888;
            font-size: 11px;
            cursor: pointer;
            margin-left: 8px;
        }
        .post-comment-item .reply-btn:hover {
            color: #667eea;
        }
        .expand-comments-btn {
            color: #888;
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            margin-left: 10px;
        }
        .expand-comments-btn:hover {
            color: #667eea;
        }
        .post-reply-form {
            display: none;
            margin-top: 8px;
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
        .post-actions {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-top: 5px;
        }
        .comment-count {
            color: #888;
            font-size: 12px;
        }
        .toggle-reply-btn {
            color: #888;
            font-size: 12px;
            cursor: pointer;
            background: none;
            border: none;
        }
        .toggle-reply-btn:hover {
            color: #667eea;
        }
        .nested-reply {
            padding-left: 20px;
            border-left: 1px solid rgba(255,255,255,0.08);
            margin-left: 0;
        }
        .reply-prefix {
            color: #999;
            font-size: 12px;
        }
        .post-header {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 8px;
        }
        .post-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            flex-shrink: 0;
        }
        .comment-avatar {
            width: 28px;
            height: 28px;
            border-radius: 50%;
            object-fit: cover;
            flex-shrink: 0;
            margin-right: 8px;
        }
        .post-comment-item {
            display: flex;
            align-items: flex-start;
            flex-wrap: wrap;
            padding: 8px 0;
        }
        .delete-post-btn, .delete-comment-btn {
            background: none;
            border: none;
            color: #ff6b6b;
            cursor: pointer;
            font-size: 14px;
            padding: 0 4px;
            opacity: 0.5;
            transition: opacity 0.2s;
        }
        .delete-post-btn:hover, .delete-comment-btn:hover {
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
    
    <main class="community-container">
        <div class="search-bar">
            <form action="community" method="get">
                <input type="text" name="keyword" placeholder="搜索歌曲名、关键词、作者、类型" value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>">
                <button type="submit">搜索</button>
            </form>
        </div>
        
        <div class="post-section">
            <h3>发表帖子</h3>
            <form action="post" method="post" class="post-form">
                <textarea name="content" placeholder="分享你的想法..." rows="3"></textarea>
                <button type="submit">发布</button>
            </form>
        </div>
        
        <div class="posts-list">
            <h3>最新帖子</h3>
            <%
                List<Post> posts = (List<Post>) request.getAttribute("posts");
                if (posts != null && !posts.isEmpty()) {
                    for (Post post : posts) {
                        List<Comment> postComments = postCommentsMap.get(post.getId());
                        if (postComments == null) postComments = new ArrayList<>();
                        int commentCount = postComments.size();
            %>
                    <div class="post-item" id="post<%= post.getId() %>">
                        <div class="post-header">
                            <img src="files/avatars/user_<%= post.getUserId() %>.png" onerror="if(this.src.endsWith('.png')){this.src=this.src.replace('.png','.jpg');}else{this.style.display='none';}" class="post-avatar">
                            <div>
                                <a href="profile?userId=<%= post.getUserId() %>" class="post-author-link"><%= post.getUsername() %></a>
                                <span class="post-time"><%= new SimpleDateFormat("yyyy-MM-dd HH:mm").format(post.getPostTime()) %></span>
                            </div>
                        </div>
                        <p class="post-content"><%= post.getContent() %></p>

                        <div class="post-actions">
                            <button class="toggle-reply-btn" onclick="<% if (sessionUser != null) { %>toggleReplyForm('replyForm<%= post.getId() %>')<% } else { %>alert('请先登录')<% } %>">&crarr; 回复</button>
                            <% if (sessionUser != null && sessionUser.getId() == post.getUserId()) { %>
                            <button class="delete-post-btn" onclick="deletePost(<%= post.getId() %>)" title="删除帖子">×</button>
                            <% } %>
                            <% if (commentCount > 0) { %>
                                <span class="comment-count">(<%= commentCount %>条评论)</span>
                            <% } %>
                        </div>

                        <div class="post-reply-form" id="replyForm<%= post.getId() %>">
                            <input type="hidden" name="postId" value="<%= post.getId() %>">
                            <input type="text" name="content" placeholder="写下你的评论..." class="reply-text-input">
                            <% if (sessionUser != null) { %>
                            <button onclick="submitPostReply('<%= post.getId() %>')" class="reply-submit-btn">发送</button>
                            <% } else { %>
                            <button onclick="alert('请先登录')" class="reply-submit-btn">发送</button>
                            <% } %>
                        </div>

                        <div class="post-comments-section" id="comments<%= post.getId() %>">
                            <% for (Comment c : postComments) { %>
                                <% if (c.getParentId() == 0) { %>
                                <div class="post-comment-item">
                                    <img src="files/avatars/user_<%= c.getUserId() %>.png" onerror="if(this.src.endsWith('.png')){this.src=this.src.replace('.png','.jpg');}else{this.style.display='none';}" class="comment-avatar">
                                    <div style="flex:1;">
                                        <a href="profile?userId=<%= c.getUserId() %>" class="comment-author"><%= c.getUsername() %></a>
                                        <span class="comment-content"><%= c.getContent() %></span>
                                        <span class="comment-time"><%= new SimpleDateFormat("MM-dd HH:mm").format(c.getCommentTime()) %></span>
                                        <span class="reply-btn" onclick="<% if (sessionUser != null) { %>showNestedReply('<%= post.getId() %>', <%= c.getId() %>, '<%= c.getUsername() %>')<% } else { %>alert('请先登录')<% } %>">回复</span>
                                        <% if (sessionUser != null && sessionUser.getId() == c.getUserId()) { %>
                                        <button class="delete-comment-btn" onclick="deleteComment(<%= c.getId() %>)" title="删除评论" style="background:none;border:none;color:#ff6b6b;cursor:pointer;font-size:14px;padding:0 4px;">×</button>
                                        <% } %>
                                    </div>
                                    <%-- Find nested replies to this comment --%>
                                    <% for (Comment nested : postComments) { %>
                                        <% if (nested.getParentId() == c.getId()) { %>
                                        <div class="nested-reply" style="margin-top:4px;width:100%;">
                                            <img src="files/avatars/user_<%= nested.getUserId() %>.png" onerror="if(this.src.endsWith('.png')){this.src=this.src.replace('.png','.jpg');}else{this.style.display='none';}" class="comment-avatar" style="width:20px;height:20px;">
                                            <span class="reply-prefix">回复（<%= nested.getParentUsername() != null ? nested.getParentUsername() : "" %>）：</span>
                                            <a href="profile?userId=<%= nested.getUserId() %>" class="comment-author"><%= nested.getUsername() %></a>
                                            <span class="comment-content"><%= nested.getContent() %></span>
                                            <span class="comment-time"><%= new SimpleDateFormat("MM-dd HH:mm").format(nested.getCommentTime()) %></span>
                                            <span class="reply-btn" onclick="<% if (sessionUser != null) { %>showNestedReply('<%= post.getId() %>', <%= nested.getId() %>, '<%= nested.getUsername() %>')<% } else { %>alert('请先登录')<% } %>">回复</span>
                                        </div>
                                        <% } %>
                                    <% } %>
                                </div>
                                <% } %>
                            <% } %>
                        </div>
                        <div id="nestedReplyForm<%= post.getId() %>" class="post-reply-form" style="margin-left:20px;"></div>
                    </div>
            <%
                    }
                } else {
            %>
                    <p>暂无帖子，快来发表第一个吧！</p>
            <% } %>
        </div>
        
        <div class="music-list-section">
            <h3>音乐列表</h3>
            <div class="music-grid">
                <% 
                    List<Music> musics = (List<Music>) request.getAttribute("musics");
                    if (musics != null && !musics.isEmpty()) {
                        for (Music music : musics) {
                %>
                        <div class="music-item" onclick="location.href='playMusic?id=<%= music.getId() %>'">
                            <% if (music.getCoverUrl() != null) { %>
                                <img class="album-cover" src="<%= music.getCoverUrl() %>" alt="<%= music.getName() %>">
                            <% } else { %>
                                <div class="album-cover default-cover"></div>
                            <% } %>
                            <span class="music-name"><%= music.getName() %></span>
                            <% if (music.getArtist() != null && !music.getArtist().isEmpty()) { %>
                            <span class="music-artist"><%= music.getArtist() %></span>
                            <% } %>
                            <span class="music-type"><%= music.getType() %></span>
                            <a href="profile?userId=<%= music.getUserId() %>" class="music-author-link"><%= music.getUsername() %></a>
                            <% if (sessionUser != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
                                <span class="add-to-playlist-btn" onclick="event.stopPropagation(); showPlaylistModal(<%= music.getId() %>)">+</span>
                            <% } %>
                        </div>
                <% 
                        }
                    } else {
                %>
                        <p>暂无音乐</p>
                <% } %>
            </div>
        </div>
    </main>
    
    <footer class="footer">
        <p>© 2026 ZY音乐 畅享世界</p>
    </footer>

    <% if (sessionUser != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
    <style>
        .add-to-playlist-btn {
            position: absolute;
            top: 10px;
            right: 10px;
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
        .music-item:hover .add-to-playlist-btn {
            opacity: 1;
        }
        .music-item {
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
    </style>
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

    <script src="js/animation.js"></script>
    <script>
        window.currentUserId = <%= sessionUser != null ? sessionUser.getId() : 0 %>;

        function deletePost(postId) {
            if (!confirm('确定删除这条帖子？')) return;
            location.href = 'post?action=delete&postId=' + postId;
        }
        function deleteComment(commentId) {
            if (!confirm('确定删除这条评论？')) return;
            fetch('comment?action=delete&commentId=' + commentId, {
                method: 'POST',
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    location.reload();
                }
            })
            .catch(function(err) { console.error(err); });
        }

        <% String highlightPostId = (String) request.getAttribute("highlightPostId");
           if (highlightPostId != null && !highlightPostId.isEmpty()) { %>
        document.addEventListener("DOMContentLoaded", function() {
            var postEl = document.getElementById('post<%= highlightPostId %>');
            if (postEl) {
                postEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }
        });
        <% } %>

        function toggleReplyForm(formId) {
            var el = document.getElementById(formId);
            if (el.classList.contains('active')) {
                el.classList.remove('active');
            } else {
                el.classList.add('active');
            }
        }

        function showNestedReply(postId, parentId, parentUsername) {
            var container = document.getElementById('nestedReplyForm' + postId);
            container.innerHTML = '' +
                '<input type="hidden" id="nestedPostId" value="' + postId + '">' +
                '<input type="hidden" id="nestedParentId" value="' + parentId + '">' +
                '<input type="hidden" id="nestedParentUsername" value="' + parentUsername + '">' +
                '<input type="text" id="nestedContent" placeholder="回复 ' + parentUsername + '..." class="reply-text-input">' +
                '<button onclick="submitNestedComment()" class="reply-submit-btn">发送</button>';
            container.classList.add('active');
        }

        function submitNestedComment() {
            var postId = document.getElementById('nestedPostId').value;
            var parentId = document.getElementById('nestedParentId').value;
            var parentUsername = document.getElementById('nestedParentUsername').value;
            var content = document.getElementById('nestedContent').value.trim();
            if (!content) return;
            var formData = 'postId=' + encodeURIComponent(postId) +
                '&parentId=' + encodeURIComponent(parentId) +
                '&parentUsername=' + encodeURIComponent(parentUsername) +
                '&content=' + encodeURIComponent(content);
            fetch('comment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    alert('回复成功');
                    document.getElementById('nestedReplyForm' + postId).classList.remove('active');
                    appendPostComment(postId, data, parentId > 0);
                }
            })
            .catch(function(err) { console.error(err); });
        }

        function submitPostReply(postId) {
            var form = document.getElementById('replyForm' + postId);
            var input = form.querySelector('input[name="content"]');
            if (!input) return;
            var content = input.value.trim();
            if (!content) return;
            var formData = 'postId=' + encodeURIComponent(postId) + '&content=' + encodeURIComponent(content);
            fetch('comment', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData
            })
            .then(function(r) { return r.json(); })
            .then(function(data) {
                if (data.success) {
                    alert('回复成功');
                    input.value = '';
                    form.classList.remove('active');
                    appendPostComment(postId, data, false);
                }
            })
            .catch(function(err) { console.error(err); });
        }

        function appendPostComment(postId, data, isNested) {
            var commentsDiv = document.getElementById('comments' + postId);
            // Build avatar HTML
            var avatarHtml = '';
            if (data.avatarUrl) {
                avatarHtml = '<img src="' + data.avatarUrl + '" onerror="if(this.src.endsWith(\'.png\')){this.src=this.src.replace(\'.png\',\'.jpg\');}else{this.style.display=\'none\';}" class="comment-avatar">';
            }
            var commentHtml = '';
            if (isNested) {
                commentHtml = '<div class="nested-reply" style="margin-top:4px;width:100%;">' +
                    avatarHtml.replace('comment-avatar', 'comment-avatar') +
                    '<span class="reply-prefix">回复（' + (data.parentUsername || '') + '）：</span>' +
                    '<a href="profile?userId=' + data.userId + '" class="comment-author">' + data.username + '</a> ' +
                    '<span class="comment-content">' + data.content + '</span> ' +
                    '<span class="comment-time">' + data.time + '</span> ' +
                    '<span class="reply-btn" onclick="showNestedReply(\'' + postId + '\', 0, \'' + data.username + '\')">回复</span>' +
                    (window.currentUserId === data.userId ? '<span class="delete-comment-btn" onclick="deleteComment(' + (data.id || 0) + ')" title="删除">✕</span>' : '') +
                    '</div>';
                var parentComment = commentsDiv.querySelector('[data-comment-id="' + data.parentId + '"]');
                if (parentComment) {
                    parentComment.insertAdjacentHTML('beforeend', commentHtml);
                } else {
                    commentsDiv.insertAdjacentHTML('beforeend', commentHtml);
                }
            } else {
                commentHtml = '<div class="post-comment-item" data-comment-id="new' + Date.now() + '">' +
                    avatarHtml +
                    '<div style="flex:1;">' +
                    '<a href="profile?userId=' + data.userId + '" class="comment-author">' + data.username + '</a> ' +
                    '<span class="comment-content">' + data.content + '</span> ' +
                    '<span class="comment-time">' + data.time + '</span> ' +
                    '<span class="reply-btn" onclick="showNestedReply(\'' + postId + '\', 0, \'' + data.username + '\')">回复</span>' +
                    (window.currentUserId === data.userId ? '<span class="delete-comment-btn" onclick="deleteComment(' + (data.id || 0) + ')" title="删除">✕</span>' : '') +
                    '</div></div>';
                commentsDiv.insertAdjacentHTML('beforeend', commentHtml);
            }
            // Update comment count
            var countSpan = document.querySelector('#post' + postId + ' .comment-count');
            if (countSpan) {
                var count = parseInt(countSpan.textContent) || 0;
                countSpan.textContent = '(' + (count + 1) + '条评论)';
            } else {
                // Create count span if it doesn't exist
                var actions = document.querySelector('#post' + postId + ' .post-actions');
                if (actions) {
                    var span = document.createElement('span');
                    span.className = 'comment-count';
                    span.textContent = '(1条评论)';
                    actions.appendChild(span);
                }
            }
        }
    </script>
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
    <% if (sessionUser != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
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
        window.onclick = function(e) {
            if (e.target.id === 'playlistModal') {
                closePlaylistModal();
            }
        }
    </script>
    <% } %>
  <%@ include file="notify-bar.jsp" %>
</body>
</html>
