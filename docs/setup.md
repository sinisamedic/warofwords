# Podešavanje računara i prenos rada

Ova dokumentacija je aktivno uputstvo. Godot je opcionalna tehnička proba, ne konačno izabrani engine igre. Za rad na planu potrebni su samo Git, pristup repozitorijumu i Codex.

## 1. Verzije

Ovo su tačne verzije proverene na prvom računaru 2026-09-15, ne tvrdnja da su najnovije:

| Alat | Proverena verzija | Potreba |
| --- | --- | --- |
| Git for Windows | 2.55.0.windows.5 | Rad sa repozitorijumom; na drugom OS-u kompatibilan Git 2.x |
| Git LFS | 3.7.1 | Dostupan lokalno; nije aktiviran za ovaj repo |
| Godot standard, x86_64 | 4.7.2.stable.official.ed1daf0bf | Samo za postojeću probu, bez .NET |
| Node.js | 22.14.0 | Lokalni MCP server i verifikaciona skripta |
| npm | 9.8.1 | `npm ci` iz sačuvanog lockfile-a |
| Godot MCP server | 0.1.0, commit 328e15f7d38092371b2aca8b81c40b8188bbe747 | Izvor mkdevkit/godot-mcp, MIT |
| Inkscape | 1.4.2 | Opcionalno; prethodna dijagnostika, nije neophodan za ovu probu |

Blender verzija nije potvrđena. Android SDK/JDK, iOS Xcode i export templates još nisu podešeni/potvrđeni; konkretne verzije odabrati kada usvojimo engine i platformu prvog testa. Codex verzija nije zaključana; na svakom računaru proveriti dostupnost shell i MCP funkcija.

## 2. Kloniranje na drugom računaru

Iz foldera koji NIJE već Git repozitorijum, na primer iz svog radnog direktorijuma:

```powershell
git clone https://github.com/sinisamedic/warofwords.git
Set-Location warofwords
git remote -v
git status --short --branch
```

Ako `warofwords` već postoji, prvo pregledati sadržaj. Ako je već kopija istog repoa, koristiti nju i proveriti remote. Ne klonirati preko postojećih fajlova ili unutar druge kopije.

Ako Git traži prijavu, završiti Git Credential Manager prijavu u browseru istim GitHub nalogom koji ima pristup. Ne unositi token u remote URL, projekat ili razgovor. Ako nalog nema pristup, vlasnik mora dati pristup; ne menjati vidljivost repozitorijuma.

U Codex-u otvoriti/dodati postojeći folder `warofwords` kao projekat. Radni folder novog razgovora mora biti taj folder. Prvi zahtev može biti: „Pročitaj AGENTS.md i STATUS.md, proveri sinhronizaciju i nastavi od sledećeg koraka.”

Na prvom računaru već koristimo postojeći folder projekta sa origin-om; njegovo lokalno ime ne mora biti `warofwords`. Nije potrebno premeštanje radi GitHub-a.

## 3. Svakodnevni rad

```powershell
git status --short --branch
git remote -v
git fetch origin --prune
git log --oneline --left-right HEAD...origin/main
```

Ako je radna kopija čista i `main` samo zaostaje:

```powershell
git pull --ff-only
```

Ako postoji lokalni rad ili razilaženje, prvo zaštititi i pregledati prema AGENTS.md. Ne koristiti reset/force push. Pre promene računara reći „prelazim na drugi računar”; agent ažurira STATUS, commit-uje relevantan rad, push-uje i proverava remote SHA. Ne gasiti računar pre potvrde uspešnog push-a. Git ne čuva nesnimljene izmene otvorenog editora.

## 4. Opcionalna Godot proba

Preuzeti standardni Godot 4.7.2 sa zvaničnog arhiva https://godotengine.org/download/archive/ i raspakovati izvan repoa. Pokrenuti izvršni fajl i uvesti `setup-probe/project.godot`. Za običan prikaz otvoriti `connection_probe.tscn` i F6.

Ne preuzimati engine instalaciju preko ovog repoa. Svaki računar može imati drugu apsolutnu putanju. Za našu skriptu napraviti lokalni `.local/machine.json`:

```json
{
  "godotExecutable": "C:/Tools/Godot/Godot_v4.7.2-stable_win64.exe"
}
```

Zameniti primer stvarnom putanjom. Fajl je ignorisan. Alternativno postaviti `GODOT_EXECUTABLE` za proces. Nikada ne menjati zajedničku skriptu zbog druge putanje računara.

