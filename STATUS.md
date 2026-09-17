# Trenutno stanje

Ažurirano: 2026-09-17. **Aktivna grana: codex/campaign-worlds-hero-animation.**

## 0.1.6 — otvoren pregled, APK se ne objavljuje još

Korisnik želi da prvo vidi igru u simulatoru/pregledu, pre sledećeg APK-a. Lokalni helper .local/preview-death.gd otvara Godot pregled sa odvojenim testnim save-om, 420 novčića i svim otključanim nivoima. H ponavlja smrtonosni udar na heroja, E na protivnika, R započinje novu borbu. Ne prekidati prozor dok korisnik testira.

Najnovija korekcija: korisniku je smrt izgledala kao okretanje celog sprite-a. **Heroj sada klone kroz zglobove, savija kolena i oslanja ruke o tlo; protivnik se raspada kroz svetleću dezintegraciju i fragmente.** Na naslovnoj ostaje originalna cela ilustracija; devetodelni rig koristi se samo u borbi. Sačekati povratnu informaciju pre novog APK-a.

## Urađeno

- Utvrđen uzrok neklikabilnih nivoa u 0.1.5: tokom držanja prsta, iscrtavanje je uklanjalo dodirne oblasti. Sada ostaju aktivne do stvarnog klizanja. Regresija obuhvata držanje preko osam frejmova i zaključane nivoe.
- Tri originalne ImageGen pozadine za Sunward Ruins, Sky Bridges i Observatory. Pretapanje/pomeranje 0,55 s, uz klizanje brojeva. Reduced Motion preskače prelaz.
- Dopuna samo potrošenih polja sa ravnotežom samoglasnika i uklapanjem do tri poznate neiskorišćene reči; ograničenje pretrage 10.000 čvorova. Proširen izbor poznatih početnih reči. Rečnici prihvatanja nisu menjani.
- Artikulisan heroj sa devet delova: nezavisna glava, ruke, telo i kaput; mirovanje, pucanje, reakcija na udar. Pauza i Reduced Motion rade. Stopala su fiksirana. Naslovna koristi staru ilustraciju.
- Poraz traje 1,65 s: heroj prvo gubi oslonac, savija noge kroz teksturisanu mrežu, spušta telo i oslanja ruke uz prašinu; tek potom izbledi. Protivnik ostaje uspravan dok se njegova slika raspada kroz shader, energiju i fragmente. Reduced Motion koristi samo postepeno nestajanje. Nova borba vraća sve zglobove, mrežu nogu i shader; nema novih bitmapa.
- Poreklo novih PNG-ova i tačni promptovi: game/assets/art/README.md i prompts-0.1.6.json. Svi pojedinačno ispod 10 MiB. Nema novih LFS obrazaca.

## Provere

- **306 PASS / 0 FAIL** posle dorade poraza; test log bez script/engine grešaka. Provereni odloženi rezultat, jednokratna nagrada, pad kroz zglobove, deterministična poza, dodir tla pre nestajanja, dezintegracija i potpuno vraćanje likova u sledećoj borbi.
- Benchmark dopune: 768 poteza, oba jezika i pravila, pola nizova bira najkraće reči. Nova dopuna zadržala reč od 5+ polja posle svih 384 svoja poteza. Provereni zakoniti putevi, neponavljanje iskorišćenih reči, nepromenjena nepotrošena polja i budžet pretrage. To nije garancija za svaku moguću tablu.
- Godot renderi 1280 × 576 i 1708 × 960; pregledane tri lokacije, prelaz, borba i tri poze heroja. Veliki rig na naslovnoj je potom uklonjen na zahtev korisnika; otvoreni pregled potvrđuje originalnu ilustraciju.
- Za novi poraz snimljeno po sedam kadrova heroja/protivnika u 1708 × 960; pregledani kontakt sa tlom i raspad protivnika, uz uspravnog pobednika. Render log bez grešaka/upozorenja. Otvoren poseban interaktivni pregled 1280 × 576 sa H/E/R komandama; nije Android emulator.
- Lokalni APK 0.1.6 / code 7 je uspešno napravljen PRE poslednje korekcije. **Zastareo je u odnosu na izvor i NIJE objavljen.** Ne nuditi ga korisniku. Poslednje GitHub izdanje je v0.1.5-android-preview.
- Android provere nove verzije još nisu izvršene; za sada samo native Godot. tools/qa-android-pages.cjs sada sadrži stvarne dodire sa držanjem 450 ms. Build i ADB testove pokretati uzastopno.

## Tačan sledeći korak

Sačekati korisnikov komentar na otvoreni pregled. Primeniti korekcije. Zatim, kada zatraži nastavak isporuke, ponoviti import/test/export, Android upgrade/pages/full-partiju na emulatoru, proveriti isti sertifikat i hash, pa objaviti 0.1.6. Dok pregled traje ne pokretati novi APK build i ne objavljivati raniji lokalni paket.

Radni kod: game/project.godot. Grana za nastavak: codex/campaign-worlds-hero-animation. Pročitati AGENTS.md, proveriti Git i sačuvati lokalni rad pre usklađivanja. Ne prebacivati automatski na main.

## Istorija

- codex/shields-defeat-ready-effects, 1d5edb6, v0.1.4-android-preview: štit, uzemljenje protivnika, smer čuvara, sjaj moći i animacije poraza.
- codex/impact-enemies-music, 210e1a2, v0.1.3-android-preview: šteta pri udaru, 12 protivnika, muzika, mapa/dnevnik i odmah primenjivo slobodno povezivanje.
- codex/ornate-ui-combat-effects, bac0e4b, v0.1.2-android-preview: ukrašeni UI, efekti i početno slobodno povezivanje.
- codex/battle-polish-serbian, a499b75, v0.1.1-android-preview: srpski rečnik i borba.
- codex/android-playable, 0942094, v0.1.0-android-preview: prva igriva Android verzija.
- design/: šest usvojenih statičnih dizajna. V3 mokup/ i mockups/ sačuvani.
