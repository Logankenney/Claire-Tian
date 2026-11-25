document.getElementById('yr').textContent = new Date().getFullYear();

// let a normal mouse wheel move the work strip sideways on desktop
// (nothing on the site scrolls down, so the wheel has nothing else to do)
const reel = document.getElementById('work');
const strip = document.querySelector('.reel');
if (strip) strip.addEventListener('wheel', e => {
  if (Math.abs(e.deltaY) > Math.abs(e.deltaX)) { strip.scrollLeft += e.deltaY; e.preventDefault(); }
}, { passive: false });

// ---- photographs -------------------------------------------------------------------------------
// Anything dropped in the repo's photos/ folder shows up here: the list is read from GitHub.
// If the list can't be read, or the folder is empty, the grey stand-in frames stay.
const REPO = 'Logankenney/Claire-Tian';
const PER_TURN = 3;      // how many frames the work page shows at once
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

// work: three frames at a time. They change only when "work" is clicked, never on a timer.
// The home page shows the first three and stays still; the work page is the one that turns.
const workLink = document.querySelector('nav a[href="work.html"]');
const turning = reel && reel.classList.contains('turning');
if (reel) (async () => {
  const names = await photoList();
  if (names.length) {
    reel.querySelectorAll('figure').forEach(f => f.remove());
    names.forEach((name, i) => reel.append(figure(name, i + 1, '35mm')));
  }
  const figs = [...reel.querySelectorAll('figure')];
  const turns = Math.max(1, Math.ceil(figs.length / PER_TURN));
  let turn = 0;
  if (turning) try { turn = (parseInt(sessionStorage.getItem('turn') || '-1', 10) + 1) % turns; } catch (e) {}
  const show = () => {
    figs.forEach((f, i) => { f.hidden = Math.floor(i / PER_TURN) !== turn; });
    reel.scrollLeft = 0;
    if (turning) try { sessionStorage.setItem('turn', String(turn)); } catch (e) {}
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
