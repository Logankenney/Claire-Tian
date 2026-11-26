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
// photos/sizes.json (written by tools/photos.py): each photo's pixel size and the lighter widths made from it.
// With it, the browser is offered every size and fetches the smallest one that is sharp on the screen in use:
// the full high-resolution copy on a high-density screen or a photo's own page, a light one on an ordinary screen.
// Without it (an old cache, a failed fetch) the full copy loads, as before.
async function photoSizes() {
  try {
    const cached = sessionStorage.getItem('photo-sizes');
    if (cached) return JSON.parse(cached);
  } catch (e) {}
  let sizes = {};
  try {
    const r = await fetch('photos/sizes.json', { cache: 'no-cache' });
    if (r.ok) sizes = await r.json();
  } catch (e) {}
  if (Object.keys(sizes).length) try { sessionStorage.setItem('photo-sizes', JSON.stringify(sizes)); } catch (e) {}
  return sizes;
}
// how wide a frame is drawn, in CSS pixels (from --frame-h and --one-h in styles.css, a frame being 2 by 3)
const GRID_SIZES = '(max-width: 720px) 39vh, (max-width: 1000px) calc(46.7vw - 117px), calc(30.7vw - 77px)';
const ONE_SIZES = '(max-width: 720px) 38vh, 56vh';
const setPhoto = (img, name, info, sizes) => {
  const file = encodeURIComponent(name);
  if (info && info.w) {
    img.width = info.w; img.height = info.h;
    if (info.widths && info.widths.length) {
      img.sizes = sizes;
      img.srcset = info.widths.map(w => 'photos/w' + w + '/' + file + ' ' + w + 'w').concat('photos/' + file + ' ' + info.w + 'w').join(', ');
    }
  }
  img.src = 'photos/' + file;
};
const figure = (name, note, link, info) => {
  const f = document.createElement('figure');
  // on photo dump the frame is a link: a click opens that photo's own page, with its date, location, camera and film.
  // on home it is not: the photos there are only looked at
  const frame = document.createElement(link ? 'a' : 'div'); frame.className = 'frame fit';
  if (link) { frame.href = 'photo.html?p=' + encodeURIComponent(name); frame.setAttribute('aria-label', 'open ' + describe(name)); }
  const img = new Image(); img.alt = describe(name); img.loading = 'lazy'; img.decoding = 'async';
  setPhoto(img, name, info, GRID_SIZES);
  frame.append(img);
  const cap = document.createElement('figcaption');
  const b = document.createElement('span'); b.textContent = note;
  cap.append(b); f.append(frame, cap);
  return f;
};

// home: three frames, still, drawn from the photos folder in a new random order on every page load.
if (reel) (async () => {
  const [names, info] = await Promise.all([photoList(), photoSizes()]);
  if (names.length) {
    reel.querySelectorAll('figure').forEach(f => f.remove());
    names.forEach(name => reel.append(figure(name, NOTE, false, info[name])));
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
  const [list, info] = await Promise.all([photoList(), photoSizes()]);
  const names = list.slice().reverse().slice(0, RECENT);
  if (!names.length) return;
  recent.querySelectorAll('figure').forEach(f => f.remove());
  names.forEach(name => recent.append(figure(name, NOTE, true, info[name])));
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
  img.onerror = miss; img.alt = describe(name);
  setPhoto(img, name, (await photoSizes())[name], ONE_SIZES);
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
