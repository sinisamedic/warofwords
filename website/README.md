# War of Words — statički sajt

Engleski promotivni sajt za `https://gottaplay.net/wow/`. Čist HTML/CSS/JS: nema npm instalacije, build servera, CDN-a, baze, analitike ni kolačića. Pripremljen 2026-09-20 za lokalni pregled. **Nije objavljen i još nije spreman za prijavu Google-u dok se ne zatvore stavke ispod.**

## Prenos

1. Preneti ceo folder `wow/` u javni koren postojećeg sajta, tako da `wow/index.html` odgovara `/wow/`.
2. Sačuvati strukturu `assets/`, `privacy/`, `support/`, `delete-data/`, `terms/`. Uključiti standardni directory index i HTTPS; `/wow` treba preusmeriti na `/wow/` da relativne putanje rade. Nisu potrebna posebna SPA pravila.
3. `root-files/app-ads.txt.template` je **neaktivan obrazac**, ne gotova verifikaciona datoteka. Preimenovati tek nakon unosa stvarnog AdMob zapisa. Ako na domenu već postoji `app-ads.txt`, dopuniti ga bez uklanjanja postojećih redova. Konačna lokacija: `/app-ads.txt`, van `/wow/`.
4. Ne prenositi ovaj README, izveštaje ni pomoćne skripte na javni hosting. Ne menjati postojeće browser igre. Glavni sajt kasnije treba dopuniti linkom ka WoW i precizirati postojeću oznaku „Web-only“.

## Linkovi i kontakti

`wow/site-config.js` sadrži budući Google Play URL i tri profila (Instagram, TikTok, YouTube). Prazni profili su vidljivo „Coming soon“ i nisu lažni klikabilni linkovi. Kada pravi URL bude upisan, kartica automatski postaje link. Ne navoditi izmišljene korisničke profile.

Izdavač je **GottaPlay**, po potvrdi korisnika. `hello@gottaplay.net` i `privacy@gottaplay.net` preuzeti su sa postojećeg sajta, ali vlasnik još nije proverio da rade. Dok je `contactsVerified: false`, kontakt je označen kao nepotvrđen i nema aktivnog mailto linka. Posle stvarne provere podesiti `contactsVerified: true`; to uklanja samo obaveštenje o kontaktu, ne ostale otvorene uslove.

Pri objavi Google Play linka ažurirati i pre-release tekst, FAQ, meta description i datum politike. Jedno polje konfiguracije nije automatska potvrda da je izdanje objavljeno ili da su uslovi rešeni.

## Obavezno dovršiti pre javnog izdanja / Google pregleda

- Potvrditi Google Play nalog, finalni store listing i identitet izdavača; ime GottaPlay ili War of Words mora se poklapati sa politikom privatnosti. Prikazivanje trgovačkog naziva ne rešava obaveze javnih identifikacionih podataka u Console.
- Stvarno testirati prijem na obe email adrese i zameniti ako je potrebno. Podsetnik u ovom zadatku obuhvata to i verifikaciju naloga.
- Potvrditi hosting/email provajdere i rokove pristupnih logova, podrške i bekapa. Dogovoriti rokove zadržavanja i realizovati server proces brisanja. Nema izmišljene tvrdnje „brišemo za 30 dana“.
- Online igra koristi anonimni Supabase Auth profil, pa proveriti primenljivost zahteva za brisanje naloga. Sajt sadrži javnu putanju za zahtev, ali ona postaje operativna tek sa potvrđenim kontaktom, proverom vlasništva i procesom brisanja. Aplikacija trenutno nema in-app kontrolu brisanja; dodati je ako je potrebna. Nickname nije jedinstven, ne koristiti ga kao jedini dokaz vlasništva.
- U aplikaciju dodati dostupne linkove privatnosti/podrške/brisanja. Dostupna web stranica sama ne zamenjuje in-app zahteve.
- Popuniti Google Play Data safety prema stvarnoj release verziji, Supabase toku i svim SDK-ovima; ne kopirati marketinški opis kao deklaraciju.
- Potvrditi ciljane starosne grupe i rating. Ne proglašavati igru dečjom ili 13+ bez dogovora. Ako cilj uključuje decu, proveriti Families zahteve i odobrene oglase.
- Ako se uključi AdMob: proveriti Godot Android integraciju, podatke SDK-a, regionalne saglasnosti/UMP, opciju kasnije promene privacy izbora, nagrađivanje tek nakon potvrde SDK-a i ponašanje bez oglasa. Promeniti politiku privatnosti **pre** distribucije takvog APK/AAB-a. Trenutna politika tačno opisuje verziju bez reklamnog SDK-a, ne predstavlja gotovu AdMob politiku za buduću integraciju.
- Uneti pravi AdMob publisher zapis, proveriti HTTP 200 i javni pristup `/app-ads.txt`, dodati `https://gottaplay.net/wow/` kao developer website u Play listingu i završiti AdMob verifikaciju/pregled.
- Pri prenosu proveriti da postojeći hosting/template ne ubacuje analitiku, reklame ili tracking skripte. Ako ih ubacuje, dopuniti politiku i saglasnosti; isporučeni folder ih nema.
- Ukloniti pre-release obaveštenja tek nakon stvarnog završetka navedenih poslova. Nijedna stranica ne garantuje odobravanje Google-a.

