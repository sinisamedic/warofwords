# Production artwork

Generated with OpenAI ImageGen on 2026-09-16 for this project, using our approved original screen designs as style references. No Slugterra screenshots or characters are shipped. Source PNGs are retained without bitmap post-processing. Exact prompts: `prompts.json`.

| File | Purpose | Original generated output |
| --- | --- | --- |
| arena.png | Side-view arena, 2172 × 724 | exec-bdf260b5-569d-4e25-8f4b-165116ffb529.png |
| map.png | Campaign environment, 1774 × 887 | exec-34a5a8ee-e281-4675-9343-c4b6d5201908.png |
| fighters.png | Two original fighters, 1774 × 887 | exec-957541f2-0749-40a9-a105-b7dd31d90a70.png |
| ability-atlas.png | Eight illustrated abilities/boosts, 1774 × 887 | exec-79d4c5fb-91a8-4ead-b964-34630244e8e5.png |

The character sheet has an opaque magenta background. Earlier transparency attempts produced a painted checker pattern; those attempts are excluded from the game. `scripts/actor.gd` removes magenta at runtime with a chroma-key shader and selects the relevant half of the sheet. These are separate 2D sprites with movement/effects, not skeletal character animations.

AI-generated assets follow the applicable OpenAI terms; no third-party stock license is claimed. The atlas was generated with the built-in ImageGen tool using `design/screens/06-battle.png` as a style reference. `ornaments.gd` samples circular regions at runtime without changing the source PNG; dynamic segmented charge rings and labels are drawn separately. Portraits likewise sample the existing fighter sheet through `portrait.gd`. Original vector token sources are in `../ui/`. Sound effects are synthesized by `scripts/sound.gd`.
