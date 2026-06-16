<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - 登录</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="manifest" href="manifest.json">
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/app.css">
    <style>
        .login-form input {
            color: #000 !important;
        }
        .login-form input::placeholder {
            color: #666 !important;
        }
        .register-btn {
            display: block;
            width: 100%;
            padding: 12px;
            margin-top: 15px;
            background-color: #6c5ce7;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            transition: background-color 0.3s;
        }
        .register-btn:hover {
            background-color: #5a4ad1;
        }
        .error-popup {
            display: none;
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            z-index: 1000;
            text-align: center;
            max-width: 320px;
        }
        .error-popup.show {
            display: block;
        }
        .error-popup p {
            margin: 0 0 20px 0;
            color: #e74c3c;
            font-size: 16px;
        }
        .error-popup button {
            padding: 10px 30px;
            background: #6c5ce7;
            color: white;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 14px;
        }
        .overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 999;
        }
        .overlay.show {
            display: block;
        }
    </style>
</head>
<body>
    <div class="background-animation"></div>

    <div class="login-container">
        <h1>ZY音乐</h1>
        <form action="login" method="post" class="login-form">
            <div class="form-group">
                <label>手机号/用户名称</label>
                <input type="text" name="loginKey" required placeholder="请输入手机号或用户名称">
            </div>
            <div class="form-group">
                <label>密码</label>
                <input type="password" name="password" required placeholder="请输入密码">
            </div>
            <button type="submit" class="login-btn">登录</button>
            <a href="register.jsp" class="register-btn">注册账号</a>
        </form>
    </div>

    <%
        String error = (String) request.getAttribute("error");
        if (error != null) {
    %>
    <div class="overlay show" id="overlay"></div>
    <div class="error-popup show" id="errorPopup">
        <p><%= error %></p>
        <button onclick="closePopup()">确定</button>
    </div>
    <% } %>

    <footer class="footer">
        <p>© 2026 ZY音乐 畅享世界</p>
    </footer>

    <script src="js/animation.js"></script>
    <script>
        function closePopup() {
            document.getElementById('errorPopup').classList.remove('show');
            document.getElementById('overlay').classList.remove('show');
        }
    </script>
</body>
</html>
