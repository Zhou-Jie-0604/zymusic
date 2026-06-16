package com.zjlymusic.servlet;

import com.zjlymusic.entity.User;
import com.zjlymusic.service.UserService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginServlet extends HttpServlet {
    private UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String loginKey = request.getParameter("loginKey");
        String password = request.getParameter("password");

        if (loginKey == null || loginKey.trim().isEmpty()) {
            request.setAttribute("error", "手机号/用户名称不能为空");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        if (password == null || password.trim().isEmpty()) {
            request.setAttribute("error", "密码不能为空");
            request.getRequestDispatcher("login.jsp").forward(request, response);
            return;
        }

        User user = userService.login(loginKey, password);

        if (user != null) {
            HttpSession session = request.getSession();
            session.setAttribute("user", userService.getUserById(user.getId()));
            response.sendRedirect("index.jsp");
        } else {
            request.setAttribute("error", "账号/密码错误，请重试");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
