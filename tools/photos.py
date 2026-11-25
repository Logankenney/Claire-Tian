#!/usr/bin/env python3
"""Get photos ready for the site: small WebP copies and the list the pages read.

Run from the repo folder after adding photographs to photos/:

    python3 tools/photos.py

Each .jpg, .jpeg or .png in photos/ gets a WebP copy (at most 1600 pixels on the long side) next to it,
the original moves to photos/originals/, and photos.json is written with every WebP in photos/, sorted
by name. Needs Pillow (python3 -m pip install pillow). Running it again changes nothing that is done.
"""
import json
import pathlib
import sys

from PIL import Image, ImageOps

LONG_SIDE = 1600
QUALITY = 80
ROOT = pathlib.Path(__file__).resolve().parent.parent
PHOTOS = ROOT / 'photos'
ORIGINALS = PHOTOS / 'originals'


def convert(src: pathlib.Path) -> pathlib.Path:
    out = src.with_suffix('.webp')
    with Image.open(src) as im:
        im = ImageOps.exif_transpose(im)
        if im.mode not in ('RGB', 'L'):
            im = im.convert('RGB')
        im.thumbnail((LONG_SIDE, LONG_SIDE), Image.LANCZOS)
        im.save(out, 'WEBP', quality=QUALITY, method=6)
    ORIGINALS.mkdir(exist_ok=True)
    src.rename(ORIGINALS / src.name)
    return out


def main() -> int:
    if not PHOTOS.is_dir():
        print('no photos/ folder', file=sys.stderr)
        return 1
    for src in sorted(PHOTOS.iterdir()):
        if src.is_file() and src.suffix.lower() in ('.jpg', '.jpeg', '.png'):
            out = convert(src)
            print(f'{src.name} -> {out.name} ({out.stat().st_size // 1024} KB)')
    names = sorted(p.name for p in PHOTOS.glob('*.webp'))
    (ROOT / 'photos.json').write_text(json.dumps(names, indent=1) + '\n')
    print(f'photos.json: {len(names)} photos')
    return 0


if __name__ == '__main__':
    sys.exit(main())
