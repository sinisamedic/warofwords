# War of Words — dizajn igre

Ažurirano: 2026-09-17. Radni naziv. Poslednja eksplicitna korisnička odluka ima prednost.

## Novi smer — dnevni izazov i globalna rang-lista, 2026-09-17

Korisnik je nakon funkcionalnog prikaza zatražio da završni ekran dnevnog izazova i rang-lista budu vizuelno usklađeni sa usvojenim ekranima: ukrašeni okviri, postojeća tipografija i dugmad. Trenutni prikaz je funkcionalni prototip, nije usvojen završni dizajn. Najpre je zatražio osposobljavanje Android build okruženja.

Korisnik je usvojio početak online nadogradnje na besplatnom servisu: prvo profil/nadimak, dnevni izazov i globalna rang-lista, potom razmatranje izazivanja prijatelja i duela uživo. Ima pripremljen Supabase projekat. Ova odluka proširuje prethodni offline smer; kampanja protiv računara ostaje.

Prva implementacija koristi izdvojen izazov od 120 s, četiri kategorije (rečnik × povezivanje), jedan pokušaj po anonimnom profilu/kategoriji/danu po UTC-u, proveru poteza na serveru i offline vežbu. Bodovanje `10 × pločice + 5 × max(0, pločice − 4)` i generator dopune su **probni implementacioni izbori**, ne konačan turnirski balans. Multiplayer, monetizacija i trajni nalozi nisu ovim implementirani. Detalji i stvarna ograničenja: [daily-online.md](daily-online.md).

## 0.1.6 — kampanja, dopuna i animacije

- Popravljen izbor nivoa: držanje prsta preko više iscrtavanja više ne uklanja dodirnu oblast. Novi regresioni test zadržava dodir preko osam frejmova, uz poseban test zaključanog nivoa.
- Korisnik je zatražio zasebne pozadine za tri lokacije kampanje. Generisane su Sunward Ruins, Sky Bridges i Observatory; promena poglavlja koristi 0,55 s pretapanja sa blagim pomeranjem. Brojevi zadržavaju svoje klizanje. Reduced Motion preskače prelaz.
- Dopuna pokušava da uklopi do tri poznate, još neiskorišćene reči koristeći samo potrošena polja i nepromenjena preostala slova. Rad je ograničen; slučajna dopuna vodi računa o samoglasnicima. Puni rečnici i postojeće pravilo osvežavanja prazne table ostaju.
- Prva artikulisana 2D animacija heroja ima devet delova i zasebne zglobove glave, tela, ruku i kaputa: mirovanje, pucanje i udarac. Stopala miruju, pauza zaustavlja animaciju, Reduced Motion vraća neutralnu pozu.
- Posle komentara da smrt izgleda kao okretanje slike, poraz heroja koristi zaseban pokret tela, glave, ruku i kaputa, savijanje kolena kroz teksturisanu mrežu i oslanjanje šaka na tlo. Prašina prati spuštanje; nestajanje počinje tek posle pada. Protivnik se dezintegrira u energiju i fragmente bez obrtanja celog sprite-a. Prikaz traje 1,65 s pre rezultata; Reduced Motion ostaje blago postepeno nestajanje. Nagrada se i dalje beleži odmah i samo jednom.
- **Poslednja korisnikova korekcija: originalna nepodeljena ilustracija ostaje na naslovnoj, gde je lik velik. Novi animirani lik se koristi samo u borbi, za pregled.** Ne proširivati rig na protivnike pre povratne informacije.
- Posle pregleda uživo i dorade smrti korisnik je 2026-09-17 izričito zatražio novi APK. Finalni 0.1.6 build obuhvata ceo originalni lik na naslovnoj i nove animacije poraza. Provere i identitet paketa: `QA-0.1.6.md`.

## Usvojeno

