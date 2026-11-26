# Claire-Tian compiled text files

Every text file of the site as it stood on `main` at closeout (`45c71dd`, 2026-11-25), followed by the first starter page from the project's shared folder. Photographs are listed in `FILE_MANIFEST.md` and are not reproduced here.

**PDF files:** there are none. No PDF exists in the repository, in any of its history, or in the project's shared folder, so nothing was left out.

## Contents

- `.gitignore`
- `.nojekyll`
- `404.html`
- `CNAME`
- `README.md`
- `booking.js`
- `contact.html`
- `index.html`
- `photo.html`
- `photos.json`
- `photos/README.md`
- `photos/details.json`
- `recent.html`
- `site.js`
- `styles.css`
- `tools/photos.py`
- `site-starter/index.html` (shared folder)

## .gitignore

62 bytes, 7 lines.

`````text
node_modules/
dist/
.env
.env.*
!.env.example
*.log
.DS_Store
`````

## .nojekyll

0 bytes, 0 lines.

`````text

`````

## 404.html

342 bytes, 4 lines.

`````html
<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>nothing · claire tian</title><link rel="stylesheet" href="/styles.css?v=28"></head>
<body class="page"><main class="sheet"><h2>nothing here</h2><p><a class="go" href="/">leave</a></p></main></body></html>
`````

## CNAME

20 bytes, 1 lines.

`````text
www.claire-tian.com
`````

## README.md

2089 bytes, 30 lines.

`````markdown
# Claire-Tian

A development project starting with a website, expanding into social media management, and eventually supporting a multi-model processing system.

## Website

A plain static site served by GitHub Pages at https://www.claire-tian.com. There is no build step: what is in `main` is what is served.

| File | What it is |
|---|---|
| `index.html` | Home page: the two lines of copy and three frames, shrunk to fit; it does not scroll or change |
| `recent.html` | Photo dump (menu name; the file keeps its old name so links still work), newest first, in the same sideways strip, with the short about copy |
| `contact.html` | The contact address and the "i have an idea" box |
| `styles.css` | All styling: light, black and white, lowercase |
| `site.js` | Loads the photos listed in `photos.json` in a new random order on each page load, sideways scrolling |
| `photos/` | The photographs, as small WebP copies; originals in `photos/originals/` (see `photos/README.md`) |
| `photos.json` | The list of photos the pages show, written by `tools/photos.py` |
| `tools/photos.py` | Makes WebP copies of new photos and rewrites `photos.json` |
| `booking.js` | The contact address (`CONTACT_EMAIL`, one line) and the idea box |
| `CNAME` | The domain GitHub Pages serves |

To preview, run `python3 -m http.server` in this folder and open http://localhost:8000.

**Still placeholder:** the grey frames on the home and photo dump pages, until `photos/` has photographs in it. The contact address `hello@claire-tian.com` is real and forwards to Claire.

**Booking:** the contact page has one prompt, "i have an idea", and one text box. The site has no server, so sending opens the visitor's email app with the idea filled in. A form service or a scheduling embed can replace it later.

**Deploying:** Settings > Pages > "Deploy from a branch", branch `main`, folder `/ (root)`. Every merge to `main` then publishes on its own.

**Colour:** photographs are shown black and white by one line at the top of `styles.css` (`--photo`). Change it to `--photo: none;` to show them in colour.
`````

## booking.js

862 bytes, 15 lines.

`````javascript
// Where "send" on the contact page addresses the email. It forwards to Claire's inbox.
// The address is not shown on the page.
const CONTACT_EMAIL = "hello@claire-tian.com";

// "i have an idea": one text box. The site has no server, so sending opens the visitor's own
// email app with the idea filled in.
const form = document.getElementById('idea');
if (form) form.addEventListener('submit', e => {
  e.preventDefault();
  const status = document.getElementById('status');
  const idea = form.elements.idea.value.trim();
  if (!idea) { status.textContent = 'nothing written.'; form.elements.idea.focus(); return; }
  location.href = 'mailto:' + CONTACT_EMAIL + '?subject=' + encodeURIComponent('i have an idea') + '&body=' + encodeURIComponent(idea);
  status.textContent = 'your email app should open. if it does not, write to ' + CONTACT_EMAIL + '.';
});
`````

## contact.html

1303 bytes, 35 lines.

`````html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>contact · claire tian</title>
<meta name="description" content="contact claire tian.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@300;400&display=swap" rel="stylesheet">
<link rel="stylesheet" href="styles.css?v=28">
</head>
<body>
  <aside class="side">
    <h1 class="name"><a href="./">claire tian</a></h1>
    <nav aria-label="Main">
      <a href="recent.html">photo dump</a>
      <a href="contact.html" aria-current="page">contact... please don't</a>
    </nav>
    <div class="foot">© <span id="yr"></span> claire tian.<br>all rights reserved.</div>
  </aside>

  <main class="sheet contact">
    <form id="idea" novalidate>
      <label for="idea-text">i have an idea</label>
      <textarea id="idea-text" name="idea" aria-describedby="status"></textarea>
      <button class="send" type="submit">send</button>
      <p class="status" id="status" role="status" aria-live="polite"></p>
    </form>
  </main>

<script src="site.js?v=19"></script>
<script src="booking.js?v=9"></script>
</body>
</html>
`````

