# Beskraj: ručno slanje i lista svih partija

**Dopuna 2026-09-20:** poraz više ne pravi nacrt dok igrač odlučuje o nastavku. Najviše tri nagrađena nastavka čuvaju zbirni skor. Konačan nacrt nastaje jednom, tek pri izboru ZAVRŠI POHOD ili nakon potrošena tri nastavka i narednog poraza. Sva pravila ručnog slanja ispod primenjuju se na taj konačni nacrt. Detalji u [admob.md](admob.md).

Aktuelna pravila (2026-09-19) zamenjuju prethodni automatski tok. Poraz čuva partiju kao lokalni nacrt u `endless_outbox` sa jedinstvenim ID-em. Ni otvaranje ekrana, kucanje, čekanje, potvrda tastature, zatvaranje prozora ni otvaranje Rekorda ne šalju rezultat. Nema tajmera za pozadinsko slanje ili promenu imena. Stara zastavica `endless_name_dirty` više nema dejstvo.

Ime je unapred popunjeno poslednjim zapamćenim nadimkom i može da se izmeni. Dugme POŠALJI jedino poziva `send_run` za upravo tu partiju i trenutno uneto ime. Tokom slanja prikazuje SLANJE, tek potvrda servera postavlja POSLATO i zaključava dugme. Greška vraća mogućnost izmene i ručnog ponovnog slanja istog ID-a. Slabiji rezultat se šalje normalno; nove partije uvek počinju kao neposlate. Ostali raniji nacrti ne šalju se zajedno sa novim rezultatom. Posle napuštanja prozora ostaju na disku; još nema posebnog pregleda/slanja starih nacrta.

Prozor privremeno uključuje `Input.emulate_mouse_from_touch` za standardno polje za ime, dugmad i skrol, kao Dnevni izazov. Pri zatvaranju vraća prethodno podešavanje. Promena veličine čuva tekst i fokus unosa. Test koristi stvarni Godot ulazni tok sa ScreenTouch događajima i unosom tastera, ne samo emitovanje signala dugmeta.

## Server i rangiranje

Migracije 202609190001–0004 postavljene su na projekat War of Words (`phfbohgbeqjvtfsgcjwi`). `endless_runs` čuva svaku poslatu partiju pojedinačno, uključujući slabije i nulte skorove, sa imenom iz tog slanja. Isto ime/profil može da ima više redova. `endless_finish` deduplikuje `(user_id, run_id)`; ponovljeni zahtev može ispraviti ime ali ne menja bodove postojeće partije.

`endless_attempt_leaderboard(p_adjacent, p_run)` rangira sve partije preko oba jezika. Vraća top 10 i, ako je trenutna partija niže, dva reda neposredno ispred nje i njen red; preklop sa top 10 se ne duplira. Trenutni red je istaknut i prozor se pomera do njega. Svi rezultati ostaju sačuvani iako lista prikazuje samo ovaj izbor. Jednaki skorovi dele numerički rang, redosled između njih je stabilan po vremenu/identitetu partije. Zahtev za okolinu proverava da je tražena partija vlasništvo prijavljenog profila.

Poznati najbolji skorovi iz starijih klijenata bez zapisa pojedinačnih partija preneti su u novu tabelu bez ponavljanja istih poznatih rezultata. Ranije nezabeležene slabije partije nije moguće retroaktivno obnoviti. Stari `endless_leaderboard` ostaje zbog kompatibilnosti APK-a 0.1.18 i ranijih.

Dnevni izazov zadržava zajedničku listu oba jezika i svoj postojeći način verifikacije/rangiranja. Pravilo povezivanja je i dalje odvojeno. Anonimna sesija je zajednička; tabele imaju RLS bez direktnog pristupa klijenta. RPC upis vezuje za `auth.uid()`, lista ne izlaže UUID.

Beskraj ostaje beta sa klijentskim bodovima, bez serverskog replay-a. Reinstalacija bez povezivanja naloga stvara novi identitet. Pre javnog takmičenja potrebni su provera borbe, moderacija i ograničenje učestalosti.

## Provere

- `tools/test-attempt-rankings.mjs`: 17 provera svih partija jednog profila, oba jezika, top 10, dva susedna bolja, granica 10/11, deduplikacije, ispravke imena i prava.
- `game/tests/test_rankings.gd`: dodir/unos, zabrana svih automatskih slanja, eksplicitni klik, neuspeh/ručni retry, nove slabije partije, odvojeni nacrti, stanje dugmeta, skrol i povratak input podešavanja.
- `game/tests/test_endless_online.gd`: čita živu listu i odbija negativni testni upis, bez lažnih javnih skorova.
- `preview_endless.gd`: izolovan vizuelni pregled, bez dozvoljenih upisa; F8 je primer poraza. Pravi rezultati se čitaju sa servera.
