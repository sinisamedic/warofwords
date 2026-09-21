# AdMob i nastavci u Beskraju

## Uzrast — 2026-09-21

Mlađi od 13 i nepoznat uzrast: bez oglasa, SDK inicijalizacije kroz rewarded tok i bez nastavka nakon poraza. Nema besplatnih nastavaka. Za 13+ ostaju tri SDK-potvrđena nastavka; mrežne deklaracije i produkcija tek slede. Centralna zabrana u rewarded servisu i završnom callback-u radi i kad UI pozove funkciju direktno.

Za 13–17 konzervativno se šalje under-age-of-consent i u UMP i u RequestConfiguration, uz maksimalni sadržaj G; 18+ koristi false tag, maksimalni sadržaj PG (G i PG oglasi) i postojeći produkcioni UMP tok. PG je plafon za Families mixed-audience aplikaciju, ne MA: https://support.google.com/admob/answer/10477886 . Postavke se primenjuju pre MobileAds.initialize. Koristi se API pinovanog Poing dodatka; novija Google dokumentacija označava TFUA/TFCD kao deprecated, ali dokumentuje njihovo mapiranje. Nativno ponašanje AAR-a se mora proveriti u narednom Android build-u. Desktop test nije potvrda Play/Families usklađenosti, dostupnosti oglasa ni native prenosa tagova.

Korisnik je 2026-09-20 odobrio najviše **tri nagrađena nastavka po partiji**. Svaki vraća 100 HP; protivnik, tabla, oprema, reči, vreme i ukupni bodovi ostaju. Revive ne donosi healing bodove. Povratak iz oglasa otvara pauzu, tako da protivnik ne može napasti pre nego što igrač nastavi.

Poraz pre potrošenog limita čuva `continue_pending` u snimku partije. Ni nacrt za rang-listu ni mrežni upis tada ne postoje. Igrač može pogledati oglas ili završiti pohod. Konačan nacrt nastaje tek pri odustajanju ili četvrtom porazu, jednom; dugme POŠALJI ostaje jedini način slanja. Zatvaranje aplikacije u odluci vraća istu odluku, a sačuvani broj nastavaka ne može se resetovati nastavkom partije.

## Razvojna konfiguracija

- App ID: `ca-app-pub-5562106147014166~4923218215`.
- Rewarded jedinica Endless Continue: `ca-app-pub-5562106147014166/2184629377`.
- `game/scripts/rewarded_continue.gd`: `TEST_ADS = true`, Google testna rewarded jedinica `ca-app-pub-3940256099942544/5224354917`. Stvarna jedinica je zabeležena, ali se ne šalju zahtevi za plaćene oglase.
- SDK se pokreće na Androidu tek pri eksplicitnom izboru oglasa. Desktop nema automatsku simulaciju nagrade. Testovi koriste izdvojen fake provider koji se nikada ne bira u normalnoj igri.
- Nagrada se prihvata samo iz SDK reward callback-a za aktivni zahtev i primenjuje tek nakon zatvaranja oglasa. Greška, timeout učitavanja, preskakanje, dvostruki klik i stari callback ne troše nastavak. Nema tajmera koji glumi nagradu.
- Produkcioni tok pre inicijalizacije oglasa ažurira UMP saglasnost, prikazuje potreban obrazac i dozvoljava zahteve samo pri statusu NOT_REQUIRED ili OBTAINED. U podešavanjima se pojavljuje AD PRIVACY kada UMP zahteva ulaz za promenu izbora. Razvojni Google test oglasi ne čekaju konfiguraciju produkcionog UMP obrasca.

## Android zavisnosti i poreklo

Poing Studios Godot AdMob **5.1.0**, MIT, upstream commit `615974e9f66921a54e3c71c33db0856bdbf19d13` iz https://github.com/poingstudios/godot-admob-plugin/releases/tag/v5.1.0. Kopija izvora u `game/addons/admob/`, licenca u istom folderu. Android arhiva `android-template-v4.7.2.zip`, samo `ads` modul; bez mediation mreža. AAR biblioteke su ispod 150 KiB, nijedan novi binarni fajl nije iznad 10 MiB. Maven zavisnosti deklarisane su u `android/bin/ads/poing_godot_admob_ads.gd` (Google next-gen Mobile Ads SDK 1.4.0). Izmene kopije: isključeno automatsko preuzimanje platformskih biblioteka pri otvaranju editora i omogućeno verzionisanje Android binarnih biblioteka. Originalni SDK se preuzima iz Maven repozitorijuma tokom Gradle build-a.

Gradle Android export je sada potreban. Zvanični Godot 4.7.2 `android_source.zip` iz export templates raspakuje se u ignorisani `game/android/build/`; ne verzionisati ovaj generisani build niti Gradle keš. Lokalna provera i potpisivanje ostaju u `tools/build-android.ps1`.

## Pre produkcionih oglasa

Provereni SHA256 preuzetih izdanja: `poing-godot-admob-v5.1.0.zip` = `8c53ff52719edf6a81cc7d32a9cdaad2d9e11693c85faca25008a1c19355726f`; `android-template-v4.7.2.zip` = `f7fdf644d50c0e231d8f02ae044057e489d0bcafcf50e908a4858477e7ee05ee`. Originalni vendor whitespace je očuvan; Godot generiše dodatne `.uid`/import metapodatke. Android pakovanje potvrđuje SDK i UMP registracije; veći lokalni APK sadrži nekompresovane ARM64/x86_64 engine biblioteke radi direktnog učitavanja.

Ostaviti TEST_ADS uključen dok nisu završeni: Play/AdMob verifikacija i pregled, produkciona UMP poruka u AdMob Privacy & messaging, ciljane starosne grupe i odgovarajući SDK tagovi, javne potvrđene privacy/support adrese, usklađena web politika i Play Data safety. Ne uključivati plaćene oglase u razvojnom testiranju.

Server-side verification nije aktiviran; klijentski callback daje nagradu. Beskraj već ima beta rang-listu sa klijentskim bodovima. Za javno takmičenje ostaju server validacija nagrade/borbe i jasno pravilo rangiranja partija sa nastavcima. Ova promena ne menja Supabase niti objavljuje probne rezultate.

## Provere

`game/tests/test_rewarded_continue.gd` proverava tri nastavka, četvrti poraz, jedno konačno slanje u lokalni outbox, očuvanje skora/protivnika/kampanje, restart, odbijenu nagradu, dvostruke i zakasnele callback-ove i timeout. `render_rewarded_continue.gd` pravi slike u šest jezika bez mrežnih upisa i bez stvarnih oglasa.

Izvori: https://developers.google.com/admob/android/next-gen/rewarded i https://developers.google.com/admob/android/next-gen/privacy.
