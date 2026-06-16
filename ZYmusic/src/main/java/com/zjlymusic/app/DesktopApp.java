package com.zjlymusic.app;

import com.zjlymusic.util.EmbeddedServer;
import javafx.application.Application;
import javafx.application.Platform;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.BorderPane;
import javafx.scene.layout.VBox;
import javafx.scene.web.WebEngine;
import javafx.scene.web.WebView;
import javafx.stage.Stage;

public class DesktopApp extends Application {
    private EmbeddedServer embeddedServer;

    @Override
    public void start(Stage stage) {
        BorderPane root = new BorderPane();
        Label statusLabel = new Label("正在启动 ZY音乐...");
        statusLabel.setStyle("-fx-text-fill: white; -fx-font-size: 14px;");

        VBox loadingBox = new VBox(12, statusLabel);
        loadingBox.setPadding(new Insets(24));
        loadingBox.setStyle("-fx-background-color: linear-gradient(to bottom right, #1a1a2e, #0f3460);");
        root.setCenter(loadingBox);

        Scene scene = new Scene(root, 1280, 800);
        stage.setTitle("ZY音乐");
        stage.setScene(scene);
        stage.setMinWidth(960);
        stage.setMinHeight(640);
        stage.show();

        Thread serverThread = new Thread(() -> {
            try {
                embeddedServer = EmbeddedServer.getInstance();
                embeddedServer.start();
                String url = embeddedServer.getBaseUrl() + "/index.jsp";

                Platform.runLater(() -> {
                    WebView webView = new WebView();
                    WebEngine engine = webView.getEngine();
                    engine.setUserAgent(engine.getUserAgent() + " ZYMusicDesktop/1.0");
                    engine.load(url);
                    root.setCenter(webView);
                    stage.setTitle("ZY音乐 - 桌面版");
                });
            } catch (Exception ex) {
                ex.printStackTrace();
                Platform.runLater(() -> statusLabel.setText("启动失败: " + ex.getMessage()));
            }
        }, "zymusic-server");
        serverThread.setDaemon(true);
        serverThread.start();
    }

    @Override
    public void stop() {
        try {
            if (embeddedServer != null) {
                embeddedServer.stop();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public static void main(String[] args) {
        if (args.length > 0 && "--server-only".equals(args[0])) {
            try {
                EmbeddedServer.getInstance().start();
                EmbeddedServer.getInstance().getBaseUrl();
                Thread.currentThread().join();
            } catch (Exception ex) {
                ex.printStackTrace();
                System.exit(1);
            }
            return;
        }
        launch(args);
    }
}
