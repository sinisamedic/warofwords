# Trenutno stanje

Ažurirano: 2026-09-16. Aktivna grana: `codex/screen-mockups`.

## Aktuelno: V3 mobilni mockup

- Otvoriti **V3 mokup/index.html** lokalno u browseru, telefon vodoravno. Uputstvo i granice: `V3 mokup/README.md`. Istraživanje Slugterre: `V3 mokup/RESEARCH.md`.
- Šest glavnih ekrana: meni, kampanja, arsenal, power-upovi, unapređenja, borba. Dodatno: pomoć, pauza, pobeda, poraz.
- Potvrđeno od korisnika: susedna slova + dijagonale, dopuna korišćenih polja, oružja/sposobnosti umesto bića, tipovi/boje slova pune odgovarajuće sposobnosti. Landscape, engleski, računar i odrasla publika ostaju usvojeni.
- V3 predlaže 28 polja (7 × 4), krupne komande bez desktop atlasa, četiri sposobnosti, tri power-upa i bonus za 6+ slova. Brojevi, tema i tempo nisu konačno usvojeni.
- Interaktivni demo: prevlačenje ili tap + ✓, punjenje po tipu, dopuna polja, aktiviranje sposobnosti, CPU napadi, pauza, nagrada i unapređenja tokom sesije.
- `mockups/` (V2) je sačuvan bez izmena. V3 koristi istu originalnu arenu; nema novih generisanih slika, paketa ili velikih binarnih fajlova.

## Provere / važno ograničenje

- `node --check` prošao.
- Izolovane provere stvarnih JS funkcija prošle: broj polja, susedstvo i dijagonale, povratak i zabrana ponavljanja polja, punjenje po tipu, bonus, dopuna samo korišćenih polja, šteta, štit, lečenje, CPU, pauza, power-up jednom i nagrada jednom.
- To nisu end-to-end testovi. Browser alat je odbio lokalni file URL zbog svoje politike pristupa. **V3 nije vizuelno potvrđen u browseru niti na fizičkom telefonu.** Ne prepisivati stare V2 vizuelne provere kao provere V3.
- Lokalni proverni skript: `.local/v3-review/logic.cjs` (ignorisano).
- Demo lista nije produkcioni rečnik, dopuna nije kvalitetan generator. Nema trajnog napredovanja, naloga, zvuka ili prave kampanje. Promene se resetuju pri ponovnom učitavanju.

## Tačan sledeći korak

Na landscape telefonu otvoriti V3. Probati Play → Prepare → Battle, reč STONE ili STONES u prvom redu i PLANE u trećem. Aktivirati napunjen štit, zatim druge sposobnosti. Pregledati Power-ups i Workshop. Potvrditi mobilnu kompoziciju i tek zatim menjati grafiku ili širiti implementaciju. Smer punjenja po bojama i pravilo susedstva ne pitati ponovo.

Zatim potvrditi tempo, bonus, broj polja i **engine**. Godot je samo tehnički isproban, nije izabran.

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
- Engine, licencirani engleski rečnik, tema, balans i monetizacija ostaju otvoreni. Aktivne odluke su u `docs/game-design.md`.
