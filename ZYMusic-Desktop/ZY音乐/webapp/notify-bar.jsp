<!-- Notification Bar -->
<a href="notifications" style="text-decoration:none;display:block;">
<div id="notifyBar" style="position:fixed;bottom:0;left:0;right:0;z-index:99999;background:rgba(20,20,40,0.92);text-align:center;padding:10px 12px;cursor:pointer;border-top:1px solid rgba(255,255,255,0.08);">
  <span id="notifyBarText" style="color:#888;font-size:13px;">&#25105;&#30340;&#28040;&#24687;</span>
</div>
</a>
<script>
(function(){
  var bar = document.getElementById("notifyBarText");
  if (!bar) return;
  var lastId = 0, resetTimer = null;
  var MSG_DEF = '\u6211\u7684\u6d88\u606f';
  var MSG_RED = '\u2764\ufe0f\u6709\u4eba\u60f3\u4f60\u4e86\uff0c\u5feb\u53bb\u770b\u770b\u662f\u8c01\u5427';
  function check() {
    var x = new XMLHttpRequest();
    x.open("GET", "notifications", true);
    x.setRequestHeader("X-Requested-With", "XMLHttpRequest");
    x.onload = function() {
      if (x.status !== 200) return;
      try {
        var list = JSON.parse(x.responseText);
        if (list.length && list[0].id > lastId) {
          lastId = list[0].id;
          if ((Date.now() - new Date(list[0].time).getTime()) < 300000) {
            bar.textContent = MSG_RED;
            bar.style.color = "#ff4466";
            bar.style.fontWeight = "bold";
            clearTimeout(resetTimer);
            resetTimer = setTimeout(reset, 300000);
          }
        }
      } catch(e) {}
    };
    x.send();
  }
  function reset() {
    bar.textContent = MSG_DEF;
    bar.style.color = "#888";
    bar.style.fontWeight = "normal";
  }
  var init = new XMLHttpRequest();
  init.open("GET", "notifications", true);
  init.setRequestHeader("X-Requested-With", "XMLHttpRequest");
  init.onload = function() {
    if (init.status !== 200) return;
    try {
      var list = JSON.parse(init.responseText);
      if (list.length) {
        lastId = list[0].id;
        var age = Date.now() - new Date(list[0].time).getTime();
        if (age < 300000) {
          bar.textContent = MSG_RED;
          bar.style.color = "#ff4466";
          bar.style.fontWeight = "bold";
          clearTimeout(resetTimer);
          resetTimer = setTimeout(reset, 300000 - age);
        }
      }
    } catch(e) {}
  };
  init.send();
  setInterval(check, 15000);
})();
</script>