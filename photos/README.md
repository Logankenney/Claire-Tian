# photos

Drop photographs in this folder, then run `python3 tools/photos.py` from the repo folder (or ask Claude to). It
makes a small WebP copy of each new photo (at most 1400 pixels on the long side), moves the original to
`photos/originals/`, and rewrites `photos.json`, the list the pages read. A photo that is not in `photos.json`
does not show.

- Use `.jpg`, `.jpeg`, `.png` or `.webp`. Any size; the script shrinks it.
- Every frame on the site is portrait (2 by 3). A landscape or square photo is cropped to its middle, so portrait originals look best.
- **home** picks three from this folder in a new random order every time the page loads, and does not scroll.
- **home** and **photo dump** show photos the same way: same size and shape, same gap, same black and white, the same caption ("35mm"; no numbers, no dates).
- **photo dump** shows the eight newest, judged by file name. Name files so newer ones sort later, for example `2026-11-03-subway.jpg`.
- The file name, without the date and extension, is used as the photo's description for screen readers.

Until this folder has photos, the pages show grey stand-in frames.

## people

people appear only in candid or unposed photographs. no posed portraits: nobody looking into the lens, arranged for the picture. if a photo is unclear, leave it out and ask.
