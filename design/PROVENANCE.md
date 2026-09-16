# Poreklo vizuelnog dizajna

Datum: 2026-09-16. Alat: ugrađeni `image_gen.imagegen`, preko veštine `imagegen`. Nije korišćen API/CLI fallback, preuzete stock slike ili tuđi Slugterra materijali.

## Šest novih slika

| Fajl | Dimenzije | Bajtova |
| --- | --- | --- |
| screens/01-main-menu.png | 1774 × 887 | 3065250 |
| screens/02-campaign.png | 1774 × 887 | 3210976 |
| screens/03-arsenal.png | 1774 × 887 | 2828726 |
| screens/04-power-ups.png | 1774 × 887 | 2945711 |
| screens/05-upgrades.png | 1774 × 887 | 2798366 |
| screens/06-battle.png | 1774 × 887 | 2946979 |

Šest poziva za šest ekrana, bez odbačenih varijanti. Izlazi su kopirani neizmenjeni u repo; izvorne kopije alata nisu obrisane. Svaki fajl je manji od 10 MiB; oko 17 MiB ukupno. Za ovaj mali skup nisu uvedeni Git LFS obrasci; rast biblioteke produkcionih grafika zahtevaće novu procenu pre dodavanja velikih fajlova.

## Reference

- Za borbu: postojeća originalna slika `../mockups/assets/sunward-arena.png`, u ulozi reference sveta i likova. Njeno poreklo i raniji prompt: `../mockups/assets/README.md`.
- Za preostalih pet ekrana: novoizrađeni `screens/06-battle.png`, u ulozi reference vizuelnog identiteta i komponenata.
- Korisnikov Slugterra screenshot služi ranije usvojenom rasporedu duela/table; nije ugrađen niti preuzet u ove fajlove.

Tačan skup promptova nalazi se u [prompts.json](prompts.json). Tražena nominalna rezolucija 1920 × 960; stvarni izvoz alata je 1774 × 887. Nije rađeno naknadno skaliranje da bi se prikazala lažna viša rezolucija.

## Namena / autorski status

AI-generisani originalni vizuelni predlozi za ovaj projekat. Nije deklarisana posebna otvorena licenca niti ekskluzivnost. PNG masteri sadrže naslikan tekst i nisu paket fontova, odvojenih tekstura ili animacija. Za distribuciju igre pripremiti i dokumentovati stvarne produkcione resurse i njihove uslove korišćenja.