- Mobilna igra u **landscape** položaju. Telefon je osnovni format; ne umanjivati desktop interfejs.
- Početni engleski interfejs i rečnik; posle testa 0.1.0 korisnik traži **odvojena podešavanja jezika interfejsa i rečnika, sa srpskim za test**.
- Borba protiv **računara**, bez ljudskog protivnika u ovom smeru.
- Kompozicija po korisnikovoj Slugterra referenci: duel i zdravlje gore, velika tabla slova dole, napunjene sposobnosti nadohvat prstiju.
- Slova u krugovima; više mogućih reči na tabli.
- **Podrazumevano se povezuju susedna slova, uključujući dijagonale.** Posle testa 0.1.1 korisnik je usvojio i podesivo slobodno povezivanje udaljenih slova.
- **Korišćena slova nestaju i dopunjavaju se novim.** Prethodna V2 hipoteza pet reči po istoj tabli je odbačena.
- **Oružja i sposobnosti umesto sakupljivih bića.**
- **Slova imaju tipove/boje i pune odgovarajuća oružja/sposobnosti.** Nije usvojeno punjenje unapred izabranog oružja niti zajednički energetski bazen.
- Vedriji stil, privlačan i odraslima. Znanje reči treba da doprinosi pobedi.
- V3 je u novom folderu **V3 mokup**. Sačuvati prethodni `mockups/` kao V2.
- Za sada samo najvažniji ekrani: meniji, borba, power-upovi i unapređenja. Ne širiti atlas na sve moguće situacije.
- Korisnik ima Samsung S23 Ultra, ali želi standardan mobilni prikaz, ne ekskluzivni raspored za taj model.
- Korisnik je usvojio šest dizajna i dao slobodu za kompletnu igrivu Android verziju. **Godot 4.7.2**, aktivni projekat `game/`. Ranije ograničenje na statični dizajn više ne važi.

## Aktivna implementacija — 0.1.5

Ovo su sprovedene odluke za prvi test, izabrane u okviru korisnikove dozvole da samostalno rešimo detalje. Predstavljaju početni balans, ne trajno zaključavanje ekonomije ili rečnika.

- Originalni Sunward Ruins svet, odrasla istraživačica i 12 različitih protivnika. 2D, svetla pozadina i kontrastne komande. Šest osnovnih ekrana + pomoć, pauza, pobeda/poraz, opcije i dnevnik reči.
- Tabla 7 × 4, polja približno 59 logičkih piksela, dodirna oblast 60 × 60 i razmak centara 65, minimalna osnova 854 × 480 (16:9) sa proširenjem širine na širim telefonima. Reči najmanje 3 slova, bez ponavljanja polja i bez iste reči u istom duelu. Dijagonale važe. Prevlačenje ili dodir + ✓; brzi pokreti prate i pređena polja između događaja dodira.
- Samo iskorišćena polja se dopunjavaju. Solver proverava mogućnosti; prazna tabla se automatski osvežava. Četiri ugrađene reči u redovima čine nove table pristupačnim, uz dodatne dijagonalne kombinacije. Hint otkriva putanju, ne šalje reč automatski.
- SCOWL 2020.12.07, američki engleski, 76.802 reči dužine 3–16, uključujući infleksije. [Poreklo i tačni filteri](../game/data/README.md). Nema definicija ni kurirane liste za uzrast.
- Svako polje puni svoju boju za 1; reči od 6+ daju 2 po polju. Napunjena sposobnost ne skladišti višak. Svaka reč dodatno nanosi `dužina + 2 × max(0, dužina − 4)` direktne štete.

| Sposobnost | Energija | Nivo 1 | Dobit po nivou |
| --- | --- | --- | --- |
| Pulse, zlatna | 4 | 24 štete | +8 |
| Aegis, plava | 5 | 20 zaštite od sledećeg napada | +5 |
| Arc, ljubičasta | 7 | 18 štete + prekida najavu napada | +6 štete |
| Mend, zelena | 5 | 24 lečenja | +6 |

