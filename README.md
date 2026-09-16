# War of Words — mobilna igra u planiranju

Originalna igra za Android i iOS: igrač prevlači preko slova u krugovima, sastavlja reči i prikuplja energiju koju troši na borbene sposobnosti. Slugterra je referenca za osećaj borbe i napredovanja; svet, likovi i grafika biće originalni. Naziv repozitorijuma nije potvrda konačnog naziva igre.

**Status:** istraživanje i planiranje. Engine, jezik rečnika, tema i konkretan balans još nisu usvojeni. Godot 4.7.2 je samo tehnički isproban. Igrivi prototip još ne postoji.

## Nastavak rada

### Mockupovi ekrana

Otvoriti **[mockups/index.html](mockups/index.html)** lokalno u browseru — bez instalacije i servera. [Atlas ekrana](mockups/README.md) sadrži 84 ekrana/stanja, probu povezivanja slova i osam povezanih tokova. [Dizajn ekrana](docs/screen-design.md) opisuje predloge i granice. Aktivni rad na ovim mockupovima je na grani `codex/screen-mockups`.

1. Pročitati [AGENTS.md](AGENTS.md) i [STATUS.md](STATUS.md).
2. Proveriti Git stanje i sinhronizovati prema tim uputstvima.
3. Dogovoriti otvorene odluke iz [dizajna igre](docs/game-design.md).

Repozitorijum: https://github.com/sinisamedic/warofwords

## Pokretanje postojeće tehničke probe

Ovo nije igra. Standardnim Godotom **4.7.2** uvesti `setup-probe/project.godot`, otvoriti `connection_probe.tscn` i pritisnuti **F6**. Scena prikazuje tekst koji je ranije napravljen kroz MCP; taj tekst sam po sebi ne potvrđuje trenutnu vezu. Bez aktivnog MCP servera scena i dalje može da se pokrene.

Za stvarnu proveru veze, zavisnosti i podešavanje računara pratiti [docs/setup.md](docs/setup.md).

## Struktura

- `docs/game-design.md` — usvojeni zahtevi, predlozi i otvorene odluke.
- `docs/setup.md` — ponovljivo podešavanje računara i MCP-a.
- `docs/PLAN.md` — sačuvano detaljno početno istraživanje.
- `docs/GODOT-SETUP.md` — istorijski izveštaj prve MCP probe.
- `setup-probe/` — mala tehnička Godot proba i dodatak sa lokalnom ispravkom.
- `tools/godot-mcp/server/` — verzionisani izvori MCP servera i zaključane zavisnosti.
- `.local/` — ignorisani podaci pojedinačnog računara, logovi i lokalne arhive.

Kod, dokumentacija i odabrani izvorni grafički/zvučni materijali pripadaju GitHub-u. Keš, zavisnosti, instalacije alata i tajne ostaju lokalno. Git LFS još nije uveden: nema velikih binarnih materijala za slanje.
