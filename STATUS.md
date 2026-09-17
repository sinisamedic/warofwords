# Trenutno stanje

Ažurirano: 2026-09-17. **Aktivna grana: codex/impact-enemies-music.**

## Aktuelno — Android 0.1.3

Završene dorade posle korisnikovog testa 0.1.2:

- Šteta tek pri udaru reči/Pulse/Arc/CPU projektila. Arc tada odlaže naredni napad; štit podignut tokom leta važi pri udaru.
- Projektili u letu čuvaju se kroz pauzu, meni i restart. Prvi smrtonosni dolazak završava duel, nagrada se upisuje jednom.
- Jači trzaj samo pogođenog lika; Reduced Motion ga uklanja.
- Mapa i dnevnik imaju horizontalno prevlačenje i strelice. Centrirani naslovi; dnevnik 4 kolone × 5 redova, 20 reči po strani.
- Glavni lik podignut na platformu, vidljivija animacija; dnevnik je ikona knjige pored Podešavanja. Veće ilustrovane ikone Arsenala/Unapređenja prema master dizajnu.
- **Povezivanje slova → Bilo koja / Any letters** sada važi odmah i za započetu borbu. Tabla, energija, reči i projektili ostaju sačuvani. Rečnik se i dalje bira za nove borbe.
- 12 zasebnih protivnika i njihovih portreta. Izvorne PNG datoteke sa alfa kanalom i tačni ImageGen promptovi u repou.
- Dve CC0 orkestarske numere (Joth / TAD), zaseban prekidač Muzika, postepeni prelazi, tiši miks u pauzi i zaustavljanje u pozadini. Poreklo i licenca u game/assets/music/ i game/licenses/.
- Novi binarni izvori su pojedinačno ispod 10 MiB. APK ostaje u ignorisanom exports/ i objavljuje se kroz GitHub Release. Prethodni dizajni/mokupovi nisu menjani.

## Provere

- Godot import + **210 automatskih provera, 0 grešaka**, u završnom build-u.
- Stvarni renderi 16:9 i širokog telefona; pregledani meni, opcije, dnevnik, Đ i novi protivnici. Popravljeno kadriranje visokih kruna.
- Nadogradnja preko 0.1.2 čuva napredak. Završni instalirani base.apk potvrđen SHA256 otiskom.
- Puna Android partija: STONE prevlačenjem, pobeda preko REPAIRMAN/SENTINELS, novčići, unapređenje i restart. Srpski OBURVANJE i nezavisni jezici; sva četiri prekidača se čuvaju.
- Slobodno povezivanje: ADDITIVES preko udaljenih pločica, pomoć, restart i trenutno menjanje pravila postojeće borbe. Runtime logovi bez grešaka.
- Android mapa/dnevnik: oba smera prevlačenja, strelice, 20 reči po strani i granica poslednje strane. Privremeni podaci vraćeni u originalni save; runtime log bez grešaka.
- Paket com.sinisamedic.warofwords, 0.1.3 / code 4, isti debug sertifikat kao ranija izdanja. 86.512.940 bajta.
- SHA256: b13ee2f88d3ea67dbd1643db42f3072c033ab815908f89f4b9269e207ac60c6d.
- Detalji i granice: **docs/QA-0.1.3.md**. Cilj izdanja: v0.1.3-android-preview. Ishod Git push-a i objave proverava se posle tih operacija; nije unapred pretpostavljen ovim zapisom.

## Tačan sledeći korak

Instalirati **0.1.3 preko postojeće aplikacije**, bez deinstaliranja/brisanja podataka. Na S23 Ultra proveriti trenutak udara i health-a, jačinu reakcije/vibracije, nove protivnike i muzički miks. Za lakše sastavljanje dugih reči: Podešavanja → Povezivanje slova → Bilo koja; odmah važi i kada se nastavi postojeća borba. Ikona knjige pored podešavanja otvara dnevnik.

Telefon, baterija, zvučnici i trajni FPS nisu provereni ovde. Srpski i težina generatora ostaju za dalji korisnički test. Nema dodatno zaključane monetizacije niti iOS isporuke.

## Nastavak na drugom računaru

Pročitati AGENTS.md i ovaj fajl, sačuvati eventualni lokalni rad i proveriti remote/upstream, zatim:

```powershell
git fetch origin --prune
git switch codex/impact-enemies-music
git pull --ff-only
```

Ako grana nije lokalna: git switch --track origin/codex/impact-enemies-music. Aktivni projekat je game/project.godot. docs/setup.md i docs/android.md opisuju alate. Signing ključ i instalacije nisu u Git-u; main još nije aktivna grana igre.

## Istorija

- codex/ornate-ui-combat-effects, bac0e4b, v0.1.2-android-preview: ukrašeni UI, efekti i početno slobodno povezivanje.
- codex/battle-polish-serbian, a499b75, v0.1.1-android-preview: srpski rečnik i dorada borbe.
- codex/android-playable, 0942094, v0.1.0-android-preview: prva igriva Android verzija.
- design/: šest usvojenih statičnih dizajna, masteri neizmenjeni. V3 mokup/ i mockups/ sačuvani.
