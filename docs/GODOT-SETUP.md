# Godot i MCP — lokalno podešavanje

Datum: 2026-09-15.

Istorijski izveštaj prve probe; uputstva sa apsolutnim putanjama ispod opisuju samo taj računar. Za aktuelno, prenosivo podešavanje koristiti [setup.md](setup.md). Server izvori i lockfile sada su verzionisani; build i instalirane zavisnosti ostaju lokalni. Verifikaciona skripta sada koristi lokalnu putanju iz .local/machine.json i nove scene u probe_runs umesto prepisivanja originalne scene.

## Instalirano i provereno

- Korisnik je raspakovao i pokrenuo standardni Godot u `C:/Projects/Godot`.
- Izvršni fajl: `Godot_v4.7.2-stable_win64.exe`.
- Proverena verzija: `4.7.2.stable.official.ed1daf0bf`.
- MCP izvor: https://github.com/mkdevkit/godot-mcp ; MIT licenca.
- Preuzet commit: `328e15f7d38092371b2aca8b81c40b8188bbe747`.
- Lokalni izvor i izgrađeni server: `tools/godot-mcp/server/build/index.js`.
- Node: `C:/nvm4w/nodejs/node.exe`.
- Codex registracija: `godot-local`, stdio; promenljiva `GODOT_MCP_PORT=6505`.
- Server sluša samo na `127.0.0.1:6505`; Godot dodatak se povezuje na njega.

## Probni projekat

Otvoriti `setup-probe/project.godot`. Dodatak `addons/godot_mcp` već je uključen. Ovo je tehnička provera veze, ne početak implementacije igre ili izbor njenog vizuelnog identiteta.

Uspešno provereno pravim MCP klijentom kroz stdio server i Godot editor:

1. Čitanje projekta i verzije.
2. Kreiranje scene `connection_probe.tscn`.
3. Dodavanje Label objekta, promena teksta i veličine fonta.
4. Čuvanje scene i čitanje stabla objekata.
5. Pokretanje scene, čitanje stabla objekata iz pokrenute igre.
6. Snimanje ekrana; slika vizuelno pregledana.
7. Zaustavljanje igre.

Izveštaj: `.local/godot-mcp-verification.json`; slika: `.local/godot-mcp-probe.png`; nezavisni log: `.local/godot-editor.log`. Drugi prolaz nema ERROR poruka u logu.

Provera je obavljena skriptom `tools/verify-godot-mcp.mjs`. Ona otvara editor i pravi/ponovo pravi samo probnu scenu. Ne koristiti je nad scenom koju korisnik počne ručno da menja. Po završetku privremeni server se zatvara, a editor ostaje otvoren. Codex će pokretati svoj server iz sačuvane konfiguracije kada učita MCP vezu.

Registracija u Codex podešavanjima je uspela; novi MCP alati još nisu potvrđeni kao pozivi u tekućoj sesiji. Posle ponovnog učitavanja Codexa proveriti `get_project_info` pre daljeg rada.

## Lokalna ispravka i ograničenja

- `setup-probe/addons/godot_mcp/commands/scene_commands.gd`: čuvanje scene čeka `process_frame` pre poziva `save_scene`, jer Godot 4.7 ne dozvoljava dijalog napretka tokom deferred poziva. Dodata je provera povratnog koda čuvanja. Izvorni checkout nije menjan; pri prenosu dodatka u buduću igru preneti ovu ispravku.
- `get_editor_errors` dodatka nije pouzdan dokaz da nema grešaka: prvi prolaz je vratio nulu iako je nezavisni Godot log sadržao greške dijaloga. Uvek proveravati i stvarni log.
- Ostalih približno 160 komandi nismo pojedinačno testirali. Android/iOS izvoz i mobilni SDK nisu podešeni niti testirani.
- Dodatak ubrizgava tri runtime autoload servisa. Namenjen je razvoju; pre distribucije igre ukloniti ih iz produkcione konfiguracije.
- Jedan editor po portu; ne otvarati više projekata sa istim dodatkom na portu 6505 istovremeno.
- `tools/godot-mcp` je lokalno preuzet checkout, izostavljen iz glavnog Git praćenja. Ako se folder projekta preseli, ažurirati apsolutnu putanju u Codex MCP konfiguraciji.

## Sledeće

Učitati `godot-local` u Codex i potvrditi poziv. Potom dogovoriti jezik rečnika i osnovnu borbu iz `PLAN.md` pre igrivog prototipa. Tema još nije izabrana.
