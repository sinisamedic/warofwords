# War of Words

**Razvojni pregled:** 24 nivoa, šest lokacija, 12 uređaja i dva artefakta. Dodati Žar, Rezonator, Bastion i Crpljenje. Novi APK nije pravljen; igrivi pregled: Godot `--path game --script res://tests/preview_wave_two.gd` (zaseban probni save). Detalji u [STATUS.md](STATUS.md).

**Android 0.1.13:** velike kampanjske nagrade sa ukrašenom oznakom osvojenog, jasnije istaknuto izabrano pojačanje i broj završenog nivoa na pobedi. Medaljoni imaju čist zlatni rub bez crnog donjeg oboda. Prvi talas opreme, dijalozi otključavanja, dnevni izazov i globalna rang-lista ostaju dostupni. [Online režim i postavljanje](docs/daily-online.md).

**Igriva Android verzija u Godotu 4.7.2.** Landscape duel protiv računara: povezuj engleska ili srpska slova, uz izbor susednog ili slobodnog povezivanja, napuni borbene sposobnosti i savladaj 24 susreta u aktuelnom izvoru (12 u objavljenom APK-u 0.1.13). Kampanja i vežba rade offline; rangirani dnevni izazov zahteva internet. Radni naziv i balans mogu se menjati nakon testa na telefonu.

## Probaj igru

- [Preuzmi APK 0.1.13](https://github.com/sinisamedic/warofwords/releases/download/v0.1.13-android-preview/WarOfWords-0.1.13-android.apk). Lokalno: `exports/WarOfWords-0.1.13-android.apk`. **Instalira se preko 0.1.12, 0.1.11 ili 0.1.10 bez deinstalacije**, sa istim potpisom; prelazak sa 0.1.12 čuva ceo napredak (provereno u emulatoru). Potpis se razlikuje od kućnih verzija 0.1.7–0.1.9 kao i kod prethodnog paketa; pri prelasku sa njih potrebna je deinstalacija koja briše lokalni napredak. Stanje objave: [STATUS.md](STATUS.md).
- [Instalacija na telefonu i izgradnja APK-a](docs/android.md).
- Izvor: importuj **game/project.godot** u Godot 4.7.2 i pritisni F5.
- **Play → Prepare → Battle**. Poveži STONE u prvom redu prve table. Srpski: **Options → Interface language / Word dictionary → Srpski**. Izbori su nezavisni. **Letter connection → Any letters** dozvoljava udaljena slova. Pravilo povezivanja važi odmah i za započetu borbu. Novi rečnik važi za novu borbu.

## Šta je uključeno

Ukrašeni meniji, reljefni naslov, kamena tabla, svetleći spojevi i slojeviti efekti borbe. Šest osnovnih ekrana, 12 misija u tri poglavlja, osam uređaja u četiri borbena mesta sa osam zajedničkih nivoa, dva pasivna artefakta, tri besplatna power-upa, novčići i otključavanje misija, odvojen izbor jezika menija i rečnika, 76.802 engleske i 1.740.276 srpskih oblika reči, nagoveštaji, dnevnik pronađenih reči, zvuk, vibracija i automatsko čuvanje nedovršene borbe. 12 različitih protivnika, orkestarska muzika sa zasebnim prekidačem, šteta pri udaru projektila, prevlačenje mape/dnevnika i 20 reči po strani. Originalni svet i likovi; Slugterra je referenca za kompoziciju duela i table.

[Pravila i balans](docs/game-design.md) · [Provere i granice verzije](docs/QA-0.1.13.md) · [Urađeno i ideje za dalje](docs/next-steps.md) · [Status i sledeći korak](STATUS.md).

U 0.1.6: popravljen izbor nivoa, tri pozadine lokacija sa animiranim pretapanjem, bolja dopuna slova i artikulisani heroj u borbi. Pri porazu heroj savija kolena i pada kroz zglobove, a protivnik se raspada u energiju i fragmente. Naslovna zadržava originalnu celu ilustraciju.

## Nastavi na drugom računaru

Prvo pročitati [AGENTS.md](AGENTS.md), zaštititi postojeće izmene i proveriti remote. [Sažetak završenog rada, prioriteti i materijali za zaseban prenos](docs/next-steps.md). Aktivna radna grana je **codex/equipment-wave-one**; naredne komande važe za čistu kopiju bez razilaženja:

```powershell
git fetch origin --prune
git switch codex/equipment-wave-one
git pull --ff-only
```

Ako grana nije lokalna: `git switch --track origin/codex/equipment-wave-one`. GitHub prenosi izvor i asset-e; Godot, Android SDK, JDK i export templates se instaliraju zasebno. Javni `game/online_config.json` napraviti zasebno prema [online uputstvu](docs/daily-online.md); nije u Git-u. [Podešavanje računara](docs/setup.md).

## Struktura

- `game/` — aktivna igra, asset-i, rečnik, licence, testovi i Android export preset.
- `tools/build-android.ps1`, `tools/build-dictionary.ps1` — ponovljiva izgradnja i provere.
- `design/` — šest usvojenih statičnih dizajna, očuvani masteri i specifikacija.
- `V3 mokup/`, `mockups/` — prethodni interaktivni predlozi, sačuvani bez izmena.
- `setup-probe/`, `tools/godot-mcp/` — ranija tehnička proba i MCP alati; igra ih ne koristi.
- `docs/PLAN.md`, `docs/GODOT-SETUP.md` — istorija istraživanja.
- `.local/`, `exports/` — lokalni alati, logovi, keš i izlazni APK; ne commit-uju se.

Repozitorijum: https://github.com/sinisamedic/warofwords. Poreklo novih materijala i licence nalaze se uz `game/assets/`, `game/data/` i `game/licenses/`. Novi izvorni binarni fajlovi su pojedinačno manji od 10 MiB; LFS nije potreban za ovaj paket izvora.
