# 🎵 ZYMusic (ZY音乐)

一个基于 Java 的全栈音乐应用，支持 Web 端与桌面端 (JavaFX)，具备音乐播放、社区互动、歌单管理等完整功能。

## ✨ 功能特性

### 🎧 音乐播放器
- 音乐上传与管理（支持 FLAC 转码）
- 在线流媒体播放
- 音乐下载
- 歌单创建、编辑与管理
- 音乐搜索

### 👥 社区系统
- 社区动态发布与浏览
- 帖文点赞
- 评论互动
- 用户个人主页
- 消息通知系统

### 📱 PWA 支持
- 支持安装到移动设备桌面
- 离线访问支持
- 响应式设计，适配手机与电脑

### 🖥️ 桌面客户端
- 基于 JavaFX 的独立桌面应用
- 内嵌 Jetty 服务器，一键启动
- 系统托盘支持

## 🛠️ 技术栈

| 层级 | 技术 |
|------|------|
| **语言** | Java 17, JSP, JavaScript |
| **后端框架** | Jetty 9.4, Tomcat Embed 9 |
| **桌面框架** | JavaFX 17 |
| **数据库** | H2, SQLite |
| **构建工具** | Maven |
| **前端** | JSP, HTML5, CSS3, Service Worker (PWA) |
| **音频处理** | JFLAC, FFmpeg |

## 📁 项目结构

```
ZYmusic(2)/
├── ZYmusic/                    # 主项目（Maven）
│   ├── src/main/java/         # Java 源码
│   │   └── com/zjlymusic/
│   │       ├── app/           # 应用入口 (DesktopApp, AppLauncher)
│   │       ├── dao/           # 数据访问层
│   │       ├── entity/        # 实体类
│   │       ├── service/       # 业务逻辑层
│   │       ├── servlet/       # HTTP 控制器
│   │       └── util/          # 工具类 (服务器、数据库、音频)
│   ├── src/main/webapp/       # Web 前端 (JSP + JS + CSS)
│   ├── tools/                 # 辅助脚本
│   └── pom.xml                # Maven 配置
├── ZYMusic-Desktop/           # 桌面端打包
│   └── ZY音乐/
│       ├── app/               # 依赖 JAR 包
│       ├── tools/             # ffmpeg
│       ├── webapp/            # Web 资源
│       └── 启动.bat            # 启动脚本
├── tools/                     # Python 工具脚本
├── 安装教程.txt               # 安装说明
└── README.md
```

## 🚀 快速开始

### 环境要求
- JDK 21（项目中已附带 `jdk21/` 目录）
- Maven 3.6+
- FFmpeg（用于音频转码，需单独下载放入 `tools/` 目录）

### 运行方式

**方式一：桌面客户端**
```bash
# 使用项目自带的 JDK 启动
双击 ZYMusic-Desktop/ZY音乐/启动.bat
```

**方式二：命令行启动**
```bash
cd ZYmusic
mvn clean package -DskipTests
java -jar target/ZYMusic.jar
```

**方式三：Web 模式**
```bash
cd ZYmusic
mvn jetty:run
# 访问 http://localhost:8080
```

## 📝 数据处理脚本

项目还包含以下 Python 辅助脚本：

| 脚本 | 功能 |
|------|------|
| `generate_report.py` | 数据报告生成 |
| `rewrite_report.py` | 报告重写 |
| `modify_docx.py` | Word 文档修改 |
| `gen_roadmap.py` | 技术路线图生成 |
| `tech_roadmap.py` | 技术路线图工具 |
| `tools/gen_notify_bar.py` | 通知栏生成 |

## ⚠️ 免责声明

本项目仅供学习交流使用。由于无法获得免费公网 IP，各设备拥有独立的数据库和账号系统。

## 📄 License

MIT License

---

**作者**: Zhou-Jie-0604
**仓库**: https://github.com/Zhou-Jie-0604/zymusic
