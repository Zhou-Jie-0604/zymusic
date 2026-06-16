package com.zjlymusic.servlet;

import com.zjlymusic.dao.UserDAO;
import com.zjlymusic.entity.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.regex.Pattern;

public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^[a-zA-Z0-9]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\d{11}$");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String phone = request.getParameter("phone");

        // Validate username
        if (username == null || username.trim().isEmpty()) {
            request.setAttribute("error", "用户名称不能为空");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate password - must be > 8 chars and alphanumeric
        if (password == null || password.length() <= 8) {
            request.setAttribute("error", "密码必须大于8位且为字符或数字");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }
        if (!PASSWORD_PATTERN.matcher(password).matches()) {
            request.setAttribute("error", "密码必须为字符或数字");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate phone - must be exactly 11 digits
        if (phone == null || !PHONE_PATTERN.matcher(phone).matches()) {
            request.setAttribute("error", "手机号错误");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Check if username already exists
        User existingUser = userDAO.getUserByUsername(username);
        if (existingUser != null) {
            request.setAttribute("error", "该用户名称已被注册");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Check if phone already exists
        User existingPhoneUser = userDAO.getUserByPhone(phone);
        if (existingPhoneUser != null) {
            request.setAttribute("error", "该手机号已被注册");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Create new user
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setPassword(password);
        newUser.setPhone(phone);
        newUser.setAvatar("files/covers/default-cover.svg");
        newUser.setNickname(username);

        boolean success = userDAO.addUser(newUser);
        if (success) {
            response.sendRedirect("login.jsp");
        } else {
            request.setAttribute("error", "注册失败，请重试");
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
}
