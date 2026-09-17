# Trenutno stanje

Ažurirano: 2026-09-17. **Aktivna grana: codex/campaign-worlds-hero-animation.**

## 0.1.6 — objavljen Android preview

Korisnik je posle pregleda uživo i korekcije poraza izričito zatražio novi APK. Napravljen je nov paket `exports/WarOfWords-0.1.6-android.apk`, versionCode 7, 94.859.979 bajtova. SHA256: `9afb875fec3100f2b44b6c480082c76827419d57460f47ce9b6a1a86d8d150a7`. Koristi isti potpis kao prethodna izdanja; instalira se preko postojeće aplikacije bez deinstaliranja.

Objava proverena: [v0.1.6-android-preview](https://github.com/sinisamedic/warofwords/releases/tag/v0.1.6-android-preview), release commit `ae22331`. APK i SHA256 su dostupni, GitHub veličine/hash-evi odgovaraju lokalnim fajlovima; izdanje više nije draft.

Najnovija korekcija: korisniku je smrt izgledala kao okretanje celog sprite-a. **Heroj sada klone kroz zglobove, savija kolena i oslanja ruke o tlo; protivnik se raspada kroz svetleću dezintegraciju i fragmente.** Na naslovnoj ostaje originalna cela ilustracija; devetodelni rig koristi se samo u borbi.

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
- Finalni APK 0.1.6 / code 7 zamenjuje raniji neobjavljeni lokalni build. Potpis i manifest su provereni: ARM64 + x86_64, API 24–36, samo VIBRATE dozvola. Novi import/test/export log bez grešaka i upozorenja.
- Android nadogradnja sa 0.1.5 čuva kompletan save i započetu borbu; instalirani hash odgovara APK-u. Kampanja/dnevnik prolaze prevlačenja, povratak i zadržane dodire nivoa. Puna partija prolazi pobedu, nagradu, unapređenje, restart, srpsku reč i nezavisne jezike. Detalji i ograničenja: `docs/QA-0.1.6.md`.
- **ANDROID COMBAT QA PASSED:** Pulse sa štitom, pobeda/Next, smrt tokom dodira/Retry, bez dupliranja nagrada i runtime grešaka. Android harness sada potvrđuje promenu jezika i čeka završetak leta pri sporom radu emulatora. APK nije menjan posle nadogradnje i instalirane hash provere.

## Tačan sledeći korak

Sačekati korisnikov test APK-a 0.1.6 na fizičkom telefonu, naročito utisak o dopuni slova i pokretima heroja. Ne pokretati novi dizajn ili veliku implementaciju bez nove povratne informacije.

Radni kod: game/project.godot. Grana za nastavak: codex/campaign-worlds-hero-animation. Pročitati AGENTS.md, proveriti Git i sačuvati lokalni rad pre usklađivanja. Ne prebacivati automatski na main.

## Istorija

- codex/shields-defeat-ready-effects, 1d5edb6, v0.1.4-android-preview: štit, uzemljenje protivnika, smer čuvara, sjaj moći i animacije poraza.
- codex/impact-enemies-music, 210e1a2, v0.1.3-android-preview: šteta pri udaru, 12 protivnika, muzika, mapa/dnevnik i odmah primenjivo slobodno povezivanje.
- codex/ornate-ui-combat-effects, bac0e4b, v0.1.2-android-preview: ukrašeni UI, efekti i početno slobodno povezivanje.
- codex/battle-polish-serbian, a499b75, v0.1.1-android-preview: srpski rečnik i borba.
- codex/android-playable, 0942094, v0.1.0-android-preview: prva igriva Android verzija.
- design/: šest usvojenih statičnih dizajna. V3 mokup/ i mockups/ sačuvani.
