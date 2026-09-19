# Multi-mode artwork — 2026-09-19

## Playtest polish

`portal-scene.png` removes the baked ring from our earlier illustration; `portal-ring.png` is a separate transparent rotating sprite. `hourglass-v2.png` follows the slender hourglass of the approved battle mockup. Built-in ImageGen, copied unchanged with alpha, original prompts in `polish-prompts.json`. Original outputs: `exec-d8086f22-d854-4e49-b790-7b35883b41e2.png`, `exec-fbd211cd-472e-4e1b-bfab-b563469e26c3.png`, `exec-8c240965-db11-404b-927e-f41ddaa2497c.png`. Each below 10 MiB. Campaign card uses existing licensed/original `fighters.png` cutouts, independently posed over the terrace. The original card files are retained as design history. New boss skull and compact wave frame are original code-authored SVGs in `assets/ui/`.

Original assets generated with built-in OpenAI ImageGen, based on the project's own approved v2 mockups. Applicable OpenAI terms; no stock or external franchise assets. Exact prompts and reference paths: `prompts.json`. Output PNGs copied unchanged, including alpha for both bilingual boss headers and hourglass. Each file is below 10 MiB; ordinary Git matches existing art policy, no LFS history migration.

- `sky-court.png`: shared menu/endless terrace background.
- `mode-campaign.png`, `mode-endless.png`, `mode-daily.png`: separate illustrations; no embedded UI text. Runtime aspect-preserving crops, subtle pan and particles/portal/sand animation. Reduced Motion disables movement.
- `boss-sr.png`, `boss-en.png`: localized victory headers. Other labels remain real localized text.
- `hourglass.png`: enemy-turn countdown ornament, with runtime progress ring/particles.

Original generated filenames, in the same order: `exec-db5a5d2c-cc85-41ae-bdfb-8c48028d5a93.png`, `exec-199aee35-aa7f-4f92-94d5-9f535507cff7.png`, `exec-42065f56-d155-41ef-a035-cd592a22bfda.png`, `exec-df17cf04-8744-4ddf-961f-c379961294ec.png`, `exec-6985ba91-4d06-4e4d-9a64-78bdf67a4919.png`, `exec-29b4f0da-9b25-4a84-a9c3-c24c0252a2b3.png`, `exec-b44dec58-1f91-4fac-9163-dead9d01a147.png`.

Mockup power-up illustrations were not introduced. Runtime reuses the campaign's exact ability atlas indices 4/5/6 and existing effects/names. Resonator and Ember remain alternative gold-slot weapons; the mockup showing both equipped simultaneously was illustrative and is corrected in the playable preview.

## Portal — tri sloja, 2026-09-19

`portal-enemies.png` i providni `portal-hero.png` su originalne ImageGen izvedenice prethodne projektne ilustracije `portal-scene.png`. Između njih igra crta postojeći rotirajući `portal-ring.png`. Tačni promptovi su u `portal-layers-prompts.json`; bez novih materijala trećih strana.

`wave-design-reference.png`: korisnički priložen isečak usvojene originalne ImageGen makete `design/concepts/multi-mode-2026-09-19/v2/02-endless-battle-v2.png`, sačuvan bez izmene. Godot koristi kružni UV region originalnog boss medaljona (centar 379,86; poluprečnik 27), bez nove interpretacije ikonice.
