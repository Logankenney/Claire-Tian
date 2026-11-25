document.getElementById('yr').textContent = new Date().getFullYear();

// let a normal mouse wheel move the work strip sideways on desktop
// (nothing on the site scrolls down, so the wheel has nothing else to do)
const reel = document.getElementById('work');
const strip = document.querySelector('.reel');
if (strip && !strip.classList.contains('still')) strip.addEventListener('wheel', e => {
  if (Math.abs(e.deltaY) > Math.abs(e.deltaX)) { strip.scrollLeft += e.deltaY; e.preventDefault(); }
}, { passive: false });

// ---- photographs -------------------------------------------------------------------------------
// Anything dropped in the repo's photos/ folder shows up here: the list is read from GitHub.
// If the list can't be read, or the folder is empty, the grey stand-in frames stay.
const REPO = 'Logankenney/Claire-Tian';
const PER_TURN = 10;    // how many frames the work page's strip holds at once
const HOME = 3;         // how many the home page shows
const RECENT = 4;        // how many the recent shots page shows

async function photoList() {
  try {
    const cached = sessionStorage.getItem('photos');
    if (cached) return JSON.parse(cached);
  } catch (e) {}
  try {
    const r = await fetch('https://api.github.com/repos/' + REPO + '/contents/photos');
    if (!r.ok) return [];
    const names = (await r.json()).filter(f => f.type === 'file' && /\.(jpe?g|png|webp)$/i.test(f.name)).map(f => f.name).sort();
    try { sessionStorage.setItem('photos', JSON.stringify(names)); } catch (e) {}
    return names;
  } catch (e) { return []; }
}
const describe = name => name.replace(/\.[^.]+$/, '').replace(/^\d{4}[-_.]?\d{2}[-_.]?\d{0,2}[-_.]?/, '').replace(/[-_]+/g, ' ').trim() || 'photograph';
const figure = (name, n, note) => {
  const f = document.createElement('figure');
  const frame = document.createElement('div'); frame.className = 'frame fit';
  const img = new Image(); img.src = 'photos/' + encodeURIComponent(name); img.alt = describe(name); img.loading = 'lazy';
  frame.append(img);
  const cap = document.createElement('figcaption');
  const a = document.createElement('span'); a.textContent = String(n).padStart(2, '0');
  const b = document.createElement('span'); b.textContent = note;
  cap.append(a, b); f.append(frame, cap);
  return f;
};

// home and work draw from the photos folder in a new random order on every page load.
// work: ten frames in the strip. Clicking "work" moves ten further through that order and wraps
// round, so the strip always holds ten (or every photo, when the folder has fewer). No timer.
// home: three frames, still.
const workLink = document.querySelector('nav a[href="work.html"]');
const turning = reel && reel.classList.contains('turning');
if (reel) (async () => {
  const names = await photoList();
  if (names.length) {
    reel.querySelectorAll('figure').forEach(f => f.remove());
    names.forEach(name => reel.append(figure(name, 0, '35mm')));
  }
  const figs = [...reel.querySelectorAll('figure')];
  for (let i = figs.length - 1; i > 0; i--) { const k = Math.floor(Math.random() * (i + 1)); [figs[i], figs[k]] = [figs[k], figs[i]]; }
  const per = Math.min(turning ? PER_TURN : HOME, figs.length);
  const turns = Math.max(1, Math.ceil(figs.length / per));
  let turn = 0;
  const show = () => {
    const start = turn * per;
    figs.forEach((_, k) => {
      const f = figs[(start + k) % figs.length];
      f.hidden = k >= per;
      f.querySelector('figcaption span').textContent = String(k + 1).padStart(2, '0');   // numbered as shown
      reel.append(f);
    });
    reel.scrollLeft = 0;
  };
  show();
  if (turning) workLink.addEventListener('click', e => { e.preventDefault(); turn = (turn + 1) % turns; show(); });
})();

// recent shots: the newest few, by file name
const recent = document.querySelector('.recent');
if (recent) (async () => {
  const names = (await photoList()).slice().reverse().slice(0, RECENT);
  if (!names.length) return;
  recent.querySelectorAll('figure').forEach(f => f.remove());
  names.forEach((name, i) => recent.append(figure(name, i + 1, (name.match(/^\d{4}[-_.]?\d{2}/) || [''])[0].replace(/[-_]/, '.'))));
})();
