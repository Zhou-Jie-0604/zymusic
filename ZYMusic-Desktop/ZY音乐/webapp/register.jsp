<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐 - 注册</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="manifest" href="manifest.json">
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/app.css">
    <style>
        .register-container {
            max-width: 800px;
            margin: 80px auto;
            padding: 40px;
            background: rgba(255, 255, 255, 0.95);
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        .register-container h1 {
            text-align: center;
            color: #6c5ce7;
            margin-bottom: 30px;
        }
        .register-form .form-group {
            margin-bottom: 20px;
        }
        .register-form label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
        }
        .register-form input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e0e0e0;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
            box-sizing: border-box;
            color: #000;
        }
        .register-form input::placeholder {
            color: #666;
        }
        .register-form input:focus {
            outline: none;
            border-color: #6c5ce7;
        }
        .register-form small {
            display: block;
            margin-top: 5px;
            color: #999;
            font-size: 12px;
        }
        .register-btn {
            width: 100%;
            padding: 14px;
            background-color: #6c5ce7;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 10px;
        }
        .register-btn:hover {
            background-color: #5a4ad1;
        }
        .back-login {
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #6c5ce7;
            text-decoration: none;
        }
        .back-login:hover {
            text-decoration: underline;
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

    <div class="register-container">
        <h1>注册账号</h1>
        <form action="register" method="post" class="register-form">
            <div class="form-group">
                <label>用户名称</label>
                <input type="text" name="username" required placeholder="请输入用户名称">
            </div>
            <div class="form-group">
                <label>密码</label>
                <input type="password" name="password" required placeholder="请输入密码（必须大于8位且为字符或数字）">
                <small>密码必须大于8位且为字符或数字</small>
            </div>
            <div class="form-group">
                <label>手机号</label>
                <input type="text" name="phone" required placeholder="请输入11位手机号">
                <small>手机号必须为11位数字</small>
            </div>
            <button type="submit" class="register-btn">注册账号</button>
            <a href="login.jsp" class="back-login">返回登录</a>
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
