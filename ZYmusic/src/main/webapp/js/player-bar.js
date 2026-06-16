// Global Player Bar - single shared Audio across all pages
(function() {
  if (window.__playerBarInit) return;
  window.__playerBarInit = true;

  var bar = document.getElementById('globalPlayerBar');
  if (!bar) return;

  var coverImg = bar.querySelector('.pb-cover-img');
  var songName = bar.querySelector('.pb-song-name');
  var artistName = bar.querySelector('.pb-artist-name');
  var playBtn = bar.querySelector('.pb-play-btn');
  var progressFill = bar.querySelector('.pb-progress-fill');

  // The ONE shared audio element
  var audio = new Audio();
  audio.preload = 'auto';
  audio.volume = parseFloat(localStorage.getItem('zymusic_vol') || '0.7');

  var currentSong = null;
  var isPlaying = false;
  var playlist = [];
  var serverDuration = 0;

  function getEffectiveDuration() {
    var ad = (audio.duration && isFinite(audio.duration) && audio.duration > 0) ? audio.duration : 0;
    var sd = (serverDuration && serverDuration > 0) ? serverDuration : 0;
    return Math.max(ad, sd);
  }

  // Expose audio for player.js
  window.getPlayerAudio = function() { return audio; };
  window.isPlayerPlaying = function() { return isPlaying; };
  window.getCurrentSong = function() { return currentSong; };

  function updateProgress() {
    if (!audio || !progressFill) return;
    var effective = getEffectiveDuration();
    if (effective <= 0) return;
    var pct = Math.min((audio.currentTime / effective) * 100, 100);
    progressFill.style.width = pct + '%';
    localStorage.setItem('zymusic_time', audio.currentTime);
  }

  function updatePlayBtn() {
    if (!playBtn) return;
    playBtn.innerHTML = isPlaying
      ? '<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><rect x="6" y="4" width="4" height="16"/><rect x="14" y="4" width="4" height="16"/></svg>'
      : '<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><polygon points="8,5 19,12 8,19"/></svg>';
    if (coverImg) coverImg.classList.toggle('playing', isPlaying);
  }

  function onEnded() {
    if (!playlist.length) return;
    var idx = currentSong ? playlist.findIndex(function(s) { return s.id === currentSong.id; }) : -1;
    if (idx < 0) idx = 0;
    var next = (idx + 1) % playlist.length;
    window.playSong(playlist[next], next);
  }

  function getFullUrl(path) {
    if (!path) return '';
    if (path.indexOf('http') === 0) return path;
    var base = window.location.origin;
    if (path.indexOf('music/') === 0 || path.indexOf('avatars/') === 0 || path.indexOf('covers/') === 0 || path.indexOf('backgrounds/') === 0) {
      return base + '/files/' + path;
    }
    return base + '/' + path;
  }

  function updateUI(song) {
    if (!song) {
      if (songName) songName.textContent = '快来体验一下ZY音乐吧';
      if (artistName) artistName.textContent = '';
      if (coverImg) coverImg.src = 'files/covers/default-cover.svg';
      if (progressFill) progressFill.style.width = '0%';
      bar.classList.remove('active');
      return;
    }
    bar.classList.add('active');
    if (songName) songName.textContent = song.name || '未知歌曲';
    if (artistName) artistName.textContent = song.artist || '未知歌手';
    if (coverImg && song.cover) {
      coverImg.src = getFullUrl(song.cover);
    } else if (coverImg) {
      coverImg.src = 'files/covers/default-cover.svg';
    }
  }

  function saveState() {
    if (!currentSong) return;
    try {
      localStorage.setItem('zymusic_song', JSON.stringify({
        id: currentSong.id, name: currentSong.name, artist: currentSong.artist,
        url: currentSong.url, cover: currentSong.cover, duration: currentSong.duration
      }));
      localStorage.setItem('zymusic_playlist', JSON.stringify(playlist));
      localStorage.setItem('zymusic_playing', isPlaying ? '1' : '0');
      localStorage.setItem('zymusic_vol', String(audio.volume));
      localStorage.setItem('zymusic_time', String(audio.currentTime));
    } catch(e) {}
  }

  // Public API
  window.playSong = function(song, index) {
    if (!song || !song.url) return;
    currentSong = song;
    serverDuration = (song.duration && song.duration > 0) ? song.duration : 0;
    if (index >= 0) {
      try { localStorage.setItem('zymusic_current_index', index); } catch(e) {}
    }
    var url = getFullUrl(song.url);
    if (audio.src !== url || audio.readyState === 0) {
      audio.src = url;
      audio.load();
    }
    audio.play().then(function() {
      isPlaying = true;
      updatePlayBtn();
      updateUI(song);
    }).catch(function(e) {
      console.log('Play failed:', e);
      isPlaying = false;
      updatePlayBtn();
      updateUI(song);
    });
    saveState();
  };

  window.togglePlayPause = function() {
    if (!currentSong) return;
    if (isPlaying) {
      audio.pause();
    } else {
      audio.play().catch(function(e) {});
    }
    saveState();
  };

  window.getPlayerPlaylist = function() { return playlist; };

  window.setPlayerServerDuration = function(d) {
    if (d && d > 0) serverDuration = d;
  };

  window.setPlayerPlaylist = function(list, startIndex) {
    playlist = list || [];
    if (startIndex >= 0 && playlist[startIndex]) {
      window.playSong(playlist[startIndex], startIndex);
    }
    renderPlaylist();
  };

  function renderPlaylist() {
    if (!playlistPanel) return;
    var panelList = playlistPanel.querySelector('.pb-list');
    if (!panelList) return;
    if (!playlist.length) {
      panelList.innerHTML = '<div class="pb-list-empty">&#26242;&#26080;&#27468;&#26354;</div>';
      return;
    }
    var html = '';
    for (var i = 0; i < playlist.length; i++) {
      var s = playlist[i];
      var isCurrent = currentSong && currentSong.id === s.id;
      html += '<div class="pb-list-item' + (isCurrent ? ' active' : '') + '" onclick="window.playSong(window.getPlayerPlaylist()[' + i + '], ' + i + ');window.closePlaylist();">' +
        '<span class="pb-list-idx">' + (i + 1) + '</span>' +
        '<span class="pb-list-info"><span class="pb-list-name">' + (s.name||'') + '</span><span class="pb-list-artist">' + (s.artist||'') + '</span></span>' +
        (isCurrent ? '<span class="pb-list-playing">♫</span>' : '') +
        '</div>';
    }
    panelList.innerHTML = html;
  }

  // Keep old function names for backward compat
  window.togglePlaylist = function() {};
  window.closePlaylist = function() {};

  // Audio events
  audio.addEventListener('loadedmetadata', function() {
    if (audio.duration && isFinite(audio.duration) && audio.duration > 0) {
      if (serverDuration <= 0 || audio.duration > serverDuration) {
        serverDuration = audio.duration;
      }
    }
  });
  audio.addEventListener('timeupdate', updateProgress);
  audio.addEventListener('ended', onEnded);
  audio.addEventListener('play', function() { isPlaying = true; updatePlayBtn(); });
  audio.addEventListener('pause', function() { isPlaying = false; updatePlayBtn(); });
  audio.addEventListener('error', function(e) {
    console.log('Audio error:', audio.error);
    isPlaying = false;
    updatePlayBtn();
  });

  // Restore state on page load
  function restore() {
    try {
      var rawSong = localStorage.getItem('zymusic_song');
      var rawList = localStorage.getItem('zymusic_playlist');
      var wasPlaying = localStorage.getItem('zymusic_playing') === '1';
      var savedTime = parseFloat(localStorage.getItem('zymusic_time') || '0');
      var vol = parseFloat(localStorage.getItem('zymusic_vol') || '0.7');
      audio.volume = vol;
      if (rawSong) {
        currentSong = JSON.parse(rawSong);
        serverDuration = (currentSong.duration && currentSong.duration > 0) ? currentSong.duration : 0;
        playlist = rawList ? JSON.parse(rawList) : [currentSong];
        updateUI(currentSong);
        var url = getFullUrl(currentSong.url);
        audio.src = url;
        if (savedTime > 0) {
          audio.addEventListener('loadedmetadata', function seek() {
            if (savedTime > 0 && savedTime < audio.duration) audio.currentTime = savedTime;
            audio.removeEventListener('loadedmetadata', seek);
          });
        }
        if (wasPlaying) {
          audio.play().then(function() {
            isPlaying = true;
            updatePlayBtn();
          }).catch(function() {
            isPlaying = false;
            updatePlayBtn();
          });
        } else {
          updatePlayBtn();
        }
        renderPlaylist();
      }
    } catch(e) {
      updatePlayBtn();
    }
  }

  // Save on unload
  window.addEventListener('beforeunload', function() { saveState(); });

  // Buttons
  if (playBtn) playBtn.addEventListener('click', function(e) { e.stopPropagation(); window.togglePlayPause(); });
  // notifyBtn navigates via onclick in HTML

  // Close playlist on outside click
  // Notification panel replaced by separate page

  // Click info area -> go to play page
  var infoArea = bar.querySelector('.pb-info');
  if (infoArea) {
    infoArea.addEventListener('click', function() {
      if (currentSong && currentSong.id) {
        window.location.href = 'playMusic?id=' + currentSong.id;
      }
    });
  }

  restore();
})();
