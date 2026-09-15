# Trenutno stanje

Ažurirano: 2026-09-15. Aktivna grana: `main`.

## Završen rad

- Sačuvani početni zahtevi, istraživanje reference i predlozi dizajna.
- Korisnik je na prvom računaru raspakovao standardni Godot 4.7.2.
- Tehnička Godot MCP proba je ranije prošla: kreiranje, izmena, čuvanje i pokretanje scene, čitanje runtime stabla i pregled slike. Ispravljena lokalna kompatibilnost pri čuvanju scene.
- Postojeći folder povezan sa `sinisamedic/warofwords`; GitHub je prilikom početne provere bio prazan. Fajlovi nisu prepisani drugom kopijom.
- Pripremljeni README, AGENTS, ovaj status, game-design i setup dokumenti; ignorisani lokalni podaci i verzionisani potrebni MCP izvori sa lockfile-om i licencom.
- Unutrašnji Git MCP checkout-a sačuvan lokalno kao metapodaci u `.local/`; projekat ima jedan aktivan Git repozitorijum.

## Šta još nije odlučeno

- Engine: Godot, Unity ili Unreal. **Godot je isproban, nije konačno usvojen.**
- Tačna referenca: verovatno Slugterra: Slug it Out 2.
- Jezik i pismo prvog rečnika.
- Borbeni tempo: blagi realni ili potezni.
- Tema, konačni naziv i konkretan balans.
- Modeli test telefona i pristup Mac-u za iOS.

## Sledeći koraci

1. Na drugom računaru klonirati repo i otvoriti taj folder kao Codex projekat; pročitati AGENTS.md i ovaj status. Pratiti docs/setup.md.
2. Proveriti remote, stanje grane i `git fetch`; ne pretpostaviti sinhronizaciju iz teksta ovog fajla.
3. Sa korisnikom potvrditi engine i jezik prototipa, zatim osnovni tempo borbe. Ne širiti implementaciju pre odgovora.
4. Uporediti 7 fiksnih slova kroz tri reči naspram zamene posle svake reči kao dizajnerske hipoteze; prioritet su čitljivost i kontinuitet razmišljanja.
5. Tek po dogovoru napraviti najmanji igrivi susret iz docs/game-design.md.

## Provere i ograničenja

- Godot MCP je praktično testiran ranije na prvom računaru; u trenutnoj listi alata još nema callable Godot MCP alata. Lokalna registracija `godot-local` postoji, ali mora biti učitana/proverena u novoj sesiji.
- Godot proba nije testirana na Android/iOS. SDK i export templates nisu potvrđeni.
- Igra i rečnik još nisu implementirani. Nema finalne grafike ni velikih binarnih materijala; LFS nije aktiviran.
- Rutinske provere organizacije: sintaksa Node skripte, build MCP servera, provera linkova/diff-a i pregled sadržaja za commit. Tačan rezultat slanja i SHA proveravati kroz Git; ne smatrati ovaj status potvrdom uspešnog push-a.

## Lokalno, ne prenosi se GitHub-om

Instalacije alata, `.local/` (mašinska podešavanja, logovi, snimak probe i arhiva), `node_modules`, generisani MCP build i Godot keš. Njihov izostanak je nameran; za obnovu potrebnih delova koristiti docs/setup.md. Lokalna arhiva nije zamena za backup računara.
