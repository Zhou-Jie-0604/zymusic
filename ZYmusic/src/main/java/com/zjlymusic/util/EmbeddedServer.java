package com.zjlymusic.util;

import org.eclipse.jetty.server.HttpConfiguration;
import org.eclipse.jetty.server.HttpConnectionFactory;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.server.ServerConnector;
import org.eclipse.jetty.webapp.WebAppContext;
import org.apache.jasper.runtime.JspFactoryImpl;
import org.apache.tomcat.InstanceManager;
import org.apache.tomcat.SimpleInstanceManager;

import javax.servlet.MultipartConfigElement;
import javax.servlet.jsp.JspFactory;
import java.io.File;
import java.io.IOException;
import java.net.BindException;

public class EmbeddedServer {
    private static EmbeddedServer instance;
  /** 默认端口，需与 ngrok 转发目标 localhost:8080 一致 */
    private static final int DEFAULT_PORT = 8080;
    private static final long MAX_FILE_SIZE = 100 * 1024 * 1024L; // 100MB
    private static final long MAX_REQUEST_SIZE = 120 * 1024 * 1024L; // 120MB
    private Server server;
    private int port = DEFAULT_PORT;

    public static synchronized EmbeddedServer getInstance() {
        if (instance == null) {
            instance = new EmbeddedServer();
        }
        return instance;
    }

    public synchronized void start() throws Exception {
        if (server != null && server.isStarted()) {
            return;
        }

        DBInit.initialize();
        if (JspFactory.getDefaultFactory() == null) {
            JspFactory.setDefaultFactory(new JspFactoryImpl());
        }

        // Cloud platforms set PORT env var
        int startPort = DEFAULT_PORT;
        int maxPort = startPort + 100;
        String cloudPort = System.getenv("PORT");
        if (cloudPort != null && !cloudPort.trim().isEmpty()) {
            try {
                startPort = Integer.parseInt(cloudPort.trim());
                maxPort = startPort + 1;
            } catch (NumberFormatException ignored) {}
        }
        Exception lastError = null;

        for (int tryPort = startPort; tryPort < maxPort; tryPort++) {
            Server tryServer = new Server();

            HttpConfiguration httpConfig = new HttpConfiguration();
            HttpConnectionFactory connectionFactory = new HttpConnectionFactory(httpConfig);
            ServerConnector connector = new ServerConnector(tryServer, connectionFactory);
            connector.setHost("0.0.0.0");
            connector.setPort(tryPort);
            tryServer.addConnector(connector);

            WebAppContext webapp = new WebAppContext();
            webapp.setContextPath("/");

            File resourceRoot = AppPaths.resolveWebResourceRoot();
            webapp.setResourceBase(resourceRoot.getAbsolutePath());

            File classesDir = new File("target/classes");
            if (classesDir.exists()) {
                webapp.setExtraClasspath(classesDir.getAbsolutePath());
            }

            String tempDir = AppPaths.getTempDir().getAbsolutePath();
            MultipartConfigElement multipartConfig = new MultipartConfigElement(
                tempDir, MAX_FILE_SIZE, MAX_REQUEST_SIZE, 0);
            webapp.setAttribute("org.eclipse.jetty.multipartConfig", multipartConfig);

            webapp.setAttribute("javax.servlet.context.tempdir", AppPaths.getTempDir());
            webapp.setAttribute(InstanceManager.class.getName(), new SimpleInstanceManager());
            webapp.setParentLoaderPriority(true);
            webapp.setConfigurationDiscovered(true);

            webapp.setAttribute("org.eclipse.jetty.server.webapp.ContainerIncludeJarPattern", ".*\\.jar$");
            webapp.setInitParameter("org.eclipse.jetty.servlet.SessionCookie", "JSESSIONID");

            tryServer.setHandler(webapp);

            try {
                tryServer.start();
                server = tryServer;
                port = tryPort;
                System.out.println("========================================");
                System.out.println("  ZY音乐服务已启动");
                System.out.println("========================================");
                System.out.println("  本机访问: http://localhost:" + port);
                System.out.println("  公网访问: https://zymusic.loca.lt");
                System.out.println("========================================");
                return;
            } catch (BindException be) {
                lastError = be;
                try { tryServer.stop(); } catch (Exception ignored) {}
            } catch (IOException ioe) {
                // Jetty wraps BindException in IOException with "Failed to bind" message
                if (ioe.getCause() instanceof BindException
                    || (ioe.getMessage() != null && ioe.getMessage().contains("Failed to bind"))) {
                    lastError = ioe;
                    try { tryServer.stop(); } catch (Exception ignored) {}
                } else {
                    try { tryServer.stop(); } catch (Exception ignored) {}
                    throw ioe;
                }
            } catch (Exception e) {
                try { tryServer.stop(); } catch (Exception ignored) {}
                throw e;
            }
        }
        throw new BindException("无法绑定端口 (尝试范围: " + startPort + " - " + (maxPort - 1) + ")，所有端口均被占用。最后错误: " + (lastError != null ? lastError.getMessage() : "未知"));
    }

    private String getLocalLanIP() {
        try {
            java.net.InetAddress localAddress = java.net.InetAddress.getLocalHost();
            // 查找局域网IP（通常以192.168或10.开头）
            java.net.NetworkInterface networkInterface = java.net.NetworkInterface.getByInetAddress(localAddress);
            if (networkInterface != null) {
                java.util.Enumeration<java.net.InetAddress> addresses = networkInterface.getInetAddresses();
                while (addresses.hasMoreElements()) {
                    java.net.InetAddress addr = addresses.nextElement();
                    if (!addr.isLoopbackAddress() && addr instanceof java.net.Inet4Address) {
                        String ip = addr.getHostAddress();
                        if (ip.startsWith("192.168.") || ip.startsWith("10.")) {
                            return ip;
                        }
                    }
                }
            }
        } catch (Exception e) {
        }
        return null;
    }

    public synchronized void stop() throws Exception {
        if (server != null) {
            server.stop();
            server = null;
        }
    }

    public int getPort() {
        return port;
    }

    public String getBaseUrl() {
        return "http://localhost:" + port;
    }

    public boolean isRunning() {
        return server != null && server.isStarted();
    }

    private int findAvailablePort(int preferred) {
        for (int p = preferred; p < preferred + 10; p++) {
            try (java.net.ServerSocket socket = new java.net.ServerSocket(p)) {
                return p;
            } catch (java.io.IOException ignored) {
            }
        }
        System.err.println("警告: 端口 " + preferred + " 至 " + (preferred + 9) + " 均被占用");
        return preferred;
    }
}
