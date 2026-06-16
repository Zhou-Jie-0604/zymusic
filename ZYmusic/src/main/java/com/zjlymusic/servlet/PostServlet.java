package com.zjlymusic.servlet;

import com.zjlymusic.entity.User;
import com.zjlymusic.service.PostService;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class PostServlet extends HttpServlet {
    private PostService postService = new PostService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("community");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) { response.sendRedirect("login.jsp"); return; }

        String content = request.getParameter("content");
        postService.createPost(content, user.getId(), user.getUsername());
        response.sendRedirect("community");
    }
}