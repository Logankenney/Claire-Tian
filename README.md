# Claire-Tian

A development project starting with a website, expanding into social media management, and eventually supporting a multi-model processing system.

## Website

A plain static site served by GitHub Pages at https://www.claire-tian.com. There is no build step: what is in `main` is what is served.

| File | What it is |
|---|---|
| `index.html` | Home page: the two lines of copy and three frames, shrunk to fit; it does not scroll or change |
| `work.html` | Work page: the sideways reel, ten frames in the strip, with the scroll arrow |
| `recent.html` | Recent shots, newest first, in the same sideways strip, with the short about copy |
| `contact.html` | The contact address and the "i have an idea" box |
| `styles.css` | All styling: light, black and white, lowercase |
| `site.js` | Loads the photos listed in `photos.json` in a new random order on each page load, turns the work page when "work" is clicked, sideways scrolling |
| `photos/` | The photographs, as small WebP copies; originals in `photos/originals/` (see `photos/README.md`) |
| `photos.json` | The list of photos the pages show, written by `tools/photos.py` |
| `tools/photos.py` | Makes WebP copies of new photos and rewrites `photos.json` |
| `booking.js` | The contact address (`CONTACT_EMAIL`, one line) and the idea box |
| `CNAME` | The domain GitHub Pages serves |

To preview, run `python3 -m http.server` in this folder and open http://localhost:8000.

**Still placeholder:** the grey frames on the home, work and recent shots pages, until `photos/` has photographs in it. The contact address `hello@claire-tian.com` is real and forwards to Claire.

**Booking:** the contact page has one prompt, "i have an idea", and one text box. The site has no server, so sending opens the visitor's email app with the idea filled in. A form service or a scheduling embed can replace it later.

**Deploying:** Settings > Pages > "Deploy from a branch", branch `main`, folder `/ (root)`. Every merge to `main` then publishes on its own.

**Colour:** photographs are shown black and white by one line at the top of `styles.css` (`--photo`). Change it to `--photo: none;` to show them in colour.
