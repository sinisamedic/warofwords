# Dizajn ekrana — landscape revizija 02

Datum: 2026-09-16. Aktivni atlas: [mockups/index.html](../mockups/index.html). Usvojene odluke: [game-design.md](game-design.md).

## Razlog revizije

Korisnik je dostavio screenshot koji jasno pokazuje horizontalnu arenu iznad velike slagalice. Potvrdio je engleski za prvu verziju, solo protivnika kojim upravlja računar, mnogo slova sa više mogućih reči i vedriji izgled pogodan i za odrasle. Prva portrait verzija sa sedam slova i simpatičnim bićima ne odgovara tom smeru i zamenjena je.

## Kompozicija borbe

Artboard 1024 × 576, landscape 16:9:

- Gore oko 40% visine: odrasli igrač levo, mehanički računarski protivnik desno, odvojene trake zdravlja, centralna pauza, čitljiva najava napada.
- Dole oko 60%: centralna mreža 7 × 5 sa 35 krugova; energija i tri sposobnosti levo; trenutna reč, povratna informacija i komande uz tablu.
- Igrački tekst je na engleskom. Oznaka **COMPUTER** jasno razlikuje tip protivnika.
- Arena je jedna koncept ilustracija; zdravlje, slova, putanja, brojevi i dugmad su pravi nezavisni UI elementi.
- Poslednji red table mora u celosti biti vidljiv. Borba nema skrol; duži pomoćni meniji mogu imati skrol panela.

Broj krugova, povezivanje nesusednih slova i trajanje table kroz pet reči su predlozi, ne eksplicitno usvojena pravila. Na uskim uređajima prvo proveriti fizičku veličinu krugova i čitljivost; umanjeni atlas nije dokaz dobrog mobilnog UX-a.

## Vizuelni ton

Svetloplava, kamen/pesak, topla zlatna i ljubičasti akcent protivnika. Tamna boja se koristi za tekst i kontrast, umesto velike tamnozelene površine. Odrasla istraživačica i modularna oprema daju avanturistički ton. Tema nije zaključana; ona konkretizuje novi raspored za pregled.

Za odrasliju publiku ne oslanjati se samo na drugačiju grafiku: izazovi traže više različitih reči i duže reči; energija i najava protivnika daju razlog da se bira između kratke reči odmah i duže reči uz rizik. Nema usvojene tvrdnje o balansu dok se ne testira sa stvarnim ljudima.

## 86 ekrana i stanja

| Grupa | Obuhvat |
| --- | --- |
| First launch | Naslov, engleski jezik/rečnik, lokalni profil, prolog, tri lekcije |
| Expedition | Baza, horizontalna mapa, atlas oblasti, uslov otključavanja, briefing, loadout, priča |
| Combat | Osnovna arena, povezivanje, prihvaćena/nevažeća/prekratka/ponovljena reč, energija, najava CPU-a, tri sposobnosti, tabla, zdravlje, boss, pauza, napuštanje |
| Results & progression | Pobeda/poraz, analiza, nagrada, modul, izbor i dve potvrde grana, završetak oblasti |
| Loadout & workshop | Kolekcija, tri odvojena detalja modula, zaključano/prazno stanje, unapređenja, materijali, ranac, završna stanja grana |
| Optional activities | Trajni zadaci, trening i rezultat, dnevnik, dossier protivnika, vokabularski izazov, kozmetika |
| Settings | Audio, pristupačnost, engleska pravila, predlog reči, profil, pomoć, prijava problema, poreklo, brisanje profila |
| Recovery | Povratak iz pozadine, prekinut dodir, učitavanje, paket, offline, konflikt i potvrda save-a, greška čuvanja, oporavak borbe, rotacija **u landscape** |

Sve definicije, razlozi i izlazne veze su u `mockups/screens.js`. Broj uključuje modale i različita stanja istog osnovnog ekrana. Prethodnih 84 identifikatora je očuvano radi postojećih direktnih linkova; dodati su `ability-strike` i `ability-disrupt`.

## Osam tokova

1. Prva ekspedicija: engleski → profil → uvod → povezivanje → energija → čitanje protivnika.
2. Osnovna petlja: baza → mapa → briefing → sposobnosti → reč → napad → pobeda → nagrada.
3. Poraz: upozorenje → kritično zdravlje → savet → nova taktika → ponovni pokušaj.
4. Otkriće: boss → nagrada → novi modul → grana nadogradnje.
5. Reč: unos → različiti razlozi odbijanja → opcioni predlog za pregled.
6. Prekid: dodir/aplikacija → pauza → bezbedan nastavak.
7. Napredak: čuvanje → greška → lokalni/offline → opcioni konflikt.
8. Slobodno istraživanje: ciljevi, trening, dnevnik, moduli i izgled.

## Primeri stvarne interakcije u atlasu

Povezivanje/tapkanje slova, validacija prema maloj engleskoj listi, nagrada po dužini, zabrana ponovne nagrade, mešanje, nova tabla, trošenje energije, CPU napad, štit, prekid sa oporavkom, pobeda/poraz i pauza. Sve ostalo je ilustrativni tok bez trajnog čuvanja ili servisa.

## Sledeći pregled

Početi od `#battle`, uključiti **Start computer demo**, probati STONE, BRIDGE, STREAM i STREAMLINE, pogledati `#encounter`, `#home` i Atlas. Zatim potvrditi broj slova, pravilo susedstva i način dopune/zamene. Engine i produkcioni rečnik dolaze nakon tog dogovora.
