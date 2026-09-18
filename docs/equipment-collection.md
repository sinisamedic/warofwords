# Predlog kolekcije opreme — War of Words

Datum: 2026-09-18. **Prvi talas je usvojen i implementiran u 0.1.10:** Ogledalo, Pečat, Obnova, Pečat leksikona i Rezervna ćelija. Tačna aktivna pravila i skaliranje: [dizajn igre](game-design.md). Ostatak pune kolekcije ispod je budući predlog. Osnova predloga je bila verzija 0.1.9.

## 1. Šta igrač bira

Predlog pune kolekcije: **16 aktivnih uređaja i šest pasivnih artefakata**, ukupno 22 predmeta. Posle prvog talasa postoji osam aktivnih uređaja (Pulse, Breach, Aegis, Mirror, Arc, Seal, Mend i Bloom) i dva artefakta (Lexicon Seal i Reserve Cell). Preostaje osam uređaja i četiri artefakta kao predlog. Tabele ispod čuvaju izvorni predlog iz 0.1.9; za implementirane predmete merodavna su pravila u [game-design.md](game-design.md).

Za duel se oprema po jedan uređaj svake boje i jedan artefakt:

| Mesto | Izbor u kolekciji | Uloga |
| --- | --- | --- |
| Zlatno | 4 oružja | Direktna šteta, proboj, sagorevanje ili nagrada za dugu reč |
| Plavo | 4 odbrambena uređaja | Pouzdan štit, odbijanje, duža zaštita ili tempirana kontra |
| Ljubičasto | 4 taktička uređaja | Prekid, zabrana lečenja, zamrzavanje ili slabljenje napada |
| Zeleno | 4 uređaja podrške | Trenutno, postepeno, napadačko ili unapred pripremljeno lečenje |
| Artefakt | 1 od 6 | Pasivno menja stil igre; nema dodatno dugme u borbi |

Ostaju četiri velika borbena dugmeta i postojeći izbor jednog power-upa pre duela. Svaka pločica i dalje puni svoju boju. Široka kolekcija nastaje izborom alternativa u Arsenalu. Predmeti treba da podstaknu pitanje: **„Koju reč tražim i zašto čuvam ovu sposobnost?”**

Sve vrednosti u narednim tabelama odnose se na nivo unapređenja 1. To su polazne vrednosti za simulaciju i probu na telefonu, bez tvrdnje da je balans već potvrđen.

## 2. Zlatna oružja — kako nanosim štetu

| EN / SR | Energija | Dejstvo | Razlog za izbor i ograničenje |
| --- | --- | --- | --- |
| **Pulse / Puls** — postojeće | 4 | 24 štete jednim projektilom. | Pouzdano i često pucanje; nema posebno dejstvo na oklop. |
| **Breach / Proboj** — postojeće | 4 | 18 štete; pri udaru razbija oklop pre obračuna štete. | Otvara oklopljenog protivnika za sve kasnije napade; protiv nezaštićenog cilja Puls udara jače. |
| **Ember / Žar** — novo | 5 | 12 štete na udaru i po 6 nakon 2, 4 i 6 sekundi: ukupno 30. | Sagorevanje zaobilazi oklop, početni udar podleže oklopu. Oklop ostaje za druge napade. Spor završetak daje protivniku priliku da napadne ili se izleči. Ponovni pogodak osvežava jedno sagorevanje, bez slaganja više istih efekata. |
| **Resonator / Rezonator** — novo | 6 | Koristi poslednju potvrđenu reč: `18 + 5 × min(max(pločice − 3, 0), 6)` štete. Reč od 3 daje 18, od 6 daje 33, od 9+ daje 48. | Igrač čuva punjenje dok ne pronađe dugu reč. Kratka reč pre pucanja zamenjuje prethodnu i smanjuje udar. Bez potvrđene reči daje osnovnih 18. |

**Izgled:** Puls ostaje mesingani top sa svetlim jezgrom; Proboj ima oštar kristalni vrh i segmentisanu cev; Žar ima keramičke prstenove i vidljiv žar u komori; Rezonator izgleda kao zvučna viljuška oko kristala, sa lebdećim runama. Rezonator prikazuje očekivanu štetu u kratkom detalju pri selekciji/aktivaciji; ne dodavati trajni red sitnih brojeva u borbu.

