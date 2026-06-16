const CACHE_NAME = 'zymusic-v5';
const CORE_ASSETS = [
  './index.jsp',
  './manifest.json',
  './css/style.css',
  './css/app.css',
  './js/animation.js',
  './js/player-bar.js',
  './js/player.js',
  './icons/icon-144x144.png',
  './icons/icon-192x192.png',
  './icons/icon-512x512.png'
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME).then(function(cache) {
      return cache.addAll(CORE_ASSETS).catch(function(err) {
        console.log('Cache install error:', err);
      });
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(keys.filter(function(key) {
        return key !== CACHE_NAME;
      }).map(function(key) {
        return caches.delete(key);
      }));
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', function(event) {
  if (event.request.method !== 'GET') return;
  // Don't cache API calls or file serving
  var url = new URL(event.request.url);
  if (url.pathname.indexOf('/files/') === 0 ||
      url.pathname.indexOf('/uploadMusic') === 0 ||
      url.pathname.indexOf('/deleteMusic') === 0 ||
      url.pathname.indexOf('/updateProfile') === 0 ||
      url.pathname.indexOf('/like') === 0 ||
      url.pathname.indexOf('/comment') === 0 ||
      url.pathname.indexOf('/search') === 0) {
    return; // Network-only for dynamic content
  }
  event.respondWith(
    caches.match(event.request).then(function(cached) {
      return cached || fetch(event.request).then(function(response) {
        if (response && response.status === 200) {
          var clone = response.clone();
          caches.open(CACHE_NAME).then(function(cache) {
            cache.put(event.request, clone);
          });
        }
        return response;
      }).catch(function() {
        return caches.match('./index.jsp');
      });
    })
  );
});
