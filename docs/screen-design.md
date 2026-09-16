# Dizajn ekrana — koncept 01

Datum: 2026-09-16. **Predlog za razmatranje, ne usvojena tema, ekonomija ili engine.**

Traženi rezultat je pregled svih relevantnih ekrana i situacija igre. Napravljen je samostalan [atlas 84 ekrana i stanja](../mockups/README.md), sa interaktivnim prikazom i osam povezanih tokova. Nije pokrenuta velika implementacija igre.

## Vizuelni smer: Svet odjeka

Reči bude ostrva koja gube glas. Svetionik je baza, mala originalna bića predstavljaju sposobnosti, a staze vode kroz oblasti sa čuvarima. Boje: tamni petrolej kao mirna podloga, svetla nana za prijateljske elemente, zlatna za važne akcije i energiju, koralna za najavu opasnosti. Slova su svetli kružni elementi i imaju najveći kontrast.

Radni nazivi: Iskra (udarac), Ljuska (štit), Zvono (prekid), Mrmljavac (običan protivnik), Čuvar tišine (boss), Svetlucavi gaj (prva oblast). Nisu konačan identitet. Nema preuzetih Slugterra likova ili materijala.

## Obuhvat

| Grupa | Ekrani i stanja |
| --- | --- |
| Prvi susret | Naslov, jezik i pismo, lokalni profil, prolog, tri koraka uputstva |
| Baza i ekspedicija | Svetionik, mapa, ostrva, zaključana oblast, priprema susreta, tri sposobnosti, priča |
| Borba | Normalno stanje, prevlačenje, prihvaćena/nevažeća/prekratka/ponovljena reč, nedovoljna/puna energija, najava, udarac, štit, prekid i cooldown, novi/iscrpljen skup, kritično zdravlje, boss i nova faza, pauza, napuštanje |
| Ishod | Pobeda, poraz, sažetak, garantovana nagrada, novi odjek, izbor i zasebne potvrde grana, oslobođena oblast |
| Kolekcija | Kolekcija, detalj sposobnosti, zaključano i prazno stanje, radionica, trošak, nedovoljni materijali, uspeh nadogradnje i povratne grane, ranac, predmet |
| Dodatni sadržaj | Zadaci i nagrade, svi zadaci završeni, trening i rezultat, dnevnik i protivnik, izazov, kozmetika i detalj |
| Podešavanja | Audio kontrole, pristupačnost, pravila reči, lokalna prijava reči i potvrda, profil i čuvanje, pomoć, formular problema i potvrda, poreklo materijala, brisanje profila |
| Prekidi | Povratak iz pozadine, prekid dodira, učitavanje, greška paketa, offline režim, konflikt napretka i potvrda, neuspešno čuvanje, oporavak susreta, orijentacija |

Svaki ekran ima identifikator, razlog postojanja, izlazne veze i oznaku obima u `mockups/screens.js`. Katalog uključuje pune ekrane, modalne dijaloge i promene stanja istog ekrana; broj 84 nije broj različitih osnovnih rasporeda.

## Osam tokova

1. Prvo pokretanje → jezik → profil → priča → tri kratke vežbe → baza.
2. Baza → mapa → priprema → tim → reč → sposobnost → pobeda → nagrada → mapa.
3. Najava → kritično zdravlje → poraz → promena taktike → novi pokušaj.
4. Boss → druga faza → otkriće → nadogradnja → završetak oblasti.
5. Odbijena reč → objašnjenje uzroka → opcioni predlog reči za pregled.
6. Prekid dodira/aplikacije → pauza → potvrda nastavka → isti susret.
7. Pobeda → problem čuvanja → lokalni napredak → opcioni cloud konflikt i potvrda.
8. Slobodno istraživanje zadataka, treninga, dnevnika, kolekcije i izgleda.

## Pravila interakcije

- Slova su stabilna tokom dodira; jedan krug najviše jednom; povratak uklanja poslednje slovo; puštanje potvrđuje. `pointercancel` otkazuje.
- Veliki ciljevi za slova; poruka iznad table ostaje vidljiva. Udarac se prikazuje gore, ne preko slova.
- Za svaku grešku dati razlog i sledeći korak. Odbijena reč nije kazna resursima.
- Pauzirati pri gubitku fokusa aplikacije u budućoj igri. Atlas pokazuje ovaj tok, ali nema pravi borbeni sat.
- Opasnost ima tekst/simbol uz boju. Pristupačnost predviđa veći tekst, kontrast, mirniju animaciju i unos tapkanjem.
- Upozoriti pre gubitka napretka ili trajne grane; ne izmišljati uspešno čuvanje. Konflikt traži pregled obe verzije.
- Telefon je uspravan kao dizajnerska hipoteza; finalni safe-area, skrolovanje i tastatura zahtevaju uređaj.

## Predloženi obim prvog prototipa

Prvo testirati uputstvo, jednu borbu, njena stanja validacije i energije, pauzu, pobedu/poraz i brz novi pokušaj. Jedan izbor nadogradnje tek nakon potvrde unosa. Sve ostalo služi viziji celog proizvoda i ne predstavlja nalog za implementaciju.

Kolekcija, oblasti i radionica su proširenja. Zadaci, kozmetika, cloud i dodatni izazovi su opcioni. PvP, chat, prijatelji, klanovi, reklamno oživljavanje, prodavnica stvarnim novcem, kupovine i pretplate nisu uključeni jer nisu dogovoreni. Ako se usvoje, zahtevaju zaseban dizajn mečeva, moderacije, mrežnih prekida i kupovine/povraćaja; postojeći atlas ne tvrdi da te sisteme pokriva.

## Sledeće odluke

1. Pregledati borbu, bazu i mapu; potvrditi ili odbaciti vizuelni pravac.
2. Potvrditi jezik/pismo, engine i tempo borbe.
3. Proći osnovni tok i odabrati minimum za prvi igrivi test.
4. Proveriti čitljivost na stvarnom telefonu, pa tek onda ulagati u finalne likove, animacije i produkcioni rečnik.

Ne donositi odluku o modelu monetizacije na osnovu demonstracionog materijala ili valute u mockupu.
