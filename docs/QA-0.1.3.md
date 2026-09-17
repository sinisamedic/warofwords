# Provera Android verzije 0.1.3 — 2026-09-17

## Paket

- Godot 4.7.2; `com.sinisamedic.warofwords`; versionName **0.1.3**, versionCode **4**.
- `exports/WarOfWords-0.1.3-android.apk`, **86.512.940 bajta**.
- SHA256: `b13ee2f88d3ea67dbd1643db42f3072c033ab815908f89f4b9269e207ac60c6d`.
- ARM64 + x86_64, minimum API 24, target 36. VIBRATE bez INTERNET dozvole.
- Potpis proveren; isti sertifikat kao ranija izdanja: `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`.
- U APK-u su provereni novi protivnici, ikonice, obe muzičke datoteke i CC0 licenca.

## Automatske provere

**210 PASS / 0 FAIL** u završnom build-u (`game/tests/test_game.gd`). Pored rečnika, kampanje, unapređenja, srpskog jezika, fontova i slobodnog povezivanja:

- HP ne pada pri ispaljivanju ni pre isteka leta; pada tačno jednom na dolasku.
- CPU šteta i potrošnja štita čekaju dolazak; štit podignut tokom leta blokira udar.
- Arc prekida najavu pri dolasku. Stariji smrtonosni projektil završava duel, bez duplih nagrada.
- Projektil u letu preživljava JSON, pauzu, meni i ponovno učitavanje. Energija se ne troši ponovo, niti se udar ponavlja posle restarta. Neispravni payload-i se odbijaju.
- Ograničenje kozmetičkih čestica ne briše stvarne napade; 30 brzih testnih napada stiže tačno jednom.
- Trzaj je samo na pogođenom liku; Reduced Motion ga uklanja.
- Mapa/dnevnik: oba smera prevlačenja, granice stranica, zaključana poglavlja, poslednja nepotpuna strana, vertikalni pokreti i strelice.
- Promena povezivanja odmah menja i započetu borbu. Stari save bez tog polja ostaje kompatibilan.
- Dve prave muzičke datoteke duže od minuta (191,69 / 65,07 s), nezavisan mute, pauza u pozadini, nastavak i trajno podešavanje.
- Izbor svakog od 12 zasebnih likova i portreta.

## Vizuelna provera

Stvarni Godot renderi na 1708 × 960 i 1280 × 576: glavni meni, srpski meni sa Continue, centrirani naslovi, 4 × 5 dnevnik, opcije, protivnici i portreti, Đ/č/ć/š/ž i efekti. Visoke krune iz atlasa imaju eksplicitne regione kako ne bi bile odsečene. Godot log bez script/engine grešaka. Master dizajni i stariji mokupovi nisu menjani.

## Android provera

Instalirani `base.apk` proveren je SHA256 otiskom jednakim gornjem fajlu. Nadogradnja čuva kompletan save, pa Continue vraća istu tablu, reči i pravilo. Početna provera preko 0.1.2 i završna provera instaliranog paketa su prošle.

Svi završni scenariji su prošli na navedenom instaliranom APK-u:

- STONE prevlačenjem, Freeze, restart i pauza, pobeda preko REPAIRMAN / SENTINELS, 300 novčića, unapređenje od 160 i očuvanje 140 pri restartu.
- Srpski OBURVANJE dodirima + potvrdom, odvojen izbor jezika i rečnika, čuvanje sva četiri prekidača, vraćanje srpskog duela uz engleske menije.
- ADDITIVES preko udaljenih polja `[6,0,20,3,11,17,16,2,5]`, Hint, restart i promena pravila iste sačuvane borbe u oba smera.
- Mapa i dnevnik: stvarno Android prevlačenje napred/nazad, strelica vodi na istu stranu, 41 reč u tri strane, granica poslednje strane. Povratna strana daje identičan snimak. Privremeni fixture je vraćen u originalni save.
- `UPGRADE QA PASSED`, `ANDROID QA PASSED`, `FREE ANDROID QA PASSED`, `ANDROID PAGING QA PASSED`. Završni runtime logovi bez script/engine/Android fatal grešaka.

Odabrani renderi i snimci: `docs/screenshots/0.1.3/`. Lokalni kompletni logovi su u ignorisanom `.local/`; testne skripte su verzionisane.

Ponovljive komande, samo na namenskom emulatoru 2400 × 1080:

```powershell
node tools/qa-android-upgrade.cjs --serial emulator-5554 --apk exports/WarOfWords-0.1.3-android.apk
node tools/qa-android.cjs --serial emulator-5554 --reset-test-data
node tools/qa-android-free.cjs --serial emulator-5554
node tools/qa-android-pages.cjs --serial emulator-5554 --temporary-fixture
```

Prvi test čuva napredak. Drugi briše samo testne podatke igre u emulatoru. Treći nastavlja tu partiju. Poslednji privremeno postavlja 41 reč i otključane regione, zatim u `finally` vraća originalni save. Skripte odbijaju fizički telefon. Godot import/export i Android testove pokretati uzastopno: gašenje editorovog ADB procesa može prekinuti paralelan test.

## Granice

S23 Ultra, zvučnici telefona, subjektivni miks/haptika, baterija i dugotrajan FPS nisu mereni. Provereni su fajlovi, miks/lifecycle logika, stvarni renderer i Android ponašanje. Muzika su autorski CC0 snimci; konačan izbor i glasnoću potvrđuje korisnikov test. Likovi imaju 2D animacije pomeranjem/nagibom, bez skeletne animacije. Srpski je probni rečnik. Čuvanje je lokalno; APK instalirati preko postojeće igre, bez deinstaliranja.
