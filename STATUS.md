# Trenutno stanje

Ažurirano: 2026-09-18. **Aktivna grana: codex/equipment-wave-one.**

## Posle 0.1.10 — ilustracija Proboja i predlozi ikonice

- Proboj sada ima detaljnu ilustraciju zlatnog projektila koji probija metalni oklop, umesto privremenog linijskog simbola. Zajednički prikaz opreme koristi je u Arsenalu, unapređenjima, pripremi i borbi; kružno punjenje ostaje dinamičko. Originalni ImageGen PNG i tačan prompt su u `game/assets/art/`.
- Godot uvoz i stvarni renderi pet stanja na 1280×576 prolaze bez script/engine grešaka. Pregledani Arsenal i borba; interaktivni Godot pregled otvoren sa izolovanim probnim napretkom. Mehanika nije menjana. Novi APK nije pravljen: objavljeni 0.1.10 još sadrži stari simbol.
- Četiri originalna **predloga** ikonice telefona: Zlatni W, Slova puna energije, Heroj i Živi leksikon. Galerija `design/icon-proposals/index.html` ima prikaze 48/64 px, kružnu/zaobljenu masku i svetlu/tamnu podlogu. Izvorne slike i tačni promptovi sačuvani; nijedan predlog još nije odabran niti ugrađen.
- **Sledeći korak:** korisnik bira ikonicu; zatim pripremiti Android launcher resurse za taj izbor i sledeći APK sa novom ilustracijom Proboja. Aktivna grana ostaje `codex/equipment-wave-one`.

## 0.1.10 — prvi talas opreme

Korisnik je odobrio implementaciju prvog talasa i novi APK sa lokalnim potpisom. Urađeni su Ogledalo, Pečat, Obnova, Pečat leksikona i Rezervna ćelija: ukupno osam aktivnih uređaja i dva artefakta. Ostatak kolekcije je budući predlog.

