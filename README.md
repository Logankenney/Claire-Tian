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
| `stats.js` | The visitor log: sends each page view, time on page, sideways scroll and clicks (photos, ig, send) to the Supabase function `hit`. No cookies; the server keeps each visitor's ip address (deleted after 400 days). Browser storage is listed in `docs/cookies-register.json` |
| `privacy.html` | One line on the visitor log and a "privacy" link to `legal.html`; linked as "privacy" under the footer (bottom left on phones) |
| `legal.html` | The full legal and privacy page (privacy notice and terms of use). Reached only from the link on `privacy.html`: not in the menu or footer, `noindex` |
| `analytics/` | The Supabase side: `schema.sql` (table and `record_hit`), `weekly.sql` (`weekly_report_data`), `hit/index.ts` (the edge function), `ip.sql` (ip addresses, country and network, `weekly_access_data`, the ML visitor code) |
| `tools/weekly_report.py` | Writes the Friday site report (status board, issues with sub-tasks, priority emails, agent processes, traffic, visitor access by ip address, cookies register check, SEO, competition) from `weekly_report_data` + `weekly_access_data` JSON |
| `docs/cookies-register.json` | The cookies register: every cookie and browser storage item the site sets and every outside service a page load reaches; the weekly report flags anything in the code that is not listed |

To preview, run `python3 -m http.server` in this folder and open http://localhost:8000.

**Still placeholder:** the grey frames on the home and photo dump pages, until `photos/` has photographs in it. The contact address `hello@claire-tian.com` is real and forwards to Claire.

**Booking:** the contact page has one prompt, "i have an idea", and one text box. The site has no server, so sending opens the visitor's email app with the idea filled in. A form service or a scheduling embed can replace it later.

**Deploying:** Settings > Pages > "Deploy from a branch", branch `main`, folder `/ (root)`. Every merge to `main` then publishes on its own.

**Colour:** photographs are shown black and white by one line at the top of `styles.css` (`--photo`). Change it to `--photo: none;` to show them in colour.

**Visitor log and weekly report:** every page loads `stats.js`, which posts to the Supabase project `claire-tian-analytics`. Visit any page with `?notrack` to stop counting your own browser (`?track` to start again). Every Friday at 8 AM Eastern a scheduled Claude task reads the week's numbers, runs `tools/weekly_report.py`, files the report in Jarvis Document Control (projects/Claire-Tian/Reports/<date>), logs the week's visitor metadata to the Jarvis ML dataset `claire_tian_visitors` (ip addresses only as a one-way code), and emails a link to it.

**Turning on ip addresses (once, after this is merged):** run `analytics/ip.sql` in the Supabase SQL editor, then redeploy the `hit` function from `analytics/hit/index.ts`. For country and network, make a free ipinfo.io account and add its token as the secret `IPINFO_TOKEN` (Supabase > Edge Functions > Secrets).