## index.html

1991 bytes, 35 lines.

`````html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>claire tian</title>
<meta name="description" content="claire tian. only feelings. photographs on film, nyc.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@300;400&display=swap" rel="stylesheet">
<link rel="stylesheet" href="styles.css?v=28">
</head>
<body class="home">
  <aside class="side">
    <h1 class="name"><a href="./">claire tian</a></h1>
    <nav aria-label="Main">
      <a href="recent.html">photo dump</a>
      <a href="contact.html">contact... please don't</a>
    </nav>
    <div class="foot">© <span id="yr"></span> claire tian.<br>all rights reserved.</div>
  </aside>

  <main class="reel still" id="work" aria-label="photographs">
    <!-- stand-ins. photographs dropped in the photos/ folder replace these on their own (see photos/README.md) -->
    <figure><div class="frame p1" role="img" aria-label="photograph 01, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p2" role="img" aria-label="photograph 02, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p3" role="img" aria-label="photograph 03, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p4" role="img" aria-label="photograph 04, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p5" role="img" aria-label="photograph 05, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p6" role="img" aria-label="photograph 06, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
  </main>

<script src="site.js?v=19"></script>
</body>
</html>
`````

## photo.html

1670 bytes, 41 lines.

`````html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>photograph · claire tian</title>
<meta name="description" content="a photograph by claire tian.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@300;400&display=swap" rel="stylesheet">
<link rel="stylesheet" href="styles.css?v=28">
</head>
<!-- one photograph and its details. opened from any photo as photo.html?p=<file name>.
     the details come from photos/details.json (see photos/README.md); a missing one shows as a dash. -->
<body class="plate">
  <aside class="side">
    <h1 class="name"><a href="./">claire tian</a></h1>
    <nav aria-label="Main">
      <a href="recent.html">photo dump</a>
      <a href="contact.html">contact... please don't</a>
    </nav>
    <div class="foot">© <span id="yr"></span> claire tian.<br>all rights reserved.</div>
  </aside>

  <main class="one" aria-label="photograph">
    <a class="close" href="./">close</a>
    <div class="single">
      <div class="frame fit"><img id="shot" alt=""></div>
      <dl class="facts">
        <div><dt>date</dt><dd data-k="date">—</dd></div>
        <div><dt>location</dt><dd data-k="location">—</dd></div>
        <div><dt>camera</dt><dd data-k="camera">—</dd></div>
        <div><dt>film</dt><dd data-k="film">—</dd></div>
      </dl>
    </div>
    <p class="gone" hidden>nothing here. <a class="go" href="./">leave</a></p>
  </main>

<script src="site.js?v=19"></script>
</body>
</html>
`````

## photos.json

1052 bytes, 27 lines.

`````json
[
 "2026-07-02-enchanted-in-portugal-02.webp",
 "2026-07-02-enchanted-in-portugal-03.webp",
 "2026-07-02-enchanted-in-portugal-04.webp",
 "2026-07-02-enchanted-in-portugal-05.webp",
 "2026-07-02-enchanted-in-portugal-06.webp",
 "2026-07-02-enchanted-in-portugal-07.webp",
 "2026-07-02-enchanted-in-portugal-08.webp",
 "2026-07-02-enchanted-in-portugal-09.webp",
 "2026-07-02-enchanted-in-portugal-10.webp",
 "2026-07-02-enchanted-in-portugal-11.webp",
 "2026-07-02-enchanted-in-portugal-12.webp",
 "2026-07-02-enchanted-in-portugal-13.webp",
 "2026-07-02-enchanted-in-portugal-14.webp",
 "2026-07-02-enchanted-in-portugal-15.webp",
 "2026-07-02-enchanted-in-portugal-16.webp",
 "2026-08-30-prague-on-film-1.webp",
 "2026-08-30-prague-on-film-2.webp",
 "2026-10-10-caymans-wedding-02.webp",
 "2026-10-10-caymans-wedding-04.webp",
 "2026-10-20-tokyo-on-film-02.webp",
 "2026-10-20-tokyo-on-film-03.webp",
 "2026-10-20-tokyo-on-film-04.webp",
 "2026-10-20-tokyo-on-film-05.webp",
 "2026-10-20-tokyo-on-film-06.webp",
 "2026-10-20-tokyo-on-film-08.webp"
]
`````

## photos/README.md

2336 bytes, 33 lines.

