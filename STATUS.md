# Trenutno stanje

Ažurirano: 2026-09-17. **Aktivna grana: codex/campaign-options-dialog-polish.**

## Aktuelno — Android 0.1.5

Završeno svih pet dorada posle korisnikovog testa 0.1.4:

- Staza sa nivoima prati prst u kampanji i glatko prelazi u novo poglavlje; pozadina miruje. Strelice koriste isti prelaz. Kratak pokret i zaključana granica vraćaju stazu na mesto.
- Veći prikaz izabranog protivnika desno, iznad informativnog panela, bez prekrivanja brojeva ili Prepare dugmeta. Izbor menja sliku, naziv i borbu.
- Četiri velika dugmeta sa ikonama u rasporedu 2 × 2: zvučnik, nota, telefon sa vibracijom i kornjača za Reduced Motion. Jasno ON/OFF stanje; kratki naziv opcije u donjoj traci nakon promene.
- Pobeda ima krunu/lovor, ukrašeni okvir, velike zvezdice, izdvojenu nagradu i najdužu reč.
- Pauza ima grb, ime protivnika i tri pokazatelja sa ikonama: broj reči, zdravlje, trajanje.
- Oba borca vidljivije dišu i njišu se oko stopala, bez lebdenja. Reduced Motion uklanja klizanje i njihanje.

Pravila, balans, rečnici, efekti, muzika i napredak ostaju kompatibilni. Povezivanje slova → Bilo koja i dalje odmah menja pravilo postojeće borbe. Master dizajni i stari mokupovi nisu menjani.

## Provere i paket

- Godot 4.7.2 import/test/export; **290 automatskih provera, 0 grešaka** u završnom build-u.
- Pravi renderi 16:9 i širokog telefona; srpski i engleski, uključene/isključene opcije, kampanja usred prevlačenja, pauza, pobeda i završetak kampanje. Snimci: docs/screenshots/0.1.5/.
- Instalacija preko 0.1.4 čuva kompletan glavni save. Završni UPGRADE QA PASSED potvrđuje instalirani SHA256 i istu nastavljenu borbu/rečnik/pravilo.
- ANDROID PAGING QA PASSED: pomeranje tokom držanog dodira, smirivanje, povratak na identičan prikaz, izbor nivoa pored velike ilustracije i pokretanje baš te misije. Privremeni glavni save vraćen; runtime log bez grešaka.
- ANDROID QA PASSED: prava odigrana pobeda, nagrada i otključavanje, kupovina unapređenja, nastavak pauzirane borbe, trajnost četiri nove ON/OFF komande i nezavisnih jezika, prihvatanje srpske reči i ponovno pokretanje bez engine/script grešaka.
- Paket com.sinisamedic.warofwords, **0.1.5 / code 6**, isti debug sertifikat kao ranije. **86.662.480 bajtova**.
- SHA256: **179e9fb4ddea16d2fcc8030787896b487dd5a0aa8843ea917064836212a38459**.
- Detalji: docs/QA-0.1.5.md. Cilj izdanja: v0.1.5-android-preview. Ishod Git push-a i objave proverava se posle tih operacija; ovaj zapis ih ne pretpostavlja unapred.

Devet originalnih vektorskih ikonica/ukrasa može se ponovo napraviti sa node tools/build-polish-ui.cjs. Poreklo u game/assets/ui/README.md. Novi Git fajlovi su pojedinačno ispod 10 MiB. APK i lokalni testni podaci su ignorisani.

## Tačan sledeći korak

Instalirati **0.1.5 preko postojeće aplikacije**, bez deinstaliranja ili brisanja podataka. Na S23 Ultra proveriti osećaj klizanja kampanje, prikaz protivnika i izbor nivoa, jasnost ikonica ON/OFF, pobedu/pauzu i jačinu idle animacije. Kornjača ON znači manje animacija; za nove animacije treba da bude OFF.

Fizički telefon, baterija i dugotrajan FPS nisu mereni. Srpski i generator ostaju za korisnički test. Nema novih odluka o monetizaciji niti iOS isporuke.

## Nastavak na drugom računaru

Pročitati AGENTS.md i ovaj fajl, sačuvati eventualni lokalni rad i proveriti remote/upstream, zatim:

```powershell
git fetch origin --prune
git switch codex/campaign-options-dialog-polish
git pull --ff-only
```

Ako grana nije lokalna: git switch --track origin/codex/campaign-options-dialog-polish. Projekat je game/project.godot. docs/setup.md i docs/android.md opisuju alate. Potpisni ključ i instalacije nisu u Git-u; main još nije aktivna grana igre.

## Istorija

- codex/shields-defeat-ready-effects, 1d5edb6, v0.1.4-android-preview: štit, uzemljenje protivnika, smer čuvara, sjaj moći i animacije poraza.
- codex/impact-enemies-music, 210e1a2, v0.1.3-android-preview: šteta pri udaru, 12 protivnika, muzika, mapa/dnevnik i odmah primenjivo slobodno povezivanje.
- codex/ornate-ui-combat-effects, bac0e4b, v0.1.2-android-preview: ukrašeni UI, efekti i početno slobodno povezivanje.
- codex/battle-polish-serbian, a499b75, v0.1.1-android-preview: srpski rečnik i borba.
- codex/android-playable, 0942094, v0.1.0-android-preview: prva igriva Android verzija.
- design/: šest usvojenih statičnih dizajna. V3 mokup/ i mockups/ sačuvani.