## 3. Plava odbrana — kako preživljavam

| EN / SR | Energija | Dejstvo | Razlog za izbor i ograničenje |
| --- | --- | --- | --- |
| **Aegis / Egida** — postojeće | 5 | Upija do 20 štete sledećeg pogotka. | Sigurna priprema odbrane, naročito pred snažan udar; ostatak tog štita nestaje posle pogotka. |
| **Mirror / Ogledalo** — novo | 6 | Upija do 14 štete sledećeg pogotka; vraća projektil sa polovinom stvarno upijene štete, zaokruženo nadole. | Deo odbrane pretvara u napad. Slabije upijanje i veća cena od Egide. Odbijeni projektil ima svoj let i podleže protivničkom oklopu. |
| **Bastion / Bastion** — novo | 7 | Zajedničkih 24 zaštite za najviše dva sledeća pogotka. | Dobar protiv niza umerenih napada; drugi pogodak dobija samo preostalu zaštitu. Više energije i slabiji odnos zaštite prema ceni od Egide. |
| **Counterguard / Kontraštit** — novo | 4 | Štit od 12 traje 4 sekunde. Ako u tom prozoru potpuno upije pogodak, vraća projektil za 10 štete. | Nagrada za čitanje najave napada. Delimičan blok nema kontru, a promašen vremenski prozor troši punjenje. |

**Izgled:** Egida je poznato plavo energetsko polje; Ogledalo ima kristalne plohe koje na udaru vraćaju snop; Bastion dve krupne oklopne ploče i dve jasne oznake pogodaka; Kontraštit kratko širi mehaničke latice. Aktivna plava odbrana ne može se slagati sa drugom plavom odbranom. Plavo mesto ostaje isto za celu borbu.

## 4. Ljubičasta taktika — kako utičem na protivnika

| EN / SR | Energija | Dejstvo | Razlog za izbor i ograničenje |
| --- | --- | --- | --- |
| **Arc / Luk** — postojeće | 7 | 18 štete, prekida najavljenu akciju i ponovo postavlja odbrojavanje po sadašnjem pravilu. | Univerzalan prekid, uključujući lečenje ako stigne pre njega; visoka cena. |
| **Seal / Pečat** — novo | 5 | Projektil za 8 štete obeležava protivnika. Njegovo naredno lečenje u roku od 20 sekundi ne uspeva i troši oznaku. | Jeftin odgovor iscelitelju koji može unapred da se pripremi. Ne zaustavlja običan napad; protiv drugih tipova ostaje slab projektil. |
| **Hourglass / Peščanik** — novo | 6 | Na dolasku talasa zaustavlja odbrojavanje protivnika na 5 sekundi; nema štete. | Kupuje vreme za traženje reči. Ne zaustavlja već ispaljene projektile, a ista najavljena akcija se nastavlja posle isteka. |
| **Gravity / Gravitacija** — novo | 5 | Projektil za 6 štete; dva sledeća protivnikova oštećujuća napada imaju 30% manju osnovnu štetu. | Pomaže protiv teških napadača. Lečenje ne troši oznaku i nije oslabljeno; ne pomera odbrojavanje. |

**Izgled:** Luk je zavojnica sa električnim granama; Pečat je kružni mehanički pečat čiji znak ostaje iznad neprijatelja; Peščanik ima lebdeći ljubičasti pesak; Gravitacija je giroskop koji na udaru pravi sabijeni prsten oko cilja.

Peščanik i postojeći Freeze dele stanje zamrzavanja: trajanja se ne sabiraju. Posle odmrzavanja Peščanik ne može ponovo da zamrzne protivnika dok se njegova naredna planirana akcija ne izvrši. Spremno punjenje ostaje sačuvano i dugme jasno pokazuje privremenu nedostupnost. Ovo je predlog zaštite od beskonačnog odlaganja, koji mora da se proveri zajedno sa svim postojećim prekidima.

## 5. Zelena podrška — kako se vraćam u borbu

