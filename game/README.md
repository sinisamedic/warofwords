# War of Words — playable Android 0.1.2

Offline landscape word combat, implemented in Godot 4.7.2. Open `project.godot`, then run the main scene. Android installation/build instructions: [../docs/android.md](../docs/android.md).

Six core screens: home, campaign, arsenal, power-ups, upgrades, battle. Includes tutorial, pause, victory/defeat, campaign ending, word journal and settings. Twelve unlockable CPU encounters in three chapters. Original 2D environments and fighters, ability effects, synthesized audio and optional haptics.

Connect adjacent letters (diagonals allowed), or choose Free in Options for distant tiles; release to submit or tap letters then ✓. Used tiles refill. Each tile color charges its ability. Six-letter words double the charge; all valid words also deal damage. No repeated words in one duel. Hint reveals a possible path. Choose one free, single-use power-up before each duel.

Progress is saved locally, including an unfinished duel. Returning to an unfinished duel starts paused. Options include sound, haptics and reduced motion. UI language and word dictionary are independent (English / Serbian Latin). Serbian includes Č/Ć/Š/Đ/Ž and LJ/NJ/DŽ tiles, with 1,740,276 inflected forms; English has 76,802 entries. Saved duels retain their own dictionary and connection rule. Free-mode taps can jump directly; swipes select crossed tiles. Portrait health bars, rich enamel letter tokens, illustrated abilities with segmented circular charge, and an icon-only boost follow the approved battle design. Confirm/cancel appear only for tap composition. See [source and build recipe](data/README.md).

This is the first complete testable campaign, with provisional balancing and two character sprites shared across encounters. Earlier designs/mockups remain in their own folders. See [QA and limitations](../docs/QA-0.1.2.md) for what has actually been tested.

0.1.2 adds the approved title emblem and stone playfield, reusable gold frames and icons, an ornate coin counter, Noto Serif headings/tiles for Serbian Đ, a glowing word trail, and thirteen original layered audio assets. Muzzle, flight, explosion and shield effects synchronize with impact audio and optional haptics. Reduced Motion limits movement and particles. Original assets, licenses and reproducible SVG/audio recipes are included.
