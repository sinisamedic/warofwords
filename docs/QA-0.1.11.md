# Provere 0.1.11 — ikonica i Proboj

Datum: 2026-09-18. Godot 4.7.2, Android code 12. Opseg: odabrana W ikonica sa manjim slovom i Android adaptive slojevima; potpuna ilustracija Proboja sa vrhom projektila preko oboda. Mehanika i mrežni kod nisu menjani.

## Provere

- `tools/build-android.ps1`: uvoz, 1.552 PASS / 0 FAIL, refill benchmark sa 0 neuspeha, potpisani izvoz. Build log nema script/engine greške ni upozorenja.
- Godot renderi pet stanja: Arsenal, unapređenja, priprema, delimično i potpuno punjenje Proboja, na 1280×576. Vizuelno pregledani Arsenal i borba: cela alfa silueta, bez odsečenog vrha, sa nezavisnim spoljnim prstenom punjenja. Log završava sa `BREACH ART QA COMPLETE`.
- Potpis v2/v3 validan; zipalign sa 16 KiB proverom prolazi. Paket `com.sinisamedic.warofwords`, versionName 0.1.11, versionCode 12, API 24–36, ARM64/x86_64. Manifest koristi adaptive launcher XML; posebni foreground i background su uključeni.
- Namenski API 36 emulator: `adb install --no-incremental -r` preko stvarne 0.1.10 uspeva. Ceo `progress.json` je identičan pre i neposredno posle instalacije, bez brisanja podataka. Aplikacija zatim prijavljuje `WarOfWords: ready`, bez script greške ili pada.
- Prvi start emulatora obnavlja nepodudaran shader keš (`Failed to load cached shader, recompiling`) i Android `am start -W` prijavljuje timeout dok traje inicijalizacija; nakon toga igra uspešno postaje spremna. To nije predstavljeno kao start bez upozorenja.
- Stvarni Android launcher pregledan u spisku aplikacija: W je ceo u kružnoj ikoni, zlatni ukras i plava podloga su vidljivi. Fizički Samsung ostaje korisnička proba; nije tvrđeno da su svi proizvođački launcher-i testirani.

Lokalni dokazi: `.local/build-0.1.11.log`, `.local/breach-full-art-qa.log`, `.local/breach-art-arsenal.png`, `.local/breach-art-battle-partial.png`, `.local/android-011-install.log`, `.local/android-011-launch.log`, `.local/android-011-drawer.png`.

## Paket

- `exports/WarOfWords-0.1.11-android.apk`: 103.173.929 bajtova.
- SHA256: `8e1750b7605bb783a1f7a5641f00c36dcd58d104205164b91c50f26c2ea5c5d6`.
- Sertifikat SHA256: `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`, isti kao 0.1.10. Privatni ključ ostaje van Git-a.
- Izvorni PNG fajlovi pojedinačno su ispod 3 MB; nema novih fajlova preko 10 MiB. APK ide u release assets, ne u Git istoriju.
