# Predlog: naslovna sa tri režima i Beskraj reči

Datum: 2026-09-19. **Samo vizuelni koncept, nije odobren za implementaciju.**

Korisnik je završio svih 24 nivoa brzo i lako, uz različitu opremu, unapređenja i susedno povezivanje. Primetio je da bi predložena arena sa beskonačnim protivnicima suviše ličila na kampanju. Traži prvo dizajn i pregled nove naslovne, pre menjanja igre.

- `01-home.png`: tri ravnopravna ulaza — Kampanja, Beskraj reči, Dnevni izazov. Manji logo, ilustracija po režimu, odvojeni status i akcija. Arsenal/Unapređenja su označeni kao kampanjski alati. Rekordi/Rečnik su samo predlozi navigacije, ne nove implementirane funkcije.
- `02-endless.png`: dominira tabla 7×4 sa susednom rečju MOST. Bez borbenog protivnika, zdravlja i oružja. Predloženi bodovi, lični rekord, niz reči i vremenska rezerva koja se dopunjava rečima. Tajmer, multiplikator, pomoć i bodovanje tek treba dogovoriti; moguća je i varijanta bez vremenskog pritiska.

Svi rezultati/brojevi su ilustrativni. Mali plus uz novčiće u generisanoj naslovnoj nije odluka o prodavnici ili monetizaciji; ne prenositi ga u implementaciju bez dogovora. Tekst/slova i tačni razmaci su konceptualni, finalni UI bi koristio stvarne lokalizovane kontrole.

Poreklo: originalne OpenAI ImageGen makete, važe primenljivi OpenAI uslovi; bez spoljnog stock/franšiznog sadržaja. Reference su naši prethodni Godot snimci naslovne i borbe. Originali: `exec-85ef5516-a17e-45c0-9379-96ca2cea104f.png` i `exec-cc6fcdeb-35f6-4248-8cc4-302c20369393.png`. Sačuvano bez izmene rastera. Tačni promptovi u `prompts.json`.

Kod igre, balans, online servis i APK nisu menjani. Sledeći korak je korisnička povratna informacija o izgledu naslovne i karakteru beskonačnog režima.
