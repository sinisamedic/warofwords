"""Create small web derivatives of existing project art; run from repository root."""
from pathlib import Path
from PIL import Image
import shutil

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'website' / 'wow' / 'assets'
OUT.mkdir(parents=True, exist_ok=True)
sources = {
    'hero': ('game/assets/art/endless/mode-campaign.png', 1400),
    'sky': ('game/assets/art/endless/sky-court.png', 1700),
    'endless': ('game/assets/art/endless/mode-endless.png', 800),
    'daily': ('game/assets/art/endless/mode-daily.png', 800),
    'campaign': ('game/assets/art/endless/mode-campaign.png', 800),
    'battle': ('.local/manual-rank-final/battle-en.png', 1440),
    'arsenal': ('.local/wave-two-qa/arsenal-ember-en.png', 1440),
    'home': ('.local/manual-rank-final/home-en.png', 1440),
    'ember': ('game/assets/art/equipment-ember.png', 360),
    'bastion': ('game/assets/art/equipment-bastion.png', 360),
    'siphon': ('game/assets/art/equipment-siphon.png', 360),
    'icon': ('game/assets/launcher/icon-main.png', 96),
}
for name, (source, size) in sources.items():
    with Image.open(ROOT / source) as img:
        img.thumbnail((size, size), Image.Resampling.LANCZOS)
        img.save(OUT / f'{name}.webp', quality=86, method=6)
for name in ['Cinzel.ttf', 'Lora.ttf']:
    shutil.copyfile(ROOT / 'game/assets/fonts' / name, OUT / name)
for name in ['Cinzel-OFL.txt', 'Lora-OFL.txt']:
    text = (ROOT / 'game/licenses' / name).read_text(encoding='utf-8')
    (OUT / name).write_text('\n'.join(line.rstrip() for line in text.splitlines()) + '\n', encoding='utf-8')
print('Prepared', len(sources), 'images and licensed local fonts.')
