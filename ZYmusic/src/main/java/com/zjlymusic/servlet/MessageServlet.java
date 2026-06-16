package com.zjlymusic.servlet;

import com.zjlymusic.dao.NotificationDAO;
import com.zjlymusic.dao.UserDAO;
import com.zjlymusic.entity.Message;
import com.zjlymusic.entity.Notification;
import com.zjlymusic.entity.User;
import com.zjlymusic.dao.MessageDAO;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Date;
import java.util.List;

public class MessageServlet extends HttpServlet {
    private MessageDAO messageDAO = new MessageDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) { response.sendRedirect("login.jsp"); return; }

        String otherUserIdStr = request.getParameter("userId");
        if (otherUserIdStr == null || otherUserIdStr.trim().isEmpty()) {
            response.sendRedirect("profile");
            return;
        }

        int otherUserId = Integer.parseInt(otherUserIdStr);
        User otherUser = new UserDAO().getUserById(otherUserId);
        if (otherUser == null) {
            response.sendRedirect("profile");
            return;
        }

        List<Message> messages = messageDAO.getMessagesBetweenUsers(sessionUser.getId(), otherUserId, 200);
        request.setAttribute("otherUser", otherUser);
        request.setAttribute("messages", messages);
        request.getRequestDispatcher("messages.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) { response.sendRedirect("login.jsp"); return; }

        String receiverIdStr = request.getParameter("receiverId");
        String content = request.getParameter("content");

        if (receiverIdStr == null || content == null || content.trim().isEmpty()) {
            response.sendRedirect("profile");
            return;
        }

        int receiverId = Integer.parseInt(receiverIdStr);
        Message msg = new Message();
        msg.setSenderId(sessionUser.getId());
        msg.setReceiverId(receiverId);
        msg.setContent(content.trim());
        msg.setSendTime(new Date());
        messageDAO.addMessage(msg);

        // Create notification for receiver
        Notification n = new Notification();
        n.setUserId(receiverId);
        n.setType("message");
        n.setFromUserId(sessionUser.getId());
        n.setFromUsername(sessionUser.getUsername());
        n.setContent(content.trim());
        n.setRelatedId(sessionUser.getId());
        n.setRelatedType("message");
        n.setCreateTime(new Date());
        new NotificationDAO().addNotification(n);

        response.sendRedirect("messages?userId=" + receiverId);
    }
}