| EN / SR | Energija | Dejstvo | Razlog za izbor i ograničenje |
| --- | --- | --- | --- |
| **Mend / Isceljenje** — postojeće | 5 | Odmah vraća 24 HP, do maksimuma. | Pouzdano kada je zdravlje nisko; višak lečenja se gubi. |
| **Bloom / Obnova** — novo | 5 | Odmah 6 HP, zatim još po 6 nakon 2, 4, 6 i 8 sekundi: ukupno 30. | Veći učinak ako se aktivira ranije. Sporo za spas od neposrednog jakog udarca. Novi cast osvežava jedan efekat, ne sabira regeneracije. |
| **Siphon / Crpljenje** — novo | 6 | Projektil za 20 štete. Pri pogotku leči polovinu stvarno oduzetog zdravlja protivnika, zaokruženo nadole. | Agresivna podrška koja završava oslabljene mete. Oklop smanjuje i štetu i lečenje; višak štete preko preostalog HP-a ne računa se. |
| **Lifeline / Životna rezerva** — novo | 6 | Unapred postavlja rezervu: kada posle pogotka ostane 1–30 HP, automatski vraća 20 i nestaje. | Može da se pripremi pri punom zdravlju dok igrač traži reči. Slabije i skuplje od Isceljenja; ne vraća mrtvog lika. Samo jedna aktivna rezerva. |

**Izgled:** Isceljenje zadržava svetleći zeleni injektor; Obnova je metalni lotos koji se polako otvara; Crpljenje ima dve povezane komore i povratni snop; Životna rezerva je ampula sa jasno vidljivim zelenim svetlom uz portret heroja. Oprema ostaje mehanička i fantastična, sa materijalima usklađenim sa usvojenim dizajnom.

## 6. Šest artefakata — jedan pasivni izbor

Artefakt se bira pre duela. U borbi se vidi mala ikona uz portret; njen dodir otvara kratak opis uz pauziranje. Nema petog dugmeta za aktivaciju.

| EN / SR | Dejstvo | Stil i izgled |
| --- | --- | --- |
| **Lexicon Seal / Pečat leksikona** | Svaka prihvaćena reč od 7+ pločica dodaje 4 štete svom običnom projektilu. | Za poznavaoce dugih reči; zlatni pečat sa urezanim slovima. |
| **Prism Lens / Prizmatično sočivo** | Reč koja koristi sve četiri boje, posle normalnog punjenja, dodaje 1 energiju najmanje popunjenom mestu prema odnosu trenutne energije i kapaciteta. Kod jednakosti redosled je zlatna, plava, ljubičasta, zelena. Ako je sve puno, bonus propada. | Podstiče izbor putanje i boja; kristalno sočivo sa četiri jasno odvojena segmenta. |
| **Reserve Cell / Rezervna ćelija** | Čuva najviše 2 jedinice viška za svaku boju odvojeno. Nakon aktivacije uređaja njegova sačuvana energija prelazi u to mesto i rezerva te boje se prazni. | Za igrača koji čuva punu moć za pravi trenutak; bakarna baterija sa četiri kapsule. Nema zajedničkog bazena energije. |
| **Warden Seal / Čuvarev pečat** | Prva aktivirana plava odbrana u duelu dobija još 8 zaštite. Kod Bastiona povećava zajednički fond; kod Kontraštita ne produžava vreme. | Lakši ulazak u težak susret; kameni bedž sa plavim jezgrom. |
| **Focus Gyro / Žiroskop fokusa** | Svaka reč od 6+ pločica smanjuje osnovnu štetu sledećeg još neispaljenog protivničkog napada za 2, najviše 6 ukupno. Bonus se troši pri ispaljivanju tog napada. Ne utiče na projektil u letu; ne troši se pri lečenju. | Odbrana kroz znanje reči; tri prstena koja se poravnavaju. |
| **Phoenix Emblem / Feniksov amblem** | Jednom u duelu, udar koji bi spustio HP na nulu ostavlja 1 HP i troši amblem. Nema daljeg perioda neranjivosti. | Poslednja prilika da se igrač spase drugim potezom; odraslo stilizovano metalno pero sa užarenim vrhom. Sledeći pogodak i dalje može biti smrtonosan. |

