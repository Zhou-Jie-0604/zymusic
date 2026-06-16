<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.zjlymusic.entity.User" %>
<%@ page import="com.zjlymusic.entity.Music" %>
<%@ page import="com.zjlymusic.entity.Playlist" %>
<%@ page import="com.zjlymusic.service.MusicService" %>
<%@ page import="com.zjlymusic.service.PlaylistService" %>
<%@ page import="java.util.List" %>
<%
    List<Music> latestMusics = new MusicService().getLatestMusic(8);
    User sessionUser = (User) session.getAttribute("user");
    List<Playlist> userPlaylists = null;
    if (sessionUser != null) {
        userPlaylists = new PlaylistService().getPlaylistsByUserId(sessionUser.getId());
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>ZY音乐</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <%@ include file="pwa-head.jsp" %>
    <meta name="theme-color" content="#1a1a2e">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-title" content="ZY音乐">
    <link rel="manifest" href="manifest.json">
    <link rel="stylesheet" type="text/css" href="css/style.css">
    <link rel="stylesheet" type="text/css" href="css/app.css">
    <style>
        body { background: #000; }
        .header, .footer, .main-content { position: relative; z-index: 10; }
    </style>
</head>
<body class="has-player-bar">
    <div style="position:fixed;top:0;left:0;width:100%;height:100%;background:#000;z-index:0;"></div>
    <canvas id="homeBgCanvas" style="position:fixed;top:0;left:0;width:100%;height:100%;z-index:0;pointer-events:none;"></canvas>

    <header class="header">
        <h1 class="title">ZY音乐</h1>
        <nav class="nav">
            <a href="index.jsp">首页</a>
            <a href="community">社区</a>
            <a href="upload.jsp">上传歌曲</a>
            <a href="profile">个人主页</a>
            <%
                User user = (User) session.getAttribute("user");
                if (user != null) {
            %>
                <a href="logout">退出登录</a>
            <% } else { %>
                <a href="login.jsp">登录</a>
            <% } %>
        </nav>
    </header>

    <main class="main-content">
        <div class="feature-section">
            <div class="feature-card" onclick="location.href='upload.jsp'">
                <h3>上传歌曲</h3>
                <p>分享你的音乐作品</p>
            </div>
            <div class="feature-card" onclick="location.href='playMusic'">
                <h3>播放音乐</h3>
                <p>畅听海量歌曲</p>
            </div>
            <div class="feature-card" onclick="location.href='community'">
                <h3>社区互动</h3>
                <p>与音乐爱好者交流</p>
            </div>
            <div class="feature-card" onclick="showSearchModal()">
                <h3>在线搜索</h3>
                <p>搜索歌曲和歌手</p>
            </div>
        </div>

        <div class="music-list">
            <h2>最新上传</h2>
            <div class="music-grid home-music-grid">
                <% if (latestMusics != null && !latestMusics.isEmpty()) {
                    for (Music music : latestMusics) {
                %>
                    <div class="music-item home-music-item" onclick="location.href='playMusic?id=<%= music.getId() %>'">
                        <% if (music.getCoverUrl() != null) { %>
                            <img class="album-cover" src="<%= music.getCoverUrl() %>" alt="<%= music.getName() %>">
                        <% } else { %>
                            <div class="album-cover default-cover"></div>
                        <% } %>
                        <span class="music-name"><%= music.getName() %></span>
                        <% if (music.getArtist() != null && !music.getArtist().isEmpty()) { %>
                            <span class="music-artist"><%= music.getArtist() %></span>
                        <% } %>
                        <% if (sessionUser != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
                            <span class="add-to-playlist-btn" onclick="event.stopPropagation(); showPlaylistModal(<%= music.getId() %>)">+</span>
                        <% } %>
                    </div>
                <%  }
                   } else { %>
                    <p class="empty-tip">暂无音乐，快去上传第一首吧！</p>
                <% } %>
            </div>
        </div>
    </main>

    <div class="search-modal" id="searchModal">
        <div class="search-modal-content">
            <div class="search-header">
                <h3>在线搜索</h3>
                <span class="search-close" onclick="closeSearchModal()">&times;</span>
            </div>
            <div class="search-input-container">
                <input type="text" id="searchInput" placeholder="输入歌曲名或歌手名..." onkeydown="if(event.keyCode===13)doHomeSearch()">
                <button onclick="doHomeSearch()" style="padding:10px 24px;border:none;border-radius:25px;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:#fff;cursor:pointer;margin-left:8px;">搜索</button>
            </div>
        </div>
    </div>

    <style>
        .search-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.7); z-index: 2000; justify-content: center; align-items: center; }
        .search-modal.active { display: flex; }
        .search-modal-content { background: #1a1a2e; padding: 25px; border-radius: 15px; width: 600px; max-width: 90%; max-height: 80vh; overflow-y: auto; }
        .search-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .search-header h3 { color: #fff; margin: 0; }
        .search-close { color: #888; font-size: 28px; cursor: pointer; }
        .search-close:hover { color: #fff; }
        .search-input-container input { width: 100%; padding: 12px 20px; border-radius: 25px; border: none; background: rgba(255, 255, 255, 0.1); color: #fff; font-size: 16px; outline: none; }
        .search-input-container input::placeholder { color: #888; }
        .search-results { margin-top: 20px; }
        .search-hint { color: #888; text-align: center; padding: 20px; }
        .search-result-item { display: flex; align-items: center; padding: 12px; border-radius: 8px; margin-bottom: 10px; background: rgba(255, 255, 255, 0.05); cursor: pointer; }
        .search-result-item:hover { background: rgba(255, 255, 255, 0.15); }
        .search-result-cover { width: 50px; height: 50px; border-radius: 8px; margin-right: 15px; object-fit: cover; }
        .search-result-cover-placeholder { width: 50px; height: 50px; border-radius: 8px; margin-right: 15px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); display: flex; align-items: center; justify-content: center; color: white; font-size: 20px; }
        .search-result-info { flex: 1; }
        .search-result-name { color: #fff; font-size: 16px; }
        .search-result-artist { color: #888; font-size: 12px; margin-top: 5px; }
    </style>

    <footer class="footer">
        <p>© 2026 ZY音乐 畅享世界</p>
    </footer>

    <% if (sessionUser != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
    <style>
        .add-to-playlist-btn { position: absolute; top: 10px; right: 10px; width: 24px; height: 24px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; opacity: 0; transition: opacity 0.3s; font-size: 16px; line-height: 1; }
        .music-item:hover .add-to-playlist-btn { opacity: 1; }
        .music-item { position: relative; }
        .playlist-modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0, 0, 0, 0.7); z-index: 2000; justify-content: center; align-items: center; }
        .playlist-modal.active { display: flex; }
        .playlist-modal-content { background: #1a1a2e; padding: 25px; border-radius: 15px; width: 350px; max-width: 90%; }
        .playlist-modal-content h3 { color: #fff; margin-bottom: 15px; }
        .playlist-option { display: block; padding: 12px 15px; color: #fff; text-decoration: none; border-radius: 8px; margin-bottom: 5px; transition: background 0.3s; }
        .playlist-option:hover { background: rgba(255, 255, 255, 0.1); }
        .modal-close { color: #888; cursor: pointer; margin-top: 15px; text-align: center; display: block; }
    </style>
    <div class="playlist-modal" id="playlistModal">
        <div class="playlist-modal-content">
            <h3>添加到歌单</h3>
            <div id="playlistOptions">
                <% for (Playlist p : userPlaylists) { %>
                    <a class="playlist-option" href="javascript:void(0)" onclick="addToPlaylist(<%= p.getId() %>)"><%= p.getName() %></a>
                <% } %>
            </div>
            <a href="playlist" class="modal-close">管理歌单</a>
            <span class="modal-close" onclick="closePlaylistModal()">取消</span>
        </div>
    </div>
    <% } %>

    <script>
        function showSearchModal() {
            document.getElementById('searchModal').classList.add('active');
            document.getElementById('searchInput').focus();
        }
        function closeSearchModal() {
            document.getElementById('searchModal').classList.remove('active');
        }
        function doHomeSearch() {
            var keyword = document.getElementById('searchInput').value.trim();
            if (!keyword) return;
            location.href = 'community?keyword=' + encodeURIComponent(keyword);
        }
        document.getElementById('searchModal').addEventListener('click', function(e) {
            if (e.target === this) { closeSearchModal(); }
        });
    </script>

    <script src="js/pwa.js"></script>
    <script>
    (function() {
        var canvas = document.getElementById('homeBgCanvas');
        if (!canvas) return;
        var ctx = canvas.getContext('2d');
        var W, H;
        var snowflakes = [];
        var particles = [];
        var time = 0;

        function resize() {
            W = canvas.width = window.innerWidth;
            H = canvas.height = window.innerHeight;
        }
        resize();
        window.addEventListener('resize', resize);

        // --- Snowflake class ---
        function Snowflake() {
            this.reset(true);
        }
        Snowflake.prototype.reset = function(init) {
            this.x = Math.random() * W * 1.1 - W * 0.05;
            this.y = init ? Math.random() * H : -20 - Math.random() * 80;
            this.size = 6 + Math.random() * 20;
            this.speedY = 0.6 + Math.random() * 2.2;
            this.speedX = (Math.random() - 0.5) * 0.8;
            this.opacity = 0.35 + Math.random() * 0.6;
            this.rotation = Math.random() * Math.PI * 2;
            this.rotSpeed = (Math.random() - 0.5) * 0.015;
            this.wobbleAmp = 0.4 + Math.random() * 2.0;
            this.wobbleSpeed = 0.008 + Math.random() * 0.025;
            this.wobblePhase = Math.random() * Math.PI * 2;
        };
        Snowflake.prototype.update = function() {
            this.y += this.speedY;
            this.wobblePhase += this.wobbleSpeed;
            this.x += this.speedX + Math.sin(this.wobblePhase) * this.wobbleAmp;
            this.rotation += this.rotSpeed;
            if (this.y > H + 40) this.reset(false);
            if (this.x < -30) this.x = W + 20;
            if (this.x > W + 30) this.x = -20;
        };
        function drawSnowflake(ctx, x, y, s, rot, alpha) {
            ctx.save();
            ctx.globalAlpha = alpha;
            ctx.translate(x, y);
            ctx.rotate(rot);
            ctx.fillStyle = '#ffffff';
            ctx.strokeStyle = 'rgba(220,235,255,0.7)';
            ctx.lineWidth = s * 0.04;
            // 6 arms of the snowflake
            for (var arm = 0; arm < 6; arm++) {
                ctx.save();
                ctx.rotate((Math.PI / 3) * arm);
                // Main arm
                ctx.beginPath();
                ctx.moveTo(0, 0);
                ctx.lineTo(0, -s * 0.5);
                ctx.stroke();
                // Branch left
                ctx.beginPath();
                ctx.moveTo(0, -s * 0.18);
                ctx.lineTo(-s * 0.12, -s * 0.32);
                ctx.stroke();
                // Branch right
                ctx.beginPath();
                ctx.moveTo(0, -s * 0.18);
                ctx.lineTo(s * 0.12, -s * 0.32);
                ctx.stroke();
                // Branch left (outer)
                ctx.beginPath();
                ctx.moveTo(0, -s * 0.33);
                ctx.lineTo(-s * 0.1, -s * 0.44);
                ctx.stroke();
                // Branch right (outer)
                ctx.beginPath();
                ctx.moveTo(0, -s * 0.33);
                ctx.lineTo(s * 0.1, -s * 0.44);
                ctx.stroke();
                // Tip dot
                ctx.fillStyle = 'rgba(255,255,255,0.85)';
                ctx.beginPath();
                ctx.arc(0, -s * 0.5, s * 0.05, 0, Math.PI * 2);
                ctx.fill();
                ctx.restore();
            }
            // Center dot
            ctx.fillStyle = 'rgba(255,255,255,0.9)';
            ctx.beginPath();
            ctx.arc(0, 0, s * 0.07, 0, Math.PI * 2);
            ctx.fill();
            // Soft outer glow
            var grd = ctx.createRadialGradient(0, 0, s * 0.05, 0, 0, s * 0.55);
            grd.addColorStop(0, 'rgba(220,240,255,0.3)');
            grd.addColorStop(1, 'rgba(255,255,255,0)');
            ctx.fillStyle = grd;
            ctx.beginPath();
            ctx.arc(0, 0, s * 0.55, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        }

        // --- Particle class (light sparkles on water) ---
        function Particle() {
            this.reset(true);
        }
        Particle.prototype.reset = function(init) {
            this.x = Math.random() * W;
            this.y = H * 0.55 + Math.random() * H * 0.45;
            this.baseY = this.y;
            this.size = 0.5 + Math.random() * 2.5;
            this.opacity = 0.15 + Math.random() * 0.55;
            this.phase = Math.random() * Math.PI * 2;
            this.speed = 0.01 + Math.random() * 0.04;
            this.driftX = (Math.random() - 0.5) * 0.3;
            this.driftY = (Math.random() - 0.5) * 0.2;
        };
        Particle.prototype.update = function() {
            this.phase += this.speed;
            this.x += this.driftX;
            this.y = this.baseY + Math.sin(this.phase) * 3;
        };
        Particle.prototype.draw = function(ctx) {
            ctx.save();
            ctx.globalAlpha = this.opacity;
            var grd = ctx.createRadialGradient(this.x, this.y, 0, this.x, this.y, this.size * 3);
            grd.addColorStop(0, 'rgba(220,235,255,0.9)');
            grd.addColorStop(0.3, 'rgba(180,210,255,0.4)');
            grd.addColorStop(1, 'rgba(255,255,255,0)');
            ctx.fillStyle = grd;
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size * 3, 0, Math.PI * 2);
            ctx.fill();
            ctx.fillStyle = 'rgba(255,255,255,0.95)';
            ctx.beginPath();
            ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
            ctx.fill();
            ctx.restore();
        };

        // Initialize
        var snowflakeCount = Math.min(60, Math.floor(W / 20));
        for (var i = 0; i < snowflakeCount; i++) snowflakes.push(new Snowflake());
        var particleCount = Math.min(120, Math.floor(W / 12));
        for (var j = 0; j < particleCount; j++) particles.push(new Particle());

        // --- Water ripple layers ---
        var rippleLayers = [];
        for (var k = 0; k < 5; k++) {
            rippleLayers.push({
                amplitude: 15 + Math.random() * 40,
                frequency: 0.003 + Math.random() * 0.008,
                speed: 0.3 + Math.random() * 0.8,
                phase: Math.random() * Math.PI * 2,
                opacity: 0.03 + Math.random() * 0.06,
                yOffset: H * 0.45 + Math.random() * H * 0.5
            });
        }

        function drawWaterSurface() {
            // Deep blue gradient background
            var skyGrd = ctx.createLinearGradient(0, 0, 0, H);
            skyGrd.addColorStop(0, '#7eb8da');
            skyGrd.addColorStop(0.25, '#5a9fc4');
            skyGrd.addColorStop(0.5, '#1a4a6e');
            skyGrd.addColorStop(0.75, '#0a2848');
            skyGrd.addColorStop(1, '#040f1e');
            ctx.fillStyle = skyGrd;
            ctx.fillRect(0, 0, W, H);

            // Ripple/wave layers
            for (var r = 0; r < rippleLayers.length; r++) {
                var layer = rippleLayers[r];
                ctx.save();
                ctx.globalAlpha = layer.opacity;
                ctx.strokeStyle = '#c8dff5';
                ctx.lineWidth = 1.5;
                ctx.beginPath();
                var wavY = layer.yOffset;
                for (var x = 0; x <= W; x += 2) {
                    var y = wavY + Math.sin(x * layer.frequency + time * 0.02 * layer.speed + layer.phase) * layer.amplitude;
                    if (x === 0) ctx.moveTo(x, y);
                    else ctx.lineTo(x, y);
                }
                ctx.stroke();
                ctx.restore();
            }

            // Subtle light streaks (god rays)
            ctx.save();
            ctx.globalAlpha = 0.03;
            for (var g = 0; g < 8; g++) {
                var gx = W * (0.1 + g * 0.1);
                var grd2 = ctx.createLinearGradient(gx, 0, gx + 80, H);
                grd2.addColorStop(0, 'rgba(255,255,255,0.5)');
                grd2.addColorStop(0.4, 'rgba(200,220,255,0.1)');
                grd2.addColorStop(1, 'rgba(255,255,255,0)');
                ctx.fillStyle = grd2;
                ctx.fillRect(gx - 40 + Math.sin(time * 0.005 + g) * 50, 0, 120 + Math.random() * 60, H);
            }
            ctx.restore();

            // Large ambient light orbs deep underwater
            for (var o = 0; o < 5; o++) {
                var ox = W * (0.1 + o * 0.2 + Math.sin(time * 0.003 + o) * 0.05);
                var oy = H * (0.6 + o * 0.08);
                var orbGrd = ctx.createRadialGradient(ox, oy, 0, ox, oy, 200 + o * 50);
                orbGrd.addColorStop(0, 'rgba(140,200,240,0.06)');
                orbGrd.addColorStop(1, 'rgba(0,0,0,0)');
                ctx.fillStyle = orbGrd;
                ctx.beginPath();
                ctx.arc(ox, oy, 200 + o * 50, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        function animate() {
            time++;
            ctx.clearRect(0, 0, W, H);

            drawWaterSurface();

            // Draw particles first (behind snowflakes)
            for (var p = 0; p < particles.length; p++) {
                particles[p].update();
                particles[p].draw(ctx);
            }

            // Update and draw snowflakes
            for (var s = 0; s < snowflakes.length; s++) {
                snowflakes[s].update();
                var sf = snowflakes[s];
                drawSnowflake(ctx, sf.x, sf.y, sf.size, sf.rotation, sf.opacity);
            }

            requestAnimationFrame(animate);
        }

        // Handle canvas resize when butterflies/particles need repositioning
        window.addEventListener('resize', function() {
            resize();
            // Adjust ripple layer positions
            for (var r = 0; r < rippleLayers.length; r++) {
                rippleLayers[r].yOffset = H * 0.45 + Math.random() * H * 0.5;
            }
        });

        animate();
    })();
    </script>

    <% if (sessionUser != null && userPlaylists != null && !userPlaylists.isEmpty()) { %>
    <script>
        function showPlaylistModal(musicId) {
            window.currentMusicIdForPlaylist = musicId;
            document.getElementById('playlistModal').classList.add('active');
        }
        function closePlaylistModal() {
            document.getElementById('playlistModal').classList.remove('active');
        }
        function addToPlaylist(playlistId) {
            var musicId = window.currentMusicIdForPlaylist;
            if (!musicId) return;
            fetch('playlist?action=addMusic&playlistId=' + playlistId + '&musicId=' + musicId, {
                method: 'POST',
                headers: { 'X-Requested-With': 'XMLHttpRequest' }
            })
                .then(function(response) {
                    if (response.ok) { closePlaylistModal(); alert('已添加到歌单'); }
                })
                .catch(function(err) { console.error(err); closePlaylistModal(); });
        }
        window.onclick = function(e) {
            if (e.target.id === 'playlistModal') { closePlaylistModal(); }
        }
    </script>
    <% } %>
  <%@ include file="notify-bar.jsp" %>
</body>
</html>
