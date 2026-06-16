document.addEventListener('DOMContentLoaded', function() {
    var coverInput = document.querySelector('input[name="cover"]');
    var preview = document.getElementById('coverPreview');

    if (!coverInput || !preview) {
        return;
    }

    coverInput.addEventListener('change', function() {
        var file = coverInput.files && coverInput.files[0];
        if (!file) {
            preview.classList.add('hidden');
            preview.innerHTML = '';
            return;
        }

        var reader = new FileReader();
        reader.onload = function(event) {
            preview.innerHTML = '<img src="' + event.target.result + '" alt="封面预览">';
            preview.classList.remove('hidden');
        };
        reader.readAsDataURL(file);
    });
});