Svi artefakti su alternative u jednom mestu. Njihove koristi i učestalost moraju da se uporede u testu, naročito Feniks naspram bonusa koji rade kroz ceo duel.

## 7. Četiri primera kompleta

| Namera | Zlatno / plavo / ljubičasto / zeleno | Artefakt | Odluka tokom igre |
| --- | --- | --- | --- |
| Protiv oklopa | Proboj / Egida / Luk / Isceljenje | Rezervna ćelija | Prvo razbij oklop; sačuvaj Luk za opasan potez. |
| Duge reči | Rezonator / Bastion / Peščanik / Obnova | Pečat leksikona | Napravi bezbedan prozor za dugu reč, pa iskoristi jači hitac. |
| Protiv iscelitelja | Žar / Ogledalo / Pečat / Crpljenje | Prizmatično sočivo | Obeleži lečenje i održavaj pritisak dok puniš različite boje. |
| Tempirana odbrana | Puls / Kontraštit / Gravitacija / Životna rezerva | Feniksov amblem | Prati najavu udarca, unapred pripremi rezervu i odgovori kontrom. |

Ovo su primeri za test, bez obećanja da su najbolji kompleti. Pobeda mora ostati moguća sa početnom opremom i dobrim rečima. Novi protivnik ne sme da zahteva predmet koji se dobija tek njegovim porazom.

## 8. Otključavanje i unapređenja

- Predlog je jasno otključavanje kroz kampanju i podvige. Kartica zaključanog predmeta kaže tačan uslov i vodi na odgovarajući susret. Monetizacija ostaje otvorena odluka; ovaj predlog je ne određuje.
- Postojeći Proboj ostaje nagrada za četvrti susret. Predlog prvog talasa: Obnova za treći susret, Pečat za šesti, Ogledalo za osmi; Pečat leksikona za pobedu sa bar jednom rečju od sedam pločica, Rezervna ćelija za deseti susret.
- Postojeće zabeležene pobede automatski otključavaju odgovarajuće nagrade. Podvig sa rečju važi odmah samo ako save već pouzdano dokazuje da je ispunjen; u suprotnom radi se u sledećoj borbi. Ništa se ne zaključava igračima koji već imaju predmet.
- Preostali predmeti mogu se dobijati iz opcionih izazova na postojećim nivoima i kasnijih poglavlja. Tačna raspodela dolazi posle potvrde obima kampanje; 24–30 nivoa nije pretpostavka ovog predloga.
- Sve alternative iste boje dele postojećih osam nivoa unapređenja, kao Puls i Proboj. Igrač može odmah da isproba otključanu varijantu bez ponovnog ulaganja u isti tip mesta. Zadržati postojeće novčiće i cene dok test ne pokaže potrebu za izmenom.
- Skalirati štetu, lečenje i zaštitu u odnosu na nivo boje. Trajanje kontrole, procenat odbijanja i broj blokiranih pogodaka ne rastu automatski. Tačne krive novih uređaja ostaju zadatak balansa pre implementacije.
- Kasnija, opciona veština sa pojedinim predmetom može dati gravuru, novi izgled efekta ili značku za izazov. Statistički bonus i novi sistem retkosti nisu potrebni za prvi talas.

## 9. Kako izgleda Arsenal na telefonu

Četiri kartice boja i kartica artefakata. Unutar boje četiri velike kartice u mreži 2 × 2. Svaka ima prepoznatljivu ilustraciju, kratak naziv, cenu energije i oznaku opremljenog/zaključanog predmeta. Tap otvara veliki detalj: jedna rečenica dejstva, prednost, ograničenje i dugme Opremi.

U dnu detalja vidi se cela izabrana četvorka i artefakt, uz mogućnost kratkog pregleda opreme u pripremi duela. Predmet menja ikonu i efekat odgovarajućeg postojećeg borbenog dugmeta. Karakteristična cev/modul na ruci heroja je kasnija vizuelna dorada; ne traži se 16 novih celih likova.

