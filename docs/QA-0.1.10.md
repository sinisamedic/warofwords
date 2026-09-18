# Provere 0.1.10 — prvi talas opreme

Datum: 2026-09-18. Godot 4.7.2, Android code 11. Opseg: Ogledalo, Pečat, Obnova, Pečat leksikona, Rezervna ćelija i izbor kompleta u Arsenalu.

## Automatske provere

- 1.552 PASS / 0 FAIL: postojeća igra, taktika kampanje, 41 nova provera opreme i dnevni režim. Refill benchmark: 0 neuspeha, oba rečnika i oba pravila povezivanja. Nisu menjani rečnici, generator ni serverska pravila.
- Provereni odložena refleksija, stvarno upijena šteta i zaokruživanje, smrt pre povratnog udara, oznaka Pečata i jednokratno poništavanje lečenja, istek, svi tikovi Obnove, osvežavanje bez slaganja, granica HP i pauza.
- Provereni uslovi otključavanja, stari save sa Probojem, promena inventara tokom sačuvanog duela, projektili/tikovi/rezerva pri nastavku, odvojene rezervne energije, sedam pločica naspram srpskih digrafa, duplikati reči i odbijanje nevažećih podataka.
- Prvi izvoz zaustavljen je zbog nepotpunih lokalnih signing promenljivih. Posle postavljanja putanje, alias-a i lozinke, potpisani izvoz prolazi. Stari test taktike je pri izlasku prerano završavao audio server; sačekivanje od 0,5 s uklanja upozorenje, završni test nema grešaka/upozorenja. Runtime kod zvuka nije menjan.
- Uvoz/izvoz novog paketa nema script/engine greške. Sve nove izvorne slike su pojedinačno manje od 2,4 MB. PNG izvori ostaju nepromenjeni, Godot koristi 512 px uvoz sa mipmapama.

Lokalni logovi: `.local/build-0.1.10.log`, `.local/tactics-010-final.log`, `.local/test-equipment.log`, `.local/import-010-final.log`, `.local/export-010.log`.

## Prikaz

Godot renderi: 1280 × 720 i 1280 × 576, engleski/srpski Arsenal, zaključan predmet, svih pet kategorija, priprema, unapređenje i borba. Provereni veliki dodirni ciljevi, kontrast teksta, dvoredni nazivi artefakata i statusi koji ne prekrivaju lica boraca. Ponovljivo:

```powershell
Godot --path game --resolution 1280x720 --script res://tests/render_equipment.gd
Godot --path game --resolution 1280x576 --script res://tests/render_equipment.gd
```

## Android paket

- `exports/WarOfWords-0.1.10-android.apk`, **97.487.635 bajtova**.
- SHA256: `aaa6461663627902708b867034a0669726d3b170b883af7f8b195c7e28a3f584`.
- `apksigner verify`: v2/v3 prolaze. Sertifikat SHA256: `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276` — lokalni potpis ovog računara iz izdanja do 0.1.6, različit od kućnih 0.1.7–0.1.9. Korisnik je odobrio ovu zamenu i novu instalaciju.
- `zipalign -c -P 16 4` prolazi. API 24–36, ARM64 + x86_64, INTERNET/VIBRATE. Online javna konfiguracija vraćena je iz objavljenog APK-a 0.1.7, ostaje ignorisana i nije u Git-u. Nijedan privatni serverski ključ nije potreban.
- Instalacija na namenski Android API 36 emulator uspešna. **ANDROID EQUIPMENT QA PASSED:** stvarni dodiri proveravaju zaključani predmet, izbor svih uređaja, izbor i uklanjanje oba artefakta, aktiviranje Ogledala/Pečata/Obnove, povrat rezerve, pauzu, force-stop i nastavak. Nema runtime script grešaka ni pada aplikacije. Originalni podaci emulatora vraćeni su u `finally`. Log `.local/android-equipment-qa.log`; snimci `.local/android-equipment-*.png`.
- Javni konfiguracioni host i format ključa potvrđeni; read-only HTTPS `/auth/v1/health` vraća GoTrue. Nije slat novi rezultat na globalnu listu. SHA256 instaliranog `base.apk` identičan je izvornom APK-u.

Ponovljivo, na namenskom emulatoru sa 2400 × 1080 landscape prikazom:

```powershell
node tools/qa-android-equipment.cjs --serial emulator-5554 --temporary-fixture
```

## GitHub objava

[v0.1.10-android-preview](https://github.com/sinisamedic/warofwords/releases/tag/v0.1.10-android-preview), izvorni commit `bc9e819`, prerelease (nije draft). APK i SHA256 asset-i imaju potvrđene veličine i GitHub digest-e identične lokalnim fajlovima.

## Granice provere

Emulator je sporiji od fizičkog telefona i pri početku prijavljuje ponovno prevođenje keširanog OpenGL shader-a. To nije nova greška skripte niti merilo FPS-a na Samsung telefonu. Kvalitet vibracije, subjektivni balans i duže partije na fizičkom uređaju ostaju korisnička proba. Globalno bodovanje nije menjano niti su za ovu doradu slati novi QA rezultati na javnu listu.
