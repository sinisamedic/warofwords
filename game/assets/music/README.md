# Music recordings

Downloaded 2026-09-17 directly from the authors' OpenGameArt uploads. Both works are dedicated under **CC0 1.0**; legal text is included in `../../licenses/music-CC0-1.0.txt`. No paid account, streaming, or online service is required by the app.

| File | Composition / author | Source | Duration |
| --- | --- | --- | --- |
| fantasy-orchestral-theme.mp3 | Fantasy Orchestral Theme — Joth | https://opengameart.org/content/fantasy-orchestral-theme | 191.69 s |
| treasure-hunter.mp3 | Treasure Hunter — TAD | https://opengameart.org/content/treasure-hunter | 65.07 s |

Original downloads, without re-encoding:

- https://opengameart.org/sites/default/files/FantasyOrchestralTheme_1.mp3
- https://opengameart.org/sites/default/files/treasure_hunter_0.mp3

The first recording accompanies menus; the second accompanies battles. `scripts/music.gd` mixes independent music players at 19% linear volume, crossfades over 1.4 seconds and softens recording boundaries. Paused menus duck music to 7.5%; disabling music or backgrounding the app pauses both recordings. Sound effects have their own toggle. These are authored orchestral recordings, not our procedural sound effects.

Attribution is also shown in the in-game Credits screen. Each source file is below 10 MiB. Original files and their license are versioned; export builds are not.
