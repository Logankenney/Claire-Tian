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
