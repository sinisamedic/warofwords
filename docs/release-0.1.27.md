# 0.1.27 / code28 — tok nove partije i jezika

Datum: 2026-09-22.

## Izmene

- Kada postoji sačuvana Kampanja ili Beskraj, naslovna eksplicitno nudi i novu partiju i nastavak.
- Promena jezika rečnika briše nastavke Kampanje i Beskraja; ostala podešavanja ih čuvaju.
- Povratak iz Beskraja više ne prenosi njegovog protivnika kao izabrani nivo Kampanje.
- Upozorenje o brisanju nastavka pri promeni jezika prevedeno je na svih šest jezika.

## Provere i paketi

- Pun `tools/build-android.ps1 -TestOnly` tok završen je sa izlazom 0, uključujući regresije za sva tri prijavljena slučaja. Ostaju poznata neblokirajuća Windows CA/log i ObjectDB upozorenja.
- APK: `exports/WarOfWords-0.1.27-android.apk`, 267.816.841 bajt, SHA256 `0b5374d31696dee41ee1c94cecdc4c3b39b9d8d77dfbb5537dbcad89e5b82505`.
- Play AAB: `exports/WarOfWords-0.1.27-play.aab`, 152.397.539 bajtova, SHA256 `829770391e77d034cdb1f402eaf05b4b1b3b270184fd4bdd0ef5c5868ee4f16`.
- APK manifest: `com.gottaplay.warofwords`, code 28, verzija 0.1.27, min API 24, target API 36. Potpis v2 je potvrđen; SHA256 sertifikata je `429a2d1b4700535f04c7252e8b28c0f8c4bb584a6cd8b7d863cd08070eff0abc`. Provera 16 KiB poravnanja prolazi.
- Sve 24 provere rečnika iz gotovog APK-a prolaze: šest jezika, poklapanje punog i izvornog rečnika, igrive i početne reči.
- AAB prolazi `bundletool 1.18.3 validate`; manifest potvrđuje isti paket/verziju/API opseg. `jarsigner` potvrđuje potpis uz očekivana upozorenja za samopotpisani sertifikat, vremenski žig i redosled ZIP unosa.
- Telefon nije bio povezan preko ADB-a. Instalacija i ručna provera tri ispravke na fizičkom uređaju ostaju obavezne pre zamene produkcionog izdanja.

Produkcijska prijava 0.1.26 bila je na Google pregledu u trenutku pripreme ovog kandidata. Dogovoreni tok je prvo interni Play test 0.1.27, zatim zamena produkcije tek posle uspešne ručne provere.

## Play stanje

- AAB je uploadovan u nacrt internog izdanja `0.1.27 internal`; Play ga je prepoznao kao code 28 / 0.1.27 i nije prijavio greške.
- Prikazana su dva neblokirajuća upozorenja: nedostaju deobfuscation fajl i simboli za izvorni kod. Ista upozorenja su postojala i za prethodni paket.
- Završno `Save and publish` nije potvrđeno u trenutku ove beleške. Produkciona prijava nije menjana.
