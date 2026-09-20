# Zvučne verzije za pregled — 2026-09-20

Korisnik je zatražio muziku i/ili efekte nakon objavljivanja prve neme verzije. Svih osam objava sada ima `video-9x16-audio.mp4`. To su nove lokalne verzije za pregled; nisu postavljene na mreže. `video-9x16.mp4` i `preview.webm` ostaju izvorne neme kopije. Evidencija javno objavljenih verzija ostaje u `PUBLISHED.md`.

## Muzika i prava

- 01, 02, 04, 05: **Treasure Hunter — TAD**, početak numere, [izvor i CC0 licenca](https://opengameart.org/content/treasure-hunter).
- 03, 06, 07, 08: **Fantasy Orchestral Theme — Joth**, od 25. sekunde, [izvor i CC0 licenca](https://opengameart.org/content/fantasy-orchestral-theme).
- Koriste se postojeći fajlovi `game/assets/music/`; izvorni podaci u njihovom README-u, lokalna licenca `game/licenses/music-CC0-1.0.txt`. Nema muzike preuzete sa tuđih društvenih objava. CC0 ne zahteva potpis autora, ali ga ovde čuvamo.
- Efekti su originalni proceduralni WAV fajlovi projekta, bez eksternih semplova: `game/assets/audio/README.md`, recept `tools/build-sound-effects.cjs`.

## Montaža

Muzika ima kratak ulaz i 0,65 s izlaz. Nema govora. Gameplay 01/02/06 dobija efekte iz igre: pet povezivanja slova sa rastućom visinom, prihvatanje reči, ispaljivanje, let i pogodak. Nema izmišljene pobede, rezultata ili reakcija.

Efekti su rekonstruisani iz stvarnih asseta igre prema scenariju snimanja `source/capture.gd`, a nisu originalna audio traka snimljene sesije. U gameplay vremenu: slova 1,5 / 2 / 2,5 / 3 / 3,5 s, ispaljivanje 4 s, pogodak 4,42 s (trajanje leta u igri 0,42 s). Objave 01/06 imaju uvod od 3 s. Sitno odstupanje do nekoliko kadrova moguće je zbog dodatnih screenshot čekanja u capture skripti. Statične video-kartice imaju samo muziku.

Video tok se kopira bez rekompresije i promene kadrova. Audio: AAC, 48 kHz, stereo, 192 kbps. Dvoprolazna normalizacija cilja −16 LUFS / −1,5 dBTP; konačna AAC merenja i identičnost video toka beleži `AUDIO-QA.json`. Potpuno dekodiranje svih osam zvučnih MP4 prolazi. Tehnička provera ne zamenjuje slušni pregled na telefonu; korisnik treba da presluša odnos muzike i efekata.

## Reprodukcija i korišćenje

Posle `source/build.py` pokrenuti `source/add-audio.py` pomoću Python-a sa imageio-ffmpeg. Skripta čuva izvorne neme fajlove i generiše zvučne MP4, `01-audio-preview.mp3` i izveštaj provera. Privremeni WAV miksovi ostaju u ignorisanom `.local/social-audio/`.

Za TikTok, Shorts i Instagram Reels koristiti novu `video-9x16-audio.mp4` verziju nakon pregleda. PNG karuseli nemaju ugrađen zvuk; zvučni MP4 je njihova video adaptacija. Nema automatskog dodavanja dodatne platformske muzike preko već urađenog miksa.

Već objavljene neme objave nisu izmenjene, obrisane niti duplirane. O eventualnoj ponovnoj objavi odlučuje korisnik nakon preslušavanja.