- Svi počinju na nivou 1, najviše nivo 8. Unapređenje košta `100 + trenutni nivo × 60`; početak sa 180 novčića. Aegis započinje duel sa 3 energije da pomogne prvoj odbrani.
- 12 susreta, tri poglavlja, svaki četvrti boss. Svaki protivnik ima zaseban izgled i portret, uz rastuće statistike. Boss svaki treći udar dodaje 8 štete. Nema mrežnog matchmaking-a ni AI koji rešava isti rečnik.
- Igrač ima 100 HP. Za indeks misije m=0…11 protivnik ima `72+13m` HP, boss još 35. Napad `12+m`, razmak `max(8,14−0.42m)` sekundi, prvi napad +4 s. Poslednje 3 s se najavljuju. Arc vraća pun razmak +3 s; Aegis se troši pri jednom udaru.
- Izbor jednog power-upa pre borbe: Freeze 8 s, Fresh Board, Overcharge ×2 za sledeću reč. Jedna besplatna upotreba po duelu.
- Prva pobeda `120+20m` novčića; ponavljanje `40+5m`; poraz do 25, po 2 za pronađenu reč. Zvezdice prema preostalom zdravlju: 3 za ≥70, 2 za ≥35, inače 1. Otključava se sledeća misija.
- Lokalni save sa rezervnom kopijom, autosave borbe na 5 s i posle poteza, pauza pri gubitku fokusa. Continue Duel vraća i tablu i potrošeni power-up i počinje pauzirano. Poslednjih najviše 600 pronađenih jedinstvenih reči ulaze u dnevnik posle duela.
- Offline bez naloga, oglasa, kupovina ili monetizacije. Zvučni efekti su sintetisani; pozadinska muzika su dve licencirane CC0 orkestarske numere. Muzika, efekti, haptika i reduced motion imaju odvojena podešavanja.

## Dorade posle testa 0.1.2 — usvojeno 2026-09-17

- **Šteta se obračunava tek pri dolasku projektila, nakon 0,42 s leta.** Ovo važi za reči, Pulse, Arc i CPU. Energija se troši pri ispaljivanju; Arc odlaže naredni CPU napad pri udaru. Aegis proverava i troši štit pri udaru, pa se može aktivirati tokom leta protivničkog projektila. Lečenje ostaje trenutno.
- Napadi u letu čuvaju iznos štete i preostalo vreme. Pauza, meni i restart ih ne gube niti ponavljaju. Prvi smrtonosni projektil završava duel; ostali se otkazuju. Nagrada se upisuje samo jednom. Završni ekran čeka 1,35 s za pad/eksploziju poraženog lika.
- Jači trzaj samo pogođenog lika (Pulse/Arc do 25 logičkih piksela), nagib i smirivanje kroz 0,48 s. HUD miruje. Reduced Motion uklanja trzaj.
- Mapa i dnevnik podržavaju horizontalno prevlačenje od najmanje 50 logičkih piksela. Strelice ostaju dostupne. Prevlačenje ne otključava zaključana poglavlja.
- Centrirani naslovi ekrana. Dnevnik ima 4 kolone × 5 redova, 20 reči po strani, najviše 600 jedinstvenih reči iz završenih duela.
- Glavni lik podignut na platformu, vidljivija animacija disanja/ljuljanja. Dnevnik je mala ikona knjige pored Podešavanja. Veće ilustrovane ikone topa i zupčanika u Arsenalu/Unapređenjima prate odobreni dizajn.
- **Podešavanja → Povezivanje slova → Bilo koja** (English: **Options → Letter connection → Any letters**). Promena sada važi odmah i za sačuvanu borbu, uz očuvanje table, reči, energije i projektila. Svaku pločicu koristiš jednom; dodirima možeš birati bilo koja udaljena slova, pa ✓. Rečnik se i dalje bira za novu borbu, a započeta zadržava svoj.
- 12 originalnih tela i odgovarajućih portreta: mannequin, copper scout, stone guardian, bronze champion, avian watcher, crystal sentinel, iron guardian, storm knight, astral sentinel, archive keeper, sunforged elite i last warden. Siluete, materijali i oprema se razlikuju. Ostaju 2D likovi sa animacijom transformacije; nema skeletne animacije.
- **Music / Muzika** ima zaseban trajni prekidač. Joth: *Fantasy Orchestral Theme* (191,69 s) za menije; TAD: *Treasure Hunter* (65,07 s) za borbu. CC0 izvori i licence: `game/assets/music/README.md`. Postepeni prelazi, tiši miks u pauzi, zaustavljanje u pozadini. Efekti imaju nezavisan prekidač.
- Android 0.1.4 / code 5, isti paket i potpis za nadogradnju. Balans generatora i rečnik ostaju probni; monetizacija nije uvedena.

Sledeći odeljci beleže dorade po verzijama; odluke 0.1.5 imaju prednost nad starijim zapisima.

Sledeće odluke doneti na osnovu stvarnog testa telefona: tempo čitanja pod pritiskom, težina rečnika, dodatne animacije/različiti protivnici i dugoročna progresija. Monetizacija i iOS nisu deo verzije 0.1.0.

