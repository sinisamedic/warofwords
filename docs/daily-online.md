# Dnevni izazov i globalna rang-lista

Radna grana: `codex/daily-global-leaderboard`. Ovo je novi režim; objavljeni APK 0.1.6 ostaje offline.

## Stanje provere 2026-09-17

Servis je objavljen na korisnikovom potvrđenom projektu `phfbohgbeqjvtfsgcjwi`, Free / Frankfurt. Stvarni test preko Node HTTPS klijenta završen je u 17:32:35 UTC: EN 70 i SR 30 bodova na odvojenim listama, potvrđeni idempotentni Start/Submit, odbijen zahtev bez sesije i direktno čitanje tabela. Gateway JWT kontrola ostala je uključena. Testni profil „QA provera” je jasno označen; rezultati su stvarno izračunati na serveru.

Godot UI i offline pravila prolaze 1106 provera uz svih 306 postojećih regresija. Direktan Godot mrežni test nije prošao na ovom računaru: Avast HTTPS scanning izdaje lokalni sertifikat koji Windows/Node prihvataju, a Godot/mbedTLS odbija. Proba sa postojećim pouzdanim CA sertifikatima nije rešila parsiranje; nije uveden TLS bypass niti promenjen antivirus. Potrebna je zasebna provera na Androidu. Android SDK/JDK/templates i stari potpisni ključ nisu pronađeni na standardnim putanjama; novi APK nije napravljen.

## Pravila prve implementacije

- Dva minuta; nova kategorija svakog dana u 00:00 UTC. Četiri odvojene liste: en/sr × susedna/slobodna slova.
- Jedan rangirani pokušaj dnevno **po anonimnom profilu i kategoriji**. Nadimak 3–20 slova/brojeva/razmaka/`_`/`-`. Nadimci nisu jedinstveni.
- Svi u kategoriji imaju isti početni raspored. Zaseban ponovljiv generator `daily-v1` koristi istu logiku u Godotu i na serveru. Izbor različitih reči vodi ka različitim dopunama; dopunjuju se samo iskorišćena polja. Poznate neiskorišćene reči se umeću duž potrošene putanje kada ima mesta; nema garancije beskonačno rešive table.
- Poeni: `10 × broj pločica + 5 × max(0, broj pločica − 4)`. Minimum tri pločice; LJ/NJ/DŽ su po jedna. Reč može samo jednom. Najviše 240 poteza, razmak bar 250 ms. Precizan balans je početni implementacioni izbor za probu.
- Nema kampanjskih unapređenja, moći, power-upova ni nagoveštaja. Ovo je vremenski izazov reči, ne borba protiv CPU-a.
- Vežba radi offline na zasebnoj tabli, ne troši rangirani pokušaj i nikad se ne prikazuje kao globalni rezultat.
- Rangirano vreme određuje server. Prelazak u pozadinu ili odlazak sa ekrana ne pauzira rok. Slanje je dozvoljeno tek posle 120 s, uz još 30 s za transport/ponavljanje slanja.
- Napredak pokušaja čuva se posle validne reči. Ponovni Start iste kategorije vraća isti pokušaj i preostalo vreme; ponovljeno slanje ne menja već potvrđeni rezultat.
- Lista prikazuje prvih 20 i, kada postoji, igrača sa po dva suseda oko njegovog mesta. Jednaki bodovi dele rang. Kroz rezultate se lista po šest redova.

## Arhitektura

Telefon → HTTPS Edge Function `daily` → privatne PostgreSQL tabele.

Telefon šalje putanje pločica i relativna vremena, a server ponavlja partiju, proverava rečnik, putanje, ponavljanje, dopunu i sam računa bodove. Poslati broj bodova se ne koristi. Baza ima RLS i nema direktnih prava za `anon`/`authenticated`. RPC funkcije sme pozivati samo serverska uloga. Gateway JWT provera ostaje **uključena**, a svaki HTTP zahtev dodatno proverava korisnički bearer token preko Supabase Auth `/user`. Ova kombinacija radi sa aktuelnim podešavanjem potpisivanja ciljnog projekta.

Anonimni profil živi u `user://daily-session.json`. Reinstalacija/brisanje podataka može napraviti drugi profil; to nije zaštita „jedna osoba = jedan pokušaj”. Čuvanje na više uređaja i povezivanje sa trajnim nalogom nisu deo ovog koraka. Automatsko rešavanje reči i falsifikovanje relativnih vremena unutar dozvoljenog serverskog prozora nisu potpuno sprečeni. Pre javnog turnira dodati jaču kontrolu zloupotrebe, limite zahteva, moderaciju nadimaka i eventualno verifikaciju poteza uživo.

