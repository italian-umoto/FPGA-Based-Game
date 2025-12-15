from PIL import Image
from pathlib import Path

# ===============================
# USER-EDITABLE PARAMETERS
# ===============================
INPUT_IMAGE = r"vga_assets\PNG File\bone.png"
BG_W = 160
BG_H = 120

# ===============================
# AUTO OUTPUT NAME
# ===============================
img_path = Path(INPUT_IMAGE)
OUT_FILE = img_path.stem + ".mem"   # "one.png" -> "one.mem"

# ===============================
# CONVERSION LOGIC
# ===============================
def rgb_to_rgb6(r, g, b):
    r2 = r >> 6
    g2 = g >> 6
    b2 = b >> 6
    return (r2 << 4) | (g2 << 2) | b2  # RRGGBB (6 bits)

img = Image.open(img_path).convert("RGB")
img = img.resize((BG_W, BG_H), Image.NEAREST)

px = img.load()

with open(OUT_FILE, "w") as f:
    for y in range(BG_H):
        for x in range(BG_W):
            r, g, b = px[x, y]
            val = rgb_to_rgb6(r, g, b)
            f.write(f"{val:02X}\n")

print(f"Wrote {BG_W * BG_H} pixels to {OUT_FILE}")
print(f"Source image: {img_path}")
