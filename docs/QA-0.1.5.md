# Provera Android verzije 0.1.5 — 2026-09-17

## Paket

- Godot 4.7.2; `com.sinisamedic.warofwords`; versionName **0.1.5**, versionCode **6**.
- `exports/WarOfWords-0.1.5-android.apk`, **86.662.480 bajtova**.
- SHA256: `179e9fb4ddea16d2fcc8030787896b487dd5a0aa8843ea917064836212a38459`.
- ARM64 + x86_64, minimum API 24, target 36; samo VIBRATE dozvola, bez INTERNET.
- Potpis proveren: `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`, isti kao ranija izdanja.

## Automatske i vizuelne provere

**290 PASS / 0 FAIL** u završnom import/test/export postupku, bez script/engine grešaka.

Nove provere pokrivaju pomeranje sadržaja tokom držanja prsta, interpolaciju nakon puštanja, povratak na mesto, zaključana poglavlja, blokiranje starih dodirnih oblasti tokom prelaza, veliki ON/OFF dodirni prostor bez preklapanja, vidljiv pomak glave/ramena i stopala oba lika na platformi. Reduced Motion zaustavlja njihanje i klizanje. Prethodne provere rečnika, čuvanja, štete, efekata, muzike i nagrada i dalje prolaze.

Godot renderi **1708 × 960** i **1280 × 576**: kampanja sa protivnicima, klizanje između dve staze, opcije u oba jezika sa mešanim ON/OFF stanjima, ukrašena pauza, pobeda sa dve osvojene zvezdice i završetak kampanje na srpskom. Nove ikonice i ukrasi su originalni vektori sa generatorom. Master dizajni nisu menjani. Odabrani renderi: `docs/screenshots/0.1.5/`.

## Android postupak

Instalacija preko 0.1.4 čuva kompletan glavni save. Završna provera potvrđuje isti SHA256 instaliranog `base.apk`, nastavak iste table/reči/rečnika i log bez runtime grešaka: **UPGRADE QA PASSED**.

**ANDROID PAGING QA PASSED**: dnevnik, obe strelice/smera, stvarno pomeranje staze dok je dodir zadržan, smirivanje nakon puštanja, povratak na identičan prikaz prve strane i izbor trećeg nivoa pored ilustracije, koji pokreće tačno tu misiju. Originalni glavni save vraćen; log bez runtime grešaka.

**ANDROID QA PASSED**: prevlačenjem potvrđen STONE, upotreba power-upa, čuvanje i nastavak pauzirane borbe, prava pobeda rečima SEAPLANES / DRUMLINS / INTONE, nagrada i otključavanje sledeće misije, unapređenje za 160 novčića i trajnost napretka posle restarta. Četiri nove ON/OFF komande i odvojeni jezici ostaju sačuvani. Srpska reč SPORAĆEVI prihvaćena dodirima i potvrdom; sačuvana srpska borba zadržava rečnik i nakon promene jezika novih borbi. Završni runtime log nema engine/script grešaka.

Namenski emulator 2400 × 1080, ista instalacija igre i potpis. Pre prvog čitanja podataka sačekati `sys.boot_completed=1`. Prvo pokretanje na ovom emulatoru kompajlira grafičke shadere; te početne zastoje razlikovati od GDScript grešaka. Testove pokretati uzastopno i tek nakon završetka Godot izvoza.

```powershell
node tools/qa-android-upgrade.cjs --serial emulator-5554 --apk exports/WarOfWords-0.1.5-android.apk
node tools/qa-android-pages.cjs --serial emulator-5554 --temporary-fixture
node tools/qa-android.cjs --serial emulator-5554 --reset-test-data
```

Upgrade test čuva podatke i poredi hash instaliranog `base.apk`. Test stranica privremeno otključava kampanju i dodaje dnevnik, snima sadržaj usred držanog pokreta, proverava oba smera, pa pokreće izabranu misiju pored velike slike protivnika. U `finally` vraća originalni glavni save. Puna partija briše samo testne podatke ove igre na emulatoru, proverava pobedu, unapređenje, nove ikonice i srpsku borbu. Skripte odbijaju fizički telefon.

## Granice

Nisu merene performanse/baterija na S23 Ultra. Likovi su 2D slike sa transformacijom oko stopala, bez skeletne animacije. Srpski i težina generatora ostaju probni. Instalirati APK preko postojeće aplikacije, bez deinstaliranja.