Za nove ilustracije koristiti isti materijalni jezik: mesing i zlato, emajl u boji energije, kristali, slojeviti metalni detalji i snažna silueta čitljiva na telefonu. Boja ima i zaseban simbol. Statusi se prikazuju ikonicama sa kratkim indikatorom trajanja ili broja upotreba, bez gomilanja sitnog teksta preko table. Reduced Motion zadržava čitljivu promenu stanja.

## 10. Pravila koja sprečavaju nejasne kombinacije

- Sva dužina meri se brojem pločica, kao postojeće razbijanje oklopa. Srpsko LJ/NJ/DŽ na jednoj pločici broji se kao jedna. Iste pogodnosti važe u oba rečnika i oba režima povezivanja.
- Samo prihvaćena nova reč pokreće bonuse reči. Nevažeće reči, ponovljene reči, povratni projektili i naknadna sagorevanja ne daju energiju niti ponovo pokreću te bonuse.
- Rezonator pamti poslednju prihvaćenu reč do nove prihvaćene reči ili kraja borbe. Može se ponovo napuniti i koristiti; kratka nova reč svesno menja njegov potencijal.
- Početna plava energija ostaje 3; druge boje i sve rezerve počinju prazne. Kapacitet određuje opremljeni uređaj. Oružje, artefakt, rezervna energija, poslednja reč, trajanja i potrošene jednokratne moći deo su snimka duela.
- Šteta, prekid, zabrana lečenja i početak sagorevanja nastupaju na udaru. Gravitacija i Žiroskop menjaju buduće napade pri njihovom ispaljivanju. Za računanje: bonus teškog/boss napada, zatim Gravitacija (zaokruživanje nadole), zatim Žiroskop, uz minimum 1. Plava zaštita se proverava tek pri pogotku heroja.
- Posle štita obračunava se HP; Feniks, ako je opremljen i nepotrošen, može da ostavi 1 HP; zatim Životna rezerva može da leči živog heroja. Kombinacija Feniks + Rezerva je namerna moguća sinergija, ali ostaje samo jedna zaštita od smrti po duelu. Proveriti da nije previše jaka.
- Pauza zaustavlja sva trajanja. Nastavak vraća njihov preostali deo, bez novih punjenja i podviga. Smrt završava borbu jednom i otkazuje preostale projektile, tikove i lečenja. Životna rezerva i Crpljenje ne oživljavaju već poraženog lika.
- Nema slaganja identičnih statusa; osvežavanje ne ostavlja beskonačno više paralelnih tikova. UI pre trošenja jasno odbija aktivaciju nedostupne odbrane/rezerve ili kontrole pod privremenim ograničenjem.
- Rangirani dnevni izazov ostaje sa istim pravilima za sve: kampanjska oprema, nivoi i artefakti tamo ne daju bonuse. Predlog ne zahteva promenu dnevnog servera.

## 11. Redosled kojim bih pravio kolekciju

**Prvi talas — završen u 0.1.10: ukupno osam aktivnih uređaja i dva artefakta.** Zadržano je pet prvobitnih uređaja, dodati Ogledalo, Pečat i Obnova, uz Pečat leksikona i Rezervnu ćeliju. Svaka boja ima dve opcije. Dorade izgleda i otključavanja objavljene su zaključno sa 0.1.13.

**Drugi talas:** Žar, Rezonator, Bastion i Crpljenje, kada postojeći protivnici i težina budu isprobani na telefonu. Dodati i jasnije prikaze trajnih efekata.

**Treći talas:** Kontraštit, Peščanik, Gravitacija, Životna rezerva i preostala četiri artefakta. Oni traže najviše provere međusobnih uticaja, tajmera i spašavanja od smrti.

Četiri mesta + jedan artefakt, deljenje unapređenja po boji i obim prvog talasa već su potvrđeni i implementirani. Pre proširivanja kolekcije probati postojeće alternative na teškom napadaču, iscelitelju i oklopljenom protivniku, na početnom i visokom nivou unapređenja; oba rečnika, susedno/slobodno povezivanje, pauzu/nastavak, smanjene animacije i dodirni prostor na telefonu. Drugi/treći talas i njegovo otključavanje tek dogovoriti. Cilj je različit razlog za izbor svake varijante, uz očuvanu vrednost dobrog sastavljanja reči. [Aktuelni sledeći koraci](next-steps.md).
