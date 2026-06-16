document.addEventListener('DOMContentLoaded', function() {
    createLeaves();
});

function createLeaves() {
    const background = document.querySelector('.background-animation');
    const leafCount = 20;
    
    for (let i = 0; i < leafCount; i++) {
        const leaf = document.createElement('div');
        leaf.className = 'leaf';
        leaf.style.left = Math.random() * 100 + '%';
        leaf.style.animationDelay = Math.random() * 8 + 's';
        leaf.style.animationDuration = (5 + Math.random() * 5) + 's';
        leaf.style.width = (10 + Math.random() * 15) + 'px';
        leaf.style.height = leaf.style.width;
        leaf.style.background = `hsl(${120 + Math.random() * 60}, 70%, 40%)`;
        background.appendChild(leaf);
    }
}