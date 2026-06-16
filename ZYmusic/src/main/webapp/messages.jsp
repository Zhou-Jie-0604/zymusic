<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%@ page import="com.zjlymusic.entity.Message" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null) { response.sendRedirect("login.jsp"); return; }
    User otherUser = (User) request.getAttribute("otherUser");
    List<Message> messages = (List<Message>) request.getAttribute("messages");
    SimpleDateFormat sdf = new SimpleDateFormat("MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - <%= otherUser != null ? "与 " + otherUser.getUsername() + " 的私信" : "私信" %></title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="pwa-head.jsp" %>
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/app.css">
    <style>
        body { background: #0a0a1a; margin: 0; }
        .chat-wrapper {
            position: fixed; top: 0; left: 0; right: 0; bottom: 0;
            display: flex; flex-direction: column; max-width: 700px;
            margin: 0 auto; background: #0f0f24;
        }
        .chat-top {
            display: flex; align-items: center; gap: 12px;
            padding: 12px 16px; background: rgba(20,20,50,0.95);
            border-bottom: 1px solid rgba(255,255,255,0.08);
            flex-shrink: 0; z-index: 10;
        }
        .chat-back { color: #667eea; text-decoration: none; font-size: 18px; }
        .chat-avatar {
            width: 36px; height: 36px; border-radius: 50%; object-fit: cover;
            background: rgba(255,255,255,0.1);
        }
        .chat-avatar-placeholder {
            width: 36px; height: 36px; border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 16px; font-weight: bold;
        }
        .chat-username { color: #fff; font-size: 16px; font-weight: 600; }
        .chat-body {
            flex: 1; overflow-y: auto; padding: 16px;
            display: flex; flex-direction: column; gap: 12px;
        }
        .msg-row { display: flex; gap: 10px; max-width: 85%; }
        .msg-row.mine { align-self: flex-end; flex-direction: row-reverse; }
        .msg-row.other { align-self: flex-start; }
        .msg-avatar {
            width: 34px; height: 34px; border-radius: 50%; object-fit: cover;
            flex-shrink: 0; background: rgba(255,255,255,0.1);
        }
        .msg-avatar-placeholder {
            width: 34px; height: 34px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 14px; font-weight: bold;
        }
        .msg-bubble {
            padding: 10px 14px; border-radius: 16px;
            font-size: 14px; line-height: 1.5; word-break: break-word;
        }
        .msg-row.mine .msg-bubble {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff; border-bottom-right-radius: 4px;
        }
        .msg-row.other .msg-bubble {
            background: rgba(255,255,255,0.1);
            color: #ddd; border-bottom-left-radius: 4px;
        }
        .msg-username-label { color: #8899ff; font-size: 12px; margin-bottom: 2px; }
        .msg-time { color: #888; font-size: 11px; margin-top: 4px; }
        .msg-row.mine .msg-time { text-align: right; }
        .chat-bottom {
            display: flex; gap: 8px; padding: 12px 16px;
            background: rgba(20,20,50,0.95);
            border-top: 1px solid rgba(255,255,255,0.08);
            flex-shrink: 0;
        }
        .chat-input {
            flex: 1; padding: 10px 16px; border-radius: 20px;
            border: 1px solid rgba(255,255,255,0.15);
            background: rgba(255,255,255,0.08); color: #fff;
            font-size: 14px; outline: none; resize: none;
        }
        .chat-input::placeholder { color: #666; }
        .chat-send {
            padding: 10px 24px; border-radius: 20px; border: none;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: #fff; font-size: 14px; cursor: pointer;
            white-space: nowrap;
        }
        .chat-send:hover { opacity: 0.9; }
        .chat-empty { color: #666; text-align: center; padding: 60px 20px; flex: 1; display: flex; align-items: center; justify-content: center; }
        .chat-empty-inner { font-size: 15px; }
    </style>
</head>
<body>
    <div class="chat-wrapper">
        <div class="chat-top">
            <a href="javascript:history.back()" class="chat-back">&larr;</a>
            <% if (otherUser != null) {
                String otherAvatar = otherUser.getAvatarUrl();
                if (otherAvatar != null) { %>
                    <img class="chat-avatar" src="<%= otherAvatar %>" alt="">
                <% } else { %>
                    <div class="chat-avatar-placeholder"><%= otherUser.getUsername().substring(0, 1).toUpperCase() %></div>
                <% } %>
                <span class="chat-username">我的私信 - <%= otherUser.getUsername() %></span>
            <% } else { %>
                <span class="chat-username">我的私信</span>
            <% } %>
        </div>

        <div class="chat-body" id="chatBody">
            <% if (messages != null && !messages.isEmpty()) {
                for (Message m : messages) {
                    boolean isMine = (m.getSenderId() == sessionUser.getId());
                    String avatarUrl = isMine ? sessionUser.getAvatarUrl() : m.getSenderAvatarUrl();
                    String displayName = isMine ? sessionUser.getUsername() : m.getSenderUsername();
            %>
                <div class="msg-row <%= isMine ? "mine" : "other" %>">
                    <% if (avatarUrl != null) { %>
                        <img class="msg-avatar" src="<%= avatarUrl %>" alt="">
                    <% } else { %>
                        <div class="msg-avatar-placeholder"><%= displayName != null ? displayName.substring(0, 1).toUpperCase() : "?" %></div>
                    <% } %>
                    <div>
                        <div class="msg-username-label"><%= displayName %></div>
                        <div class="msg-bubble"><%= m.getContent() %></div>
                        <div class="msg-time"><%= sdf.format(m.getSendTime()) %></div>
                    </div>
                </div>
            <%  }
              } else { %>
                <div class="chat-empty">
                    <div class="chat-empty-inner">暂无消息，发送第一条私信吧</div>
                </div>
            <% } %>
        </div>

        <% if (otherUser != null) { %>
        <form class="chat-bottom" method="post" action="messages">
            <input type="hidden" name="receiverId" value="<%= otherUser.getId() %>">
            <input type="text" class="chat-input" name="content" placeholder="输入消息..." autocomplete="off" required>
            <button type="submit" class="chat-send">发送</button>
        </form>
        <% } %>
    </div>
    <script>
        // Auto-scroll to bottom
        (function() {
            var body = document.getElementById('chatBody');
            if (body) body.scrollTop = body.scrollHeight;
        })();
    </script>
</body>
</html>
