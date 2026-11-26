# Claire-Tian history log

The story of the project from first message to closeout, compiled on 2026-11-25 from the project chat, the git history of `Logankenney/Claire-Tian`, its pull requests, and the Jarvis Document Control records. All times are UTC and every event below happened on 2026-11-25. The whole build took one day.

## What was built

A static photography site for Claire Tian at https://www.claire-tian.com, served by GitHub Pages from the `main` branch of `Logankenney/Claire-Tian`, with no build step. At closeout it has four pages:

- **home** (`index.html`): three portrait photos, level and centred, shuffled on every load. No copy, no links, no scrolling.
- **photo dump** (`recent.html`): a sideways strip of the ten newest photos with one line under them, "the moments that transcend time".
- **photo page** (`photo.html?p=<file>`): opens from a photo on photo dump and shows it large in full colour with date, location, camera and film.
- **contact** (`contact.html`, menu label "contact... please don't"): "i have an idea", one text box and "send", which opens the visitor's email app.

Photos show in black and white and fade to their own colour while the mouse is on them. The site is light mode only, lowercase, mono type, on a paper background, and nothing scrolls up or down.

## Timeline

### 1. Start, plan and first draft (07:08 to 07:46)

- 07:08 The project opens. Logan asks for a photography site with booking, a GitHub repository, and later agents that manage a social media presence.
- 07:09 Logan: start with a GitHub repo and a public page; the owned domain is www.claire-tian.com. 07:13: the domain is at GoDaddy.
- 07:13 to 07:14 First design brief: edgy, very Gen-Z, after the style of petra-collins.com, with elements of Lorde's visual mood. Treated as inspiration for an original design.
- 07:16 First starter page drafted: quiet sidebar, typewriter text, sideways photo strip, a sun-bleached day look and a "go to night" switch. Saved to the project's shared folder as `site-starter/`.
- 07:18 to 07:20 Logan asks for the project to be logged with Jarvis (his own multi-agent system, repository `Logankenney/ai-multi-agent-vm`) and to use its unified memory.
- 07:25 The repository `Logankenney/Claire-Tian` is created and initialised (commit `d16b13f`). 07:27 Logan: "repo is created".
- 07:44 PR #1 opens with the starter site and the `CNAME` file for the domain.

### 2. Going live: Jarvis, DNS, Pages and HTTPS (07:33 to 09:36)

