# 0.1.28 / code29 — kraći početak Beskraja

Datum: 2026-09-22.

## Izmena

- Na naslovnoj, kada postoji sačuvan Beskraj, usko dugme za novu partiju sada piše `BEGIN` umesto `ENTER ARENA`.
- Kratki prevodi su: srpski `POČNI`, nemački `START`, francuski `JOUER`, španski `INICIAR` i italijanski `INIZIA`.
- Puno dugme na ekranu bez nastavka i dugme pripreme nisu menjani.

## Provere i paketi

- Kompletan `tools/build-android.ps1 -TestOnly` tok prošao je bez neuspeha; ostaju poznata neblokirajuća Windows CA/log i ObjectDB upozorenja.
- APK: `exports/WarOfWords-0.1.28-android.apk`, 267.816.949 bajtova, SHA256 `addff6d33b4442d327f0b6d0868f6b8af993ed5214a109832ae9e24a79f602cd`.
- Play AAB: `exports/WarOfWords-0.1.28-play.aab`, 152.397.610 bajtova, SHA256 `7b40d5fc1d2111821f4d1f07aaba8efe75739963ef55638f9a9fc6c84f83d872`.
- APK i AAB manifesti potvrđuju paket `com.gottaplay.warofwords`, code 29, verziju 0.1.28, min API 24 i target API 36.
- APK potpis v2 je potvrđen; SHA256 sertifikata je `429a2d1b4700535f04c7252e8b28c0f8c4bb584a6cd8b7d863cd08070eff0abc`. Provera 16 KiB poravnanja prolazi.
- Sve 24 provere rečnika iz APK-a prolaze. AAB prolazi `bundletool 1.18.3 validate`, a `jarsigner` potvrđuje potpis uz poznata ZIP/self-signed upozorenja.
- Telefon nije povezan preko ADB-a. Ručna proba na uređaju sledi kroz interni Play kanal.

Produkcijska prijava 0.1.26 nije menjana.