## Postavljanje na besplatan Supabase projekat

1. Pokrenuti SQL iz `supabase/migrations/202609170001_daily.sql` u SQL Editor-u novog projekta. Kreira samo tabele/funkcije ovog režima i privatni bucket `daily-dictionaries`. Migracija je jednokratna; ne pokretati je ponovo preko postojeće šeme bez pregleda.
2. U Authentication → Sign In / Providers uključiti **Anonymous sign-ins**. Za javno izdanje proceniti CAPTCHA/ograničenja registracije; razvojni klijent još nema CAPTCHA tok.
3. `node tools/prepare-daily-dictionaries.mjs` priprema dva gzip fajla i manifest u `.local/daily-dictionaries/`. Upload oba `*-daily-v1.txt.gz` fajla u privatni bucket. Rečnici potiču iz istih licenciranih izvora kao igra; licence su u `game/licenses/`.
4. U Edge Function secrets upisati `DAILY_DICTIONARY_EN_SHA256` i `DAILY_DICTIONARY_SR_SHA256` iz generisanog manifesta. To su kontrolni hash-evi, ne pristupni ključevi. Standardne Supabase serverske promenljive već daje runtime; nikad ih ne stavljati u igru.
5. Deploy funkcije `daily` iz `supabase/functions/daily/`. CLI: `supabase functions deploy daily --project-ref PROJECT_REF`. Za editor u dashboardu: `node tools/bundle-daily-function.mjs` priprema jedan fajl `.local/supabase-daily.ts`. Ostaviti gateway opciju legacy JWT provere uključenu. Ako se kasnije menja algoritam potpisivanja tokena, posebno proveriti kompatibilnost pre promene bezbednosnih podešavanja.
6. Kopirati `game/online_config.example.json` u ignorisani `game/online_config.json`, uneti **Project URL i publishable key**. Nikada secret/service_role ključ. Export eksplicitno uključuje ovaj javni konfiguracioni fajl i INTERNET dozvolu. Na drugom računaru konfiguraciju pripremiti zasebno.
7. Uraditi end-to-end test stvarnog početka, isteka 120 s, slanja, serverom izračunatog rezultata, ponovljenog slanja i čitanja globalne liste. Lokalni/mokovani testovi sami ne dokazuju da je servis objavljen.

## Ponovljive provere

U izolovanom APPDATA folderu unutar `.local/`, uz lokalnu Godot putanju:

```powershell
$env:APPDATA = Join-Path (Get-Location) '.local/daily-test-appdata'
& $env:GODOT_EXECUTABLE --headless --path game --script res://tests/test_daily.gd
node tools/prepare-daily-dictionaries.mjs
node tools/test-daily.mjs
node tools/test-daily-service.mjs
```

`test_daily.gd` generiše test-vektore za proveru identičnog server/Godot ponašanja. `test-daily-service.mjs` pokreće stvarni Edge handler uz simulirane granice Auth/Storage/baze; Node 24 podržava TypeScript uklanjanjem tipova. SQL test koristi PGlite 0.5.8:

```powershell
npm.cmd install --prefix .local/daily-tools --ignore-scripts --no-audit --no-fund @electric-sql/pglite@0.5.8
node tools/test-daily-database.mjs
```

PGlite koristi novu memorijsku bazu i minimalne zamene za Supabase `auth`/`storage` šemu; to nije test celog udaljenog Supabase okruženja. Postojeće regresije su `game/tests/test_game.gd`. Vizuelni render: `game/tests/render_daily.gd`, izlaz `.local/daily-qa/`.

Stvarni udaljeni test, koji kreira anonimni QA profil i rezultat (ne pokretati kao običan unit test): `node --use-system-ca tools/test-daily-live.mjs --live-daily`. Dodatak `--fresh-profile` koristi zaseban novi testni profil kada je prethodni pokušaj istekao tokom prekida procesa. `tools/capture-daily-leaderboard.mjs` čita stvarnu listu za naknadni vizuelni render; taj snimak ne predstavlja direktnu Godot mrežnu sesiju. Godot varijanta je `game/tests/test_daily_live.gd -- --live-daily` i zahteva kompatibilnu HTTPS vezu.

Zvanična dokumentacija: [anonimna prijava](https://supabase.com/docs/guides/auth/auth-anonymous), [ključevi](https://supabase.com/docs/guides/api/api-keys), [Edge autentikacija](https://supabase.com/docs/guides/functions/auth), [serverske promenljive](https://supabase.com/docs/guides/functions/secrets).