`````markdown
# photos

Drop photographs in this folder, then run `python3 tools/photos.py` from the repo folder (or ask Claude to). It
makes a small WebP copy of each new photo (at most 1400 pixels on the long side), moves the original to
`photos/originals/`, and rewrites `photos.json`, the list the pages read. A photo that is not in `photos.json`
does not show.

- Use `.jpg`, `.jpeg`, `.png` or `.webp`. Any size; the script shrinks it.
- Every frame on the site is portrait (2 by 3). A landscape or square photo is cropped to its middle, so portrait originals look best.
- **home** picks three from this folder in a new random order every time the page loads, and does not scroll.
- **home** and **photo dump** show photos the same way: same size and shape, same gap, same black and white, the same caption ("35mm"; no numbers, no dates).
- Photos show in black and white. With the mouse over one, it fades to its original colour and fades back when the mouse leaves, so keep the colour in the files you add.
- **photo dump** shows the ten newest, judged by file name. Name files so newer ones sort later, for example `2026-11-03-subway.jpg`.
- The file name, without the date and extension, is used as the photo's description for screen readers.

Until this folder has photos, the pages show grey stand-in frames.

## a page for each photo

A click on a photo on **photo dump** opens its own page (`photo.html?p=<file name>`): the photo in full colour, with four
lines: date, location, camera and film. Photos on **home** do not open anything.
Those come from `photos/details.json`. An entry is named for a set of photos (the file name without its number, for
example `2026-10-20-tokyo-on-film`), and covers every photo in that set. To give one photo its own details, add an
entry named for that exact file (for example `2026-10-20-tokyo-on-film-08.webp`); what it says wins over the set.

    "2026-10-20-tokyo-on-film": {"date": "2026.10.20", "location": "tokyo", "camera": "", "film": ""}

Anything left empty shows as a dash. `tools/photos.py` adds an entry for each new set, with the date from the file
name, and never changes what is already written.

## people

people appear only in candid or unposed photographs. no posed portraits: nobody looking into the lens, arranged for the picture. if a photo is unclear, leave it out and ask.
`````

## photos/details.json

427 bytes, 6 lines.

`````json
{
 "2026-07-02-enchanted-in-portugal": {"date": "2026.07.02", "location": "portugal", "camera": "", "film": ""},
 "2026-08-30-prague-on-film": {"date": "2026.08.30", "location": "prague", "camera": "", "film": ""},
 "2026-10-10-caymans-wedding": {"date": "2026.10.10", "location": "cayman islands", "camera": "", "film": ""},
 "2026-10-20-tokyo-on-film": {"date": "2026.10.20", "location": "tokyo", "camera": "", "film": ""}
}
`````

## recent.html

2728 bytes, 40 lines.

`````html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>photo dump · claire tian</title>
<meta name="description" content="recent photographs by claire tian.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@300;400&display=swap" rel="stylesheet">
<link rel="stylesheet" href="styles.css?v=28">
</head>
<body class="dump">
  <aside class="side">
    <h1 class="name"><a href="./">claire tian</a></h1>
    <nav aria-label="Main">
      <a href="recent.html" aria-current="page">photo dump</a>
      <a href="contact.html">contact... please don't</a>
    </nav>
    <div class="foot">© <span id="yr"></span> claire tian.<br>all rights reserved.</div>
  </aside>

  <main class="reel recent" tabindex="0" aria-label="photo dump, scroll sideways">
    <!-- stand-ins. the newest files in the photos/ folder replace these on their own (see photos/README.md) -->
    <figure><div class="frame p3" role="img" aria-label="recent photograph 01, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p1" role="img" aria-label="recent photograph 02, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p6" role="img" aria-label="recent photograph 03, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p4" role="img" aria-label="recent photograph 04, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p2" role="img" aria-label="recent photograph 05, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p5" role="img" aria-label="recent photograph 06, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p3" role="img" aria-label="recent photograph 07, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p1" role="img" aria-label="recent photograph 08, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p6" role="img" aria-label="recent photograph 09, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
    <figure><div class="frame p4" role="img" aria-label="recent photograph 10, not yet added"></div><figcaption><span>35mm</span></figcaption></figure>
  </main>
  <p class="under">the moments that transcend time</p>

<script src="site.js?v=19"></script>
</body>
</html>
`````

## site.js

5536 bytes, 107 lines.

`````javascript
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
const figure = (name, note, link) => {
  const f = document.createElement('figure');
  // on photo dump the frame is a link: a click opens that photo's own page, with its date, location, camera and film.
  // on home it is not: the photos there are only looked at
  const frame = document.createElement(link ? 'a' : 'div'); frame.className = 'frame fit';
  if (link) { frame.href = 'photo.html?p=' + encodeURIComponent(name); frame.setAttribute('aria-label', 'open ' + describe(name)); }
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
  names.forEach(name => recent.append(figure(name, NOTE, true)));
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
`````

## styles.css

11985 bytes, 171 lines.

