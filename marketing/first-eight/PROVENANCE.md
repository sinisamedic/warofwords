# Poreklo, vernost i reprodukcija

Paket za korisnički pregled. Nema objave, zakazivanja, novih naloga niti javnog hostinga.

## Izvori

- Izvor igre: `61ae882`, Godot 4.7.2, verzija projekta 0.1.22. Nova grana materijala: `codex/gottaplay-first-eight`.
- `source/board.png`, `stone-selected.png`, `stone-impact.png`, `home.png`, `settings.png`: novi direktni snimci Godot viewporta 1280×720. Generiše ih `source/capture.gd`. Gameplay u 01/02/06 je isti kratki stvarni potez prikazan sa različitim uredničkim naglaskom, ne tri različite partije.
- Gameplay: desktop Godot render Android projekta, automatski izveden legalan potez preko normalnih press/move/release funkcija. Nisu snimci fizičkog telefona, nisu reakcije igrača. Slova, HP, šteta i dopuna nisu prepravljani. Početna tabla je standardni tutorijal. Zaseban save u `.local/social-capture/`; online upis isključen. Nema rankinga ni slanja rezultata.
- `source/capture-evidence.json`: zabeležena tabla, boje, putanja, prihvaćena reč STONE, jedan potez, 72 → 65 HP. `source/verify-challenges.gd` proverava STONE i PLANET u stvarnom engleskom rečniku sa susednim povezivanjem.
- `game/assets/art/endless/mode-campaign.png`, `mode-endless.png`, `mode-daily.png`: postojeće originalne ImageGen ilustracije, prema `game/assets/art/endless/README.md` i `prompts.json`. U objavi 04 predstavljaju režime; nisu predstavljene kao snimci gameplay-a.
- `game/assets/art/hero-parts.png`: postojeći originalni ImageGen atlas. Poreklo i prompt: `game/assets/art/README.md`, `prompts-0.1.6.json`. Anatomija i animacija potvrđeni u `game/scripts/hero_rig.gd`.
- GottaPlay simboli: kopije `../WoW Website/brand/palette-b/gottaplay-symbol-light.png` i `gottaplay-symbol-dark.png`, u `source/symbol-light.png` i `symbol-dark.png`. Originalni znak dostavio vlasnik; paleta B i obrada odobrene, prema tamošnjem README-u i korisničkom zahtevu. Simbol nije precrtan. Natpis GottaPlay u ovim kompozicijama je Lato Bold; ne menja master logo.
- Paleta kompozicija: orange `#F27622`, navy `#202C46`, warm ivory `#F5F1E9`. Originalna zlatna/tirkizna grafika igre ostaje neizmenjena unutar snimaka.
- Fontovi Lato Bold i Lora iz projekta; SIL OFL. Izvori, revizije i SHA u `game/assets/fonts/README.md`, pune licence u `game/licenses/Lato-OFL.txt` i `Lora-OFL.txt`.
- Kompozicije, tekstovi i Python/GDScript alati: napravljeni za ovaj projekat. Nema novih stock fotografija, tuđih gameplay snimaka ili generisanih lažnih ekrana.
- Izvorne video-9x16.mp4 kopije su neme. Na zahtev korisnika dodate su video-9x16-audio.mp4 verzije sa CC0 muzikom i originalnim efektima igre; detaljno poreklo, postupak i ograničenja u AUDIO.md.

## Formati i uredničke granice

- PNG: 1080×1350, 4:5. MP4: 1080×1920, 9:16, H.264, yuv420p, 30 fps, faststart. JPG: naslovne slike 9:16.
- `preview.webm`: manje kopije za pregled, 540×960 / 15 fps / VP9. Za mreže koristiti MP4, ne ove kopije. Ugrađeni browser je padao i sa H.264 i sa VP9 ugrađenim plejerima, pa završna galerija prikazuje naslovne slike i linkove za preuzimanje. MP4 otvoriti u lokalnom video plejeru. Svih osam MP4 je potpuno dekodirano FFmpeg-om bez grešaka; reprodukcija u ugrađenom browseru nije potvrđena.
- Gameplay ostaje ceo u horizontalnom prozoru. Dodatni isečak je označen BOARD DETAIL ili HERO DETAIL. Zum nije novi ekran igre.
- Početna tri sekunda 01 su ilustracija; 06 su atlas. Sledećih devet sekundi su gameplay. 02 je devet sekundi istog neprekinutog poteza. 03/04/05/07/08 su mirne video-kartice.
- Snimanje koristi `--fixed-fps 30`; offline render može sporije da ispisuje PNG-ove, ali video sastavlja 30 uzastopnih simulacionih kadrova u sekundu. Ovo nije dokaz performansi Android telefona.
- Razvojni balans, šest jezika, tri režima i boje energije provereni u postojećem kodu. Ne tvrdi se multiplayer uživo, dostupan Google Play, datum izlaska, popularnost ili rezultat nekog igrača.
- Nema javnog website CTA. `gottaplay.net/wow/` ostaje planirana adresa i nije tretirana kao objavljena.
- Pojedinačne završne datoteke proveravaju se na prag 10 MiB pre Git staging-a. Sirovi PNG nizovi i FFmpeg instalacija ostaju u ignorisanom `.local/`, ne u Git-u.

## Reprodukcija

Iz korena repoa; izvršne putanje uzeti iz lokalne konfiguracije, ne menjati zajedničke fajlove:

1. Pokrenuti Godot sa `--path game --resolution 1280x720 --fixed-fps 30 --script res://../marketing/first-eight/source/capture.gd --log-file <apsolutna-putanja-u-.local>`.
2. Pokrenuti `source/verify-challenges.gd` istim Godotom sa `--headless --path game`.
3. Python sa Pillow i imageio-ffmpeg: `marketing/first-eight/source/build.py`. FFmpeg može biti instaliran u `.local/social-python`; koristi se kao lokalni alat, ne redistribuira se.
4. Pokrenuti `source/add-audio.py` za zvučne verzije. Otvoriti `index.html`, pregledati PNG i MP4. Dokumenti i galerija nastaju iz `posts.json`/izvora generatora. `SCREEN-TEXT.md` beleži tekstove i sekunde.

## Ograničenja zabeležena tokom snimanja

Godot je prijavio lokalni problem čitanja Windows certificate store-a i upisa podrazumevanog loga u sandbox-u. Snimanje i validacija reči završili su se izlazom 0; nema GDScript grešaka. Za ovaj offline snimak nije potreban mrežni servis. Ovo se ne opisuje kao engine log bez grešaka niti kao Android test.
