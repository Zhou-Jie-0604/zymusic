document.addEventListener('DOMContentLoaded', function() {
    var avatarBtn = document.getElementById('avatarBtn');
    var nicknameBtn = document.getElementById('nicknameBtn');
    var avatarModal = document.getElementById('avatarModal');
    var nicknameModal = document.getElementById('nicknameModal');
    var chooseAvatarBtn = document.getElementById('chooseAvatarBtn');
    var avatarInput = document.getElementById('avatarInput');
    var avatarCanvas = document.getElementById('avatarCanvas');
    var avatarForm = document.getElementById('avatarForm');
    var avatarData = document.getElementById('avatarData');
    var avatarZoom = document.getElementById('avatarZoom');
    var avatarCropArea = document.getElementById('avatarCropArea');
    var avatarImage = new Image();
    var cropState = { ready: false, scale: 1, x: 0, y: 0, dragging: false, lastX: 0, lastY: 0 };

    if (avatarBtn && avatarModal) {
        avatarBtn.addEventListener('click', function() {
            avatarModal.classList.remove('hidden');
        });
    }

    if (nicknameBtn && nicknameModal) {
        nicknameBtn.addEventListener('click', function() {
            nicknameModal.classList.remove('hidden');
        });
    }

    if (chooseAvatarBtn && avatarInput) {
        chooseAvatarBtn.addEventListener('click', function() {
            avatarInput.click();
        });
    }

    if (avatarInput && avatarCanvas) {
        avatarInput.addEventListener('change', function() {
            var file = avatarInput.files && avatarInput.files[0];
            if (!file) {
                return;
            }
            var fname = file.name.toLowerCase();
            if (!fname.endsWith('.png') && !fname.endsWith('.jpg') && !fname.endsWith('.jpeg')) {
                alert('请选择 PNG 或 JPG 格式图片');
                avatarInput.value = '';
                return;
            }
            var reader = new FileReader();
            reader.onload = function(event) {
                avatarImage = new Image();
                avatarImage.onload = function() {
                    cropState.ready = true;
                    cropState.scale = 1;
                    cropState.x = 0;
                    cropState.y = 0;
                    avatarZoom.value = '1';
                    avatarCropArea.classList.remove('hidden');
                    drawAvatarCrop();
                };
                avatarImage.src = event.target.result;
            };
            reader.readAsDataURL(file);
        });
    }

    function drawAvatarCrop() {
        if (!avatarCanvas || !cropState.ready) {
            return;
        }
        var ctx = avatarCanvas.getContext('2d');
        var size = avatarCanvas.width;
        var baseScale = Math.max(size / avatarImage.width, size / avatarImage.height);
        var scale = baseScale * cropState.scale;
        var width = avatarImage.width * scale;
        var height = avatarImage.height * scale;
        var x = (size - width) / 2 + cropState.x;
        var y = (size - height) / 2 + cropState.y;

        ctx.clearRect(0, 0, size, size);
        ctx.save();
        ctx.beginPath();
        ctx.arc(size / 2, size / 2, size / 2 - 2, 0, Math.PI * 2);
        ctx.clip();
        ctx.drawImage(avatarImage, x, y, width, height);
        ctx.restore();

        ctx.save();
        ctx.strokeStyle = 'rgba(255,255,255,0.9)';
        ctx.lineWidth = 4;
        ctx.beginPath();
        ctx.arc(size / 2, size / 2, size / 2 - 3, 0, Math.PI * 2);
        ctx.stroke();
        ctx.restore();
    }

    function pointerPosition(event) {
        var touch = event.touches && event.touches[0];
        return {
            x: touch ? touch.clientX : event.clientX,
            y: touch ? touch.clientY : event.clientY
        };
    }

    if (avatarCanvas) {
        avatarCanvas.addEventListener('mousedown', startDrag);
        avatarCanvas.addEventListener('touchstart', startDrag, { passive: false });
        window.addEventListener('mousemove', dragAvatar);
        window.addEventListener('touchmove', dragAvatar, { passive: false });
        window.addEventListener('mouseup', endDrag);
        window.addEventListener('touchend', endDrag);
    }

    function startDrag(event) {
        if (!cropState.ready) return;
        event.preventDefault();
        var point = pointerPosition(event);
        cropState.dragging = true;
        cropState.lastX = point.x;
        cropState.lastY = point.y;
    }

    function dragAvatar(event) {
        if (!cropState.dragging) return;
        event.preventDefault();
        var point = pointerPosition(event);
        cropState.x += point.x - cropState.lastX;
        cropState.y += point.y - cropState.lastY;
        cropState.lastX = point.x;
        cropState.lastY = point.y;
        drawAvatarCrop();
    }

    function endDrag() {
        cropState.dragging = false;
    }

    if (avatarZoom) {
        avatarZoom.addEventListener('input', function() {
            cropState.scale = Number(avatarZoom.value) || 1;
            drawAvatarCrop();
        });
    }

    if (avatarForm && avatarCanvas && avatarData) {
        avatarForm.addEventListener('submit', function(event) {
            event.preventDefault();
            if (!cropState.ready) {
                alert('请先点击”更改头像”选择图片');
                return;
            }
            drawAvatarCrop();
            var dataUrl = avatarCanvas.toDataURL('image/png');
            // Ensure the data URL is properly formatted
            if (!dataUrl || dataUrl.length < 100) {
                alert('头像裁剪数据无效，请重试');
                return;
            }
            avatarData.value = dataUrl;
            event.target.submit();
        });
    }

    document.querySelectorAll('[data-close]').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var modalId = btn.getAttribute('data-close');
            var modal = document.getElementById(modalId);
            if (modal) {
                modal.classList.add('hidden');
            }
        });
    });

    document.querySelectorAll('.modal').forEach(function(modal) {
        modal.addEventListener('click', function(event) {
            if (event.target === modal) {
                modal.classList.add('hidden');
            }
        });
    });
});