- 07:33 to 08:09 Claire-Tian is registered as a Jarvis project (Jarvis PR #191, Action Log 58k).
- 08:09 Logan's standing rule: "with every merge, create a revision and send full file to jarvis document control". Recorded in Jarvis (PR #194, Action Log 58l).
- 08:10 PR #1 merges: home, about, services, booking and contact pages. This is Rev 0.
- 08:18 Logan gives the booking address: `hello@claire-tian.com`, to forward to a private inbox (the inbox address is deliberately kept out of this public repository).
- 08:18 to 08:25 GoDaddy DNS is changed in Logan's Chrome, where he was signed in: four `A` records for `@` (185.199.108.153, 185.199.109.153, 185.199.110.153, 185.199.111.153) and a `www` `CNAME` to `logankenney.github.io`. The Claude desktop built-in browser was not available on his computer, so Chrome was used.
- 08:24 The GoDaddy account has no free email forwarding. Logan chooses to skip email for now. At closeout `hello@claire-tian.com` still does not receive mail.
- 08:25 to 08:35 GitHub Pages was set to deploy from a workflow the repository does not have, so nothing had been published. Logan approves switching it to "Deploy from a branch", `main`, `/ (root)`.
- 09:31 to 09:36 Logan asks for confirmation. The Pages setting is re-saved, a deployment runs, and the site is confirmed live over HTTPS at https://www.claire-tian.com, with "Enforce HTTPS" on.

### 3. The redesign (08:38 to 09:50)

- 08:38 Logan sees the first preview (the colourful day and night version) and marks it up with pinned comments.
- 08:43 to 09:29 The site is restyled on PR #2 to Logan's new direction: light mode only, no colour, black and white on paper, minimalist, all lowercase, a layout that is "slightly unapproachable", no vertical scrolling anywhere, portrait frames only. About, services and book pages are removed. Home and work are split, recent shots is added, and contact becomes one prompt.
- 09:40 Logan's second standing rule: "auto merge all open pr's moving forward, use auto deployment once confirmed all passes". PR #2 merges at 09:41 (Rev 1) and from here every PR merges as soon as it is ready.
- 09:45 to 09:49 Copy edits from a marked-up screenshot go in as PR #3 (Rev 2): "the moments that transcend time" and "nyc and analog based".

### 4. Photographs (09:50 to 10:52)

- 09:50 to 09:52 Instagram does not allow photos to be pulled directly, so Logan asks for Jarvis's screen grab on his computer to capture them from instagram.com/maisonsumika. He confirms he has permission to use the photos, and says originals will later go into a Jarvis Document Control photo repository that also feeds styling for the social posting agents.
- 09:58 to 10:00 Filing rules: the grabs are saved as "Claire's Posts" under Claire-Tian > Ai Social > Instagram, and all documentation for this project goes in the Jarvis Document Control project folder "Claire-Tian".
- 10:01 PR #4 (Rev 3): 26 portrait photos replace the grey stand-in frames.
- 10:12 to 10:23 "Claire's Posts" is filed in Jarvis: 42 images and 5 reel videos (Jarvis PR #211, Action Log 58z).
- 10:15 Logan states that all faces, images and likenesses are approved for use and owned by Claire Tian, and that he is authorised to act on her behalf.
- 10:17 to 10:30 PRs #5 to #7 (Rev 4 to 6): home stops scrolling, work holds ten frames, photos shuffle on every load, and stylesheet and script links are versioned so browsers drop stale copies.
- 10:50 Logan's photo rule: no posed portraits of people; people appear only in candid or unposed photos. PR #8 (Rev 7) removes the one posed wedding portrait, leaving 25 photos. The same message starts the Jarvis lessons learned registers (Jarvis PRs #221, #232, #237), handled in a separate thread.

### 5. Layout rounds (12:00 to 13:29)

Logan asks to edit the design and to see the page only after all his comments are in. Twelve pull requests follow in ninety minutes:

- 12:02 PR #9 (Rev 8): home images about 60% larger, level and centred.
- 12:07 PR #10 (Rev 9): contact is only the idea box; "film. nyc." leaves the footer.
- 12:33 PR #11 (Rev 10): recent shots laid out like home.
- 12:47 PR #12 (Rev 11): small WebP copies of the photos and a saved photo list (`photos.json`, `tools/photos.py`); the work page is removed and recent shots is renamed photo dump.
- 12:53 PR #13 (Rev 12): lighter photos (2.7 MB to 2.0 MB) and a larger "claire tian".
- 12:57 PR #14 (Rev 13): home line under the photos, menu level with them.
- 13:03 Logan asks for a full check before more edits. It passes; the one gap noted is the missing email forwarding, which Logan says to ignore for now.
- 13:07 PR #15 (Rev 14): photo dump copy centred, eight photos in the strip.
- 13:10 PR #16 (Rev 15): contact prompt and text box left-justified.
- 13:16 PR #17 (Rev 16): "the moments that" / "transcend time" on two lines.
- 13:22 PR #18 (Rev 17): home and photo dump share one set of photo rules; "only feelings" and "analog when it was still cool" move to photo dump.
- 13:29 PR #19 (Rev 18): captions keep "35mm" and show no dates.

### 6. Photo dump, colour on hover and photo pages (14:02 to 22:47)

- 14:07 PR #20 (Rev 19): photo dump loses its side copy, arrow and footer line; the current page in the menu has no strikethrough.
- 14:16 PR #21 (Rev 20): photo numbers removed from captions across the site.
- 14:25 PR #22 (Rev 21): photos fade from black and white to their original colour under the mouse, and back.
- 14:32 PR #23 (Rev 22): the photo dump strip shows the ten newest photos.
- 14:26 Logan asks for a page for each photo and, for the first time, for a pull request that is not auto-merged. 14:36 PR #24 opens with the pages in three looks (A "log", B "edge", C "rebate") and waits for his choice.
- 14:41 PR #25 (Rev 23): the colour holds across the whole photo tile until the mouse leaves it.
- 15:40 PR #26 (Rev 24): the photo dump line moves from over the photos to under them.
- 22:25 Logan chooses look A on a decision card. Looks B and C are removed. 22:38 Logan writes "merge pr 24" and it merges (Rev 25).
- 22:44 to 22:47 Logan: photos on home should not open anything. PR #27 (Rev 26): photo pages open from photo dump only, and a photo on its own page shows in colour.

### 7. Closeout (23:56)

- 23:56 Logan: "this came out great", and asks for the project to be resolved for now with a history log, action log, edit log, PR log, compiled text files and a zip batch that prepares for a possible repository move. This folder is that package (PR #28, Rev 27, merged 2026-11-26 00:02).
- 2026-11-26 01:16 to 01:20 Logan asks for a PDF presentation of the whole project, step by step, with prompts and responses together; for it to be added to the hand off package; and for two versions of the package, one for Windows and Linux and one for macOS. `PROJECT_STORY.pdf` and the Linux and macOS scripts are added as Rev 28.

## Design previews

The shared project folder keeps the screenshots made for each review round, under `site-preview/` in folders `v2` to `v24` plus `photo-page/` (the three looks) and `photo-page-final/`. They are listed with checksums in `FILE_MANIFEST.md`. The version numbers are review rounds, not releases: several rounds could go into one pull request, and some pull requests needed no preview.

## Standing rules that shaped the work

| When | Rule (Logan) |
|---|---|
| 08:09 | With every merge, create a revision and send the full file to Jarvis Document Control. |
| 09:40 | Auto-merge all open PRs once everything passes, and auto-deploy. |
| 10:00 | All documentation for the project goes in the Jarvis Document Control folder "Claire-Tian". |
| 10:15 | All faces, images and likenesses are approved for use and owned by Claire Tian. |
| 10:50 | No posed portraits of people; people only in candid or unposed photos. |
| 12:01 | Apply all comments first, then show the updated page. |

## Open at closeout

- **Email:** `hello@claire-tian.com` has no forwarding, so "send" on the contact page opens an email that will not be received until forwarding is set up (a paid GoDaddy plan, or a free forwarder such as ImprovMX).
- **Photo details:** camera and film are blank for all four photo sets and show as dashes.
- **Originals:** the site uses stand-ins captured from Instagram. Full-resolution originals have not been added to the Jarvis Photo Repository.
- **Booking:** the contact box is the only booking path. A form service or scheduling embed was left for later.
- **Social media agents:** not started.
- **README:** the file table in the repository `README.md` still describes an earlier layout in places (for example it says home shows two lines of copy). The pages themselves are as described above.
