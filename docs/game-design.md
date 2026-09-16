# Dizajn igre — odluke i hipoteze

Aktuelno: 2026-09-16. Poslednja eksplicitna korisnička instrukcija ima prednost nad starim planom.

## Usvojeni zahtevi

- Originalna mobilna igra za Android i iOS.
- **Landscape format**, prema korisnikovom screenshot-u borbe. Gore su igrač i protivnik na suprotnim stranama, zdravlje i pauza; dole velika tabla sa mnogo slova za povezivanje.
- **Prva verzija na engleskom, sa engleskim rečnikom.** Jezik više nije otvorena odluka. Tačan izvor, verzija, licenca i pravila varijanti engleskog još nisu odabrani.
- **Solo borba protiv računarski kontrolisanog protivnika.** Nema živog protivnika / PvP-a u ovom smeru.
- Slova su u krugovima. Povezivanjem se sastavljaju postojeće reči. Od ponuđenih slova treba da postoji više mogućih reči.
- Prihvaćene reči daju resurse. Ručno aktivirani napadi/sposobnosti troše resurse.
- Igra treba da bude privlačna i odraslima. Širi vokabular i pronalaženje različitih/dužih reči treba da pomognu pobedi; vizuelni identitet ne sme izgledati kao igra samo za malu decu.
- **Vedriji i svetliji stil**; prethodna dominantna tamnozelena i detinjasti mali likovi nisu odgovarajući smer.
- Slugterra screenshot je referenca za raspored i osećaj borbe. Likovi, svet, nazivi i grafika ostaju originalni. Screenshot nije produkcioni materijal projekta.
- Prioritet su dodir, čitljiv ekran, zanimljive odluke i mali početni troškovi.
- **Engine nije izabran.** Godot tehnička proba nije odluka. Ne započinjati veliku implementaciju dok se ne potvrde osnovna pravila i engine.

## Mockup revizija 02

[Atlas](../mockups/README.md) ima 86 landscape ekrana/stanja i osam tokova. Svih 84 prethodnih prikaza je zamenjeno; dodata su dva odvojena detalja sposobnosti. Prethodna portrait revizija dostupna je u Git istoriji, commit `40c1588`, kao prevaziđen predlog.

**Vizuelni predlog:** Sunward Ruins, svetle kamene ruševine sa plavim nebom, odrasla istraživačica i mehanički Sentinel. Taktički moduli Strike, Guard i Disrupt zamenjuju simpatična bića. Tema, imena, protagonistkinja i konkretna umetnička obrada još nisu potvrđeni.

Jedna originalna arena generisana je ugrađenim ImageGen alatom; poreklo i prompt su u [dokumentaciji grafike](../mockups/assets/README.md). Interfejs, slova, putanje i statistike renderuju se odvojeno, kao pravi elementi mockupa.

## Predlog table — NIJE konačno usvojeno

- **35 krugova, mreža 7 × 5**. Korisnik je potvrdio mnogo slova, ali ne ovaj tačan broj. Proveriti dodirne zone na stvarnom telefonu.
- Za ovu reviziju svaki krug može da se spoji sa bilo kojim drugim; **ne traži se susedstvo**. Dva ista slova zahtevaju dva kruga. Pravilo susedstva/dijagonala ostaje za potvrdu.
- Povratak preko prethodnog kruga briše poslednje slovo. Puštanje posle prevlačenja potvrđuje. Tapkanje pa „Enter word“ je alternativa. OS prekid dodira otkazuje unos.
- Tabla ostaje kroz **pet različitih prihvaćenih reči**, zatim dobija novi raspored posle puštanja. Pet je probna vrednost; moguće su kasnije delimična dopuna ili zamena korišćenih slova.
- Mešanje je besplatno i čuva iskorišćene reči. Ručna zamena u atlasu nema cooldown; u igri treba rešiti ritam i cenu/zabranu zloupotrebe.
- Automatska promena ne sme da se desi usred dodira. Borbeni efekti ne pomeraju slova.
- Tabla mora da ima više ostvarivih engleskih reči različitih dužina. Mockup koristi dva rasporeda istih 35 slova, ne produkcioni generator.

