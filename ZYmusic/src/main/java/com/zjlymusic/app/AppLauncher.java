package com.zjlymusic.app;

import com.zjlymusic.util.EmbeddedServer;
import java.awt.Desktop;
import java.net.URI;

public class AppLauncher {
    public static void main(String[] args) {
        System.out.println("========================================");
        System.out.println("  ZY音乐 正在启动...");
        System.out.println("========================================");

        try {
            EmbeddedServer.getInstance().start();
            String url = "http://localhost:" + EmbeddedServer.getInstance().getPort() + "/index.jsp";
            System.out.println("服务地址: " + url);

            // 自动打开浏览器
            try {
                Thread.sleep(1000);
                if (Desktop.isDesktopSupported()) {
                    Desktop.getDesktop().browse(new URI(url));
                }
            } catch (Exception e) {
                System.out.println("请手动打开浏览器访问: " + url);
            }

            System.out.println("ZY音乐 已启动，关闭此窗口停止服务");
            Thread.currentThread().join();
        } catch (Exception e) {
            e.printStackTrace();
            System.out.println("启动失败: " + e.getMessage());
            System.exit(1);
        }
    }
}
