# Trenutno stanje

Ažurirano: 2026-09-17. **Aktivna grana: codex/daily-global-leaderboard.**

## 0.1.7-dev — dnevni izazov i globalna rang-lista

Korisnik je odobrio rad redom: profil/nadimak, dnevni izazov i globalna rang-lista, na besplatnom Supabase projektu. Multiplayer uživo još nije započet.

- Dodat zaseban ekran izazova, 120 s, en/sr i susedno/slobodno povezivanje, offline vežba, lokalno čuvanje poteza po pokušaju i prikaz serverski potvrđenih rezultata. Kampanjski save i tabla ostaju odvojeni.
- Serverski generator/bodovanje su ponovljivi u Godotu i JavaScript-u. Server proverava reči iz punih licenciranih rečnika, putanje, duplikate i rok, pa sam računa rezultat. Direktan pristup tabelama je zabranjen klijentu.
- **Objavljeno na korisnikovom potvrđenom projektu `phfbohgbeqjvtfsgcjwi` („War of Words”), Free, Frankfurt.** SQL migracija uspešna, anonimni profili uključeni, privatni bucket sa en/sr rečnicima i hash-evi postavljeni, Edge Function `daily` objavljena.
- Prethodno poslati drugi Project URL nije korišćen posle korisnikove ispravke. Javni URL/ključ su u ignorisanom `game/online_config.json`; nijedan tajni Supabase ključ nije preuzet ili upisan u projekat.
- Gateway **Verify JWT with legacy secret ostaje uključen**. Automatska provera je odbila njegovo isključivanje; nastavili smo uz postojeću kontrolu i dokazali da servis tako radi. Nema preostalog zahteva za tom promenom.
- **Stvarni serverski test prošao 17:32:35 UTC:** posle punih 120 s, EN 70 i SR 30 poena pod profilom „QA provera”, oba na svojim globalnim listama. Ponovljen Start vraća isti pokušaj; ponovljen Submit ne menja score. Poziv bez sesije dobija 401, a prijavljeni klijent ne može direktno čitati privatne tabele. Test je Node HTTPS klijent, ne mrežna partija u Godotu/Androidu.
- Godot: **306 postojećih + 1106 provera dnevnog režima, 0 neuspeha**, završni logovi bez grešaka/upozorenja. Dodate provere stvarnog toka dodira kroz izbor jezika, pločice i potvrdu, izolacije save-a, determinističnosti, granica vremena i srpskih digrafa. Server/Godot parity u sve četiri kategorije, Edge handler testovi i prava/ograničenja SQL migracije kroz PGlite prolaze.
- Renderovani i pregledani početni ekran, profil/rang-lista, tabla, selekcija i rezultat na 1280 × 720. Slika rang-liste je Godot render stvarnog ranije preuzetog serverskog odgovora, **nije dokaz direktnog Godot HTTPS pristupa**. Renderi u `.local/daily-qa/`.

### Otvoreno pre Android isporuke

- Direktni Godot HTTPS test na ovom računaru blokira lokalni **Avast Web/Mail Shield**: Node/Windows prihvata njegov sertifikat, a Godot/mbedTLS prijavljuje TLS handshake i parsiranje tog CA sertifikata. Antivirus/TLS zaštita nisu menjani. Offline UI i serverski tok su provereni odvojeno; kompletan mrežni tok u Godotu/Androidu ostaje nepotvrđen.
- **Android build okruženje osposobljeno 2026-09-17:** Microsoft JDK 21.0.12.1, Android platform-tools 37.0.1, platform 35/rev 2, build-tools 36.0.0 i Godot 4.7.2 šabloni. Putanje su lokalno podešene. SDK HTTPS radi uz Windows CA skladište, bez isključivanja TLS provere.
- **Nepotpisani probni APK uspešno izvezen**, 94.856.406 bajtova, SHA256 `ebf5a074c1b85d050b6750ac994b2f7d419bc2b7ed3b18b5ccfdf7e7b48ba99b`, `.local/WarOfWords-0.1.7-UNSIGNED-CHECK.apk`. Import, postojeći/dnevni testovi i refill test prolaze; build log bez engine grešaka/upozorenja. Manifest: code 8 / 0.1.7, API 24–36, ARM64 + x86_64, INTERNET i VIBRATE; zipalign provera prolazi. Odsustvo potpisa potvrđeno apksigner-om. Nije instalaciono izdanje, nije objavljen.
- Korisnik potvrđuje da stari signing ključ verovatno nije prenet. Objašnjeno je da SHA256 APK-a sa Releases nije ključ. Godot je pri prvom izvozu automatski napravio lokalni debug ključ; on nije korišćen za probni APK i ne predstavlja preneti stari potpis. Skripta sada zahteva eksplicitnu putanju do ključa za potpisani build, a `-UnsignedCheck` omogućava bezbednu proveru izvoza.
- Korisnik je prikaz dnevnog režima ocenio kao prototip i zatražio završni izgled u stilu ostalih usvojenih ekrana. Vizuelna dorada tek sledi.
- Anonimni nalog je vezan za lokalnu sesiju; brisanje podataka može dati novi profil. Nema trajne prijave, moderacije, CAPTCHA toka ni potpune zaštite od botova. To je probna rang-lista, ne završena turnirska infrastruktura.
- Detalji, instalacija servera i testovi: `docs/daily-online.md`. Prethodni neuspešni/prekinuti live testovi ne predstavljaju uspeh; merodavan je `.local/daily-live-report.json` sa navedenim vremenom.

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

Nastaviti granu `codex/daily-global-leaderboard`. Alati i nepotpisani izvoz su provereni. Sa prethodnog računara bezbedno preneti postojeći signing ključ (van Git-a), proveriti fingerprint prema 0.1.6, doraditi izgled dnevnog režima, pa napraviti potpisani 0.1.7 i proveriti stvaran dnevni izazov → slanje → globalni plasman na telefonu. Korisniku su data Avast uputstva: Settings → General → Exceptions → Website/Domain za tačan host `phfbohgbeqjvtfsgcjwi.supabase.co`; nakon potvrde ponoviti Godot HTTPS test. Avast izuzetak još nije potvrđen niti mrežni tok u Godotu/Androidu proveren.

Radni kod: game/project.godot. Grana za nastavak: codex/daily-global-leaderboard. Pročitati AGENTS.md, proveriti Git i sačuvati lokalni rad pre usklađivanja. Ne prebacivati automatski na main.

## Istorija

- codex/shields-defeat-ready-effects, 1d5edb6, v0.1.4-android-preview: štit, uzemljenje protivnika, smer čuvara, sjaj moći i animacije poraza.
- codex/impact-enemies-music, 210e1a2, v0.1.3-android-preview: šteta pri udaru, 12 protivnika, muzika, mapa/dnevnik i odmah primenjivo slobodno povezivanje.
- codex/ornate-ui-combat-effects, bac0e4b, v0.1.2-android-preview: ukrašeni UI, efekti i početno slobodno povezivanje.
- codex/battle-polish-serbian, a499b75, v0.1.1-android-preview: srpski rečnik i borba.
- codex/android-playable, 0942094, v0.1.0-android-preview: prva igriva Android verzija.
- design/: šest usvojenih statičnih dizajna. V3 mokup/ i mockups/ sačuvani.
