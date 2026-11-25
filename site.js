document.getElementById('yr').textContent = new Date().getFullYear();
// day / night switch, remembered between visits
const root = document.documentElement, btn = document.getElementById('mode');
const setMode = m => {
  root.dataset.mode = m;
  btn.setAttribute('aria-pressed', m === 'night');
  btn.querySelector('span').textContent = m === 'night' ? 'back to daylight' : 'go to night';
  try { localStorage.setItem('mode', m); } catch (e) {}
};
let saved = null; try { saved = localStorage.getItem('mode'); } catch (e) {}
setMode(saved || 'day');
btn.addEventListener('click', () => setMode(root.dataset.mode === 'night' ? 'day' : 'night'));
// let a normal mouse wheel move the reel sideways on desktop
const reel = document.getElementById('work');
if (reel) reel.addEventListener('wheel', e => {
  if (matchMedia('(max-width: 720px)').matches) return;
  if (Math.abs(e.deltaY) > Math.abs(e.deltaX)) { reel.scrollLeft += e.deltaY; e.preventDefault(); }
}, { passive: false });
