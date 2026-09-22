# Priprema izdanja 0.1.25 / code 26

Datum: 2026-09-22. Grana: `codex/age-aware-play`.

## Implementirano

- Igra i server koriste prošireni filter od 13.730 reči u šest jezika, uključujući reference na ilegalne droge. Filter nije garancija odsustva svakog žargona; blage psovke i reference na alkohol/duvan/lekove ostaju deklarisane u IARC.
- Podešavanja → Igra i privatnost: javna politika, stranica zahteva za podatke i brisanje sopstvenog online profila uz nepovratnu potvrdu. Šest prevoda, postojeći ornamenti i boje. Lokalni napredak ostaje, a red čekanja za slanje rezultata se prazni. Greška čuva sesiju radi ponovnog pokušaja.
- Server prihvata samo identitet iz verifikovanog bearer tokena i eksplicitnu potvrdu. Ne prihvata ID drugog igrača iz zahteva. `daily` objavljen nakon poređenja živog izvora sa prethodnim HEAD-om i lokalne rezervne kopije.
- APK preset zadržava Google demo oglase; Play preset ima `live_ads` i produkcionu rewarded jedinicu. Oba koriste UMP tok. Uzrasna ograničenja ostaju ista: under13 bez SDK poziva/online toka, 13–17 TFUA/G, odrasli TFUA false/PG.

## Provere

- Pun Godot test tok: exit 0, 4.564 PASS linije, bez SCRIPT ERROR/FAIL. Postojeća upozorenja root certificate store i ObjectDB/resource pri gašenju pojedinih testova ostaju.
- Node filter/replay i test zaštite brisanja prolaze. Namenski Godot test proverava da se prazan profil ne kreira radi brisanja, greška čuva sesiju, uspeh briše lokalni token i under13 ne šalje zahtev.
- Opt-in `tools/test-profile-deletion-live.mjs --live-delete-test` kreirao je samo svoj novi QA profil, Daily pokušaj i Endless rezultat, proverio obaveznu potvrdu, obrisao profil i potvrdio odbijanje starog access/refresh tokena. Nikakav postojeći igrački profil nije učitan niti obrisan. Migrations definišu ON DELETE CASCADE za povezane tabele; zaseban administratorski upit nad obrisanim redovima nije rađen.
- Renderovano 25 ekrana (šest jezika + offline vežba); vizuelno pregledani srpski dijalog brisanja i nemački ekran privatnosti.
- APK: 24 provere spakovanih rečnika, apksigner i 16 KiB zipalign uspešni. AAB: bundletool validate uspešan; manifest paket `com.gottaplay.warofwords`, min24/target36, code26/version0.1.25. Exporti exit0.
- **Native UMP/oglasi nisu provereni na telefonu:** ADB nema povezan uređaj. Produkcioni AAB je kandidat, nije odobren za rollout.

| Artefakt | Bajtova | SHA256 |
| --- | ---: | --- |
| `exports/WarOfWords-0.1.25-android.apk` | 267815017 | `3f5162f7aa5e503db83880916370710d0c4911cd36e0a8f83fb41701a42c2cf1` |
| `exports/WarOfWords-0.1.25-play.aab` | 152395775 | `6f3f1ba09b66c20083115aeab1ee5807e3e2f52641870c374b924f614c046226` |

## Play i sajt

- IARC **Completed**: PEGI7, ESRB Everyone10+, USK12, AustralijaPG, Brazil10+, Koreja15+, Tajvan15, Saudijska Arabija12, generic7+. Više regionalne ocene se ne menjaju netačnim odgovorima radi ciljane publike9+.
- Advertising ID sačuvan: Yes; advertising/analytics/fraud prevention prema SDK dokumentaciji.
- Target audience pripremljen9–12/13–15/16–17/18+. Posebna izjava COPPA/GDPR čeka Android proveru; korisnik je izričito odobrio **nakon provere na telefonu**, ne unapred bez provere.
- Data safety popunjen i sačuvan kao nacrt: Name/User IDs collected za funkcionalnost/profil; approximate location, app interactions, diagnostics, device/other IDs collected/shared za AdMob. Podaci nisu ephemeral, zbirka je opciona kroz offline igru/izbor online funkcija i oglasa. TLS yes, anonymous guest other account method, oba deletion URL-a `https://gottaplay.net/wow/delete-data/`. Konačno Save zavisi od Target audience.
- Play URL validator je vratio403 za deletion stranicu dok normalan browser prikazuje stranicu. Potrebna ponovna provera i eventualna podrška hostinga; uzrok nije potvrđen.
- Susedni `../WoW Website` generator i četiri stranice ažurirani lokalno. Site check:5stranica/97referenci. ZIP za upload u koren hostinga: `exports/WoW-policy-update-2026-09-22.zip`, samo `wow/{privacy,support,delete-data,terms}/index.html`. Javna objava nije potvrđena. Website repo nije push-ovan.
- Nema uploadovanog Play paketa, slanja na review niti rollout-a. AdMob povezivanje sa javnim listingom i način isplate zavise od narednih korisničkih/Play koraka.

Izvor za SDK podatke: https://developers.google.com/admob/android/next-gen/privacy/play-data-disclosure . Pokretanje test oglasa ne znači odsustvo obrade podataka.

## Sledeći korak

Povezati Android telefon i odobriti USB debugging, proveriti uzrasne režime i UMP/rewarded tok na APK-u; potvrditi objavu policy ZIP-a i dostupnost URL-a Google-u. Tek potom potvrditi Target audience izjavu i završiti Data safety. Pregledati nalogov uslov testiranja sa korisnikom pre početka track-a/pozivanja testera.
