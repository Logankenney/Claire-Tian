document.getElementById('yr').textContent = new Date().getFullYear();
// let a normal mouse wheel move the reel sideways on desktop
const reel = document.getElementById('work');
if (reel) reel.addEventListener('wheel', e => {
  if (matchMedia('(max-width: 720px)').matches) return;
  if (Math.abs(e.deltaY) > Math.abs(e.deltaX)) { reel.scrollLeft += e.deltaY; e.preventDefault(); }
}, { passive: false });
