# 0.1.26 / code27 — skrol rezultata

2026-09-22, grana `codex/age-aware-play`.

## Završni Play status

Interni kanal `0.1.26 internal` objavljen 2026-09-22: Active / Available to internal testers, code27. Uključena samo lista `War of Words — internal` sa jednim odobrenim nalogom. Link: https://play.google.com/apps/internaltest/4701514081638778706 . Korisnička instalacija preko Play-a tek sledi; lokalni APK već proveren na telefonu. Ne brisati lokalne podatke radi eventualnog konflikta potpisa bez prethodnog dogovora.

Sveža Google validacija oba kanonska privacy/deletion URL-a prolazi nakon korisnikovih Cloudflare pravila. Quick checks završeni uspešno. Produkcija nije poslata na review niti javno objavljena; Managed publishing OFF. Ranija čekanja ispod predstavljaju istoriju.

## Implementacija i prethodne provere

- Redovi liste propuštaju GUI događaje; ekran obrađuje touch drag uz zadržan press/release tok za emulaciju miša. Wheel ostaje ugrađeni Godot scroll. Separator od20px odvaja top10 od konteksta tekuće partije; automatski skrol uračunava separator. SQL već vraća top10 + dva prethodna reda + tekuću poslatu partiju bez dupliranja, bez promene servera.
- `test_rankings.gd` proverava stvarne InputEventScreenTouch/ScreenDrag događaje u oba smera, wheel, visinu/separator, uređivanje nadimka i eksplicitno slanje/retry. Headless i desktop exit0, šest PASS grupa, bez script grešaka. Pregledani renderi vrha i sopstvenog reda1280×576. Headless ima postojeća root-certificate/ObjectDB upozorenja; desktop samo root-certificate upozorenje.
- Oba exporta exit0; APK isti sertifikat429a2d1b…0abc, apksigner i16KiB zipalign prolaze;24 provere spakovanih rečnika prolaze. bundletool1.18.3 validate exit0, versionCode27. APK koristi demo oglase, Play preset produkcione kao0.1.25.

| Fajl | Bajtova | SHA256 |
| --- | ---: | --- |
| `exports/WarOfWords-0.1.26-android.apk` | 267816049 | `4f2d589e0c67b7e00304d0e5e5adf8d11ae55839c838b4317d1b6d9347e53735` |
| `exports/WarOfWords-0.1.26-play.aab` | 152396830 | `c7c6adb767d9c0040e6d57dceb47c36413da55f718c4adffc35d6fd831dbe040` |

APK0.1.26/code27 instaliran na Samsung S23 Ultra bez brisanja podataka; korisnik potvrdio da score ekran dobro radi. AAB0.1.26/code27 prihvaćen i sačuvan u Publishing overview; stari paket uklonjen iz nacrta. Svih177 zemalja/regiona sačuvano po izričitoj odluci korisnika. Nema blokirajućih grešaka izdanja; mapping/native-symbol upozorenja ostaju. Quick checks još traju. Nije poslato na review niti objavljeno; Managed publishing OFF znači da bi odobrene promene mogle automatski da se objave posle slanja.

Naknadna provera0.1.25: korisnik potvrdio rewarded testni oglas i nastavak na Samsung S23 Ultra, save continues=1 i Android log bez script/fatal grešaka. Native UMP je pozvan; GDPR-not-required, zato EU dijalog nije testiran. Target audience i Data safety sačuvani nakon te provere. Nova privacy/deletion stranica javno dostupna. Play validator403 ostaje otvoren; GET/HEAD/Googlebot-UA GET sa lokalnog računara svi200, Cloudflare zaglavlja. To ne simulira Google IP niti identifikuje tačan Play User-Agent.
