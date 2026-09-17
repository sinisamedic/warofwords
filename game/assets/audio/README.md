# Original combat sound effects

Created for War of Words, 2026-09-17. These are original procedural sounds, with no stock recordings, third-party samples or external sound libraries. Recipe: `../../../tools/build-sound-effects.cjs` (from repository root: `tools/build-sound-effects.cjs`). Run `node tools/build-sound-effects.cjs` to reproduce every WAV byte for byte.

13 mono PCM WAV assets, 24 kHz / 16 bit: tap, word, shot, flight, hit, explosion, shield, arc, heal, freeze, win, lose, upgrade. The recipe layers filtered noise, phase-continuous frequency sweeps, low-frequency transients, metallic resonators and short reflected tails. Each file fades to zero and peaks below full scale (0.82; tap 0.36). The game mixes voices at -9 dB, flight at -12 dB and taps at -15 dB.

Muzzle and flight sounds start at launch; impact/explosion/shield sounds start when the projectile arrives. Disabling sound stops all active voices. Haptic launch/impact events independently obey the vibration setting. Auditory quality and tactile strength on a physical phone require listening and testing on that device.
