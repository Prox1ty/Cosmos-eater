# conv.py  ->  python conv.py bg.png bg
import sys
from PIL import Image
im = Image.open(sys.argv[1])
assert im.mode == 'P', "export as indexed"
pal = (im.getpalette() + [0]*768)[:768]
open(sys.argv[2] + '.pal', 'wb').write(bytes(v >> 2 for v in pal))
open(sys.argv[2] + '.raw', 'wb').write(im.tobytes())