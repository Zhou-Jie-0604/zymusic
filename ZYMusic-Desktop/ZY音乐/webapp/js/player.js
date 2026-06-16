// Player page JS - uses the shared global Audio from player-bar.js
document.addEventListener("DOMContentLoaded", function() {
    var playBtn = document.getElementById("playBtn");
    var prevBtn = document.getElementById("prevBtn");
    var nextBtn = document.getElementById("nextBtn");
    var progressBar = document.getElementById("progressBar");
    var volumeBar = document.getElementById("volumeBar");
    var volumeIcon = document.getElementById("volumeIcon");
    var currentTimeEl = document.getElementById("currentTime");
    var totalTimeEl = document.getElementById("totalTime");
    var vinylRecord = document.getElementById("vinylRecord");
    var coverImage = document.getElementById("coverImage");
    var playModeBtn = document.getElementById("playModeBtn");

    var baseUrl = window.location.origin;
    var songs = (window.playlistData && window.playlistData.length > 0)
        ? window.playlistData
        : [{ name: "暂无歌曲", artist: "-", url: "", duration: 0, cover: "" }];

    // Use the shared global audio element
    var audio = window.getPlayerAudio ? window.getPlayerAudio() : new Audio();
    audio.preload = "auto";
    var isPlaying = false;
    var currentSongIndex = window.initialSongIndex || 0;
    var serverDuration = 0;
    var isLoading = false;
    var isBuffering = false;

    // 0=循环播放, 1=顺序播放, 2=随机播放
    var playMode = 0;
    var playModeTitles = ['循环播放', '顺序播放', '随机播放'];
    var playModeIcons = [
        '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 2l3 3-3 3"/><path d="M7 22l-3-3 3-3"/><path d="M20 13a8 8 0 0 1-8 8 8 8 0 0 1-8-8 8 8 0 0 1 8-8"/></svg>',
        '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"/><line x1="8" y1="12" x2="21" y2="12"/><line x1="8" y1="18" x2="21" y2="18"/><polyline points="4 12 8 6 8 18"/></svg>',
        '<svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="16 3 21 3 21 8"/><line x1="4" y1="20" x2="21" y2="3"/><polyline points="21 16 21 21 16 21"/><line x1="15" y1="15" x2="21" y2="21"/><line x1="4" y1="4" x2="9" y2="9"/></svg>'
    ];

    audio.volume = (volumeBar ? volumeBar.value : 70) / 100;

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0 || seconds === Infinity) seconds = 0;
        var safeSeconds = Math.floor(seconds);
        var mins = Math.floor(safeSeconds / 60);
        var secs = safeSeconds % 60;
        if (secs < 10) secs = "0" + secs;
        return mins + ":" + secs;
    }

    function getFullUrl(relativePath) {
        if (!relativePath || relativePath.trim() === "") return "";
        if (relativePath.indexOf("http://") === 0 || relativePath.indexOf("https://") === 0) return relativePath;
        if (relativePath.indexOf("music/") === 0 || relativePath.indexOf("avatars/") === 0 || relativePath.indexOf("covers/") === 0) {
            return baseUrl + "/files/" + relativePath;
        }
        return baseUrl + "/" + relativePath;
    }

    function showSpinner() {
        playBtn.innerHTML = '<span class="btn-spinner"></span>';
        playBtn.classList.add("loading");
    }
    function hideSpinner() {
        playBtn.classList.remove("loading");
        updatePlayButton();
    }

    function getEffectiveDuration() {
        var ad = (audio.duration && isFinite(audio.duration) && audio.duration > 0) ? audio.duration : 0;
        var sd = (serverDuration && serverDuration > 0) ? serverDuration : 0;
        return Math.max(ad, sd);
    }

    function updateProgressBar() {
        if (!progressBar) return;
        var effective = getEffectiveDuration();
        if (effective > 0) {
            var pct = Math.min((audio.currentTime / effective) * 100, 100);
            progressBar.value = pct;
            currentTimeEl.textContent = formatTime(audio.currentTime);
            totalTimeEl.textContent = formatTime(effective);
        } else if (isLoading || isBuffering) {
            currentTimeEl.textContent = "0:00";
            totalTimeEl.textContent = isBuffering ? "缓冲中..." : "加载中...";
        }
    }

    function loadSong(index) {
        if (songs.length === 0) return;
        currentSongIndex = ((index % songs.length) + songs.length) % songs.length;
        var song = songs[currentSongIndex];
        document.getElementById("currentSong").textContent = song.name;
        document.getElementById("currentArtist").textContent = song.artist;
        if (coverImage && song.cover) coverImage.src = getFullUrl(song.cover);
        audio.pause();
        isPlaying = false;
        isLoading = false;
        isBuffering = false;
        serverDuration = (song.duration && song.duration > 0) ? song.duration : 0;
        if (window.setPlayerServerDuration) window.setPlayerServerDuration(serverDuration);
        if (currentTimeEl) currentTimeEl.textContent = "0:00";
        if (totalTimeEl) totalTimeEl.textContent = serverDuration > 0 ? formatTime(serverDuration) : "--:--";
        if (progressBar) progressBar.value = 0;
        if (song.url && song.url !== "") {
            audio.src = getFullUrl(song.url);
            audio.currentTime = 0;
            audio.load();
        } else {
            audio.src = "";
        }
        hideSpinner();
        // Sync playlist to global bar (without re-playing, since we already set audio.src)
        if (window.getPlayerPlaylist && window.setPlayerPlaylist) {
            // Don't call setPlayerPlaylist here - it would call playSong and reset audio.src
            // Just update the playlist reference
            try {
                localStorage.setItem('zymusic_playlist', JSON.stringify(songs));
                localStorage.setItem('zymusic_current_index', String(currentSongIndex));
            } catch(e) {}
        }
        if (window.updateLikeForSong && song.id) window.updateLikeForSong(song.id);
        if (window.loadMusicComments && song.id) window.loadMusicComments(song.id);
    }

    function updatePlayButton() {
        if (playBtn.classList.contains("loading")) return;
        playBtn.innerHTML = isPlaying ? "⏸" : "▶";
    }

    function playPause() {
        var song = songs[currentSongIndex];
        if (!song || !song.url || isLoading) return;
        if (isPlaying) {
            audio.pause();
            isPlaying = false;
            hideSpinner();
            if (vinylRecord) vinylRecord.classList.remove("playing");
        } else {
            showSpinner();
            audio.play().then(function() {
                isPlaying = true;
                hideSpinner();
                if (vinylRecord) vinylRecord.classList.add("playing");
            }).catch(function(error) {
                console.log("Play failed:", error);
                isPlaying = false;
                hideSpinner();
            });
        }
    }

    function updatePlayModeUI() {
        playModeBtn.innerHTML = playModeIcons[playMode];
        playModeBtn.title = playModeTitles[playMode];
    }

    function togglePlayMode() {
        playMode = (playMode + 1) % 3;
        updatePlayModeUI();
        localStorage.setItem("playMode", playMode);
    }

    function getNextSongIndex() {
        switch (playMode) {
            case 0: return currentSongIndex;
            case 1: return currentSongIndex + 1 >= songs.length ? -1 : currentSongIndex + 1;
            case 2:
                if (songs.length <= 1) return -1;
                var ri;
                do { ri = Math.floor(Math.random() * songs.length); } while (ri === currentSongIndex && songs.length > 1);
                return ri;
            default: return -1;
        }
    }

    function playNext() {
        var nextIndex = getNextSongIndex();
        if (nextIndex < 0) {
            isPlaying = false;
            hideSpinner();
            if (vinylRecord) vinylRecord.classList.remove("playing");
            return;
        }
        loadSong(nextIndex);
        showSpinner();
        audio.play().then(function() {
            isPlaying = true;
            hideSpinner();
            if (vinylRecord) vinylRecord.classList.add("playing");
        }).catch(function(error) { console.log("Play next failed:", error); });
    }

    function playPrev() {
        loadSong(currentSongIndex - 1);
        showSpinner();
        audio.play().then(function() {
            isPlaying = true;
            hideSpinner();
            if (vinylRecord) vinylRecord.classList.add("playing");
        }).catch(function(error) { console.log("Play prev failed:", error); });
    }

    function setVolume() {
        audio.volume = volumeBar.value / 100;
        updateVolumeIcon();
    }

    function updateVolumeIcon() {
        if (!volumeIcon) return;
        var v = audio.volume;
        if (v === 0) volumeIcon.textContent = '🔇';
        else if (v < 0.33) volumeIcon.textContent = '🔈';
        else if (v < 0.66) volumeIcon.textContent = '🔉';
        else volumeIcon.textContent = '🔊';
    }

    function playSong(index) {
        loadSong(Number(index));
        showSpinner();
        audio.play().then(function() {
            isPlaying = true;
            hideSpinner();
            if (vinylRecord) vinylRecord.classList.add("playing");
        }).catch(function(error) { console.log("Play song failed:", error); });
    }

    var isSeeking = false;

    audio.addEventListener("loadstart", function() {
        isLoading = true;
        showSpinner();
        if (totalTimeEl && serverDuration <= 0) totalTimeEl.textContent = "加载中...";
    });
    audio.addEventListener("loadedmetadata", function() {
        if (audio.duration && isFinite(audio.duration) && audio.duration > 0) {
            if (serverDuration <= 0 || audio.duration > serverDuration) {
                serverDuration = audio.duration;
                if (window.setPlayerServerDuration) window.setPlayerServerDuration(serverDuration);
            }
        }
        isLoading = false;
        hideSpinner();
        updateProgressBar();
    });
    audio.addEventListener("canplay", function() {
        isLoading = false;
        isBuffering = false;
        hideSpinner();
        updateProgressBar();
    });
    audio.addEventListener("waiting", function() {
        isBuffering = true;
        showSpinner();
        if (totalTimeEl) totalTimeEl.textContent = "缓冲中...";
    });
    audio.addEventListener("playing", function() {
        isLoading = false;
        isBuffering = false;
        hideSpinner();
        updateProgressBar();
    });
    audio.addEventListener("error", function() {
        isLoading = false;
        isBuffering = false;
        hideSpinner();
        if (totalTimeEl) totalTimeEl.textContent = "加载失败";
        isPlaying = false;
        updatePlayButton();
        if (vinylRecord) vinylRecord.classList.remove("playing");
    });
    audio.addEventListener("timeupdate", function() { if (!isSeeking) updateProgressBar(); });
    audio.addEventListener("ended", function() { playNext(); });
    audio.addEventListener("play", function() { isPlaying = true; hideSpinner(); if (vinylRecord) vinylRecord.classList.add("playing"); });
    audio.addEventListener("pause", function() { isPlaying = false; hideSpinner(); if (vinylRecord) vinylRecord.classList.remove("playing"); });

    if (playBtn) playBtn.addEventListener("click", playPause);
    if (prevBtn) prevBtn.addEventListener("click", playPrev);
    if (nextBtn) nextBtn.addEventListener("click", playNext);
    if (volumeBar) volumeBar.addEventListener("input", setVolume);

    if (progressBar) {
        progressBar.addEventListener("mousedown", function() { isSeeking = true; if (isPlaying) audio.pause(); });
        progressBar.addEventListener("input", function() {
            var effective = getEffectiveDuration();
            if (effective <= 0) return;
            audio.currentTime = (progressBar.value / 100) * effective;
            currentTimeEl.textContent = formatTime(audio.currentTime);
        });
        progressBar.addEventListener("mouseup", function() { isSeeking = false; });
        progressBar.addEventListener("click", function() {
            var effective = getEffectiveDuration();
            if (effective <= 0) return;
            audio.currentTime = (progressBar.value / 100) * effective;
        });
    }

    var lastVolume = audio.volume;
    if (volumeIcon) {
        volumeIcon.addEventListener("click", function() {
            if (audio.volume > 0) {
                lastVolume = audio.volume;
                audio.volume = 0;
                volumeBar.value = 0;
            } else {
                audio.volume = lastVolume > 0 ? lastVolume : 0.7;
                volumeBar.value = audio.volume * 100;
            }
            updateVolumeIcon();
        });
    }

    var savedPlayMode = localStorage.getItem("playMode");
    if (savedPlayMode !== null) playMode = parseInt(savedPlayMode);
    updatePlayModeUI();

    window.playSong = playSong;
    window.togglePlayMode = togglePlayMode;

    loadSong(currentSongIndex);
});
