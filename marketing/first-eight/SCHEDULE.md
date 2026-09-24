# Odobren raspored videa 02–08

Korisnik je 2026-09-20 izričito odobrio raspored ispod na sve tri mreže, sa zvukom i pripremljenim engleskim opisima. Izvršavanje preko Codex Scheduled zadatka u ovom razgovoru. Ovo nije tvrdnja da su video-fajlovi već uploadovani i zakazani unutar društvenih mreža.

Automatizacija kreirana i proverena: `gottaplay-objavi-videe-02-08`, „GottaPlay — objavi videe 02–08”, ACTIVE, thread `01a0bf34-8fc2-7aa3-9d48-2674ac548c78`. Raspored ističe 6. oktobra nakon poslednjeg termina. Automatizacija je podešavanje ove desktop aplikacije; sam Git push ne prenosi je automatski na drugi računar.

Korekcija 2026-09-22: prvi heartbeat stigao je u 19:02 UTC, odnosno 21:02 lokalno, iako je odobren termin 19:00 lokalno. U ovom izvršavanju scheduler je protumačio sat kao UTC. Postojeća automatizacija je ažurirana na 17:00 UTC, što odgovara 19:00 Europe/Belgrade za sve preostale datume kampanje; ACTIVE i novo pravilo provereni čitanjem sačuvanog podešavanja. Sledeći očekivani termin je 24. septembar 17:00 UTC / 19:00 lokalno. Tačan uzrok prvog kašnjenja nije zasebno potvrđen scheduler logom; naredno izvršavanje treba proveriti.

Provera 2026-09-24: heartbeat je stigao u 17:00:40 UTC / 19:00:40 lokalno; korekcija sata daje odobren početak rada u 19:00. Nije kreirana nova automatizacija.

| Datum 2026. | Vreme u Srbiji | Video |
|---|---|---|
| 22. septembar | 19:00 | 02 — Watch STONE become an attack. |
| 24. septembar | 19:00 | 03 — Find a five-letter word. |
| 26. septembar | 19:00 | 04 — What kind of word player are you? |
| 29. septembar | 19:00 | 05 — Read the colors, too. |
| 1. oktobar | 19:00 | 06 — This hero moves in pieces. |
| 3. oktobar | 19:00 | 07 — Can you find six? |
| 6. oktobar | 19:00 | 08 — Which language would you play in? |

Zona Europe/Belgrade, UTC+02:00 na svim navedenim datumima; jednaka lokalnoj Europe/Budapest. Vreme je početak rada, a upload i obrada mogu odložiti javno prikazivanje za nekoliko minuta. Računar i desktop aplikacija moraju raditi, lokalni projekat mora biti dostupan, a browser prijavljen na sva tri naloga. Zakazani zadatak ne garantuje objavu ako prijava, dozvole ili moderacija to blokiraju.

## Tačno odobren sadržaj

`SCHEDULE.json` sadrži po datumu tačnu putanju zvučnog MP4, SHA256 i konačne tekstove. Svi su video 9:16: Instagram Reel na @gotta.play_games, TikTok na @gottaplaygames i YouTube Short na @gottaplay_games (GottaPlay kanal UCtg24FFDgtn1NFuOtd8B9RA). Za izazove 03/07 koristi se postojeći opis video-verzije sa pauziranjem umesto teksta o prevlačenju karusela. Ne objavljivati PNG karusele umesto odobrenih videa.

## Izvršavanje i zaštita od duplikata

1. Pročitati AGENTS.md, STATUS.md, ovaj fajl, SCHEDULE.json i PUBLISHED.md. Proveriti lokalni datum/vreme i novije korisničke instrukcije. Objava 01 je već završena i ne ponavlja se.
2. Objaviti samo video predviđen za današnji datum, tek od 19:00. Ako je datum propušten, prijaviti ga korisniku; ne objavljivati propuštene videe u paketu niti menjati raspored bez dogovora. Posle 6. oktobra ne objavljivati nove videe.
3. Pre svakog uploada proveriti SHA256, tačan nalog, lokalnu evidenciju i postojeće objave/draftove na platformi. Ako ista objava već postoji ili je na moderaciji, ne praviti novu. Nastaviti postojeći upload/draft ako je jednoznačno identifikovan. Neizvestan ishod znači proveru, ne automatski ponovni klik Publish.
4. Zadržati originalni 9:16 i ugrađen zvuk, punu dužinu i odobrene opise. Ne dodavati drugu muziku. Instagram/TikTok AI oznake koristiti kao u objavi 01 za materijale koji sadrže AI ilustracije. TikTok označiti promociju sopstvenog brenda, Everyone; YouTube Public, opšta promotivna objava nije namenjena deci. Ne menjati bezbednosna/povezana podešavanja naloga. Ne rešavati CAPTCHA ili unositi nove kredencijale bez potrebnog korisničkog preuzimanja/potvrde.
5. Posle svake platforme upisati u SCHEDULE.json stvarni status, URL, vreme i eventualnu prepreku. U PUBLISHED.md zabeležiti dokaz uspeha iz UI. Razlikovati submitted/under_review od public. Ako jedna mreža ne radi, završiti ostale. Ne brisati prethodne objave u ovom zadatku.
6. Prijaviti na srpskom potvrđene linkove, neuspeh ili potreban korisnički korak. Ako nema novog ishoda ni promene, ne slati rutinske poruke. Sačuvati evidenciju pre prelaska na sledeću mrežu; Git sinhronizacija po AGENTS.md, ali neuspeh Git mreže nije dokaz neuspeha objave.
7. Posle poslednjeg termina završiti/isključiti ovu automatizaciju. Ne objavljivati išta van odobrenih sedam videa i 21 platformskog unosa.
