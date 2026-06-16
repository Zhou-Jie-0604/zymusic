package com.zjlymusic.servlet;

import com.zjlymusic.dao.NotificationDAO;
import com.zjlymusic.entity.Notification;
import com.zjlymusic.entity.User;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class NotificationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User sessionUser = (User) session.getAttribute("user");
        if (sessionUser == null) {
            if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
                response.setContentType("application/json;charset=UTF-8");
                response.getWriter().write("[]");
                return;
            }
            response.sendRedirect("login.jsp");
            return;
        }

        NotificationDAO ndao = new NotificationDAO();
        List<Notification> notifications = ndao.getNotifications(sessionUser.getId(), 100);

        // AJAX requests from notification bar - return JSON
        if ("XMLHttpRequest".equals(request.getHeader("X-Requested-With"))) {
            response.setContentType("application/json;charset=UTF-8");
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
            StringBuilder json = new StringBuilder("[");
            for (int i = 0; i < notifications.size(); i++) {
                Notification n = notifications.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\":").append(n.getId()).append(",");
                json.append("\"displayText\":\"").append(escapeJson(n.getDisplayText())).append("\",");
                json.append("\"targetUrl\":\"").append(escapeJson(n.getTargetUrl())).append("\",");
                json.append("\"time\":\"").append(sdf.format(n.getCreateTime())).append("\",");
                json.append("\"isRead\":").append(n.isRead());
                json.append("}");
            }
            json.append("]");
            response.getWriter().write(json.toString());
            return;
        }

        // Regular browser request - show full page
        request.setAttribute("notifications", notifications);
        request.getRequestDispatcher("notifications.jsp").forward(request, response);
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
