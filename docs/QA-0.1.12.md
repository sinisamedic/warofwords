# Provere 0.1.12 — otključavanje opreme

Datum: 2026-09-18. Godot 4.7.2, Android code 13. Opseg: čišćenje Proboj slike, najava nagrada u kampanji i trajno sačuvan red dijaloga za novu opremu. Pravila duela i server nisu menjani.

## Automatizovane provere

- 1.570 PASS / 0 FAIL kroz `tools/build-android.ps1`, plus refill benchmark sa 0 neuspeha. Import/export nema script/engine greške ili upozorenja.
- Dodato 18 provera: migracija starog save-a bez starih najava, podudaranje svih pet nagrada sa nivoima, nivo bez posebne nagrade, dve nagrade u jednoj pobedi, jednokratna obrada pobede, dijalog posle animacije, potvrda jednog po jednog predmeta, čuvanje reda, stvarni cold-start nove scene, Back potvrda, ponovljena pobeda, poraz, sanitizacija neispravnog reda i povratak na rezultat pobede.
- `game/tests/test_equipment.gd` pokriva dodatni tok. Opšti test animacije poraza sada izričito postavlja stanje bez nepotvrđenih nagrada; stanje sa nagradama ima zasebne provere.

## Vizuelno

- `game/tests/render_unlocks.gd` renderuje EN/SR kampanju, već osvojenu nagradu, Proboj, Pečat leksikona i Rezervnu ćeliju, kao i novu sliku na beloj/navy podlozi.
- Pregledani prikazi 1280×576 i 1280×720: cela strela bez crnog traga, čitljivi nazivi i opisi, velika potvrda, mala ikonica nagrade ispod protivnikovog opisa, bez preklapanja brojeva nivoa ili dugmeta pripreme.
- Izvori slika ostaju nepromenjeni rezultati ImageGen alata. Nova produkciona slika je 2.471.583 bajta; Godot import i dalje 512 px sa mipmapama.

## APK

Namenski API 36 emulator, 2400×1080 tokom igre: 0.1.12 instaliran preko stvarne 0.1.11 bez brisanja; ceo progress fajl identičan neposredno posle instalacije. Privremeni fixture prikazuje Proboj i Pečat leksikona: stvarni dodir potvrđuje samo prvi predmet, force-stop zadržava drugi, Android Back potvrđuje poslednji. Ponovnim startom i stvarnim Play dodirom otvorena je kampanja sa odabranim četvrtim nivoom i najavom Proboja. Pregledani Android snimci dijaloga i mape. Nema script greške/pada u proveravanim tokovima. `ANDROID 0.1.12 UNLOCK QA COMPLETE`; originalni napredak emulatora vraćen. Fizički Samsung ostaje korisnička proba.

Lokalni Android dokazi: `.local/android-012-qa.log`, `.local/android-012-runtime.log`, `.local/android-012-unlock-breach.png`, `.local/android-012-unlock-lexicon.png`, `.local/android-012-campaign-reward.png`.

Emulator pri pokretanju prijavljuje obnovu nepodudarnog shader keša (`Failed to load cached shader, recompiling`), kao i u prethodnoj verziji. Posle kompilacije svi proveravani tokovi rade; Android start nije predstavljen kao start bez upozorenja.

- `exports/WarOfWords-0.1.12-android.apk`: 103.096.196 bajtova.
- SHA256: `c2e379fe8ed494f5e359e44605b0adf928f5b7f17c97e34505b40a7e3a23299c`.
- v2/v3 potpis i zipalign prolaze. Sertifikat `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`, isti kao 0.1.10/0.1.11. Paket `com.sinisamedic.warofwords`, versionCode 13, API 24–36, ARM64/x86_64.

Lokalni logovi: `.local/build-0.1.12.log`, `.local/unlocks-test-012.log`, `.local/render-unlocks-wide.log`, `.local/render-unlocks-169.log`. Renderi: `.local/unlocks-qa-1280x576/`, `.local/unlocks-qa-1280x720/`.
