# Trenutno stanje

Ažurirano: 2026-09-16. **Aktivna grana: `codex/battle-polish-serbian`.**

## Aktuelno — Android 0.1.1

Posle fizičkog testa 0.1.0 korisnik je zatražio podešavanja, probni srpski i približavanje borbenog ekrana usvojenom dizajnu. Sprovedeno:

- Options iz glavnog menija i pauze: zvuk, vibracija, manje animacija, **odvojeni jezik menija i rečnik** (English / Srpski).
- Srpski latinicom: č/ć/š/đ/ž, LJ/NJ/DŽ na jednoj pločici, 1.740.276 offline oblika. Izvor LibreOffice/Hunspell pod MPL-2.0, verzionisani originalni izvori i ponovljiva izgradnja. Engleski ostaje SCOWL sa 76.802 reči.
- Kompaktni health barovi sa portretima i gradijentom; vidljivi likovi i niža arena. Uklonjen LINK A WORD. ×/✓ samo za sastavljanje dodirima; slide se potvrđuje puštanjem.
- Nove originalne ilustracije sposobnosti i power-upova, segmenti punjenja oko kruga, jasna ikonica Freeze, bogatiji vektorski tokeni i podebljana slova. Izgled pregledan na 16:9 i širokom Android prikazu.
- Optimizovana pozadina/tokeni/prstenovi i zaštita dodira tokom promene ekrana. Rečnici se učitavaju u pozadini i koriste štedljiviju pretragu.
- Sačuvane borbe zadržavaju svoj rečnik. Stari 0.1.0 save ostaje kompatibilan; novčići, misije i unapređenja se čuvaju.
- Paket `com.sinisamedic.warofwords`, 0.1.1 / code 2, isti debug sertifikat kao objavljeni 0.1.0. APK: `exports/WarOfWords-0.1.1-android.apk`; ne ide u Git istoriju.

## Završene provere

- Godot import i **129 automatskih provera, 0 grešaka**.
- Android emulator API 36 / 2400 × 1080: nadogradnja čuva kompletan save, stvarni slide/tap, borba do pobede, nagrada/unapređenje, restart, nezavisni jezici, srpska reč sa dijakritikom i nastavak srpske borbe posle promene menija na engleski.
- Završni APK ponovo instaliran i provereni nastavak, komande sposobnosti, Freeze i engine log. Potpis, manifest, hash i uključene licence provereni.
- **docs/QA-0.1.1.md** beleži tačan APK hash, postupak i granice; snimci su u `docs/screenshots/0.1.1/`.
- Svaki novi binarni izvor je ispod 10 MiB. Srpski rečnik je gzip od oko 4 MB, uz ceo izvor i skriptu. LFS nije potreban za ove fajlove.

## Tačan sledeći korak

Na Samsungu instalirati APK **preko postojeće aplikacije**, bez deinstaliranja. U Options podesiti zasebno Interface language i Word dictionary. Srpski rečnik važi za novu borbu; već započeta ostaje na svom jeziku.

Proveriti veličinu/udobnost dodira, čitljivost portreta i punjenja, zvuk/vibraciju, te srpske reči u nekoliko partija. Fizički telefon, baterija i trajni FPS nisu provereni ovde. Emulator je posle optimizacije beležio 19–36 FPS u borbi, što nije procena brzine na S23 Ultra. Srpski rečnik je probni, ne konačna turnirska lista; ćirilica nije deo ove izmene. Dalji balans i sledeće dorade čekaju korisnikov test.

## Nastavak na drugom računaru

Pročitati AGENTS.md i ovaj status, zaštititi eventualni lokalni rad i proveriti Git/remote, zatim:

```powershell
git fetch origin --prune
git switch codex/battle-polish-serbian
git pull --ff-only
```

Ako grana nije lokalna: `git switch --track origin/codex/battle-polish-serbian`. Aktivni Godot projekat je `game/project.godot`. Setup i Android uputstva: **docs/setup.md**, **docs/android.md**. Potpisni ključevi i lokalni alati ne prenose se Git-om. Proverene datoteke su spremne za handoff; ishod push-a, udaljeni SHA i stvarna objava izdanja potvrđuju se zasebno nakon operacije.

## Sačuvana istorija

- `codex/android-playable`, 0942094, izdanje `v0.1.0-android-preview`: prva igriva verzija, koju je korisnik probao na telefonu.
- `design/`: šest usvojenih statičnih dizajna, commit 2a5a1c7 sa `codex/screen-mockups`; masteri ostaju neizmenjeni.
- `V3 mokup/`, `mockups/`: prethodni predlozi, bez izmena.
- `setup-probe/`, `tools/godot-mcp/`: istorijska tehnička proba, izvan runtime-a igre.
