package com.zjlymusic.util;

public class ServerMain {
    public static void main(String[] args) throws Exception {
        EmbeddedServer server = EmbeddedServer.getInstance();
        server.start();
        System.out.println("访问地址: " + server.getBaseUrl());
        Thread.currentThread().join();
    }
}
