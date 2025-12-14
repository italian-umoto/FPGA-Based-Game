from PIL import Image
from pathlib import Path

# ========== USER SETTINGS ==========
IN_DIR = Path(r"vga_assets\PNG File")
OUT_FILE = Path(r"vga_assets\mem File\digits.mem")   # output .mem
W = 20
H = 30

FILES = [
    "zero.png", "one.png", "two.png", "three.png", "four.png",
    "five.png", "six.png", "seven.png", "eight.png", "nine.png"
]
# ===================================

def rgb_to_rgb6(r, g, b):
    return ((r >> 6) << 4) | ((g >> 6) << 2) | (b >> 6)  # 0..63

def convert_one(img_path: Path):
    img = Image.open(img_path).convert("RGB")
    img = img.resize((W, H), Image.NEAREST)
    px = img.load()

    vals = []
    for y in range(H):
        for x in range(W):
            r, g, b = px[x, y]
            vals.append(rgb_to_rgb6(r, g, b))
    return vals

def main():
    all_vals = []
    for name in FILES:
        p = IN_DIR / name
        if not p.exists():
            raise SystemExit(f"Missing file: {p}")
        all_vals.extend(convert_one(p))
        print(f"Added {name} ({W*H} pixels)")

    OUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT_FILE, "w") as f:
        for v in all_vals:
            f.write(f"{v:02X}\n")

    print(f"\nWrote {len(all_vals)} entries to {OUT_FILE}")
    print(f"Expected: {10*W*H} entries")

if __name__ == "__main__":
    main()
