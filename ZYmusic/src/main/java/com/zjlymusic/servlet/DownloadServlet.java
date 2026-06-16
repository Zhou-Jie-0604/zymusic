package com.zjlymusic.servlet;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;

public class DownloadServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String platform = request.getParameter("platform");
        File file;
        String downloadName;

        if ("android".equalsIgnoreCase(platform)) {
            file = new File("android-app/app/build/outputs/apk/release/app-release.apk");
            if (!file.exists()) {
                file = new File("android-app/app/build/outputs/apk/debug/app-debug.apk");
            }
            downloadName = "ZYMusic-Android.apk";
        } else {
            // 桌面版 - 使用ZIP包格式
            file = new File("target/ZYMusic-Desktop.zip");
            downloadName = "ZYMusic-Desktop.zip";
        }

        if (!file.exists() || !file.isFile()) {
            response.setContentType("text/html;charset=UTF-8");
            response.getWriter().write("<!DOCTYPE html><html><head><meta charset=\"UTF-8\"><title>ZY音乐</title></head>" +
                "<body style=\"font-family:Microsoft YaHei,sans-serif;background:#1a1a2e;color:#fff;text-align:center;padding:48px;\">" +
                "<h1>安装包还未生成</h1><p>请先在项目目录运行 build-desktop.bat 来生成安装包。</p>" +
                "<p><a style=\"color:#9bb7ff\" href=\"download.jsp\">返回下载页</a></p></body></html>");
            return;
        }

        response.setContentType("application/x-msdownload");
        response.setHeader("Content-Disposition", "attachment; filename=\"" + downloadName + "\"");
        response.setContentLengthLong(file.length());
        try (OutputStream out = response.getOutputStream()) {
            Files.copy(file.toPath(), out);
        }
    }
}