`````css
/* claire tian: light, black and white, minimal, lowercase, a little cold. */
:root {
  --paper: #efe8d9;      /* uncoated paper */
  --ink: #0e0e0e;
  --muted: #8f897b;
  --line: #d3cab7;
  --mono: "DM Mono", ui-monospace, "SF Mono", Menlo, Consolas, monospace;
  --side: 230px;
  /* how photographs are shown at rest. black and white now; for colour, change this one line to:  --photo: none;  */
  --photo: grayscale(1) contrast(1.08);
  /* the size of every photograph, on home and on photo dump alike: 2 by 3, never taller than 78vh, and narrow enough
     that three share the row beside the menu (100vw less the menu, the right margin and two gaps) */
  --frame-h: min(78vh, 46vw - 115px);
  --frame-gap: 2.5vw;
}
* { box-sizing: border-box; }
html, body { height: 100%; margin: 0; }
body {
  background: var(--paper); color: var(--ink);
  font: 300 11px/1.7 var(--mono); letter-spacing: .04em;
  text-transform: lowercase;
  overflow: hidden;
}
a { color: inherit; text-decoration: none; }
a:hover { text-decoration: line-through; }
a[aria-current], a[aria-current]:hover { text-decoration: none; }   /* the page you are on: no strike, just full black (see nav below) */
::selection { background: var(--ink); color: var(--paper); }

/* sidebar: small, top corner, nothing friendly about it */
.side { position: fixed; inset: 0 auto 0 0; width: var(--side); padding: 22px 20px; display: flex; flex-direction: column; z-index: 3; }
.name { font: 400 16px/1.7 var(--mono); letter-spacing: .42em; margin: 0 0 28px; white-space: nowrap; }
nav a { display: block; color: var(--muted); white-space: nowrap; }
nav a:hover, nav a[aria-current] { color: var(--ink); }
.foot { margin-top: auto; font-size: 9px; color: var(--muted); line-height: 1.7; }

/* work: a sideways strip of frames, no numbers, no titles */
.reel {
  position: fixed; inset: 0 0 0 var(--side);
  display: flex; gap: 6vw; align-items: flex-end;        /* everything sits low; the empty space is at the top */
  padding: 22px 12vw 22px 0;
  overflow-x: auto; overflow-y: hidden; scrollbar-width: none;
}
.reel::-webkit-scrollbar { display: none; }
/* home: three frames, still, as large as the window allows and centred top to bottom; nothing scrolls. */
.reel.still { overflow: hidden; justify-content: center; padding-right: 3vw; }
@media (min-width: 721px) {
  /* half the height of a row of photos with its caption (21px); the row is centred top to bottom */
  body { --row-half: calc((var(--frame-h) + 21px) / 2); }
  .home nav { position: fixed; left: 20px; top: max(77px, calc(50vh - var(--row-half) - 4px)); }   /* home menu: top level with the top of the photos, never up into the name */
}
figure { margin: 0; flex: 0 0 auto; display: flex; flex-direction: column; }
figure:nth-of-type(even) { margin-bottom: 12vh; }   /* uneven on purpose */
figure:nth-of-type(3n) { margin-bottom: 5vh; }
.still figure:nth-of-type(n), .recent figure:nth-of-type(n) { margin-bottom: 0; }   /* level, not staggered */
/* home and photo dump share every photo rule: same size, same shape, same gap, level and centred top to bottom,
   same black and white, same fade to colour under the mouse, same caption. only the behaviour differs: home is still, photo dump scrolls sideways. */
.reel.still, .reel.recent { align-items: center; gap: var(--frame-gap); }
.still .frame, .recent .frame { height: var(--frame-h); width: auto; }
.frame { height: 62vh; aspect-ratio: 2 / 3; position: relative; overflow: hidden; background: #1a1a1a; }
.frame:not(.fit) { opacity: .9; outline: 1px solid var(--ink); outline-offset: 5px; }   /* stand-ins read as x-ray plates */
.frame img { width: 100%; height: 100%; object-fit: cover; display: block; filter: var(--photo); transition: filter .3s ease; }
/* mouse over a photo: it fades to its original colour, and fades back to black and white when the mouse leaves.
   the whole tile counts, the photo and the caption row under it, so the colour holds until the mouse is off the tile.
   only where there is a real pointer, so a tap on a phone does not leave a photo stuck in colour */
@media (hover: hover) { figure:hover .frame img, .frame:hover img { filter: grayscale(0) contrast(1); } }
a.frame { display: block; cursor: pointer; }   /* on photo dump a photo is a link to its own page */
/* every frame is portrait, 2 by 3. a real photo fills it; a landscape one is cropped to the middle. */
.frame.fit { background: none; }
.frame.fit::after { content: none; }
figure[hidden] { display: none; }
/* stand-ins until real photos are dropped in: swap a .frame's contents for an <img> */
.p1 { background: radial-gradient(55% 40% at 30% 28%, #d8d8d8 0, transparent 70%), linear-gradient(165deg, #6f6f6f, #1c1c1c 60%, #050505); }
.p2 { background: radial-gradient(45% 35% at 72% 22%, #f2f2f2 0, transparent 70%), linear-gradient(200deg, #a9a9a9, #4a4a4a 55%, #121212); }
.p3 { background: radial-gradient(30% 22% at 50% 62%, #bdbdbd 0, transparent 70%), linear-gradient(180deg, #0a0a0a, #262626 60%, #000); }
.p4 { background: radial-gradient(60% 45% at 22% 78%, #e6e6e6 0, transparent 70%), linear-gradient(140deg, #c9c9c9, #6a6a6a 60%, #1d1d1d); }
.p5 { background: radial-gradient(50% 38% at 60% 40%, #ffffff 0, transparent 70%), linear-gradient(170deg, #dcdcdc, #8a8a8a 55%, #2a2a2a); }
.p6 { background: radial-gradient(55% 45% at 40% 30%, #9a9a9a 0, transparent 70%), linear-gradient(190deg, #3c3c3c, #151515 60%, #000); }
.frame::after { /* film grain */
  content: ""; position: absolute; inset: 0; opacity: .5; mix-blend-mode: overlay; pointer-events: none;
  background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>");
}
figcaption { padding-top: 6px; font-size: 9px; color: var(--muted); display: flex; justify-content: flex-end; }   /* "35mm" under the right corner of the photo; no numbers */

/* contact: one narrow column, pushed off-centre, mostly empty. nothing on this site scrolls down. */
.sheet { position: fixed; inset: 0 0 0 calc(var(--side) + 22vw); padding: 22px 24px 22px 0; overflow: hidden; display: flex; flex-direction: column; justify-content: flex-end; }
.sheet > * { max-width: 34ch; }
.sheet h2 { font: inherit; margin: 0 0 20px; color: var(--muted); }
.sheet p { margin: 0 0 14px; }
.sheet a.go { border-bottom: 1px solid var(--ink); }
.sheet a.go:hover { text-decoration: none; border-bottom-color: transparent; }
/* recent shots: the same sideways strip as work, with dates */
.note { font-size: 9px; }
/* photo dump: laid out like home (frames level, centred top to bottom), but the strip scrolls sideways. one line of copy sits under the photos; nothing beside or over them */
.under { margin: 0; font-size: 14px; text-align: center; color: var(--ink); }
@media (min-width: 721px) {
  /* on one line, centred under the row, a little below the captions and never off the bottom of the window; it stays put while the strip moves */
  .under { position: fixed; left: var(--side); right: 3vw; top: min(calc(50vh + var(--row-half) + 4vh), calc(100vh - 12px)); transform: translateY(-50%); white-space: nowrap; }
}

/* contact: one prompt, one text box */
form { display: grid; gap: 8px; margin-top: 24px; }
form label { color: var(--ink); }
textarea {
  font: inherit; letter-spacing: inherit; text-transform: none; color: var(--ink); background: transparent;
  border: 0; border-bottom: 1px solid var(--line); border-radius: 0; padding: 6px 0; width: 100%; height: 96px; resize: none;
}
textarea:focus { outline: 0; border-bottom-color: var(--ink); }
button.send { justify-self: start; font: inherit; letter-spacing: inherit; text-transform: lowercase; cursor: pointer; color: var(--ink); background: none; border: 0; border-bottom: 1px solid var(--ink); padding: 0; margin-top: 8px; }
button.send:hover { border-bottom-color: transparent; }
.status { min-height: 1.7em; margin: 0; color: var(--muted); }
/* one photograph and its details (photo.html): the photo large and centred, four facts with it, "close" in the far corner.
   nothing scrolls. */
.one { position: fixed; inset: 0 0 0 var(--side); padding: 22px 3vw 22px 0; display: flex; align-items: center; justify-content: center; }
.single { display: flex; }
.single[hidden] { display: none; }
.single .frame { height: var(--one-h); width: auto; }
.single .frame img { filter: none; }   /* on its own page a photo shows in its original colour, always */
.close { position: fixed; top: 24px; right: 24px; color: var(--muted); z-index: 4; }
.close:hover { color: var(--ink); }
.facts { margin: 0; }
.facts div { display: flex; align-items: baseline; }
.facts dt { color: var(--muted); }
.facts dd { margin: 0; }
.gone { margin: 0; color: var(--muted); }
.gone a { color: var(--ink); border-bottom: 1px solid var(--ink); }
/* the facts sit beside the photo, level with its bottom edge, each on a dotted line like a darkroom log */
.plate { --one-h: min(84vh, (100vw - var(--side) - 30ch - 12vw) * 1.5); }
.plate .single { align-items: flex-end; gap: 3vw; }
.plate .facts { width: 30ch; }
.plate .facts dt { flex: 1; display: flex; align-items: baseline; }
.plate .facts dt::after { content: ""; flex: 1; margin: 0 8px; border-bottom: 1px dotted var(--muted); opacity: .7; transform: translateY(-3px); }

/* the contact page only: the prompt, text box and "send" sit half way down, at the left edge where the pictures start on the other pages, text left-justified */
.sheet.contact { inset: 0 0 0 var(--side); padding: 22px 24px 22px 0; justify-content: center; align-items: flex-start; text-align: left; }
.sheet.contact form { width: 34ch; max-width: 100%; margin-top: 0; }

@media (max-width: 1000px) {   /* narrower windows: sized so two share the row */
  :root { --frame-h: min(78vh, 70vw - 175px); }
  .still figure:nth-of-type(n+3) { display: none; }
}
@media (max-width: 720px) {
  /* phones: the name and menu sit on top, the strip still runs sideways underneath */
  body { display: flex; flex-direction: column; }
  .side { position: static; flex: none; width: auto; padding: 18px 18px 0; display: block; }
  .name { margin: 0 0 10px; }
  nav { display: flex; flex-wrap: wrap; gap: 0 14px; }
  .foot { display: none; }
  .reel { position: static; flex: 1; min-height: 0; gap: 12vw; padding: 34px 18vw 18px 18px; }
  :root { --frame-h: min(58vh, 120vw); --frame-gap: 8vw; }
  .reel.still { padding: 18px; }   /* home: the one photo, in the middle */
  .still figure:nth-of-type(n+2) { display: none; }     /* a phone has room for one */
  .frame { height: 50vh; }
  figure:nth-of-type(even) { margin-bottom: 9vh; }
  /* photo dump: the strip is as tall as its photos and sits half way down what is left (equal space above and below);
     the line of copy sits just under it, the same distance below the captions as on a wide screen */
  .dump .side { order: -1; }
  body.dump::before { content: ""; flex: 1 1 0; padding-top: calc(4vh - 12px); }   /* same padding as the line below, so the two spaces match */
  .dump .reel { flex: none; padding: 0 18vw 0 18px; }
  .dump .under { flex: 1 1 0; padding: calc(4vh - 12px) 18px 0; }
  /* one photograph: under the name and menu, its facts under it */
  .one { position: static; flex: 1; min-height: 0; padding: 12px 18px 18px; }
  .plate { --one-h: min(56vh, 120vw); }
  .plate .single { flex-direction: column; align-items: stretch; gap: 12px; }
  .plate .facts { width: auto; }
  .close { top: 20px; right: 18px; }
  .sheet { position: static; flex: 1; min-height: 0; padding: 50px 18px 18px 22vw; }
  .sheet h2 { margin-bottom: 18px; }
  .sheet.contact { padding: 24px 18px; }
}
@media (max-height: 520px) { .sheet, .sheet.contact { overflow-y: auto; justify-content: flex-start; } }   /* a phone on its side still reaches "send" */
@media (prefers-reduced-motion: reduce) { * { transition: none !important; } }
`````

