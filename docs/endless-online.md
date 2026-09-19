# Globalne liste i slanje Beskraja

## Dopuna 2026-09-19: svi jezici zajedno

Migracija `202609190003_shared_language_rankings.sql` postavljena je na War of Words. I Beskraj i Dnevni izazov sada biraju najbolji rezultat po profilu preko svih jezika pre računanja plasmana. Nema duplih redova; argument jezika ostaje zbog kompatibilnosti starih poziva, ali ne filtrira listu. Podaci o jeziku u partijama ostaju za pravila/replay. Pravilo povezivanja i dnevna verzija/datum ostaju filteri. Ova dopuna zamenjuje ranije jezičko razdvajanje opisano ispod.

Poraz ima eksplicitno dugme POŠALJI REZULTAT uz ime, sa stanjem SLANJE / POSLATO i ponovnim pokušajem. Automatsko slanje ostaje; pritisak ne stvara novu partiju. `tools/test-shared-rankings.mjs` proverava objedinjavanje i prava (15 provera). Mrežni test potvrđuje identične žive SR/EN odgovore u oba režima.

Migracije `202609190001_endless.sql` i `202609190002_endless_runs.sql` postavljene su na potvrđeni Supabase projekat War of Words (`phfbohgbeqjvtfsgcjwi`) 2026-09-19. Druga dodaje privatne pojedinačne partije i RPC-e `endless_finish` / `endless_name`; postojeći dnevni rezultati i Edge funkcija ostaju isti.

Klijent koristi postojeću anonimnu sesiju Dnevnog izazova. Autentikacija je serijalizovana da istovremeno učitavanje liste i slanje ne otvore dva identiteta. Privatne tabele `endless_scores` i `endless_runs` imaju RLS i nemaju direktan anon/authenticated pristup. Upisi se vezuju za `auth.uid()`. Lista vraća prvih 20 i sopstveni red, bez UUID-a; jednaki bodovi dele rang. Kategorije: SR/EN i susedno/slobodno povezivanje.

Svaki poraz u Beskraju upisuje kompletnu statistiku u `endless_outbox` u lokalnom progress.json, sa stabilnim nasumičnim UUID-om. Slanje počinje automatski ako postoji nadimak; potvrđeni zapis uklanja se iz reda. Bez veze ostaje sačuvan; pokušaj se ponavlja pri otvaranju liste i na 45 sekundi dok igra radi. Server deduplikuje `(user_id, run_id)`. Svaki pohod čuva zasebno, a najbolji pozitivan rezultat sa najmanje jednom reči ulazi na listu. Slabija partija ne briše bolji rezultat.

Nadimak od 3–20 slova/brojeva, razmaka, crtice ili donje crte deli isti daily-profile.json sa Dnevnim izazovom. Prvi rezultat čeka unos. Izmena se pamti posle kratke pauze u kucanju ili potvrde; server ažurira ime na najboljim rezultatima tog profila. Neuspešna promena označena je sa `endless_name_dirty` i ponavlja se i nakon ponovnog pokretanja. Stari `endless_pending` ostaje radi kompatibilnosti, ali se raniji rekordi ne objavljuju retroaktivno.

Rekordi na naslovnoj imaju serverske tabove Beskraj / Dnevni izazov (današnji UTC izazov). Ekran poraza sadrži listu Beskraja, nadimak, statistiku i opremu. Sopstveni red je istaknut. Greška veze ne prikazuje lokalnu listu kao globalnu.

Ovo je i dalje klijentski prijavljena beta statistika Beskraja, bez serverskog replay-a ili dokaza kampanjskih unapređenja. Ograničenja polja nisu zaštita od modifikovanog klijenta. Nema nagrada ni novca. Reinstalacija bez povezivanja naloga pravi novi identitet. Pre javnog takmičenja potrebni su provera borbe, ograničenja učestalosti i moderacija.

Provere:

- `tools/test-endless-database.mjs`: 20 lokalnih PGlite provera prava, autentikacije, rangiranja, privatnosti, deduplikacije i promene imena.
- `game/tests/test_rankings.gd`: bez stvarnih upisa proverava red, prekid veze, pamćenje/promenu imena tokom slanja, brzu promenu kategorije i UI.
- `game/tests/test_endless_online.gd`: izolovani anonimni identitet, čitanje obe žive liste i odbijanje negativnog rezultata. Ne objavljuje lažne bodove.
- `game/tests/preview_endless.gd`: izolovana probna igra; F8 prikazuje primer poraza, a probni rezultati imaju isključenu automatsku objavu. Liste se čitaju sa servera.
