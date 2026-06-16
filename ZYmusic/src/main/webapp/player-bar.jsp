<!-- Global Player Bar -->
<div id="globalPlayerBar">
  <div class="pb-progress"><div class="pb-progress-fill"></div></div>
  <div class="pb-cover">
    <img class="pb-cover-img" src="files/covers/default-cover.svg" alt="">
  </div>
  <div class="pb-info">
    <div class="pb-song-name">快来体验一下ZY音乐吧</div>
    <div class="pb-artist-name"></div>
  </div>
  <button class="pb-play-btn" title="播放/暂停">
    <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor"><polygon points="8,5 19,12 8,19"/></svg>
  </button>
  <button class="pb-notify-btn" id="notifyBtn" title="消息" onclick="location.href='notifications'">
    <span class="pb-notify-text">&#28040;&#24687;</span>
  </button>
</div>
<script src="js/player-bar.js"></script>
