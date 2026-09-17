# Provera Android verzije 0.1.6 — 2026-09-17

## Paket

- Godot 4.7.2; `com.sinisamedic.warofwords`; versionName **0.1.6**, versionCode **7**.
- `exports/WarOfWords-0.1.6-android.apk`, **94.859.979 bajtova**.
- SHA256: `9afb875fec3100f2b44b6c480082c76827419d57460f47ce9b6a1a86d8d150a7`.
- ARM64 + x86_64; minimum API 24, target API 36; samo VIBRATE dozvola, bez INTERNET.
- Potpis: `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`, isti kao prethodna izdanja.
- Novi build sadrži sva tri pejzaža kampanje, atlas heroja, deformaciju nogu i shader raspada protivnika. Testovi i lokalni helper za ponavljanje poraza nisu u APK-u. Raniji neobjavljeni 0.1.6 paket je zamenjen ovim build-om.

## Import, testovi i izvoz

**306 PASS / 0 FAIL**, zatim **REFILL RESULT: 0 failures**. Završni import/test/export log nema script/engine grešaka ni upozorenja. Provere pokrivaju nivoe pri zadržanom dodiru, animaciju prelaza lokacija, mirovanje/pucanje/udarac heroja, savijanje kolena i pad kroz zglobove, dodir tla pre nestajanja, raspad protivnika, odložen rezultat, jednokratnu nagradu i ispravno vraćanje likova u sledećoj borbi.

Benchmark dopune ima 768 poteza: engleski/srpski, susedno/slobodno povezivanje, stara/nova dopuna. Nova dopuna zadržala je bar jednu reč od pet ili više polja posle svih svojih 384 poteza; provereni su zakoniti putevi, neponavljanje potrošenih reči i nepromenjena neiskorišćena slova. Rezultat nije garancija za svaku slučajnu tablu.

## Vizuelni pregled

Native Godot: 1280 × 576 i 1708 × 960. Pregledane tri lokacije, prelaz, borba, mirovanje/pucanje/udarac i po sedam kadrova poraza oba lika. Originalna cela ilustracija ostaje na naslovnoj; artikulisani heroj koristi se samo u borbi. Reduced Motion izostavlja pad i raspad.

## Android provere

Namenski emulator 2400 × 1080, Android API 36, host GPU. Postupci se izvršavaju uzastopno posle završetka Godot izvoza.

- **UPGRADE QA PASSED:** instalacija preko 0.1.5 / code 6 čuva kompletan save. Hash instaliranog `base.apk` jednak je objavljenom artefaktu. Nastavak čuva tablu, pronađene reči, rečnik i pravilo povezivanja. Runtime log nema grešaka.
- **ANDROID PAGING QA PASSED:** prevlačenje i strelice dnevnika, granice stranica, pomeranje kampanje tokom zadržanog dodira i smirivanje nakon puštanja, povratak na isto poglavlje. Dodiri od 450 ms biraju nivoe 1, 3 i 4; nivo 3 pored velike slike protivnika pokreće upravo misiju 2 (indeksi počinju od nule). Originalni glavni save vraćen. Nema runtime grešaka.

- **ANDROID QA PASSED:** STONE prevlačenjem, dopuna i šteta, power-up, nastavak sačuvane pauzirane borbe, Aegis, prava pobeda rečima SENTINELS / REPAIRMAN, nagrada, otključavanje i unapređenje za 160 novčića. Srpska reč OPASIVAČE potvrđena stvarnim dodirima. Oba jezika i četiri podešavanja opstaju posle restarta; promena jezika menija i rečnika novih borbi ne menja rečnik sačuvanog duela. Završni log nema engine/script grešaka.

Prvi prolaz celog testa nije registrovao kratak dodir za promenu jezika menija odmah posle otvaranja opcija na sporom emulatoru. Harness sada zadržava taj dodir 150 ms i potvrđuje sačuvan izbor, sa najviše tri idempotentna pokušaja. Ceo test je potom ponovljen i prošao na istom APK-u. Povremeno upozorenje emulatora o nečitljivom shader kešu dovodi do rekompajliranja; nije GDScript greška.

- **ANDROID COMBAT QA PASSED:** napunjen Pulse radi uz aktivan štit; smrtonosni udar daje pobedu i nagradu tačno jednom; Next pokreće sledeću misiju. Smrt heroja tokom držanog dodira završava poraz, a Retry vraća istu misiju sa punim zdravljem bez ponovne nagrade. Sva tri runtime loga bez grešaka. Originalni save vraćen.

Prvi borbeni prolaz pauzirao je pre završetka leta projektila pri sporoj rekompilaciji shadera. Harness sada po potrebi nastavlja borbu dok u sačuvanom stanju nema projektila u letu i ostavlja više vremena za novi završetak. Ponovljene su sve borbene provere na nepromenjenom APK-u.

```powershell
node tools/qa-android-upgrade.cjs --serial emulator-5554 --apk exports/WarOfWords-0.1.6-android.apk
node tools/qa-android-pages.cjs --serial emulator-5554 --temporary-fixture
node tools/qa-android.cjs --serial emulator-5554 --reset-test-data
node tools/qa-android-combat.cjs --serial emulator-5554 --temporary-fixture
```

## Granice

Nisu merene performanse i baterija na fizičkom S23 Ultra. Heroj koristi 2D zglobove i deformaciju postojećih slika; protivnici imaju shader dezintegraciju, ne zasebne skelete. Srpski rečnik i balans dopune ostaju probni. Ovo je debug-potpisan Android preview, ne Play Store izdanje. Instalirati preko postojeće aplikacije bez deinstaliranja.
