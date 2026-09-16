# Trenutno stanje

Ažurirano: 2026-09-16. Aktivna grana: `codex/screen-mockups`.

## Aktuelna revizija 02 — landscape i engleski

- Korisnik je potvrdio **landscape**, mnogo kružnih slova ispod arene, **engleski za prvu verziju** i **računarskog protivnika**. Traži vedriji izgled i publiku koja uključuje odrasle; širi vokabular treba da pomaže pobedi. Odluke su u `docs/game-design.md`.
- Preuređen atlas: **86 landscape ekrana/stanja**, osam tokova. `mockups/index.html` se otvara direktno u browseru bez servera/instalacije. Uputstvo: `mockups/README.md`; dizajn: `docs/screen-design.md`.
- Novi vizuelni **predlog**: svetle Sunward Ruins, odrasla istraživačica, mehanički Sentinel i tri modula umesto malih simpatičnih bića. Konkretna tema, imena, protagonistkinja i balans nisu usvojeni.
- Probna mreža **7 × 5 / 35 slova**, sa više mogućih reči. Slobodno povezivanje bilo kojih krugova, pet reči po tabli i pravila zamene su hipoteze. Demo lista ima **600 engleskih zapisa**, od kojih 584 mogu da se sastave prema broju slova na svakoj od dve demonstracione table. To nije produkcioni rečnik niti generator.
- **Start computer demo** pokreće jednostavan CPU koji najavljuje i izvodi udare. Reči pune energiju, Strike/Guard/Disrupt rade; pauza čuva stanje. Katalog je početno zamrznut radi pregleda. Nema trajnog napredovanja, cloud-a, telemetrije ili slanja prijava.
- Provere: svih 86 ekrana na širinama 1440/1024/844/390 px u Edge-u, bez JS grešaka, nepoznatih ciljnih ekrana, horizontalnog prelivanja i ispadanja kontrola iz okvira. Testirani STONE klik/drag, STREAMLINE, ponovljene reči, mešanje, peta reč i nova tabla, poništavanje, tastatura, energija, CPU napad, štit, prekid, trening i pauza. Vizuelno pregledani borba, baza, briefing, kolekcija, atlas, putanja reči i landscape focus. **Nije test na fizičkom telefonu.**
- `mockups/assets/sunward-arena.png` je originalna slika generisana ugrađenim ImageGen alatom (~2.64 MiB). Tačan prompt i poreklo: `mockups/assets/README.md`. `mockups/preview.png` je snimak našeg UI-ja. Nema fajlova preko 10 MiB, novih paketa ili potrebe za LFS-om.
- Prvi portrait predlog je u Git istoriji, commit `40c1588`; ne koristiti njegova pravila sedam slova/srpski/portrait kao aktuelne odluke.
- Rad je pripremljen za običan push ove grane. Stvarni ishod i handoff SHA proveriti kroz Git / završnu poruku, ne zaključivati iz ove rečenice da je push uspeo.

**Na drugom računaru**, posle provere i čuvanja eventualnih lokalnih izmena prema AGENTS.md:

```powershell
git fetch origin --prune
git switch codex/screen-mockups
git pull --ff-only
```

Ako grana još ne postoji lokalno, `git switch --track origin/codex/screen-mockups`. Ako repo tek kloniraš, koristi postojeća uputstva iz `docs/setup.md`, pa prebaci na ovu granu.

**Tačan sledeći korak:** otvoriti `mockups/index.html#battle`, uključiti „Start computer demo“ i probati STONE, BRIDGE, STREAM i STREAMLINE. Pregledati „Focus view“ na vodoravnom telefonu, pa potvrditi broj slova, susedstvo/slobodno povezivanje i način zamene/dopune. Zatim potvrditi tempo CPU-a i engine. Engleski i landscape se više ne tretiraju kao otvorene odluke. Ne implementirati svih 86 prikaza odjednom.

## Završen rad

- Sačuvani početni zahtevi, istraživanje reference i predlozi dizajna.
- Korisnik je na prvom računaru raspakovao standardni Godot 4.7.2.
- Tehnička Godot MCP proba je ranije prošla: kreiranje, izmena, čuvanje i pokretanje scene, čitanje runtime stabla i pregled slike. Ispravljena lokalna kompatibilnost pri čuvanju scene.
- Postojeći folder povezan sa `sinisamedic/warofwords`; GitHub je prilikom početne provere bio prazan. Fajlovi nisu prepisani drugom kopijom.
- Pripremljeni README, AGENTS, ovaj status, game-design i setup dokumenti; ignorisani lokalni podaci i verzionisani potrebni MCP izvori sa lockfile-om i licencom.
- Unutrašnji Git MCP checkout-a sačuvan lokalno kao metapodaci u `.local/`; projekat ima jedan aktivan Git repozitorijum.

## Šta još nije odlučeno

- Engine: Godot, Unity ili Unreal. **Godot je isproban, nije konačno usvojen.**
- Korisnikov screenshot je konkretna referenca kompozicije borbe. Tačno izdanje reference nije prepreka ovom dizajnu.
- Izvor/verzija/licenca produkcionog **engleskog** rečnika i US/UK varijante; jezik prve verzije je potvrđen.
- Broj slova, pravilo susedstva i zamena/dopuna nakon reči.
- Borbeni tempo: blagi realni ili potezni.
- Tema, konačni naziv i konkretan balans.
- Modeli test telefona i pristup Mac-u za iOS.

## Sledeći koraci

1. Na drugom računaru otvoriti repo, proveriti sinhronizaciju i nastaviti granu `codex/screen-mockups` prema odeljku iznad. Pročitati AGENTS.md i ovaj status.
2. Proveriti remote, stanje grane i `git fetch`; ne pretpostaviti sinhronizaciju iz teksta ovog fajla.
3. Sa korisnikom potvrditi novi raspored, pravila table, engine i osnovni tempo borbe. Ne širiti implementaciju pre odgovora.
4. Proveriti 35 slova i pet reči po tabli naspram dopune korišćenih slova; prioritet su čitljivost, dodir i zanimljiv izbor reči za širu publiku.
5. Tek po dogovoru napraviti najmanji igrivi susret iz docs/game-design.md.

## Provere i ograničenja

- Godot MCP je praktično testiran ranije na prvom računaru; u trenutnoj listi alata još nema callable Godot MCP alata. Lokalna registracija `godot-local` postoji, ali mora biti učitana/proverena u novoj sesiji.
- Godot proba nije testirana na Android/iOS. SDK i export templates nisu potvrđeni.
- Produkciona igra i kompletan engleski rečnik nisu implementirani. Postoji HTML simulacija i koncept grafika; LFS nije aktiviran.
- Rutinske provere organizacije: sintaksa Node skripte, build MCP servera, provera linkova/diff-a i pregled sadržaja za commit. Tačan rezultat slanja i SHA proveravati kroz Git; ne smatrati ovaj status potvrdom uspešnog push-a.

## Lokalno, ne prenosi se GitHub-om

Instalacije alata, `.local/` (mašinska podešavanja, logovi, snimak probe i arhiva), `node_modules`, generisani MCP build i Godot keš. Njihov izostanak je nameran; za obnovu potrebnih delova koristiti docs/setup.md. Lokalna arhiva nije zamena za backup računara.
