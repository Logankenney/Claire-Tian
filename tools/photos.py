#!/usr/bin/env python3
"""Get photos ready for the site: high-resolution WebP copies, lighter sizes of each, and the lists the pages read.

Run from the repo folder after adding photographs to photos/:

    python3 tools/photos.py

Each .jpg, .jpeg or .png in photos/ gets a high-resolution WebP copy next to it (the original's full size, up
to 2400 pixels on the long side, for sharp photos on high-density screens and on a photo's own page), plus
lighter copies 400, 600, 800, 1000 and 1200 pixels wide in photos/w400/ to photos/w1200/ (only the widths smaller than
the original). The pages ask the browser to fetch the smallest copy that is sharp on the screen in use, so a
phone or an ordinary screen loads a fraction of the bytes. The original moves to photos/originals/,
photos.json is written with every WebP in photos/, sorted by name, and photos/sizes.json records each
photo's pixel size and its lighter widths. photos/details.json (the date, location, camera and film shown on a photo's own page) gets an
entry for every new set of photos, with the date read from the file name and the rest left empty to fill in;
nothing already written there is changed. Needs Pillow (python3 -m pip install pillow). Running it again changes nothing that is done.

    python3 tools/photos.py --rebuild

makes every WebP copy (and every lighter size) again from photos/originals/, for when the size or quality below
changes.
"""
import json
import pathlib
import re
import sys

from PIL import Image, ImageOps

LONG_SIDE = 2400   # a frame is up to 84% of the window's height; on a 2x screen that is about 2400 pixels
QUALITY = 80       # high-resolution copy: no visible loss next to the original
WIDTHS = (400, 600, 800, 1000, 1200)   # lighter copies for the browser to pick from (srcset), each at most this wide
SMALL_QUALITY = 72  # downscaled copies hide compression well; film grain stays
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
        for w in WIDTHS:
            if w >= im.width:
                continue
            small = im.resize((w, round(im.height * w / im.width)), Image.LANCZOS)
            folder = PHOTOS / f'w{w}'
            folder.mkdir(exist_ok=True)
            small.save(folder / out.name, 'WEBP', quality=SMALL_QUALITY, method=6)
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
    # sizes.json: each photo's pixel size and the lighter widths made for it, so the pages can offer the browser
    # every size (srcset) and reserve the frame before the photo arrives
    sizes = {}
    for name in names:
        with Image.open(PHOTOS / name) as im:
            w, h = im.size
        sizes[name] = {'w': w, 'h': h, 'widths': [x for x in WIDTHS if (PHOTOS / f'w{x}' / name).exists()]}
    (PHOTOS / 'sizes.json').write_text('{\n' + ',\n'.join(f' {json.dumps(k)}: {json.dumps(v)}' for k, v in sizes.items()) + '\n}\n')
    print(f'sizes.json: {len(sizes)} photos')
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
