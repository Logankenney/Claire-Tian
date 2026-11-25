# Claire-Tian

A development project starting with a website, expanding into social media management, and eventually supporting a multi-model processing system.

## Website

A plain static site served by GitHub Pages at https://www.claire-tian.com. There is no build step: what is in `main` is what is served.

| File | What it is |
|---|---|
| `index.html` | Home page: the two lines of copy and the first three frames, shrunk to fit; it does not scroll or change |
| `work.html` | Work page: the sideways reel, three frames at a time, with the scroll arrow |
| `recent.html` | Recent shots, newest first, in the same sideways strip, with the short about copy |
| `contact.html` | The contact address and the "i have an idea" box |
| `styles.css` | All styling: light, black and white, lowercase |
| `site.js` | Loads photos from `photos/`, turns the work page when "work" is clicked, sideways scrolling |
| `photos/` | Drop photographs here and the site shows them (see `photos/README.md`) |
| `booking.js` | The contact address (`CONTACT_EMAIL`, one line) and the idea box |
| `CNAME` | The domain GitHub Pages serves |

To preview, run `python3 -m http.server` in this folder and open http://localhost:8000.

**Still placeholder:** the grey frames on the home, work and recent shots pages, until `photos/` has photographs in it. The contact address `hello@claire-tian.com` is real and forwards to Claire.

**Booking:** the contact page has one prompt, "i have an idea", and one text box. The site has no server, so sending opens the visitor's email app with the idea filled in. A form service or a scheduling embed can replace it later.

**Deploying:** Settings > Pages > "Deploy from a branch", branch `main`, folder `/ (root)`. Every merge to `main` then publishes on its own.