- Novi Arsenal ima pet kategorija, velike detaljne ilustracije, opis, brojke, uslove otključavanja i izbor. Četiri borbena mesta, jedan pasivni artefakt, zajednička unapređenja po boji. EN/SR prikaz. Priprema pokazuje komplet.
- Ogledalo vraća deo stvarno upijene štete tek pri udaru povratnog projektila. Pečat sprečava sledeće lečenje unutar 20 s. Obnova leči u pet delova tokom 8 s. Artefakti pojačavaju dugu reč ili čuvaju višak energije. Oprema, rezerva, aktivni efekti i projektili ostaju vezani za sačuvan duel.
- Otključavanja: Obnova susret 3, Pečat 6, Ogledalo 8, Rezervna ćelija 10; Pečat leksikona pobedom uz reč od 7+ pločica. Proboj ostaje susret 4. Ranije pobede važe. Detaljan balans: `docs/game-design.md`.
- APK `exports/WarOfWords-0.1.10-android.apk`, code 11, 97.487.635 bajtova, SHA256 `aaa6461663627902708b867034a0669726d3b170b883af7f8b195c7e28a3f584`. Potpis v2/v3 i zipalign prolaze. Koristi lokalni sertifikat `a071affa…d276` (isti kao do 0.1.6), **različit od kućnih 0.1.7–0.1.9**. Korisnik je izričito odobrio deinstalaciju i gubitak napretka. Ključ ostaje van Git-a.
- 1.552 PASS / 0 FAIL + refill benchmark. Završni uvoz/izvoz i test opreme bez script grešaka. Test taktike sada čeka 0,5 s na gašenje audio servera i više nema upozorenje pri izlasku. Godot renderi EN/SR pregledani na 1280×720 i 1280×576.
- **ANDROID EQUIPMENT QA PASSED** na API 36 / 2400×1080: izbor i uklanjanje opreme dodirima, aktiviranje novih moći, rezerva, pauza, force-stop i nastavak. Originalni podaci emulatora vraćeni. Fizički Samsung i balans još nisu testirani. Detalji i ponovljivi testovi: `docs/QA-0.1.10.md`.
- Javni `game/online_config.json` obnovljen iz objavljenog APK-a 0.1.7, ignorisan kao ranije; HTTPS health provera prolazi. Dnevna pravila/server nisu menjani. Nisu slati novi QA rezultati na rang-listu.
- **Objavljeno i provereno:** [v0.1.10-android-preview](https://github.com/sinisamedic/warofwords/releases/tag/v0.1.10-android-preview), izvorni commit `bc9e819`. APK i SHA256 prilog su dostupni; GitHub digest i veličine odgovaraju lokalnim fajlovima. Izdanje je prerelease, nije draft. Izvor je push-ovan na `codex/equipment-wave-one`; lokalni i udaljeni SHA provereni.

## 0.1.9 — taktika kampanje i poraz

Korisnik je odobrio tri tipa protivnika, novo oružje kao nagradu kampanje i sređivanje ekrana poraza. Trajni profil je odložen; veća kampanja i kolekcija ostaju predlozi.

- Prvi susret je obuka; ostali imaju teški drugi udar, otkazivo lečenje ili oklop koji se razbija rečju od šest pločica. Najave i savet postoje u pripremi, borbi i porazu. Broj nivoa ostaje 12.
- Proboj se dobija pobedom na četvrtom susretu. Zamenjuje Puls po izboru u Arsenalu: razbija oklop, ali nanosi 6 manje štete; deli nivo unapređenja. Stari igrači sa tom pobedom ga već imaju. Oprema i oklop sačuvane borbe pravilno se nastavljaju.
- Novi poraz: ukrašeni panel, protivnik i preostalo zdravlje, reči/vreme/nagrada, najduža reč, taktički savet, Mapa/Arsenal/Ponovi. Pregledani EN/SR prikazi na 1280×720 i 1280×576.
- Lokalni **exports/WarOfWords-0.1.9-android.apk**, code 10, 94.897.470 bajtova, SHA256 `4d2d64722789d51d2d1658d82e86d1d75e3e2f3c668619dc777dc8b04251b89b`. Potpis je isti kao 0.1.7/0.1.8, apksigner i zipalign prolaze. **Nije objavljen na GitHub Releases.**
- 1511 PASS provera igre/taktike/dnevnog režima i refill benchmark bez neuspeha. Završni build nema script/engine greške. Test taktike je pri izlasku zadržavao dva MP3 audio objekta; test sada sačeka gašenje audio servera i zasebna završna provera prolazi bez upozorenja. Runtime kod nije menjan tom korekcijom testnog gašenja. Logovi `.local/android-019-build.log`, `.local/tactics-final.log`, renderi `.local/tactics-qa/`.
- Supabase/daily server nije menjan. Fizička proba novog balansa i ekrana poraza tek sledi. Detalji i početne brojke: `docs/game-design.md`.

## 0.1.8 — dopuna, dodirni odziv i katanci

**APK je gotov lokalno, nije objavljen na GitHub-u.** Izvorni commit `48068a8` je push-ovan. GitHub draft `v0.1.8-android-preview` (release ID 390972680) sadrži samo SHA256 prilog. Dva CLI uploada su zastala; direktan GitHub API potom je dva puta vratio HTTP 500 `Error saving asset`. Nema APK asset-a. Ne nuditi release download link dok upload i digest nisu potvrđeni. Lokalni paket je korisniku dat za probu.

- Korisnik potvrđuje da rang-lista radi na telefonu. Tražio je uklanjanje niza gotovih reči na istoj putanji, zvuk/vibraciju izbora u dnevnom izazovu i vežbi, i ikonicu katanca umesto „KLJUČ”. Sve tri izmene implementirane.
- Kampanja i daily-v2 dopuna ugrađuju najviše jednu poznatu reč, uz najmanje dva preostala polja i bar jedno novo. Nikada namerno ne postavljaju celu reč samo u obrisana polja. Nepotrošena slova ostaju ista; nasumična dopuna može slučajno napraviti reč. Početne table i bodovanje nisu menjani.
- Daily server podržava i v1 i v2; migracija čuva stare pokušaje/rezultate i odvaja nove rang-liste. Migracija i nova funkcija su objavljene. Automatska provera prvo je zaustavila deploy; posle izričite korisnikove potvrde objava je uspešna. JWT kontrola ostaje uključena.
- APK `exports/WarOfWords-0.1.8-android.apk`, code 9, 94.893.374 bajta, SHA256 `62d6e86ba22dceb6c786cecdcb11b210a3731716103968226fe598be8d94bf28`. Isti potpis kao 0.1.7, potvrđen apksigner-om; zipalign prolazi. Instalirati preko 0.1.7 bez deinstalacije.
- Završni build: 1487 PASS provera igre/dnevnog režima, refill benchmark bez neuspeha, log bez script/engine grešaka. Kampanjska nova dopuna imala je 5+ reč na svih 384 testiranih tabli; maksimum dopune oko 20 ms na ovom računaru. To nije garancija za svaki slučaj.
- Node/Godot parity u sva četiri režima, zamrznuti v1 replay, handler validacija i obe SQL migracije/prava pristupa prolaze. **Stvarni Godot v2 test 8/8 prolazi**, uključujući 120 s → potvrdu → globalni plasman i srpsku kategoriju. Stvarni read-only pozivi potvrđuju dostupnost obe verzije liste. Logovi: `.local/android-018-build.log`, `.local/daily-v2-live.log`, `.local/legacy-live.log`.
- Katanac pregledan na renderu 1280×576. Zvuk izbora testiran preko stvarnog audio dispatch-a: jedan događaj za novo polje, bez dupliranja i bez zvuka kad je utišan. Stvarna vibracija na telefonu ostaje korisnička proba; kod koristi isti Android haptic poziv i podešavanje kao kampanja.

## 0.1.7 — novi izgled i novi potpis, APK spreman

Objavljeno i provereno: [v0.1.7-android-preview](https://github.com/sinisamedic/warofwords/releases/tag/v0.1.7-android-preview), izvorni commit `88de060`. APK i SHA256 su uploadovani; GitHub digest/veličina odgovaraju lokalnom paketu. Izdanje je prerelease, nije draft.

Korisnik je izričito odobrio novi ključ, jednu deinstalaciju stare testne aplikacije i gubitak lokalnog napretka. Stari ključ više nije prepreka ovoj isporuci.

- Dnevni izazov, tabla i rezultat koriste postojeću Observatory ilustraciju, pravilno skalirane ukrašene panele, reljefna dugmad, naslovni font, zlatne žetone, krunu i istaknut sopstveni red na listi. Nisu dodate nove spoljne slike. Tekst se prilagođava širini; oba jezika zadržana.
- Napravljen potpisani APK exports/WarOfWords-0.1.7-android.apk, code 8, 94.889.278 bajtova; SHA256 118ad610bbba0e84a687975e4f11d4e0531244412fc978ae9b0357723bbf2d36.
- Novi namenski RSA 3072 ključ: sertifikat SHA256 429a2d1b4700535f04c7252e8b28c0f8c4bb584a6cd8b7d863cd08070eff0abc. Ključ i lokalni signing.json ostaju isključivo u ignorisanom .local/signing/; machine.json pokazuje na konfiguraciju. **Pre prelaska na drugi računar bezbedno preneti ceo signing folder van Git-a i napraviti rezervnu kopiju.** To nije stari niti automatski generisan Godot ključ.
- Provere: 306 postojećih + 1106 dnevnih provera i refill benchmark bez neuspeha; import/export log bez engine grešaka/upozorenja. Potpis v2/v3 i zipalign validni; API 24–36, ARM64/x86_64, INTERNET/VIBRATE. Godot renderi pregledani na 1280×720 i 1280×576. Pravi desktop Godot online tok prethodno potvrđen sa 8/8 provera; mrežni kod nije menjan ovom doradom.
- Telefon nije povezan preko ADB-a; instalacija i online partija na fizičkom uređaju ostaju korisnička proba. Potrebna deinstalacija verzija do 0.1.6 pre instalacije 0.1.7.

## Prethodna faza 0.1.7-dev — istorija implementacije

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

- **Godot HTTPS prepreka rešena:** korisnik je dodao Avast izuzetak za host projekta. Izolovani stvarni Godot test (`--headless`) prošao je svih 8 provera, `LIVE DAILY RESULT: 0 failures`: prijava, početak/idempotentnost, bodovanje, srpski rečnik, potvrda rezultata posle 120 s, zaštita od prepisivanja, globalni sopstveni plasman i završetak srpske kategorije. Log `.local/daily-godot-headless-live.log` bez engine/TLS grešaka. Prvi vidljivi test uključivao je dodatne korisničke poteze (12 reči / 545 poena koje je server sačuvao), pa nije merodavan za automatizovane tvrdnje o tri poteza. Android mrežni test ostaje otvoren.
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

Nastaviti granu `codex/equipment-wave-one`. Posle objave 0.1.10 korisnik proba novi Arsenal, otključavanja i kombinacije na telefonu; naročito Pečat protiv iscelitelja, Ogledalo protiv snažnog udarca i Obnovu u dužoj borbi. Tek posle povratnih informacija menjati balans ili birati drugi talas. Ostali uređaji iz kolekcije i trajni profil još nisu implementirani.

Za drugi računar: `git fetch origin --prune`, pregledati lokalno stanje, nastaviti `codex/equipment-wave-one` i povući bez destruktivnog resetovanja. Engine/SDK/template-i se ne prenose Git-om. Signing ključ i javnu online konfiguraciju preneti zasebno van Git-a; ne vraćati slučajno kućni potpis ako se nastavlja linija 0.1.10. Raniji 0.1.8 draft ostaje neobjavljen.

## Istorija

- codex/shields-defeat-ready-effects, 1d5edb6, v0.1.4-android-preview: štit, uzemljenje protivnika, smer čuvara, sjaj moći i animacije poraza.
- codex/impact-enemies-music, 210e1a2, v0.1.3-android-preview: šteta pri udaru, 12 protivnika, muzika, mapa/dnevnik i odmah primenjivo slobodno povezivanje.
- codex/ornate-ui-combat-effects, bac0e4b, v0.1.2-android-preview: ukrašeni UI, efekti i početno slobodno povezivanje.
- codex/battle-polish-serbian, a499b75, v0.1.1-android-preview: srpski rečnik i borba.
- codex/android-playable, 0942094, v0.1.0-android-preview: prva igriva Android verzija.
- design/: šest usvojenih statičnih dizajna. V3 mokup/ i mockups/ sačuvani.