## Dorade posle fizičkog testa 0.1.0 — usvojeno 2026-09-16

- Manji health HUD sa portretima, zlatnim kapsulama i zelenim/crvenim gradijentom; likovi ostaju vidljivi. Arena zauzima 180 od 480 logičkih piksela visine.
- Uklonjen prazan naslov LINK A WORD. Reč se pokazuje samo tokom sastavljanja. × i ✓ postoje samo pri dodirivanju pojedinačnih slova; prevlačenje se potvrđuje puštanjem prsta.
- Ilustrovane kružne sposobnosti i power-upovi, segmenti energije oko kruga, emajlirane pločice sa jačim bojama i podebljanim slovima. Freeze i Hint imaju ikone, sa brojem preostalih upotreba za power-up.
- Options je dostupan iz glavnog menija i pauze. Zvuk, vibracija, manje animacija, jezik menija i rečnik su trajna nezavisna podešavanja.
- Srpski za test je latinica (implementacioni izbor): č/ć/š/đ/ž i LJ/NJ/DŽ na jednoj pločici. Najmanje 3 korišćene pločice; bonus i šteta broje pločice, ne Unicode znakove. Početna srpska reč je KAMEN.
- Srpski Hunspell/LibreOffice izvor pod MPL-2.0, 1.740.276 oblika od 3–12 slova srpske abecede. Izvor, tačna revizija, filtriranje i licence: game/data/README.md. Rečnik je probni pravopisni resurs, ne konačna turnirska lista.
- Promena rečnika važi za nove borbe. Sačuvana borba nosi svoj kod rečnika; borbe iz 0.1.0 podrazumevaju engleski. Novčići, misije i unapređenja ostaju zajednički.
- Verzija 0.1.1 / Android versionCode 2 koristi isti paket i potpis za nadogradnju 0.1.0. Monetizacija nije uvedena.

## Dorade posle fizičkog testa 0.1.1 — usvojeno 2026-09-17

- Zajednički ukrašeni zlatni/navy okviri dugmadi i panela na svim ekranima, ikone Arsenala, Unapređenja, podešavanja i dnevnika. Reljefan originalni naslov i novčić sa kompasom prate master dizajn.
- Donji borbeni deo je kameno okruženje sa bršljanom i tamnim pločama. Jedan ukrašeni panel na spoju arene i table prikazuje reč tokom sastavljanja, a inače poruku ili najavu napada. Tap potvrda ostaje uslovna.
- Noto Serif Bold za naslove i pločice umesto prethodnog fonta; Đ/đ i ostali srpski dijakritici ostaju stvarni Unicode znakovi u rečniku, prikazu i save-u. Svetleći spoj ima zlatni sjaj, svetlo jezgro i putujuće varnice.
- **Options → Letter connection → Adjacent / Free.** Srpski: **Podešavanja → Povezivanje slova → Susedna / Slobodno**. Slobodno dozvoljava bilo koji razmak između izabranih pločica, ali svaku samo jednom. Dodirima se može direktno preskočiti na udaljenu pločicu; prevlačenje bira pređene pločice i dopušta prelazak preko praznina. Povratak na prethodnu pločicu uklanja poslednju. Minimum, punjenje, bonus i rečnik ostaju isti.
- Implementacioni izbor: podešavanje važi za nove borbe, a započeta zadržava svoje pravilo. Stare borbe bez polja `adjacent_only` koriste susedna slova. Nije potrebno brisati napredak. Hint pretražuje i udaljena slova u slobodnom režimu; rad pretrage je ograničen na 18.000 čvorova / 180 predloga radi odziva, pa nije iscrpan spisak svih reči.
- Originalni slojeviti WAV efekti za ispaljivanje, let, udar, eksploziju, štit, električni napad, lečenje i Freeze. Zvuk udara i haptika okidaju se pri dolasku projektila (0,42 s), a ne ponovo u svakom frejmu. Logička šteta se i dalje obračunava odmah; završni ekran čeka 0,62 s da se vidi završni udar.
- Bljesak cevi, rep projektila, električne grane, udarni talas, varnice, udar u štit, aura lečenja/zamrzavanja i blag trzaj likova. Broj efekata je ograničen; HUD i dodirne oblasti ne podrhtavaju. Pauza zaustavlja let i odložene efekte. Reduced Motion uklanja trzaje, varnice i pulsiranje, a zadržava mirniju povratnu informaciju. Sound OFF odmah prekida aktivne glasove; haptika ima nezavisno podešavanje.
- Android 0.1.2 / code 3, isti identitet paketa i potpis. Balans, monetizacija i tema nisu dodatno zaključani.