## tools/photos.py

3350 bytes, 80 lines.

`````python
#!/usr/bin/env python3
"""Get photos ready for the site: small WebP copies and the list the pages read.

Run from the repo folder after adding photographs to photos/:

    python3 tools/photos.py

Each .jpg, .jpeg or .png in photos/ gets a WebP copy (at most 1600 pixels on the long side) next to it,
the original moves to photos/originals/, and photos.json is written with every WebP in photos/, sorted
by name. photos/details.json (the date, location, camera and film shown on a photo's own page) gets an
entry for every new set of photos, with the date read from the file name and the rest left empty to fill in;
nothing already written there is changed. Needs Pillow (python3 -m pip install pillow). Running it again changes nothing that is done.

    python3 tools/photos.py --rebuild

makes every WebP copy again from photos/originals/, for when the size or quality below changes.
"""
import json
import pathlib
import re
import sys

from PIL import Image, ImageOps

LONG_SIDE = 1400   # the largest frame is about 660 pixels tall, so this stays sharp on 2x screens
QUALITY = 75
ROOT = pathlib.Path(__file__).resolve().parent.parent
PHOTOS = ROOT / 'photos'
ORIGINALS = PHOTOS / 'originals'


def convert(src: pathlib.Path, keep: bool = False) -> pathlib.Path:
    out = PHOTOS / (src.stem + '.webp')
    with Image.open(src) as im:
        im = ImageOps.exif_transpose(im)
        if im.mode not in ('RGB', 'L'):
            im = im.convert('RGB')
        im.thumbnail((LONG_SIDE, LONG_SIDE), Image.LANCZOS)
        im.save(out, 'WEBP', quality=QUALITY, method=6)
    if not keep:
        ORIGINALS.mkdir(exist_ok=True)
        src.rename(ORIGINALS / src.name)
    return out


def main() -> int:
    if not PHOTOS.is_dir():
        print('no photos/ folder', file=sys.stderr)
        return 1
    if '--rebuild' in sys.argv[1:] and ORIGINALS.is_dir():
        for src in sorted(ORIGINALS.iterdir()):
            if src.is_file() and src.suffix.lower() in ('.jpg', '.jpeg', '.png'):
                out = convert(src, keep=True)
                print(f'{src.name} -> {out.name} ({out.stat().st_size // 1024} KB)')
    for src in sorted(PHOTOS.iterdir()):
        if src.is_file() and src.suffix.lower() in ('.jpg', '.jpeg', '.png'):
            out = convert(src)
            print(f'{src.name} -> {out.name} ({out.stat().st_size // 1024} KB)')
    names = sorted(p.name for p in PHOTOS.glob('*.webp'))
    (ROOT / 'photos.json').write_text(json.dumps(names, indent=1) + '\n')
    print(f'photos.json: {len(names)} photos')
    # details.json: one entry per set (the file name without its number), for the photo pages
    path = PHOTOS / 'details.json'
    details = json.loads(path.read_text()) if path.exists() else {}
    added = 0
    for name in names:
        key = re.sub(r'[-_]\d+$', '', pathlib.Path(name).stem)
        if key in details or name in details:
            continue
        m = re.match(r'(\d{4})[-_.]?(\d{2})[-_.]?(\d{2})', key)
        details[key] = {'date': '.'.join(m.groups()) if m else '', 'location': '', 'camera': '', 'film': ''}
        added += 1
    if added:
        path.write_text('{\n' + ',\n'.join(f' {json.dumps(k)}: {json.dumps(v)}' for k, v in details.items()) + '\n}\n')
    print(f'details.json: {len(details)} entries, {added} added')
    return 0


if __name__ == '__main__':
    sys.exit(main())
`````