## 5. Priprema MCP servera

Node 22.14.0 i npm 9.8.1 su proverena kombinacija. Za različitu verziju ponoviti build i test pre upisivanja nove verzije ovde.

Iz korena repozitorijuma, PowerShell:

```powershell
Push-Location tools/godot-mcp/server
npm.cmd ci --ignore-scripts --no-audit --no-fund --cache ../../../.local/npm-cache
if ($LASTEXITCODE -ne 0) { throw 'npm ci nije uspeo' }
npm.cmd run build
if ($LASTEXITCODE -ne 0) { throw 'MCP build nije uspeo' }
Pop-Location
node tools/verify-godot-mcp.mjs --check-config
```

Izvori, package-lock.json i licenca su u repou; `node_modules` i `server/build` nastaju na svakom računaru. Nema potrebe za novim `git clone` dodatka. Na macOS/Linux-u koristiti `npm` umesto `npm.cmd` i odgovarajuće lokalne putanje.

## 6. MCP veza u Codex-u — zasebno na svakom računaru

Prvo proveriti da li `godot-local` već postoji. Ne praviti duplu konfiguraciju.

```powershell
codex mcp get godot-local --json
```

Ako ne postoji, iz korena projekta:

```powershell
$godotMcpNode = (Get-Command node).Source
$godotMcpEntry = (Resolve-Path tools/godot-mcp/server/build/index.js).Path
codex mcp add godot-local --env GODOT_MCP_PORT=6505 -- $godotMcpNode $godotMcpEntry
```

Ako postoji sa starom putanjom, pregledati pa ažurirati kroz lokalna Codex MCP podešavanja. Registracija ostaje u korisničkom Codex config-u, ne u Git-u. Ako CLI nije u PATH-u, podesiti lokalni MCP kroz Codex podešavanja: stdio, komanda je Node izvršni fajl, argument je apsolutna putanja do izgrađenog servera, port 6505.

Ponovo učitati Codex ako se novi alati nisu pojavili. Otvoriti probni projekat sa dodatkom uključenim, pa prvo pozvati čitanje podataka projekta. GitHub ne instalira niti aktivira MCP na drugom računaru.

Jedan editor/server na portu 6505. Ako port koristi Codex-ov server, ne pokretati paralelno verifikacioni server. Kod konflikta zatvoriti samo poznatu probnu sesiju, ne ubijati sve Node/Godot procese.

## 7. Samostalna tehnička provera

Kada Codex MCP server ne koristi port, pokrenuti:

```powershell
node tools/verify-godot-mcp.mjs
```

Skripta otvara probni editor. Ako je taj probni projekat već otvoren sa dodatkom, koristiti `--connect-existing`. Ne zatvara automatski postojeće editore i ne prepisuje sačuvanu probnu scenu: nova scena nastaje u ignorisanom `setup-probe/probe_runs/`. Ne koristiti na drugim projektima otvorenim na istom portu.

Proveriti `.local/godot-mcp-verification.json`, `.local/godot-editor.log` i `.local/godot-mcp-probe.png`. Slika mora biti stvarno pregledana. Dodatkov `get_editor_errors` nije dovoljan, jer njegov buffer može propustiti engine grešku.

Ranija provera cele veze je prošla. Posle izmene skripte za prenosivost provereni su sintaksa i lokalne putanje; GUI test se ne ponavlja automatski jer korisnik može imati aktivnu MCP sesiju.

## 8. Grafika, zvuk i LFS

Još nema velikih produkcionih binarnih fajlova. Kad ih izaberemo, sačuvati izvor/licencu i dogovoriti LFS obrasce PRE prvog commita (npr. .blend ili veliki .wav, prema stvarnim materijalima). Tada na oba računara instalirati Git LFS, uraditi `git lfs install`, commit-ovati `.gitattributes` zajedno sa materijalima i proveriti upload LFS objekata. Ne dodavati sve formate unapred bez procene troška i potrebe.

## 9. Poreklo izvora i lokalne ispravke

[MCP poreklo](third-party.md), [istorijski Godot test](GODOT-SETUP.md). Kod budućeg ažuriranja dodatka sačuvati ispravku `save_scene`, pregledati diff i ponoviti praktičan test. Probni dodatak sadrži runtime servise za razvoj; oni ne treba da budu u budućem produkcionom izvozu igre.
