package com.zjlymusic.servlet;

import com.zjlymusic.entity.User;
import com.zjlymusic.service.UserService;
import com.zjlymusic.util.FileUploadUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.IOException;

@MultipartConfig(maxFileSize = 50 * 1024 * 1024, maxRequestSize = 60 * 1024 * 1024)
public class UpdateProfileServlet extends HttpServlet {
    private UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("avatar".equals(action)) {
            handleAvatar(request, response, session, user);
        } else if ("nickname".equals(action)) {
            handleNickname(request, response, session, user);
        } else if ("background".equals(action)) {
            handleBackground(request, response, session, user);
        } else if ("opacity".equals(action)) {
            handleOpacity(request, response, session, user);
        } else if ("bio".equals(action)) {
            handleBio(request, response, session, user);
        } else {
            response.sendRedirect("profile");
        }
    }

    private void handleAvatar(HttpServletRequest request, HttpServletResponse response, HttpSession session, User user)
            throws IOException, ServletException {
        Part avatarPart = request.getPart("avatar");
        String avatarData = request.getParameter("avatarData");
        try {
            String avatarPath = (avatarData != null && !avatarData.trim().isEmpty())
                ? FileUploadUtil.saveAvatarDataUrl(avatarData, user.getId())
                : FileUploadUtil.saveAvatar(avatarPart, user.getId());
            String error = userService.updateAvatar(user, avatarPath);
            if (error != null) {
                session.setAttribute("profileError", error);
            } else {
                session.setAttribute("profileSuccess", "头像更新成功");
                session.setAttribute("user", userService.getUserById(user.getId()));
            }
        } catch (IOException ex) {
            session.setAttribute("profileError", ex.getMessage());
        }
        response.sendRedirect("profile");
    }

    private void handleNickname(HttpServletRequest request, HttpServletResponse response, HttpSession session, User user)
            throws IOException {
        String nickname = request.getParameter("nickname");
        String error = userService.updateNickname(user, nickname);
        if (error != null) {
            session.setAttribute("profileError", error);
        } else {
            session.setAttribute("profileSuccess", "昵称更新成功");
            session.setAttribute("user", userService.getUserById(user.getId()));
        }
        response.sendRedirect("profile");
    }

    private void handleBackground(HttpServletRequest request, HttpServletResponse response, HttpSession session, User user)
            throws IOException, ServletException {
        Part backgroundPart = request.getPart("background");
        try {
            String backgroundPath = FileUploadUtil.saveBackground(backgroundPart, user.getId());
            String error = userService.updateBackground(user, backgroundPath);
            if (error != null) {
                session.setAttribute("profileError", error);
            } else {
                session.setAttribute("profileSuccess", "背景更新成功");
                session.setAttribute("user", userService.getUserById(user.getId()));
            }
        } catch (IOException ex) {
            session.setAttribute("profileError", ex.getMessage());
        }
        response.sendRedirect(getRedirectUrl(request));
    }

    private void handleOpacity(HttpServletRequest request, HttpServletResponse response, HttpSession session, User user)
            throws IOException {
        String opacityStr = request.getParameter("opacity");
        try {
            int opacity = Integer.parseInt(opacityStr);
            userService.updateBackgroundOpacity(user.getId(), opacity);
            session.setAttribute("user", userService.getUserById(user.getId()));
        } catch (NumberFormatException e) {
            // ignore
        }
        response.sendRedirect(getRedirectUrl(request));
    }

    private String getRedirectUrl(HttpServletRequest request) {
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            try {
                String path = new java.net.URL(referer).getPath();
                if (path != null && !path.isEmpty() && !path.equals("/")) {
                    return path;
                }
            } catch (Exception ignored) {}
        }
        return "profile";
    }

    private void handleBio(HttpServletRequest request, HttpServletResponse response, HttpSession session, User user)
            throws IOException {
        String bio = request.getParameter("bio");
        String error = userService.updateBio(user, bio);
        if (error != null) {
            session.setAttribute("profileError", error);
        } else {
            session.setAttribute("profileSuccess", "个性签名更新成功");
            session.setAttribute("user", userService.getUserById(user.getId()));
        }
        response.sendRedirect("profile");
    }
}