## Dorade posle fizičkog testa 0.1.3 — usvojeno 2026-09-17

- PLAY je uže i centrirano nad karticama Arsenala/Unapređenja; veći naslov i zasebna strelica. Širina je ograničena i na širokim telefonima.
- Aegis je providno plavo energetsko polje sa dvostrukim rubom, šestougaonim ćelijama, amblemom i pokretnim odsjajima. Aktivacija i blokirani udar naglašavaju celo polje.
- Stopala svih 12 protivnika poravnata su prema stvarnim neprovidnim pikselima atlasa sa linijom tla, uz kontaktnu senku. Disanje menja visinu tela, ali ne podiže stopala. Bridge Guardian i njegov portret okrenuti su ka igraču.
- Smrtonosni udar pokreće eksploziju energije, fragmente, prašinu i pad poraženog lika. Rezultat dolazi posle 1,35 s. Važi i za heroja i za protivnike. Nagrada ostaje upisana odmah i samo jednom, tako da prekid aplikacije ne može da je izgubi ili duplira. Preostali projektili se uklanjaju.
- Završetak prekida tekući dodir na tabli; privremeno blokira komande tokom animacije, pa Retry/Next ostaju dostupni i ako je igrač držao prst u trenutku poraza.
- Napunjene moći imaju obojeni oreol, rotirajuće zrake i odsjaje; prelazak na punu energiju daje kratak šireći prsten. Trošenje energije uklanja taj sjaj. Reduced Motion zadržava miran oreol/štit i postepeno nestajanje poraženog lika, bez padanja, rotacije i letećih fragmenata.
- Android 0.1.4 / code 5, isti paket i potpis. Pravila, ekonomija i balans nisu menjani.

## Dorade posle testa 0.1.4 — usvojeno 2026-09-17

- Kampanja zadržava pozadinu. Staza sa četiri nivoa prati horizontalni pokret prsta, pa klizi do sledećeg poglavlja za 0,32 s. Kratak potez vraća sadržaj na mesto; granice i zaključana poglavlja blago pružaju otpor. Strelice koriste isti prelaz. Tokom završnog klizanja ne mogu se slučajno aktivirati stari brojevi.
- Brojevi su u zasebnoj oblasti levo; izabrani protivnik je veća originalna ilustracija desno, sa oreolom i stopalima koja prelaze preko gornje ivice informativnog panela. Ne prekriva dodirne oblasti nivoa ni Prepare. Slika, ime i borba odgovaraju istom izboru.
- Četiri leve opcije su velike pločice 2 × 2: zvučnik, nota, telefon sa vibracijom i kornjača za Reduced Motion. Stanje ON/OFF je eksplicitno; isključeno ima prigušenu ikonu. Kratak naziv opcije se pojavi u donjoj traci nakon promene. Jezici i pravilo povezivanja ostaju odvojeni.
- Pobeda dobija krunu, lovor, filigranski okvir, velike zvezdice sa jasno prikazanim neosvojenim mestima, izdvojenu nagradu i statistiku. Pauza dobija svoj grb, ime protivnika, ikonice za broj reči, zdravlje i trajanje, i poruku da je napredak sačuvan. Komande i nagrade zadržavaju svoje funkcije.
- Vidljivije disanje i njihanje oba borca u mirovanju: promena visine oko 2,7–3,2% i nagib oko 1,5°. Transformacije se oslanjaju na stopala, pa nema vertikalnog lebdenja. Reduced Motion uklanja njihanje i klizanje, uz očuvanje svih izbora.
- Android 0.1.5 / code 6, isti potpis i identitet paketa. Balans, rečnici i ekonomija nisu menjani.

## Istorija: usvojeni statični vizuelni dizajn

Šest PNG mastera i galerija nalaze se u [design/](../design/README.md). [Specifikacija](../design/DESIGN-SPEC.md) opisuje komponente, mobilne dimenzije i stanja za buduću Godot izradu. To su usklađene slike menija, kampanje, arsenala, power-upova, unapređenja i borbe. Bez simulacije. Tema, izgled i vrednosti su predlozi za pregled; nisu automatski usvojeni time što su nacrtani.

