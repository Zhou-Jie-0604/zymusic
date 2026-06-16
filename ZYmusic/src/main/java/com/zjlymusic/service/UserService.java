package com.zjlymusic.service;

import com.zjlymusic.dao.MusicDAO;
import com.zjlymusic.dao.PostDAO;
import com.zjlymusic.dao.UserDAO;
import com.zjlymusic.entity.User;

public class UserService {
    private UserDAO userDAO = new UserDAO();
    private MusicDAO musicDAO = new MusicDAO();
    private PostDAO postDAO = new PostDAO();

    public User login(String loginKey, String password) {
        User user = userDAO.getUserByUsername(loginKey);
        if (user == null) {
            user = userDAO.getUserByPhone(loginKey);
        }
        if (user == null) {
            return null;
        }
        if (user.getPassword() == null || !user.getPassword().equals(password)) {
            return null;
        }
        return user;
    }

    public boolean register(String username, String password) {
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            return false;
        }
        User existingUser = userDAO.getUserByUsername(username);
        if (existingUser != null) {
            return true;
        }
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setPassword(password);
        userDAO.addUser(newUser);
        return true;
    }

    public boolean isValidPassword(String password) {
        return password != null && !password.trim().isEmpty();
    }

    public User getUserById(int id) {
        return userDAO.getUserById(id);
    }

    public String updateAvatar(User user, String avatarPath) {
        if (user == null) {
            return "请先登录";
        }
        if (avatarPath == null || avatarPath.trim().isEmpty()) {
            return "头像保存失败";
        }
        if (userDAO.updateAvatar(user.getId(), avatarPath)) {
            user.setAvatar(avatarPath);
            return null;
        }
        return "头像更新失败";
    }

    public String updateNickname(User user, String newNickname) {
        if (user == null) {
            return "请先登录";
        }
        if (newNickname == null || newNickname.trim().isEmpty()) {
            return "昵称不能为空";
        }
        newNickname = newNickname.trim();
        if (newNickname.equals(user.getUsername())) {
            return null;
        }
        if (userDAO.isUsernameTaken(newNickname, user.getId())) {
            return "该昵称已被使用";
        }
        if (!userDAO.updateUsername(user.getId(), newNickname)) {
            return "昵称更新失败";
        }
        musicDAO.updateUsernameByUserId(user.getId(), newNickname);
        postDAO.updateUsernameByUserId(user.getId(), newNickname);
        user.setUsername(newNickname);
        return null;
    }

    public String updateBackground(User user, String backgroundPath) {
        if (user == null) {
            return "请先登录";
        }
        if (backgroundPath == null || backgroundPath.trim().isEmpty()) {
            return "背景设置失败";
        }
        if (userDAO.updateBackground(user.getId(), backgroundPath)) {
            user.setBackground(backgroundPath);
            return null;
        }
        return "背景更新失败";
    }

    public void updateBackgroundOpacity(int userId, int opacity) {
        userDAO.updateBackgroundOpacity(userId, opacity);
    }

    public String updateBio(User user, String bio) {
        if (user == null) {
            return "请先登录";
        }
        if (userDAO.updateBio(user.getId(), bio != null ? bio.trim() : "")) {
            user.setBio(bio != null ? bio.trim() : "");
            return null;
        }
        return "个性签名更新失败";
    }
}
