# Globalna beta lista Beskraja

Migracija: `supabase/migrations/202609190001_endless.sql`. Postavljena na potvrđeni projekat `phfbohgbeqjvtfsgcjwi` 2026-09-19. Ne menja Dnevni izazov niti Edge funkciju daily.

Klijent koristi postojeću anonimnu Supabase sesiju i javni konfiguracioni fajl. Tabela `endless_scores` je privatna sa RLS; nema direktnih prava anon/authenticated. Dva security-definer RPC-a vezuju upis za `auth.uid()`, ne primaju tuđi ID. Lista izlaže nadimak, rezultat, talas, broj reči, plasman i oznaku sopstvenog reda; ne izlaže UUID. Prvih 20 i sopstveni red, isti bodovi dele rang. Jedan rekord po korisniku i kategoriji; niži ili ponovljeni rezultat ne prepisuje bolji.

Ovo je klijentski prijavljena beta statistika, bez serverskog replay-a ili dokaza kampanjskih unapređenja. Ograničenja polja nisu zaštita od modifikovanog klijenta. Nema nagrada, novca ni automatske objave; korisnik unosi nadimak i bira Objavi rekord. Reinstalacija bez povezivanja naloga pravi novi identitet.

`endless_pending` u progress.json čuva najbolji završen pohod po kategoriji (bodovi, talas, reči, vreme). Stari rekord bez statistike ne može na server; potrebna je nova partija. Nije uvedena posebna ekonomija Arsenala.

Provere: `tools/test-endless-database.mjs` koristi postojeći PGlite u `.local/daily-tools`; proverava autentikaciju, izolaciju kategorija, rang, privatnost UUID-a, niži rezultat, ograničenja i zabranu direktnog pristupa. `game/tests/test_endless_online.gd` je eksplicitni mrežni test: kreira izolovanu anonimnu sesiju, čita živu listu, pokušava neispravan upis (odbijen), proverava zatvaranje UI i lokalni pending reload. Ne ostavlja lažan rezultat na listi.
