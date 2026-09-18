# Provere 0.1.13 — kampanja, pojačanja i rezultat

Datum: 2026-09-18. Godot 4.7.2, Android code 14. Korisnik je posle Godot pregleda odobrio izgled i zatražio APK uz uklanjanje crnog oboda medaljona.

## Izmene i vizuelna provera

- Velika nagrada levo od „Pripremi se“, bez tekstualnog reda o otključavanju. Osvojena ima originalni SVG bedž sa nacrtanom kvačicom.
- Malo manji medaljoni pojačanja, sjaj i zlatna oznaka odabranog, tamnija preostala dva. Reduced Motion koristi miran oreol; dodirne površine ostaju velike.
- Pobeda pokazuje broj upravo završenog nivoa; EN/SR i posebno završetak kampanje.
- Neprozirni krug iza medaljona bio je pomeren nadole i pravio crni donji obod. Uklonjen je iz zajedničkog `Ornaments.medallion`; izvorne PNG ilustracije nisu menjane. Zlatni obod, punjenje i Proboj bez punjenja ostaju isti.
- `game/tests/render_campaign_polish.gd`: oba jezika, sve nagrade pre/posle osvajanja, sva tri pojačanja, Reduced Motion i pobede 1/4/12. Raspored je pregledan na 1280×720 i 1280×576 pre korisničke potvrde. Posle uklanjanja crnog kruga ponovljen render na 1280×576 i pregledani čisti rubovi Pečata, Obnove i Rezervne ćelije preko ivice panela i svetle pozadine.

## Automatske provere i izvoz

- 1.570 PASS / 0 FAIL i refill benchmark sa 0 neuspeha.
- Import i testovi bez engine/script grešaka/upozorenja. Prvi izvoz je zaustavljen na nepotpunim lokalnim signing promenljivama. Alias je pročitan iz postojećeg ključa, lozinka iz postojećeg Godot podešavanja, bez promene sertifikata. Završni export prolazi bez grešaka/upozorenja; provere igre nisu nepotrebno ponavljane.
- v2/v3 potpis i zipalign prolaze. Paket `com.sinisamedic.warofwords`, code 14, API 24–36, ARM64/x86_64, INTERNET/VIBRATE.
- APK: `exports/WarOfWords-0.1.13-android.apk`, 103.116.885 bajtova.
- SHA256: `38a7ce34b42db540e733338a3f748deccd0262bc192271ed2589e5a697e48b5c`.
- Sertifikat SHA256: `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`, isti kao 0.1.10–0.1.12.

## Android

- API 36 namenski emulator, igra 2400×1080: 0.1.13 instaliran preko stvarne 0.1.12 bez brisanja; ceo `progress.json` identičan odmah posle instalacije.
- Stvarni dodiri otvaraju kampanju i pripremu. Izbor svakog od tri pojačanja potvrđen u sačuvanim podacima. Pregledani Android snimci kampanjske nagrade i istaknutog pojačanja; crni obod je uklonjen.
- `ANDROID 0.1.13 POLISH QA COMPLETE`, bez script grešaka/pada u proverenim tokovima. Originalni progress i backup emulatora vraćeni.
- Prvi pokušaj UI provere imao je crne snimke i nije uspeo; nije računat kao prolaz. Ekran emulatora je probuđen/otključan, a ponovljeni harness čeka stvarno iscrtan kadar, ne samo poruku „ready“. Pri hladnom startu emulator takođe obnavlja stari shader keš, kao u 0.1.12. Završna provera koristi isti APK, bez naknadne promene koda.
- Fizički Samsung i duža igra ostaju korisnička proba. Balans, mreža i rečnici nisu menjani ovim paketom.

Lokalni logovi: `.local/build-0.1.13.log`, `.local/export-0.1.13.log`, `.local/verify-apk-0.1.13.log`, `.local/render-0.1.13.log`, `.local/android-0.1.13-upgrade.log`, `.local/android-0.1.13-ui.log`, `.local/android-0.1.13-runtime.log`. Renderi: `.local/campaign-polish-1280x576/`; Android snimci: `.local/android-0.1.13-*.png`.
