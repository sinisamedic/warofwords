# War of Words — V3 mobilni mockup

Otvoriti **index.html** u browseru. Na telefonu okrenuti ekran vodoravno. Nisu potrebni server, paketi ili internet. Folder mora ostati uz `mockups/`, odakle koristi postojeću originalnu grafiku.

## Šest glavnih ekrana

- `index.html#home` — glavni meni.
- `index.html#map` — kampanja i izbor susreta protiv računara.
- `index.html#armory` — četiri oružja/sposobnosti.
- `index.html#powers` — izbor jednog power-upa.
- `index.html#workshop` — unapređenje izabrane sposobnosti.
- `index.html#battle` — borba; dodatni prozori: pomoć, pauza, pobeda i poraz.

## Kako probati

1. Play → Prepare → izabrati power-up → Battle.
2. Prevlačiti kroz **S–T–O–N–E** u prvom redu i pustiti. Može i pojedinačno tapkanje, pa dugme ✓. STONES je duža početna reč; PLANE postoji u trećem redu (od druge kolone).
3. Susedstvo uključuje dijagonale. Jedno polje može jednom po reči; vraćanje na prethodno poništava poslednji korak.
4. Zlato / ϟ puni Pulse, plavo / ◇ Aegis, ljubičasto / ⌁ Arc, zeleno / + Mend. Reči mogu mešati boje. Korišćena polja se odmah dopunjavaju.
5. Dodirnuti spremnu sposobnost. Aegis je na početku već spreman radi brze probe. Računar napada na 10 sekundi.
6. Power-up je ispod desne grupe sposobnosti. Jedna upotreba po borbi. Pauza zaustavlja vreme; odlazak na drugu karticu automatski pauzira.
7. Workshop: izbor sposobnosti preko simbola, pa Upgrade. Promena utiče na demo borbu. Nagrada za pobedu i potrošnja novčića postoje samo tokom otvorene sesije.

## Šta je potvrđeno

Landscape mobilna igra, engleski UI/rečnik, računar kao protivnik, susedna slova sa dijagonalama, dopuna iskorišćenih polja, oružja/sposobnosti umesto bića, tipovi/boje slova pune odgovarajuće sposobnosti. Vedriji izgled za publiku koja uključuje odrasle. Korisnikov telefon je Samsung S23 Ultra, ali dizajn nije ograničen na taj uređaj.

## Šta je predlog

28 slova (7 × 4), konkretna tema/grafika, četiri sposobnosti, nazivi, cene, zdravlje, tempo, 6+ slova daju dvostruku energiju, početno napunjeni štit, tri power-upa i njihovi efekti. Ovo su primeri za razgovor o dizajnu, ne usvojen balans.

## Mobilne dimenzije

Nema skaliranja desktop artboard-a, kataloga uz igru ili bočne web navigacije. Interfejs koristi stvarne CSS dimenzije: slova najmanje 44 × 44, komande najmanje 44 px, nazivi uglavnom 17–27 px. Tabla i arena dele visinu telefona. Bez skrola glavnih ekrana; duža pomoć može skrolovati unutar prozora. Uspravno se traži okretanje telefona. Za veoma male visine / browser trake raspored još treba proveriti na uređaju.

## Ispravka praznog plavog ekrana

Kod je izolovan u privatni opseg, a funkcija `top` preimenovana radi izbegavanja sudara sa browserom. Ako je V3 već otvoren, osvežiti stranicu sa Ctrl+Shift+R.

Regresiona provera pokretanja: `node "V3 mokup/tests/startup.cjs"` iz korena repozitorijuma. Izvršava ceo skript i proverava svih šest ekrana kroz DOM zamenu; ne proverava vizuelni raspored.

## Provere i granice

- Node sintaksa i izolovane provere stvarne logike prošle: 28 polja, susedstvo, dijagonale, povratak, zabrana ponavljanja polja, punjenje po tipu, bonus, zamena samo korišćenih polja, napadi, štit, lečenje, CPU, pauza, power-up jednom, nagrada jednom.
- To nisu DOM/pointer/end-to-end provere. Browser alat je blokirao otvaranje lokalnog file URL-a. **Vizuelna provera u browseru i na fizičkom telefonu nije završena.**
- Mali autorski engleski demo rečnik; validna reč koja nije u listi biće odbijena sa jasnom porukom. Nema produkcionog generatora garantovanih reči posle svake dopune.
- Nema trajnog snimanja, servera, naloga, kupovine, zvuka, napredne AI logike ili stvarne kampanje. Otključavanje narednih misija je ilustrativno. Engine nije izabran.
- Borbeni efekti su HTML/CSS ilustracija, nisu animirani game sprite-ovi.

## Poreklo i trošak materijala

Ponovo korišćena originalna slika `../mockups/assets/sunward-arena.png`. Poreklo i prethodni ImageGen prompt: [postojeća dokumentacija](../mockups/assets/README.md). Nisu generisane nove slike. SVG ikone oružja i CSS interfejs napisani su za V3. Nema preuzetih Slugterra materijala, eksternih fontova ili biblioteka. V2 fajlovi nisu menjani.

[Istraživanje reference](RESEARCH.md)