## Provera i lokalni pregled

Iz korena repozitorijuma: `python -m http.server 8765 --bind 127.0.0.1 --directory website`, zatim `http://127.0.0.1:8765/wow/`. Relativne putanje rade pri prenosu u `/wow/`. Sve javne stranice su stvarni HTML, dostupne bez prijave, čak i bez JavaScripta.

Stranica poštuje `prefers-reduced-motion`; vidljivo dugme Pause motion uklonjeno je na zahtev korisnika; sistemska postavka reduced motion i dalje isključuje animacije. Slike se otvaraju u tastaturom dostupnom dijalogu (Escape zatvara), a FAQ koristi native details. Nema automatskog audio/video sadržaja ni eksternih iframe-ova. U ovom izdanju su korišćene animacije i stvarni Godot screenshotovi, bez izmišljenog gameplay videa.

## Izvori i licence

`tools/prepare-website-assets.py` pravi optimizovane WebP kopije projektnih ilustracija i već postojećih in-engine rendera. Originalne ilustracije i promptovi: `game/assets/art/README.md`, `game/assets/art/endless/README.md` i `game/assets/launcher/README.md`. Napravljene za ovaj projekat pomoću OpenAI ImageGen; ne predstavljaju fotografije ili materijal treće strane.

Screenshotovi: `.local/manual-rank-final/battle-en.png`, `home-en.png` (Godot `render_endless.gd`), `.local/wave-two-qa/arsenal-ember-en.png` (`render_wave_two.gd`). Stvarni engine prikaz sa kontrolisanim preview stanjem, ne tvrdnja o rezultatu stvarnog igrača. Originalni screenshotovi su lokalni QA artefakti; njihove optimizovane isporučene kopije su verzionisane u `wow/assets/`.

Cinzel i Lora su lokalne kopije postojećih projektnih fontova; obe SIL OFL licence su u `wow/assets/`. Tačne upstream revizije u `game/assets/fonts/README.md`. Ne uklanjati licence pri prenosu.

## Proverene smernice (2026-09-20)

- Google Play User Data: https://support.google.com/googleplay/android-developer/answer/10144311?hl=en
- Account deletion: https://support.google.com/googleplay/android-developer/answer/13327111?hl=en
- app-ads.txt: https://support.google.com/admob/answer/9363762?hl=en
- AdMob app verification: https://support.google.com/admob/answer/14538460?hl=en
- UMP: https://support.google.com/admob/answer/10113209?hl=en

Ovo su implementirane web stranice i priprema za objavu, ne pravna potvrda niti potvrda usklađenosti buduće aplikacije. Otvorene tačke proizlaze iz stvarno nepotvrđenih naloga, kontakata i neimplementiranih funkcija, ne iz dodatnog toka odobravanja sajta.

## Dorade brenda — 2026-09-20

GottaPlay logo dostavio je vlasnik sajta u ovoj konverzaciji. `assets/gottaplay-logo.png` je neizmenjena originalna datoteka; CSS filter prikazuje zlatnu verziju bez promene oblika. Nema tvrdnje da je logo stock ili AI-generisan. `assets/frame-gold.svg` je neizmenjeni projektni SVG iz `game/assets/ui/`, prikazan tehnikom nine-slice na oba glavna dugmeta. Vlasnik je zatražio najavu da uskoro planira nove jezike; konkretni jezici i datumi nisu obećani.
