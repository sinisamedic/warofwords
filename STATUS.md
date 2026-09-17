# Trenutno stanje

Ažurirano: 2026-09-17. **Aktivna grana: codex/ornate-ui-combat-effects.**

## Aktuelno — Android 0.1.2

Završene dorade posle korisnikovog testa 0.1.1:

- Ukrašena dugmad/paneli kroz sve ekrane, ikone, novčić sa kompasom i reljefan naslov prema usvojenom dizajnu.
- Kamena pozadina table, ukrašeni panel za reč/poruke na spoju arene i table, bogatiji svetleći spoj slova.
- Noto Serif za naslove i pločice, pregledan Đ/đ i ostali srpski dijakritici; dopunjeni prevodi dinamičkih oznaka nivoa i punjenja.
- Podešavanje **Povezivanje slova: Susedna / Slobodno**. Podrazumevano susedna. Slobodno dopušta udaljene pločice, svaku samo jednom. Važi za nove borbe; započete zadržavaju svoje pravilo. Stari save je kompatibilan.
- 13 originalnih slojevitih zvučnih efekata, bljesak cevi, svetleći projektil, eksplozija/udarni talas, udar u štit, električne grane, lečenje i Freeze. Zvuk i haptika udara okidaju se pri dolasku projektila. Broj efekata ograničen, Reduced Motion smanjuje kretanje i varnice projektila.
- Izvorne PNG/SVG/WAV datoteke, promptovi, licence i ponovljive skripte su u repou. Svaki novi binarni izvor je ispod 10 MiB. APK ostaje u ignorisanom exports/ i prenosi se kroz GitHub Release.

## Završene provere

- Godot import + **163 automatske provere, 0 grešaka**.
- Instalacija preko ranije 0.1.1 čuva napredak. Završni instalirani APK je dodatno proveren SHA256 otiskom, zatim su na njemu ponovljeni puni Android scenariji.
- Android emulator: prevlačenje/dodiri, pobeda i nagrada, unapređenje, restart, odvojeni jezici, srpska reč ŠTEKETATI, slobodna ABHORRENT preko udaljenih polja, pomoć i trajno pravilo sačuvane borbe.
- Pregledani stvarni Godot renderi 16:9 i široki Android snimci, uključujući ĐAK, srpska unapređenja i efekte. Završni runtime logovi bez grešaka.
- Paket com.sinisamedic.warofwords, 0.1.2 / code 3, isti debug sertifikat kao prethodna izdanja. APK exports/WarOfWords-0.1.2-android.apk, 77.983.663 bajta.
- SHA256: fe93e38858c68e91827fed1869c62d955298e7557319beadc00d72302c0d0f2e.
- Detaljni dokazi i granice: **docs/QA-0.1.2.md**. Cilj izdanja: v0.1.2-android-preview. Ishod Git push-a i objave proverava se posle tih operacija; nije unapred pretpostavljen ovim zapisom.

## Tačan sledeći korak

Instalirati **0.1.2 preko postojeće aplikacije**, bez deinstaliranja/brisanja podataka. Na S23 Ultra proveriti izgled dugmadi, Đ, ritam ispaljivanja/udarca, zvuk i osećaj haptike. Za udaljena slova: Podešavanja → Povezivanje slova → Slobodno, zatim započeti novu borbu. Prethodna nedovršena ostaje na svom pravilu i rečniku.

Telefon, baterija i trajni FPS nisu provereni ovde. Emulator je dao i uzorak 32 FPS / 132 draw calls; učitavanje i snimanje daju niže uzorke. To nije obećanje brzine na telefonu. Srpski ostaje probni rečnik; dalje podešavanje težine i osećaja efekata čeka korisnikov test.

## Nastavak na drugom računaru

Pročitati AGENTS.md i ovaj fajl, sačuvati eventualni lokalni rad, proveriti remote/upstream, zatim:

```powershell
git fetch origin --prune
git switch codex/ornate-ui-combat-effects
git pull --ff-only
```

Ako grana nije lokalna: git switch --track origin/codex/ornate-ui-combat-effects. Aktivni projekat je game/project.godot. docs/setup.md i docs/android.md opisuju alate i izgradnju. Signing ključ i instalacije alata nisu u Git-u; main još nije aktivna grana igre.

## Sačuvana istorija

- codex/battle-polish-serbian, a499b75, v0.1.1-android-preview: prvi srpski rečnik i dorada borbe.
- codex/android-playable, 0942094, v0.1.0-android-preview: prva igriva Android verzija.
- design/: šest usvojenih statičnih dizajna; masteri neizmenjeni. V3 mokup/ i mockups/ ostaju sačuvani.
