# Trenutno stanje

Ažurirano: 2026-09-16. Aktivna grana: `codex/screen-mockups`.

## Aktuelno: šest statičnih vizuelnih dizajna

- Poslednji zahtev korisnika: samo dizajn šest osnovnih ekrana, bez simulacije i bez izrade igre. Godot je sada naveden kao ciljni engine za kasniju izradu.
- Otvoriti **design/index.html** za statičnu galeriju ili pojedinačne PNG slike iz `design/screens/`. Galerija ne sadrži JavaScript.
- Šest ekrana: glavni meni, kampanja, arsenal, power-upovi, unapređenja i borba. Svi su 1774 × 887, landscape 2:1, vizuelno usklađeni, engleski.
- Šest novih ImageGen izlaza; postojeća arena korišćena kao referenca, zatim novi borbeni ekran kao stilska referenca za ostale. Svi rezultati su vizuelno pregledani direktno kao slike. Poreklo i tačni promptovi: `design/PROVENANCE.md`, `design/prompts.json`.
- Specifikacija: `design/DESIGN-SPEC.md` — hijerarhija, tokeni, mobilne dimenzije, stanja, prelazi i odvajanje slojeva za budući Godot UI. Nisu napravljene Godot scene, kod igre ili nova simulacija.
- PNG slike su spljošteni vizuelni masteri, ne slojeviti UI kit. Asset-i, tekst/fontovi i animacije pripremaju se odvojeno tek posle usvajanja.
- Provere: šest validnih PNG-ova istih dimenzija; ključni natpisi, broj polja i putanja STONE vizuelno pregledani; u unapređenju 480−180=300. Svaki fajl ispod 10 MiB, zbir oko 17 MiB. Nema novih paketa ili LFS obrazaca. Statični lokalni linkovi provereni.
- Nema fizičkog testa telefona/hitbox-ova. Brojevi, izgled sveta, imena i 28 polja i dalje su predlog.
- V2 i V3 fajlovi ostaju neizmenjeni. V3 je prethodna simulacija, ne aktuelni dizajn koji korisnik sada traži.

**Sledeći korak:** korisnik pregleda šest slika i potvrđuje/koriguje vizuelni smer. Ne nastavljati automatski izradu igre. Posle usvajanja izdvojiti produkcione komponente i pripremiti Godot UI prema specifikaciji, uz novu autorizaciju za implementaciju.

## Prethodno: V3 mobilni mockup

- Otvoriti **V3 mokup/index.html** lokalno u browseru, telefon vodoravno. Uputstvo i granice: `V3 mokup/README.md`. Istraživanje Slugterre: `V3 mokup/RESEARCH.md`.
- Šest glavnih ekrana: meni, kampanja, arsenal, power-upovi, unapređenja, borba. Dodatno: pomoć, pauza, pobeda, poraz.
- Potvrđeno od korisnika: susedna slova + dijagonale, dopuna korišćenih polja, oružja/sposobnosti umesto bića, tipovi/boje slova pune odgovarajuće sposobnosti. Landscape, engleski, računar i odrasla publika ostaju usvojeni.
- V3 predlaže 28 polja (7 × 4), krupne komande bez desktop atlasa, četiri sposobnosti, tri power-upa i bonus za 6+ slova. Brojevi, tema i tempo nisu konačno usvojeni.
- Interaktivni demo: prevlačenje ili tap + ✓, punjenje po tipu, dopuna polja, aktiviranje sposobnosti, CPU napadi, pauza, nagrada i unapređenja tokom sesije.
- `mockups/` (V2) je sačuvan bez izmena. V3 koristi istu originalnu arenu; nema novih generisanih slika, paketa ili velikih binarnih fajlova.

## Provere / važno ograničenje

- Ispravljen prazan plavi ekran: JavaScript je izolovan od browser globalnih naziva, a funkcija `top` preimenovana u `screenHeader`. Verzija script URL-a promenjena je na 3.1 radi ponovnog učitavanja.
- `node --check` i `node "V3 mokup/tests/startup.cjs"` prošli. Novi test izvršava ceo entry script u DOM zameni i proverava generisanje svih šest ekrana i da globalni browser nazivi ostaju netaknuti. To nije pravi browser test.
- Izolovane provere stvarnih JS funkcija prošle: broj polja, susedstvo i dijagonale, povratak i zabrana ponavljanja polja, punjenje po tipu, bonus, dopuna samo korišćenih polja, šteta, štit, lečenje, CPU, pauza, power-up jednom i nagrada jednom.
- To nisu end-to-end testovi. Browser alat je odbio lokalni file URL zbog svoje politike pristupa. **V3 nije vizuelno potvrđen u browseru niti na fizičkom telefonu.** Ne prepisivati stare V2 vizuelne provere kao provere V3.
- Lokalni proverni skript: `.local/v3-review/logic.cjs` (ignorisano).
- Demo lista nije produkcioni rečnik, dopuna nije kvalitetan generator. Nema trajnog napredovanja, naloga, zvuka ili prave kampanje. Promene se resetuju pri ponovnom učitavanju.

## Raniji V3 korak (zamenjen statičnim dizajnom iznad)

Na landscape telefonu otvoriti V3. Probati Play → Prepare → Battle, reč STONE ili STONES u prvom redu i PLANE u trećem. Aktivirati napunjen štit, zatim druge sposobnosti. Pregledati Power-ups i Workshop. Potvrditi mobilnu kompoziciju i tek zatim menjati grafiku ili širiti implementaciju. Smer punjenja po bojama i pravilo susedstva ne pitati ponovo.

Tempo, bonus i broj polja ostaju predlozi. Poslednji korisnički zahtev navodi Godot za kasniju izradu; trenutno se radi samo dizajn.

## Nastavak na drugom računaru

Pročitati AGENTS.md, sačuvati eventualne lokalne izmene, proveriti remote i Git stanje, pa:

```powershell
git fetch origin --prune
git switch codex/screen-mockups
git pull --ff-only
```

Ako grana nije lokalna: `git switch --track origin/codex/screen-mockups`. Uputstvo za alate: `docs/setup.md`. GitHub prenosi izvor, ne instalacije alata.

Ovaj status opisuje sadržaj pripremljen za commit. Stvarni ishod push-a i handoff SHA proveriti kroz Git i završnu poruku; ova rečenica ne potvrđuje slanje.

## Raniji rad i lokalno okruženje

- V2 commit 493600d: 86 landscape prikaza, čuva se u `mockups/` kao prethodni predlog. V1 portrait istorija: 40c1588.
- Godot 4.7.2 i MCP proba ranije su radili na prvom računaru. To nije produkciona igra ni potvrda Android/iOS izvoza. Aktivnu MCP vezu i stvarni engine log ponovo proveriti pre korišćenja.
- Lokalni alati, `.local/`, node_modules, Godot keš i instalacije ne prenose se GitHub-om. Izvori MCP servera i licenca ostaju u `tools/`.
- Godot je ciljni engine za buduću izradu. Licencirani engleski rečnik, tema, balans i monetizacija ostaju otvoreni. Aktivne odluke su u `docs/game-design.md`.
