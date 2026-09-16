# War of Words — playable Android 0.1.0

Offline landscape word combat, implemented in Godot 4.7.2. Open `project.godot`, then run the main scene. Android installation/build instructions: [../docs/android.md](../docs/android.md).

Six core screens: home, campaign, arsenal, power-ups, upgrades, battle. Includes tutorial, pause, victory/defeat, campaign ending, word journal and settings. Twelve unlockable CPU encounters in three chapters. Original 2D environments and fighters, ability effects, synthesized audio and optional haptics.

Connect adjacent letters (diagonals allowed); release to submit or tap letters then ✓. Used tiles refill. Each tile color charges its ability. Six-letter words double the charge; all valid words also deal damage. No repeated words in one duel. Hint reveals a possible path. Choose one free, single-use power-up before each duel.

Progress is saved locally, including an unfinished duel. Returning to an unfinished duel starts paused. Options include sound, haptics and reduced motion. The dictionary has 76,802 English entries; [source and build recipe](data/README.md).

This is the first complete testable campaign, with provisional balancing and two character sprites shared across encounters. Earlier designs/mockups remain in their own folders. See [QA and limitations](../docs/QA-0.1.0.md) for what has actually been tested.
