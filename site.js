document.getElementById('yr').textContent = new Date().getFullYear();

// let a normal mouse wheel move the photo dump strip sideways on desktop
// (nothing on the site scrolls down, so the wheel has nothing else to do)
const reel = document.getElementById('work');
const strip = document.querySelector('.reel');
if (strip && !strip.classList.contains('still')) strip.addEventListener('wheel', e => {
  if (Math.abs(e.deltaY) > Math.abs(e.deltaX)) { strip.scrollLeft += e.deltaY; e.preventDefault(); }
}, { passive: false });

// ---- photographs -------------------------------------------------------------------------------
// The photos are listed in photos.json, which tools/photos.py writes (see photos/README.md).
// If that list can't be read, the folder listing is asked of GitHub instead.
// If neither can be read, or the folder is empty, the grey stand-in frames stay.
const REPO = 'Logankenney/Claire-Tian';
const HOME = 3;         // how many the home page shows
const RECENT = 10;       // how many the photo dump page shows

const isPhoto = name => /\.(jpe?g|png|webp)$/i.test(name);
async function photoList() {
  try {
    const cached = sessionStorage.getItem('photo-list');
    if (cached) return JSON.parse(cached);
  } catch (e) {}
  let names = [];
  try {
    const r = await fetch('photos.json', { cache: 'no-cache' });
    if (r.ok) names = (await r.json()).filter(isPhoto).sort();
  } catch (e) {}
  if (!names.length) try {
    const r = await fetch('https://api.github.com/repos/' + REPO + '/contents/photos');
    if (r.ok) names = (await r.json()).filter(f => f.type === 'file' && isPhoto(f.name)).map(f => f.name).sort();
  } catch (e) {}
  if (names.length) try { sessionStorage.setItem('photo-list', JSON.stringify(names)); } catch (e) {}
  return names;
}
const describe = name => name.replace(/\.[^.]+$/, '').replace(/^\d{4}[-_.]?\d{2}[-_.]?\d{0,2}[-_.]?/, '').replace(/[-_]+/g, ' ').trim() || 'photograph';
// the caption on every photo, home and photo dump alike: "35mm". no numbers, no dates.
const NOTE = '35mm';
const figure = (name, note) => {
  const f = document.createElement('figure');
  // the frame is a link: a click opens that photo's own page, with its date, location, camera and film
  const frame = document.createElement('a'); frame.className = 'frame fit';
  frame.href = 'photo.html?p=' + encodeURIComponent(name); frame.setAttribute('aria-label', 'open ' + describe(name));
  const img = new Image(); img.src = 'photos/' + encodeURIComponent(name); img.alt = describe(name); img.loading = 'lazy';
  frame.append(img);
  const cap = document.createElement('figcaption');
  const b = document.createElement('span'); b.textContent = note;
  cap.append(b); f.append(frame, cap);
  return f;
};

// home: three frames, still, drawn from the photos folder in a new random order on every page load.
if (reel) (async () => {
  const names = await photoList();
  if (names.length) {
    reel.querySelectorAll('figure').forEach(f => f.remove());
    names.forEach(name => reel.append(figure(name, NOTE)));
  }
  const figs = [...reel.querySelectorAll('figure')];
  for (let i = figs.length - 1; i > 0; i--) { const k = Math.floor(Math.random() * (i + 1)); [figs[i], figs[k]] = [figs[k], figs[i]]; }
  const per = Math.min(HOME, figs.length);
  const turn = 0;
  const show = () => {
    const start = turn * per;
    figs.forEach((_, k) => {
      const f = figs[(start + k) % figs.length];
      f.hidden = k >= per;
      reel.append(f);
    });
    reel.scrollLeft = 0;
  };
  show();
})();

// photo dump: the newest few, by file name
const recent = document.querySelector('.recent');
if (recent) (async () => {
  const names = (await photoList()).slice().reverse().slice(0, RECENT);
  if (!names.length) return;
  recent.querySelectorAll('figure').forEach(f => f.remove());
  names.forEach(name => recent.append(figure(name, NOTE)));
})();

// one photograph: photo.html?p=<file name>. its details are read from photos/details.json, where an entry is
// named for one file, or for a whole set (the file name without its number). what is not written there stays a dash.
const single = document.querySelector('.one');
if (single) (async () => {
  const q = new URLSearchParams(location.search);
  const name = q.get('p') || '';
  const miss = () => { single.querySelector('.single').hidden = true; single.querySelector('.gone').hidden = false; };
  if (!/^[\w.-]+$/.test(name) || !isPhoto(name)) return miss();
  const img = single.querySelector('img');
  img.onerror = miss; img.alt = describe(name); img.src = 'photos/' + encodeURIComponent(name);
  document.title = describe(name) + ' · claire tian';
  // "close" goes back to where the photo was opened from, or home when the page was opened directly
  single.querySelector('.close').addEventListener('click', e => {
    let here = false; try { here = new URL(document.referrer).origin === location.origin; } catch (err) {}
    if (here && history.length > 1) { e.preventDefault(); history.back(); }
  });
  let all = {};
  try { const r = await fetch('photos/details.json', { cache: 'no-cache' }); if (r.ok) all = await r.json(); } catch (e) {}
  const set = name.replace(/\.[^.]+$/, '').replace(/[-_]\d+$/, '');
  const facts = Object.assign({}, all[set], all[name]);
  single.querySelectorAll('dd[data-k]').forEach(dd => { const v = String(facts[dd.dataset.k] || '').trim(); if (v) dd.textContent = v; });
})();
