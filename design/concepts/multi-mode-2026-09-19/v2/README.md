# Redizajn v2 — 2026-09-19

Tri statične ImageGen makete za korisnički pregled, bez implementacije ili APK-a. Prethodni predlog igre bez protivnika je zamenjen korisničkim smerom: borba kao u kampanji, sledeći protivnik nakon pobede, svaki peti protivnik boss, mogućnost promene pojačanja posle bossa.

- `01-home-v2.png`: razmaknute kartice tri režima, borbena ilustracija Beskraja, kompaktni Arsenal/Unapređenja/Rekordi. Rečnik nije u glavnoj navigaciji; budući pristup kroz podešavanja je predlog.
- `02-endless-battle-v2.png`: junak i protivnik, zdravlje, talasi, boss oznaka, tabla i četiri uređaja. Peščani sat predložen kao odbrojavanje do protivničkog napada, bez novog ukupnog vremenskog ograničenja.
- `03-after-boss-v2.png`: izbor ili zadržavanje pojačanja nakon petog talasa, pa nastavak na šesti. Brojevi i statične ilustracije su primeri; generator je u bodovima ponovio cifru 3, što ne treba prenositi u stvarni UI.

Korisnik zahteva animirane naslovne kartice pri kasnijoj implementaciji. Predlog: blago pomeranje likova i čestice Kampanje, kruženje portala Beskraja, proticanje peska Dnevnog izazova, diskretan sjaj pri dodiru. Odvojeni slojevi i stvarne UI kontrole; ne rastezati kompletne raster-makete. Reduced Motion mirno stanje. Animacije nisu prikazane u ovim PNG maketama.

Otvoreno: tačan izgled, uloga sata, balans talasa/bossova, prenos zdravlja/energije i obnavljanje potrošenog pojačanja, bodovanje i rangiranje. Nisu automatski usvojeni brojevi ni efekti prikazani na maketama.

Poreklo: originalne slike generisane ugrađenim OpenAI ImageGen alatom, prema sopstvenim prethodnim maketama i snimku igre; primenljivi OpenAI uslovi. Bez spoljnog stock sadržaja. Originali `exec-0e6eaa62-42da-43bb-a597-d158f19c80fb.png`, `exec-ac3a478c-0c98-47a8-b952-7c98f2142d32.png`, `exec-b14a5ce5-c738-4c66-a3cf-a54319595d66.png`, kopirani bez izmene. Tačni promptovi i reference: `prompts.json`.
