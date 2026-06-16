<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%@ page import="com.zjlymusic.entity.Notification" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) { response.sendRedirect("login.jsp"); return; }
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    SimpleDateFormat sdf = new SimpleDateFormat("MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - 我的消息</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="pwa-head.jsp" %>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/app.css">
    <style>
        body { background: #000; }
        .header, .footer { position: relative; z-index: 10; }
        .notify-page { position: relative; z-index: 10; max-width: 680px; margin: 80px auto 100px; padding: 0 16px; }
        .notify-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .notify-header h2 { color: #fff; margin: 0; font-size: 20px; }
        .notify-card {
            display: flex; align-items: flex-start; gap: 12px;
            padding: 14px 16px; background: rgba(255,255,255,0.06);
            border-radius: 12px; margin-bottom: 8px;
            cursor: pointer; transition: background 0.2s; text-decoration: none;
        }
        .notify-card:hover { background: rgba(255,255,255,0.12); }
        .notify-card.unread { border-left: 3px solid #667eea; background: rgba(102,126,234,0.1); }
        .notify-avatar {
            width: 44px; height: 44px; border-radius: 50%; object-fit: cover;
            flex-shrink: 0; background: rgba(255,255,255,0.1);
        }
        .notify-avatar-placeholder {
            width: 44px; height: 44px; border-radius: 50%;
            flex-shrink: 0; background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 18px; font-weight: bold;
        }
        .notify-body { flex: 1; min-width: 0; }
        .notify-username { color: #8899ff; font-size: 14px; font-weight: 600; margin-bottom: 4px; }
        .notify-text { color: #ccc; font-size: 14px; line-height: 1.4; word-break: break-word; }
        .notify-time { color: #666; font-size: 12px; margin-top: 6px; }
        .notify-empty { color: #666; text-align: center; padding: 80px 20px; font-size: 16px; }
        .notify-empty-icon { font-size: 52px; margin-bottom: 16px; display: block; }
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
            <% if (sessionUser != null) { %><a href="logout">退出登录</a><% } else { %><a href="login.jsp">登录</a><% } %>
        </nav>
    </header>

    <main class="notify-page">
        <div class="notify-header">
            <a href="javascript:history.back()" style="color:#667eea;text-decoration:none;font-size:16px;">&larr; 返回</a>
            <h2>&#128276; 我的消息</h2>
            <span style="width:60px;"></span>
        </div>
        <% if (notifications != null && !notifications.isEmpty()) {
            for (Notification n : notifications) {
                String avatarUrl = n.getFromUserAvatarUrl();
                String displayName = n.getFromUsername();
                String displayText = n.getDisplayText();
                String targetUrl = n.getTargetUrl();
        %>
            <a class="notify-card <%= n.isRead() ? "" : "unread" %>" href="<%= targetUrl %>">
                <% if (avatarUrl != null) { %>
                    <img class="notify-avatar" src="<%= avatarUrl %>" alt="">
                <% } else { %>
                    <div class="notify-avatar-placeholder"><%= displayName.substring(0, 1).toUpperCase() %></div>
                <% } %>
                <div class="notify-body">
                    <div class="notify-username"><%= displayName %></div>
                    <div class="notify-text"><%= displayText %></div>
                    <div class="notify-time"><%= sdf.format(n.getCreateTime()) %></div>
                </div>
            </a>
        <%  }
          } else { %>
            <div class="notify-empty">
                <span class="notify-empty-icon">&#128276;</span>
                暂无消息通知
            </div>
        <% } %>
    </main>

    <footer class="footer"><p>© 2026 ZY音乐 畅享世界</p></footer>
    <%@ include file="notify-bar.jsp" %>
    <script src="js/player-bar.js"></script>
</body>
</html>
