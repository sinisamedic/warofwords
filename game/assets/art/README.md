# Production artwork

## Breach illustration revision — 2026-09-18

`equipment-breach.png` is an original built-in OpenAI ImageGen illustration of a gold energy lance splitting steel armor. It replaces the temporary procedural arrow/shield symbol across equipment views and battle. Our `equipment-mirror.png` supplied only the rendering style and medallion presentation; the central illustration is new. The generated PNG is copied unchanged (2,862,978 bytes); Godot imports it with a 512-pixel limit and mipmaps, like the other equipment icons. Exact prompt, reference role and original source filename: `prompts-breach.json`.

Generated for this project under applicable OpenAI terms; no third-party stock license is claimed. This file is below 10 MiB, so no new LFS pattern is required. Launcher icon proposals are separately documented in `../../../design/icon-proposals/README.md` and are not production assets yet.

## 0.1.6 preview artwork — 2026-09-17

Four original built-in ImageGen outputs, copied unchanged with source identifiers and exact prompts in `prompts-0.1.6.json`:

- `campaign-sunward.png`, `campaign-sky.png`, `campaign-observatory.png`: one landscape for each campaign location. Existing `map.png` was a style reference. Runtime uses a 0.55-second dissolve with slight panning between chapters.
- `hero-parts.png`: nine-part RGBA cutout atlas based on our existing heroine in `fighters.png`. `hero_rig.gd` selects regions at runtime, places overlapping joints, and animates torso, head, arms and coat with AnimationPlayer. No bitmap slicing or external character art. Small alpha noise is suppressed by the runtime shader.

After user review of the large cutout, **the home screen retains the original intact `fighters.png` illustration**. The articulated version is used only in battle. Its defeat pose now bends the existing leg regions with small Polygon2D meshes (`hero_leg.gd`) while separate torso, head, coat and arm joints collapse. UVs sample the unchanged atlas. Enemies use a runtime disintegration shader for defeat. All four new PNG files are individually below 10 MiB; no LFS patterns needed for this set. Approved screen design masters are unchanged.

## Previous artwork

Generated with OpenAI ImageGen on 2026-09-16 for this project, using our approved original screen designs as style references. No Slugterra screenshots or characters are shipped. Source PNGs are retained without bitmap post-processing. Exact prompts: `prompts.json`.

| File | Purpose | Original generated output |
| --- | --- | --- |
| arena.png | Side-view arena, 2172 × 724 | exec-bdf260b5-569d-4e25-8f4b-165116ffb529.png |
| map.png | Campaign environment, 1774 × 887 | exec-34a5a8ee-e281-4675-9343-c4b6d5201908.png |
| fighters.png | Two original fighters, 1774 × 887 | exec-957541f2-0749-40a9-a105-b7dd31d90a70.png |
| ability-atlas.png | Eight illustrated abilities/boosts, 1774 × 887 | exec-79d4c5fb-91a8-4ead-b964-34630244e8e5.png |
| title-emblem.png | Transparent ivory/gold title emblem, 1536 × 1024 | exec-7a97b705-7a28-4ac6-a0f4-158f1640d427.png |
| board-environment.png | Limestone, ivy and navy playfield environment, 2172 × 724 | exec-d7af5a96-9a35-4e40-88ed-f5295d0d538e.png |

The character sheet has an opaque magenta background. Earlier transparency attempts produced a painted checker pattern; those attempts are excluded from the game. `scripts/actor.gd` removes magenta at runtime with a chroma-key shader and selects the relevant half of the sheet. These are separate 2D sprites with movement/effects, not skeletal character animations.

AI-generated assets follow the applicable OpenAI terms; no third-party stock license is claimed. The atlas was generated with the built-in ImageGen tool using `design/screens/06-battle.png` as a style reference. `ornaments.gd` samples circular regions at runtime without changing the source PNG; dynamic segmented charge rings and labels are drawn separately. Portraits likewise sample the existing fighter sheet through `portrait.gd`. Original vector token sources are in `../ui/`.

The 0.1.2 emblem and playfield use the approved home/battle masters as references. Both outputs are retained unchanged, including the emblem's real alpha channel. Exact prompts and original output identifiers: `prompts-0.1.2.json`. The playfield is drawn in three horizontal regions so the central board keeps its size on wider phones. The logo is a brand asset; other UI text remains dynamic and localized.

Original scalable UI frames/icons: `tools/build-ornate-ui.cjs`. Original audio sources and synthesis recipe: `../audio/README.md`.

## 0.1.3 artwork (2026-09-17)

- `menu-icons.png`, 1774 × 887, genuine alpha: detailed brass cannon and interlocking gears based on the user's crop of our approved home design. Source output: `exec-23050275-38a6-4905-a7ed-9b6b1b855114.png`.
- `enemies.png`, 1448 × 1086, genuine alpha: 12 distinct opponents in a 4 × 3 atlas, in campaign order. Source output: `exec-8b2c7c7e-0f9c-4793-ba5a-6d35a5812a22.png`; a layout edit of `exec-01d4c693-d9e4-481d-9a1a-0a99d4cc5262.png` to separate the figures. `scripts/enemy_art.gd` selects the body and matching face crop. These sprites use native alpha, without the old magenta-key shader.

Both production files were generated with the built-in ImageGen tool and copied unchanged. Exact prompts, reference role and source identifiers: `prompts-0.1.3.json`. No external franchise characters are included. Both assets are below 10 MiB. Original approved design masters remain unchanged. Licensed music has separate provenance in `../music/README.md`.

## 0.1.10 equipment artwork (2026-09-18)

Five original OpenAI ImageGen illustrations: `equipment-mirror.png`, `equipment-seal.png`, `equipment-bloom.png`, `equipment-lexicon.png`, `equipment-reserve.png`. Each is an unchanged 1254 × 1254 source PNG, under 2.4 MB. Exact individual prompts and original output filenames: `prompts-equipment-0.1.10.json`. No external artwork or franchise references were used. Generated assets follow applicable OpenAI terms; no third-party stock license is claimed.

Godot imports icons at a 512-pixel size limit with mipmaps; the full source images remain intact. `equipment_ui.gd` samples circular UV regions and adds existing live charge rings. Original assets remain below the project's 10 MiB review threshold; no additional LFS pattern is needed.