## V3 — prethodni interaktivni predlog

[Mockup i uputstvo](../V3%20mokup/README.md), [istraživanje reference](../V3%20mokup/RESEARCH.md).

Šest glavnih ekrana: glavni meni, kampanja, arsenal, power-upovi, unapređenja i borba. Pomoć, pauza i rezultat su prozori preko borbe. UI je engleski. Katalog za dizajnere ne zauzima prostor u igri.

### Tabla i reči — predlog detalja

- 28 polja, mreža 7 × 4, minimum 44 CSS px po polju. Broj treba potvrditi na telefonu.
- Najmanje tri slova. Jedno polje jednom u reči. Povratak preko prethodnog polja skraćuje putanju.
- Prevlačenje i puštanje potvrđuju reč; pojedinačni dodiri pa ✓ su alternativa. OS prekid dodira otkazuje putanju.
- Mešanje boja unutar reči dozvoljeno je; tip svakog iskorišćenog polja puni svoju sposobnost. Uz boju se prikazuje simbol.
- Jedno slovo daje jednu energiju svog tipa; reči od 6+ slova daju dve po polju. To je predlog bonusa i nije konačan balans.
- Mockup menja samo korišćena polja, bez fizičkog padanja kolona. Konačnu animaciju i pravilo padanja treba rešiti u prototipu.
- Mala autorska lista reči je lokalna. Dopuna je demonstraciona i ne garantuje kvalitet tabli. Produkcioni rečnik/generator nisu implementirani.

### Borba — probne vrednosti

| Sposobnost | Tip slova | Cena | Osnovni efekat |
| --- | --- | --- | --- |
| Pulse | zlato / ϟ | 6 | direktna šteta 24 |
| Aegis | plavo / ◇ | 6 | zaštita 18 od narednog udarca |
| Arc | ljubičasto / ⌁ | 8 | šteta 16 i odlaganje protivnika 5 s |
| Mend | zeleno / + | 6 | lečenje 20 |

Nivoi dodaju po 2 efekta. Početna četiri nivoa su 3, 2, 2, 1. Igrač i protivnik imaju po 100 zdravlja. CPU napada na 10 s za 18 štete i najavljuje poslednje 3 s. Nema AI sastavljanja reči. Početni štit je napunjen radi probe, ostale sposobnosti delimično napunjene.

Tri predložena power-upa: zaustavljanje protivnika 8 s, mešanje table, dupliranje energije sledeće reči. Izabere se jedan i koristi jednom po susretu. Upotreba nije monetizovana.

Mockup počinje sa 480 novčića, unapređenje košta 180, pobeda daje 120. Stanje traje do reload-a. Kampanja i otključavanje su ilustrativni; nema stvarnog snimanja.

### Izgled

Ponovo se koristi prethodno generisana originalna arena Sunward Ruins. Nema novih ImageGen poziva. Tema, glavni lik, protivnik i imena sposobnosti i dalje su predlozi. SVG ikone i interfejs su originalni. Slugterra snimci su istraživačka referenca, nisu materijal igre.

## Ranije otvorene odluke (istorija pre autorizacije implementacije)

1. Pregledati šest statičnih dizajna u design/, potvrditi izgled i mobilnu čitljivost, pa dimenzije komandi i broj polja.
2. Potvrditi tempo duela, pravilo bonusa i punjenja, tipove sposobnosti i power-upove.
3. Posle usvajanja dizajna i odobrenja implementacije pripremiti komponente za Godot, zatim najmanji pravi igrivi susret.
4. Izabrati licenciran engleski rečnik: US/UK, morfologija, vlastita imena, kratice i retke reči.
5. Razviti generator sa garantovanim izborom reči i testirati težinu za odrasle.
6. Potvrditi temu, ekonomiju, napredovanje i eventualnu monetizaciju. Ništa od toga nije zaključano.

## Istorija

V2 atlas od 86 ekrana ostaje u [mockups/](../mockups/README.md). Njegovo slobodno povezivanje, zajednička energija i pet reči po tabli više nisu aktuelna pravila. V1 portrait/srpski/sedam slova nalazi se u istoriji (40c1588). Stariji PLAN.md i GODOT-SETUP.md su istorija istraživanja, ne aktivne odluke.
