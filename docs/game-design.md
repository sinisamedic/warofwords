# War of Words — dizajn igre

Ažurirano: 2026-09-16. Radni naziv. Poslednja eksplicitna korisnička odluka ima prednost.

## Usvojeno

- Mobilna igra u **landscape** položaju. Telefon je osnovni format; ne umanjivati desktop interfejs.
- Prva verzija: **engleski interfejs i engleski rečnik**.
- Borba protiv **računara**, bez ljudskog protivnika u ovom smeru.
- Kompozicija po korisnikovoj Slugterra referenci: duel i zdravlje gore, velika tabla slova dole, napunjene sposobnosti nadohvat prstiju.
- Slova u krugovima; više mogućih reči na tabli.
- **Povezuju se samo susedna slova, uključujući dijagonale.**
- **Korišćena slova nestaju i dopunjavaju se novim.** Prethodna V2 hipoteza pet reči po istoj tabli je odbačena.
- **Oružja i sposobnosti umesto sakupljivih bića.**
- **Slova imaju tipove/boje i pune odgovarajuća oružja/sposobnosti.** Nije usvojeno punjenje unapred izabranog oružja niti zajednički energetski bazen.
- Vedriji stil, privlačan i odraslima. Znanje reči treba da doprinosi pobedi.
- V3 je u novom folderu **V3 mokup**. Sačuvati prethodni `mockups/` kao V2.
- Za sada samo najvažniji ekrani: meniji, borba, power-upovi i unapređenja. Ne širiti atlas na sve moguće situacije.
- Korisnik ima Samsung S23 Ultra, ali želi standardan mobilni prikaz, ne ekskluzivni raspored za taj model.
- Engine **nije izabran**. Godot proba nije odluka. Ne započinjati veliku implementaciju pre potvrde smera, osnovne mehanike i engine-a.

## V3 — aktuelni predlog

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

## Otvorene odluke

1. Na telefonu potvrditi V3 kompoziciju, čitljivost, dodir i broj polja; naročito visinu arene prema tabli.
2. Potvrditi tempo duela, pravilo bonusa i punjenja, tipove sposobnosti i power-upove.
3. Izabrati engine, zatim napraviti najmanji pravi igrivi susret.
4. Izabrati licenciran engleski rečnik: US/UK, morfologija, vlastita imena, kratice i retke reči.
5. Razviti generator sa garantovanim izborom reči i testirati težinu za odrasle.
6. Potvrditi temu, ekonomiju, napredovanje i eventualnu monetizaciju. Ništa od toga nije zaključano.

## Istorija

V2 atlas od 86 ekrana ostaje u [mockups/](../mockups/README.md). Njegovo slobodno povezivanje, zajednička energija i pet reči po tabli više nisu aktuelna pravila. V1 portrait/srpski/sedam slova nalazi se u istoriji (40c1588). Stariji PLAN.md i GODOT-SETUP.md su istorija istraživanja, ne aktivne odluke.
