# Trajna uputstva za ovaj projekat

## Opseg i komunikacija

- Komuniciraj na srpskom, jasno i praktično. Ovaj repo služi isključivo igri War of Words (radni naziv).
- Na početku svakog rada pročitaj ovaj fajl i STATUS.md, zatim relevantnu dokumentaciju.
- Korisnik je 2026-09-16 usvojio šest vizuelnih dizajna i izričito odobrio izradu cele igrive Android verzije u prethodno dogovorenom smeru. Aktivni engine je Godot 4.7.2, projekat `game/`. Starija zabrana implementacije je time zamenjena.
- Usvojene odluke beleži u docs/game-design.md; predloge označi kao predloge. Ne zaključavaj temu, rečnik ili monetizaciju bez dogovora.
- README.md i docs/setup.md opisuju aktivna uputstva; stariji PLAN.md i GODOT-SETUP.md služe kao istorija istraživanja. Poslednja eksplicitna korisnička odluka ima prednost.

## Početak rada i sinhronizacija

1. Proveri `git status --short --branch`, aktivnu granu, upstream i `git remote -v`. Očekivani origin je https://github.com/sinisamedic/warofwords.git.
2. Uradi `git fetch origin --prune`. Ako mreža ili autentikacija ne rade, prijavi da stanje GitHub-a nije provereno; ne nazivaj kopiju sinhronizovanom.
3. Ako je kopija čista i lokalna grana samo zaostaje za upstream-om, koristi `git pull --ff-only`. Ako je već ispred, pregledaj lokalne commit-e. Ako nema upstream-a, prvo utvrdi ispravnu remote granu.
4. Ako postoje izmene, prvo pregledaj njihov sadržaj i poreklo. Za relevantan bezbedan rad napravi lokalni zaštitni commit na odgovarajućoj grani; ne uključuj tajne, lokalne artefakte ili nepovezane izmene. Druga mogućnost je eksplicitna arhiva/patch u .local/ uz posebnu kopiju nepoznatih untracked fajlova. Ne oslanjaj se samo na `git diff` jer ne čuva untracked i binarne fajlove u običnom obliku.
5. Kod razilaženja sačuvaj zaštitnu granu pre usklađivanja. Pregledaj obe strane i spoji istorije merge-om kada je smisleno; ne radi automatski rebase deljene istorije. Konflikte sa jasnim rešenjem razreši i proveri, semantičke nedoumice iznesi korisniku.
6. Zabranjeni su force push, destruktivni reset, `git clean` radi uklanjanja tuđeg rada i prepisivanje postojećih fajlova naslepo. Stash nije prenos na drugi računar.

## Grane i dva računara

- `main` je zajednička početna grana. Rutinsko uređivanje dokumentacije može direktno na main; za veće promene koristi `codex/<opis>`.
- Računari rade naizmenično. STATUS.md mora navesti aktivnu granu i konkretan sledeći korak. Ako se nastavlja nedovršena grana, push-uj i nju i dokumentuj njeno ime.
- Ako GitHub pravila odbiju direktan push, poštuj ih; koristi radnu granu i prijavi potreban PR. Ne menjaj zaštitu grana ili vidljivost repozitorijuma.
- Ne stvaraj ugnježdene Git repozitorijume. Treće strane čuvaj kao dokumentovane kopije izvora sa licencom i tačnom revizijom, ili van ovog foldera.

## Završetak dana / prelazak na drugi računar

Kada korisnik kaže „završavamo za danas” ili „prelazim na drugi računar”:

1. Sačuvaj relevantne fajlove i pokreni provere primerene izmeni.
2. Ažuriraj STATUS.md: šta je završeno, šta je nedovršeno, otvorene odluke, aktivna grana, rezultati provera i tačan sledeći korak.
3. Pregledaj diff i nove fajlove, proveri tajne i velike binarne fajlove. Stage-uj eksplicitno relevantne putanje.
4. Napravi smislen commit i uradi običan push na ispravan upstream.
5. Proveri izlaz push-a i da SHA udaljene grane odgovara lokalnom HEAD-u. Proveri lokalno stanje još jednom.
6. Prijavi commit, granu i ishod. Ako push nije uspeo, jasno navedi šta postoji samo lokalno. Ne upisuj „push uspeo” unapred u STATUS.md; SHA koji predstavlja handoff korisniku prikaži tek nakon potvrde.

Korisnik je unapred odobrio rutinske commit i push operacije za ovaj repo. Ne traži ponovnu saglasnost za njih. Ako sandbox zahteva tehničko odobrenje, koristi predviđeni mehanizam i objasni da je razlog ograničenje okruženja.

## Prenosivost, materijali i alati

- Relativne putanje u zajedničkim fajlovima; izvršni fajlovi i podešavanja računara u ignorisanom `.local/machine.json` ili odgovarajućim promenljivama okruženja.
- Ne commit-uj tokene, lozinke, signing ključeve, .env, lokalne MCP konfiguracije, node_modules, Godot keš, export build-ove ili instalacije alata.
- Izvorne slike, zvuk i dokumente verzioniši uz podatke o poreklu i licenci. Ne ignoriši sve slike ili zvuk jer su deo projekta.
- Pre PRVOG commita velikog binarnog materijala proceni Git LFS i dogovori obrasce. Proveri veličinu novih fajlova; fajl preko 10 MiB je obavezan signal za pregled, ne automatska odluka. Uvedi LFS pre `git add` takvog fajla. Ne migriraj već objavljenu istoriju bez posebnog dogovora.
- Na svakom računaru proveri verzije, MCP alate i stvarnu vezu. GitHub prenosi izvor/podešavanje projekta, ne instalira Godot, Blender, Inkscape, Node, SDK niti MCP registraciju.
- Godot MCP je razvojni dodatak; nikada ne pretpostavi da njegov prazan error buffer dokazuje odsustvo grešaka. Pregledaj i pravi engine log.
- Ne pokreći istovremeno dve Godot MCP sesije/editora na istom portu.
- Ne delegiraj podagentima bez eksplicitnog korisničkog zahteva.
