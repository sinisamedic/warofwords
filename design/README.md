# War of Words — šest statičnih dizajna ekrana

**Aktuelni rezultat je vizuelni dizajn, ne simulacija.** Otvoriti `index.html` za galeriju ili pojedinačni PNG u `screens/`. Slike se mogu otvoriti u bilo kom pregledniku fotografija, bez JavaScript-a, servera ili engine-a.

| Ekran | Fajl |
| --- | --- |
| 01 Glavni meni | [01-main-menu.png](screens/01-main-menu.png) |
| 02 Kampanja | [02-campaign.png](screens/02-campaign.png) |
| 03 Arsenal | [03-arsenal.png](screens/03-arsenal.png) |
| 04 Power-upovi | [04-power-ups.png](screens/04-power-ups.png) |
| 05 Unapređenja | [05-upgrades.png](screens/05-upgrades.png) |
| 06 Borba | [06-battle.png](screens/06-battle.png) |

## Sadržaj paketa

- Šest zasebnih, vizuelno usklađenih landscape PNG dizajna, 2:1.
- Statična HTML galerija bez skripti, simulacije, tajmera i aktivnih komandi igre.
- [DESIGN-SPEC.md](DESIGN-SPEC.md): hijerarhija, mobilne dimenzije, komponente, stanja i smernice za buduću izradu u Godotu.
- [PROVENANCE.md](PROVENANCE.md) i [prompts.json](prompts.json): poreklo i tačni promptovi.

## Kako čitati dizajn

PNG slike su vizuelni predlog izgleda završnih ekrana. Naslikana dugmad nisu interaktivna. Brojevi ilustruju konkretno stanje igre. Tema Sunward Ruins, protagonisti, nazivi sposobnosti, ekonomija i 28 polja još čekaju potvrdu.

Potvrđena pravila ostaju: telefon u landscape položaju, engleski, računar kao protivnik, susedna slova sa dijagonalama, dopuna iskorišćenih slova, boje/tipovi pune odgovarajuća oružja i sposobnosti. Ciljni engine za kasniju izradu je Godot prema poslednjem zahtevu korisnika; **u ovom koraku se igra ne implementira**.

## Za kasniju izradu

Ovo su spljošteni raster masteri ekrana, ne slojeviti Figma/PSD dokumenti ni gotovi sprite atlas-i. Ne ubacivati ceo PNG kao funkcionalni UI u Godot. Posle usvajanja dizajna odvojeno pripremiti pozadine, likove, ikone, okvire i fontove; tekst, brojke, zdravlje i stanja moraju ostati pravi UI elementi. Specifikacija razdvaja te slojeve i navodi nameravana ponašanja bez pisanja koda igre.

Prethodni V2 (`mockups/`) i V3 (`V3 mokup/`) sačuvani su bez izmena. Galerija je pregled projekta, nije sedmi ekran igre.
