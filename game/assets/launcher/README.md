# War of Words launcher icon — 0.1.11

Korisnik je 2026-09-18 izabrao prvi predlog — ivory/zlatno slovo W na plavoj pozadini — uz smanjenje slova radi kružnih prikaza. `icon-main.png` je neizmenjen rezultat ugrađenog OpenAI ImageGen alata posle te korekcije; izvorna varijanta ostaje u `design/icon-proposals/`. Tačan prompt, referenca i izvorni identifikator: [prompt.json](prompt.json).

Android resursi:

- `icon-main.png`: puni master, koristi se kao klasična i projektna ikonica.
- `icon-foreground.png`: mehanički pripremljen adaptive format, master veličine 288×288 u centru providnog platna 432×432. Originalni PNG ostaje netaknut. To odgovara prikazu od 72 dp sa overscan prostorom unutar 108 dp.
- `icon-background.svg`: jednobojna tamnoplava pozadina adaptive sloja.

Obnova platformskog formata: `godot --headless --path game --script ../tools/build-launcher-icons.gd`. Godot export sam pravi varijante za manje Android gustine. [Zvanična dokumentacija za launcher ikone i bezbednu zonu](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html#providing-launcher-icons).

Originalna AI ilustracija za ovaj projekat podleže primenljivim OpenAI uslovima; ne tvrdi se posebna stock licenca. Svaki izvorni fajl je ispod 10 MiB. Smanjenje slova je vizuelno, približno zadatom predlogu, a konačno kadriranje proverava se u Android launcheru.
