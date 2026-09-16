# War of Words — atlas ekrana

**84 ekrana i stanja, osam tokova. Vizuelni predlog, nije usvojen dizajn niti implementirana igra.**

## Otvaranje

Otvoriti `index.html` dvoklikom u Chrome-u, Edge-u ili drugom savremenom browseru. Nisu potrebni instalacija, Node, engine, internet niti lokalni server. Fajlovi `index.html`, `style.css`, `screens.js` i `app.js` moraju ostati zajedno.

- **Istraži ekrane:** pretraživ katalog, interaktivni prikaz telefona, razlog postojanja ekrana i povezani ekrani.
- **Atlas:** svi mockupovi; naslov kartice otvara ekran u punoj veličini.
- **Tokovi:** osam povezanih korisničkih puteva.
- Strelice uz naslov prolaze kroz katalog. Deo posle `#` označava ekran, npr. `index.html#home`, `index.html#battle`, `index.html#map`.

![Pregled interaktivnog atlasa](preview.png)

## Šta probati

1. Otvoriti borbu. Povezati **M → O → S → T** prevlačenjem, pa pustiti. Alternativa: kliknuti slova redom i izabrati **Potvrdi**. Tastatura: Tab i Enter.
2. Reč dodaje 5 energije; **Udarac** troši 6 i oduzima 10 zdravlja protivniku. Štit troši 5; prekid 10. Sve brojke su probne.
3. Ista reč u istom skupu ne dodaje energiju. Posle tri različite prihvaćene reči dolazi novi skup. Mešanje čuva listu iskorišćenih reči.
4. U prevlačenju povratak preko prethodnog kruga briše poslednje slovo. Sistemski prekid dodira ne šalje reč. Escape briše unos.
5. Pauza i povratak iz nje čuvaju stanje otvorene demo borbe. Pojedinačni scenariji iz kataloga su nezavisni primeri.
6. U podešavanjima pristupačnosti uključiti veći tekst i jači kontrast. Pregledati i ekran odbijene reči, poraza i neuspešnog čuvanja.

## Granice mockupa

- Borbeni sat je zamrznut. Protivnik ne napada sam. Nema balansirane igre, stvarnog cooldown-a ni produkcionog rečnika.
- Prikazani rezultati, ekonomija, profil i nagrade su ilustrativni. Demo borba nije izvor podataka za sve ekrane rezultata.
- Nema trajnog čuvanja, naloga, cloud-a, analitike, slanja prijava ili kupovine. Osvežavanje stranice resetuje demo.
- Formulari prikazuju validaciju i sledeći korak. Izbor jezika ne prevodi ceo mockup. Kolekcija prikazuje šablon detalja Ljuske; sva tri odjeka još nemaju zasebne detaljne stranice.
- Duži ekrani namerno rastu radi pregleda sadržaja. U engine-u treba dogovoriti granice skrolovanja, safe-area i ponašanje softverske tastature na stvarnom uređaju.
- Vizuelni smer „Svet odjeka“, srpska latinica, nazivi i svi dodatni sistemi su **predlozi**. Engine nije odabran.

## Obuhvat i izvor materijala

Spisak svih ekrana, razlog, obim i izlazne veze su u `screens.js`; dokument [dizajn ekrana](../docs/screen-design.md) sažima principe i otvorene odluke.

SVG likovi, pejzaž i elementi interfejsa su originalno nacrtani kodom za ovaj projekat. Nema preuzetih fontova, slika, zvuka ili biblioteka. Koriste se sistemski fontovi. `preview.png` je snimak ovog lokalnog mockupa, napravljen 2026-09-16. Za ove materijale nije uvedena zasebna javna licenca; nisu tuđa licencirana grafika. Demo reči su mala ručno upisana lista, ne uvezeni rečnik.

## Provera

2026-09-16: Node provera sintakse; headless Edge otvaranje svih 84 ekrana na širinama 1440, 390 i 320 px; provera ciljnih ekrana; bez JavaScript grešaka i horizontalnog prelivanja stranice. Provereni unos MOST klikom i prevlačenjem, +5 energije, trošenje 6 za udarac i odbijanje ponovljene reči. Vizuelno pregledani borba, baza, pauza, atlas i uski prikaz. Ovo nije Android/iOS test. Lokalni snimci i testni skript su u ignorisanom `.local/mockup-review/` jer koriste putanju browser runtime-a ovog računara.
