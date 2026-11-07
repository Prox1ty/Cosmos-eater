"""Build one shared VGA palette + raw sprite files from RGB(A) PNGs.

usage:  python build_assets.py bg.png player.png enemy.png coin.png digits.png

outputs:
  game.pal      768 bytes, 256 x (R,G,B), each 0..63
  <name>.raw    one byte per pixel (palette index), one file per input

Index 0 is reserved for "transparent" (shown as magenta if ever drawn).
Pixels with alpha < 128 become index 0.
"""
import sys
from PIL import Image

files = sys.argv[1:]
if not files:
    sys.exit(__doc__)

imgs = [Image.open(f).convert("RGBA") for f in files]


def pixels(im):
    raw = im.tobytes()  # RGBA, 4 bytes per pixel, row by row
    return [tuple(raw[i:i + 4]) for i in range(0, len(raw), 4)]


# collect every distinct visible color across all images
colors = {}  # (r, g, b) -> palette index, starting at 1
for im in imgs:
    for r, g, b, a in pixels(im):
        if a >= 128 and (r, g, b) not in colors:
            colors[(r, g, b)] = len(colors) + 1

if len(colors) > 255:
    sys.exit(f"{len(colors)} distinct colors across all images; the limit is 255 "
             "(slot 0 is reserved). Reduce colors in LibreSprite or split by level.")

# palette file: 6-bit values, slot 0 = magenta
pal = bytearray(768)
pal[0:3] = bytes((63, 0, 63))
for (r, g, b), i in colors.items():
    pal[i * 3:i * 3 + 3] = bytes((r >> 2, g >> 2, b >> 2))
open("game.pal", "wb").write(pal)

# one .raw per image
for f, im in zip(files, imgs):
    data = bytes(0 if a < 128 else colors[(r, g, b)] for r, g, b, a in pixels(im))
    out = f.rsplit(".", 1)[0] + ".raw"
    open(out, "wb").write(data)
    print(f"{out}: {im.width}x{im.height} = {len(data)} bytes")

print(f"game.pal written, {len(colors)} colors used (+ slot 0 transparent)")