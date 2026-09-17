# War of Words

**Rad u pregledu: 0.1.6**, grana `codex/campaign-worlds-hero-animation`: popravka dodira nivoa, tri animirano promenljive pozadine kampanje, dopuna koja konstruiše reči i artikulisani heroj samo u borbi. Naslovna zadržava originalnu ilustraciju. Korisnik trenutno pregleda Godot verziju pre novog APK-a; poslednji objavljeni paket ispod je 0.1.5. Videti `STATUS.md` za nastavak.

**Igriva Android verzija 0.1.5 u Godotu 4.7.2.** Landscape duel protiv računara: povezuj engleska ili srpska slova, uz izbor susednog ili slobodnog povezivanja, napuni borbene sposobnosti i savladaj 12 susreta. Sve radi offline. Radni naziv i balans mogu se menjati nakon testa na telefonu.

## Probaj igru

- APK: [WarOfWords-0.1.5-android.apk](https://github.com/sinisamedic/warofwords/releases/download/v0.1.5-android-preview/WarOfWords-0.1.5-android.apk). Lokalni build je u ignorisanom `exports/`.
- [Instalacija na telefonu i izgradnja APK-a](docs/android.md).
- Izvor: importuj **game/project.godot** u Godot 4.7.2 i pritisni F5.
- **Play → Prepare → Battle**. Poveži STONE u prvom redu prve table. Srpski: **Options → Interface language / Word dictionary → Srpski**. Izbori su nezavisni. **Letter connection → Any letters** dozvoljava udaljena slova. Pravilo povezivanja važi odmah i za započetu borbu. Novi rečnik važi za novu borbu.

## Šta je uključeno

Ukrašeni meniji, reljefni naslov, kamena tabla, svetleći spojevi i slojeviti efekti borbe. Šest osnovnih ekrana, 12 misija u tri poglavlja, četiri sposobnosti sa osam nivoa, tri besplatna power-upa, novčići i otključavanje misija, odvojen izbor jezika menija i rečnika, 76.802 engleske i 1.740.276 srpskih oblika reči, nagoveštaji, dnevnik pronađenih reči, zvuk, vibracija i automatsko čuvanje nedovršene borbe. 12 različitih protivnika, orkestarska muzika sa zasebnim prekidačem, šteta pri udaru projektila, prevlačenje mape/dnevnika i 20 reči po strani. Originalni svet i likovi; Slugterra je referenca za kompoziciju duela i table.

[Pravila i balans](docs/game-design.md) · [Provere i granice verzije](docs/QA-0.1.5.md) · [Status i sledeći korak](STATUS.md).

U 0.1.5: klizanje nivoa u kampanji sa velikom slikom izabranog protivnika, četiri velike ikone ON/OFF u opcijama, ukrašeni dijalozi pobede i pauze i vidljivije animacije mirovanja boraca. Štit, oreoli moći i animacije poraza iz prethodne verzije su zadržani.

## Nastavi na drugom računaru

Prvo pročitati [AGENTS.md](AGENTS.md), zaštititi postojeće izmene i proveriti remote. Aktivna radna grana je **codex/campaign-options-dialog-polish**:

```powershell
git fetch origin --prune
git switch codex/campaign-options-dialog-polish
git pull --ff-only
```

Ako grana nije lokalna: `git switch --track origin/codex/campaign-options-dialog-polish`. GitHub prenosi izvor i asset-e; Godot, Android SDK, JDK i export templates se instaliraju zasebno. [Podešavanje računara](docs/setup.md).

## Struktura

- `game/` — aktivna igra, asset-i, rečnik, licence, testovi i Android export preset.
- `tools/build-android.ps1`, `tools/build-dictionary.ps1` — ponovljiva izgradnja i provere.
- `design/` — šest usvojenih statičnih dizajna, očuvani masteri i specifikacija.
- `V3 mokup/`, `mockups/` — prethodni interaktivni predlozi, sačuvani bez izmena.
- `setup-probe/`, `tools/godot-mcp/` — ranija tehnička proba i MCP alati; igra ih ne koristi.
- `docs/PLAN.md`, `docs/GODOT-SETUP.md` — istorija istraživanja.
- `.local/`, `exports/` — lokalni alati, logovi, keš i izlazni APK; ne commit-uju se.

Repozitorijum: https://github.com/sinisamedic/warofwords. Poreklo novih materijala i licence nalaze se uz `game/assets/`, `game/data/` i `game/licenses/`. Novi izvorni binarni fajlovi su pojedinačno manji od 10 MiB; LFS nije potreban za ovaj paket izvora.
