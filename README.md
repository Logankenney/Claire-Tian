# Claire-Tian

A development project starting with a website, expanding into social media management, and eventually supporting a multi-model processing system.

## Website

A plain static site served by GitHub Pages at https://www.claire-tian.com. There is no build step: what is in `main` is what is served.

| File | What it is |
|---|---|
| `index.html` | Home page: the sideways reel of work |
| `about.html`, `services.html`, `contact.html` | The inner pages |
| `book.html` | Booking request form |
| `styles.css` | All styling, including the day and night colors |
| `site.js` | Day/night switch and sideways scrolling |
| `booking.js` | The contact address (`CONTACT_EMAIL`, one line) and the booking form |
| `CNAME` | The domain GitHub Pages serves |

To preview, run `python3 -m http.server` in this folder and open http://localhost:8000.

**Still placeholder:** the colored panels (swap each for an `<img>`, see the comment in `index.html`), the bio, the services and prices, the social links, and the contact address `hello@claire-tian.com`.

**Booking:** the site has no server, so the form opens the visitor's email app with the request filled in. A form service or a scheduling embed can replace it later.

**Deploying:** Settings > Pages > "Deploy from a branch", branch `main`, folder `/ (root)`. Every merge to `main` then publishes on its own.