## site-starter/index.html (project shared folder, first draft of 2026-11-25 07:16 UTC, never deployed)

9477 bytes, 176 lines.

`````html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Claire Tian · Photography</title>
<meta name="description" content="Claire Tian, photographer. Portfolio and bookings.">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Mono:wght@300;400;500&family=Instrument+Serif:ital@0;1&display=swap" rel="stylesheet">
<style>
  :root {
    --paper: #f6f1e7;      /* sun-bleached paper */
    --ink: #14131a;
    --muted: #8b8678;
    --sun: #f2c230;        /* late-afternoon yellow */
    --dusk: #2a2f8f;       /* blue hour */
    --mono: "DM Mono", ui-monospace, "SF Mono", Menlo, Consolas, monospace;
    --serif: "Instrument Serif", "Iowan Old Style", Georgia, serif;
    --side: 190px;
  }
  [data-mode="night"] {
    --paper: #0d0f2b;
    --ink: #ece8ff;
    --muted: #7d80b8;
    --sun: #ff5fa2;        /* neon afterglow */
    --dusk: #9db4ff;
  }
  * { box-sizing: border-box; }
  html, body { height: 100%; margin: 0; }
  body {
    background: var(--paper); color: var(--ink);
    font: 400 13px/1.55 var(--mono);
    text-transform: lowercase;
    transition: background .6s ease, color .6s ease;
    overflow: hidden;
  }
  a { color: inherit; text-decoration: none; }
  a:hover, a[aria-current] { text-decoration: underline; text-underline-offset: 4px; text-decoration-color: var(--sun); text-decoration-thickness: 2px; }

  /* sidebar */
  .side {
    position: fixed; inset: 0 auto 0 0; width: var(--side);
    padding: 28px 22px; display: flex; flex-direction: column; z-index: 3;
  }
  .name { font: italic 400 30px/1 var(--serif); letter-spacing: -.01em; margin: 0 0 26px; text-transform: none; }
  .name a > span { display: block; }
  .name .dot { color: var(--sun); font-style: normal; }
  nav a { display: block; padding: 1px 0; }
  nav a.soon { color: var(--muted); }
  .book {
    display: inline-block; margin-top: 20px; padding: 6px 12px;
    border: 1px solid var(--ink); border-radius: 999px;
  }
  .book:hover { background: var(--sun); border-color: var(--sun); color: #14131a; text-decoration: none; }
  .foot { margin-top: auto; font-size: 10px; color: var(--muted); line-height: 1.6; }
  .foot::before { content: ""; display: block; width: 18px; border-top: 1px solid var(--ink); margin-bottom: 10px; }
  .mode {
    font: inherit; color: var(--ink); background: none; border: 0; padding: 0; margin: 0 0 14px;
    cursor: pointer; text-transform: lowercase; font-size: 11px;
  }
  .mode i { display: inline-block; width: 9px; height: 9px; border-radius: 50%; background: var(--sun); margin-right: 7px; box-shadow: 0 0 12px var(--sun); }

  /* horizontal reel */
  .reel {
    position: fixed; inset: 0 0 0 var(--side);
    display: flex; gap: 22px; align-items: stretch;
    padding: 28px 28px 22px 10px;
    overflow-x: auto; overflow-y: hidden;
    scroll-snap-type: x proximity; scrollbar-width: none;
  }
  .reel::-webkit-scrollbar { display: none; }
  figure { margin: 0; flex: 0 0 auto; display: flex; flex-direction: column; scroll-snap-align: start; }
  .frame {
    flex: none; height: calc(100vh - 82px); aspect-ratio: 2 / 3; position: relative; overflow: hidden;
    transition: transform .5s cubic-bezier(.2,.7,.2,1), filter .5s;
  }
  .frame.wide { aspect-ratio: 4 / 3; }
  .frame.sq { aspect-ratio: 1; }
  figure:hover .frame { transform: translateY(-6px) rotate(-.4deg); filter: saturate(1.25); }
  .frame img { width: 100%; height: 100%; object-fit: cover; display: block; }
  /* placeholder "photos": swap each .frame's contents for an <img> */
  .p1 { background: radial-gradient(60% 45% at 30% 30%, #ffd9a0 0, transparent 70%), linear-gradient(160deg, #ff7a59, #c2185b 55%, #2a2f8f); }
  .p2 { background: radial-gradient(50% 40% at 70% 25%, #fff3b0 0, transparent 70%), linear-gradient(200deg, #f2c230, #f08a4b 50%, #7a4a2b); }
  .p3 { background: radial-gradient(45% 35% at 50% 60%, #ff5fa2 0, transparent 70%), linear-gradient(180deg, #10143d, #2a2f8f 60%, #0d0f2b); }
  .p4 { background: radial-gradient(70% 50% at 20% 80%, #b8f2e6 0, transparent 70%), linear-gradient(140deg, #8fd3f4, #5a6ad6 60%, #2b1f5c); }
  .p5 { background: radial-gradient(55% 40% at 60% 40%, #ffe8f1 0, transparent 70%), linear-gradient(170deg, #ffb3c7, #e86aa6 55%, #6a2c70); }
  .p6 { background: radial-gradient(60% 50% at 40% 30%, #f6f1e7 0, transparent 70%), linear-gradient(190deg, #cfd6c4, #7d8f69 60%, #2f3b2a); }
  .frame::after { /* film grain */
    content: ""; position: absolute; inset: 0; opacity: .32; mix-blend-mode: overlay; pointer-events: none;
    background-image: url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='160' height='160'><filter id='n'><feTurbulence type='fractalNoise' baseFrequency='.9' numOctaves='2' stitchTiles='stitch'/></filter><rect width='100%' height='100%' filter='url(%23n)'/></svg>");
  }
  .tag {
    position: absolute; left: 10px; top: 10px; z-index: 1; padding: 2px 7px;
    background: var(--sun); color: #14131a; font-size: 10px; transform: rotate(-3deg);
  }
  figcaption { padding-top: 8px; font-size: 11px; display: flex; justify-content: space-between; gap: 12px; }
  figcaption em { font: italic 15px/1 var(--serif); text-transform: none; }
  figcaption span { color: var(--muted); }

  .intro { flex: 0 0 min(340px, 70vw); display: flex; flex-direction: column; justify-content: flex-end; padding: 0 18px 30px 6px; scroll-snap-align: start; }
  .intro h2 { font: italic 400 clamp(44px, 6vw, 76px)/.92 var(--serif); margin: 0 0 18px; text-transform: none; letter-spacing: -.02em; }
  .intro h2 b { font-weight: 400; font-style: normal; color: var(--dusk); }
  .intro p { margin: 0; max-width: 30ch; }
  .hint { margin-top: 18px; color: var(--muted); font-size: 11px; }

  @media (max-width: 720px) {
    body { overflow: auto; }
    .side { position: static; width: auto; flex-direction: row; flex-wrap: wrap; gap: 6px 16px; align-items: baseline; padding: 20px 18px 6px; }
    .name { margin: 0; flex-basis: 100%; }
    .name a > span { display: inline; }
    nav { display: flex; flex-wrap: wrap; gap: 0 14px; }
    .book { margin-top: 8px; }
    .foot { display: none; }
    .reel { position: static; flex-direction: column; padding: 14px 18px 40px; overflow: visible; }
    .intro { flex: none; padding: 20px 0; }
    .frame { height: auto; width: 100%; }
    .hint { display: none; }
  }
  @media (prefers-reduced-motion: reduce) { * { transition: none !important; } }
</style>
</head>
<body>
  <aside class="side">
    <h1 class="name"><a href="./"><span>Claire</span> <span>Tian<span class="dot">.</span></span></a></h1>
    <nav aria-label="Main">
      <a href="#work" aria-current="page">work</a>
      <a href="#" class="soon">portraits</a>
      <a href="#" class="soon">editorial</a>
      <a href="#" class="soon">film</a>
      <a href="#" class="soon">about</a>
      <a href="#" class="soon">contact</a>
    </nav>
    <a class="book" href="#">book a shoot →</a>
    <div class="foot">
      <button class="mode" id="mode" type="button" aria-pressed="false"><i></i><span>go to night</span></button>
      <div>all photographs © <span id="yr"></span> claire tian.<br>please ask before you use them.</div>
    </div>
  </aside>

  <main class="reel" id="work" tabindex="0" aria-label="Selected work, scroll sideways">
    <section class="intro">
      <h2>soft light,<br><b>loud</b> feelings.</h2>
      <p>photographs of people at the exact second they forget the camera is there.</p>
      <div class="hint">scroll sideways →</div>
    </section>
    <figure><div class="frame p1"><span class="tag">new</span></div><figcaption><em>Bedroom Fire</em><span>01</span></figcaption></figure>
    <figure><div class="frame wide p2"></div><figcaption><em>Sunburn Season</em><span>02</span></figcaption></figure>
    <figure><div class="frame p3"></div><figcaption><em>Blue Hour, 2 a.m.</em><span>03</span></figcaption></figure>
    <figure><div class="frame sq p4"></div><figcaption><em>Pool Lights</em><span>04</span></figcaption></figure>
    <figure><div class="frame p5"></div><figcaption><em>Glitter on the Carpet</em><span>05</span></figcaption></figure>
    <figure><div class="frame wide p6"></div><figcaption><em>Somewhere Green</em><span>06</span></figcaption></figure>
  </main>

<script>
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
  reel.addEventListener('wheel', e => {
    if (matchMedia('(max-width: 720px)').matches) return;
    if (Math.abs(e.deltaY) > Math.abs(e.deltaX)) { reel.scrollLeft += e.deltaY; e.preventDefault(); }
  }, { passive: false });
</script>
</body>
</html>
`````
