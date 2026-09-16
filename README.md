# War of Words — mobilna igra u planiranju

Originalna igra za Android i iOS: igrač prevlači preko slova u krugovima, sastavlja reči i prikuplja energiju koju troši na borbene sposobnosti. Slugterra je referenca za osećaj borbe i napredovanja; svet, likovi i grafika biće originalni. Naziv repozitorijuma nije potvrda konačnog naziva igre.

**Status:** planiranje i interaktivni mockupovi. Usvojeni su landscape format, engleski jezik/rečnik za prvu verziju i borba protiv računara. Godot je ciljni engine za kasniju izradu; trenutno se radi samo vizuelni dizajn. Izvor rečnika, tema i balans još nisu usvojeni. Godot 4.7.2 je samo tehnički isproban. Produkcioni igrivi prototip još ne postoji.

## Nastavak rada

### Aktuelno: šest dizajna ekrana

Otvoriti **[statičnu galeriju dizajna](design/index.html)** ili [pojedinačne PNG slike](design/README.md). Šest usklađenih landscape ekrana za buduću mobilnu igru u Godotu, bez simulacije. [Specifikacija za izradu](design/DESIGN-SPEC.md) i [poreklo materijala](design/PROVENANCE.md).

### Prethodni V3 interaktivni mockup

Otvoriti **[V3 mokup/index.html](V3%20mokup/index.html)**. Šest osnovnih mobilnih ekrana: meni, kampanja, arsenal, power-upovi, unapređenja i borba. Susedna slova sa dijagonalama, dopuna polja i punjenje sposobnosti po bojama. [Uputstvo i granice provere](V3%20mokup/README.md). V3 još treba vizuelno proveriti na telefonu.

### Prethodni V2 atlas (sačuvan)

Otvoriti **[mockups/index.html](mockups/index.html)** lokalno u browseru — bez instalacije i servera. [Landscape atlas](mockups/README.md) sadrži **86 ekrana/stanja**, 35-slova tablu, malu englesku demo listu, simulaciju računarskog protivnika i osam povezanih tokova. Vedrija revizija 02 zamenjuje prvi portrait koncept. [Dizajn ekrana](docs/screen-design.md) opisuje predloge i granice. Aktivni rad je na grani `codex/screen-mockups`.

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
