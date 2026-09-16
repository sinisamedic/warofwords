# War of Words

**Igriva Android verzija 0.1.0 u Godotu 4.7.2.** Landscape duel protiv računara: povezuj susedna engleska slova, napuni borbene sposobnosti i savladaj 12 susreta. Sve radi offline. Radni naziv i balans mogu se menjati nakon testa na telefonu.

## Probaj igru

- APK: `WarOfWords-0.1.0-android.apk` iz isporučenog paketa / GitHub izdanja. Lokalni build je u ignorisanom `exports/`.
- [Instalacija na telefonu i izgradnja APK-a](docs/android.md).
- Izvor: importuj **game/project.godot** u Godot 4.7.2 i pritisni F5.
- **Play → Prepare → Battle**. Poveži STONE u prvom redu prve table. Pomoć je u Options → How to Play.

## Šta je uključeno

Šest osnovnih ekrana, 12 misija u tri poglavlja, četiri sposobnosti sa osam nivoa, tri besplatna power-upa, novčići i otključavanje misija, lokalni engleski rečnik sa 76.802 reči, nagoveštaji, dnevnik pronađenih reči, zvuk, vibracija i automatsko čuvanje nedovršene borbe. Originalni svet i likovi; Slugterra je referenca za kompoziciju duela i table.

[Pravila i balans](docs/game-design.md) · [Provere i granice verzije](docs/QA-0.1.0.md) · [Status i sledeći korak](STATUS.md).

## Nastavi na drugom računaru

Prvo pročitati [AGENTS.md](AGENTS.md), zaštititi postojeće izmene i proveriti remote. Aktivna radna grana je **codex/android-playable**:

```powershell
git fetch origin --prune
git switch codex/android-playable
git pull --ff-only
```

Ako grana nije lokalna: `git switch --track origin/codex/android-playable`. GitHub prenosi izvor i asset-e; Godot, Android SDK, JDK i export templates se instaliraju zasebno. [Podešavanje računara](docs/setup.md).

## Struktura

- `game/` — aktivna igra, asset-i, rečnik, licence, testovi i Android export preset.
- `tools/build-android.ps1`, `tools/build-dictionary.ps1` — ponovljiva izgradnja i provere.
- `design/` — šest usvojenih statičnih dizajna, očuvani masteri i specifikacija.
- `V3 mokup/`, `mockups/` — prethodni interaktivni predlozi, sačuvani bez izmena.
- `setup-probe/`, `tools/godot-mcp/` — ranija tehnička proba i MCP alati; igra ih ne koristi.
- `docs/PLAN.md`, `docs/GODOT-SETUP.md` — istorija istraživanja.
- `.local/`, `exports/` — lokalni alati, logovi, keš i izlazni APK; ne commit-uju se.

Repozitorijum: https://github.com/sinisamedic/warofwords. Poreklo novih materijala i licence nalaze se uz `game/assets/`, `game/data/` i `game/licenses/`. Novi izvorni binarni fajlovi su pojedinačno manji od 10 MiB; LFS nije potreban za ovaj paket izvora.