## Engleski rečnik

Mockup ima **600 ručno upisanih demonstracionih engleskih zapisa**. Provera broja ponuđenih slova nalazi 584 ostvariva zapisa na svakoj demonstracionoj tabli; to nije mera kvaliteta, učestalosti ili izbalansiranosti rečnika. Primeri: STONE, CRAFT, PLANE, BRIDGE, STREAM, PLANET, STREAMLINE.

- Najmanje tri slova; jedan zapis daje energiju jednom po tabli. Duga reč nema veštačko ograničenje na sedam slova.
- Validacija je lokalna, bez mrežnog/AI sudije. Slova se normalizuju u velika engleska slova radi prikaza; tabela i lista određuju ostvarivost.
- Produkcioni engleski rečnik treba odabrati i licencirati pre distribucije. Demo lista nije obećanje da će svaka ispravna engleska reč biti prihvaćena.
- Otvoreno: US/UK varijante, fleksijski oblici, vlastita imena, skraćenice, vulgarizmi, retke reči, učestalost i težina po oblasti.
- Neprihvaćena reč treba da dobije jasan razlog bez oduzimanja zdravlja/energije. Predlog reči za pregled ne menja rezultat borbe.

## Predlog borbe i demonstracija

Mockup prikazuje široku arenu gore i gustu tablu dole, uz sposobnosti levo i povratnu informaciju o reči desno. CPU ne sastavlja reči; izvodi najavljene obrasce napada.

Probne vrednosti:

| Dužina reči | 3 | 4 | 5 | 6 | 7 | 8+ |
| --- | --- | --- | --- | --- | --- | --- |
| Energija | 3 | 5 | 8 | 12 | 17 | 22 |

- Kapacitet energije 30; bez prenosa između susreta.
- Strike: 6 energije, 14 štete. Guard: 5 energije, ublažava 8 od sledećeg pogotka. Disrupt: 10 energije, resetuje najavu, 15 sekundi oporavka.
- Demonstracioni CPU: 12 štete na približno 10 sekundi, jasna najava poslednje tri sekunde. Igrač počinje sa 100, obični protivnik sa 80 zdravlja.
- Dugme „Start computer demo“ pokreće simulaciju. Katalog stanja je podrazumevano pauziran radi pregleda. Pauza i odlazak stranice u pozadinu zaustavljaju CPU; nastavak čuva stanje.
- Trening isključuje CPU. Boss ekran prikazuje predlog faze; kompletan boss obrazac nije implementiran.
- Brojke, tempo i trajanje nisu balansirani. Ne tvrditi da ovaj HTML mockup predstavlja izabrani engine ili gotovu borbu na telefonu.

## Napredovanje — predlozi

Kampanja protiv računara, kratke oblasti, garantovane nagrade, module kolekcija i radionica. Taktičke grane menjaju odluke: jači štit ili povraćaj energije. Zadaci za raznovrsnost i dužinu reči, trening i dnevnik su kasnije opcije. Cloud, kozmetika i dodatni izazovi su opcioni i nepovezani sa stvarnim servisima.

Monetizacija nije usvojena. Nema kupovina, reklamnog oživljavanja, PvP-a ili obaveznih servera u ovom predlogu.

## Sledeće odluke

1. Potvrditi da nova landscape kompozicija odgovara screenshot-u i nameri korisnika.
2. Proveriti 7 × 5 krugova na telefonu: dodir, čitljivost, slobodno povezivanje naspram susednih slova.
3. Potvrditi šta se događa sa korišćenim slovima i koliko reči traje ista tabla.
4. Potvrditi tempo računarskih napada i ciljnu težinu vokabulara; tek potom konkretan balans.
5. Izabrati engine i produkcioni engleski rečnik. Tema može još ostati otvorena.

Stariji [PLAN.md](PLAN.md) čuva istraživanje reference, ali njegove portrait/7-slova/srpski hipoteze više nisu aktivna uputstva.
