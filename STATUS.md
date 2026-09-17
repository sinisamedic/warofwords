# Trenutno stanje

Ažurirano: 2026-09-17. **Aktivna grana: codex/shields-defeat-ready-effects.**

## Aktuelno — Android 0.1.4

Završeno svih šest dorada posle korisnikovog testa 0.1.3:

- Uže, centrirano PLAY dugme sa većim naslovom i strelicom; ograničena širina i na širokom telefonu.
- Detaljno plavo energetsko polje štita: dvostruki rub, mreža šestougaonika, amblem i pokretni odsjaji.
- Svih 12 protivnika poravnato stopalima sa tlom prema stvarnim pikselima atlasa; kontaktna senka, disanje bez lebdenja.
- Bridge Guardian sa plavim čekićem i njegov portret okrenuti ka igraču.
- Smrtonosni udar pokreće eksploziju energije, fragmente, prašinu i pad poraženog lika. Radi za heroja i protivnike; rezultat posle 1,35 s. Nagrada se čuva odmah i samo jednom.
- Spremne moći imaju obojeni oreol, zrake i odsjaje, uz puls pri punjenju. Reduced Motion zadržava mirne signale i fade poraženog lika.
- Smrt usred držanja prsta čisti gest, pa Retry/Next ostaju upotrebljivi.

Pravila povezivanja, balans, rečnici, zvuk/muzika i napredak ostaju kompatibilni sa prethodnom verzijom. U podešavanjima **Povezivanje slova → Bilo koja** i dalje odmah važi za postojeću borbu.

## Provere i paket

- Godot 4.7.2 import/export, **269 automatskih provera, 0 grešaka** u završnom build-u.
- Pravi renderi 16:9 i širokog telefona: PLAY, štit, oreoli, protivnici i obe animacije poraza. Odabrani snimci u docs/screenshots/0.1.4/.
- Nadogradnja 0.1.3 → 0.1.4 čuva kompletan glavni save. SHA256 instaliranog base.apk jednak pripremljenom APK-u.
- Android borbeni test: pune moći i aktivan štit, pobeda, sledeća misija, poraz tokom dodira, Retry i jednokratne nagrade. Originalni glavni save vraćen nakon privremenih podataka; runtime logovi bez grešaka.
- Puna Android partija: STONE prevlačenjem, SEAPLANES/UPREARED, pobeda, unapređenje i restart; srpski RASPARAĆE, čuvanje i promena menija uz očuvan rečnik duela. Svi prekidači sačuvani. ANDROID QA PASSED, runtime log bez grešaka.
- Paket com.sinisamedic.warofwords, 0.1.4 / code 5, isti debug sertifikat kao ranije. **86.562.301 bajt**.
- SHA256: **8471ea007dcb9279d3cab6563915b81a7529e2a7a86a141714a985d3a29f4200**.
- Detalji: docs/QA-0.1.4.md. Cilj izdanja: **v0.1.4-android-preview**. Ishod Git push-a i objave proverava se posle tih operacija; ovaj zapis ih ne pretpostavlja unapred.

Novi izvor štita je originalni SVG sa dokumentovanim poreklom. Nijedan novi fajl za Git nije preko 10 MiB. APK i lokalni testni podaci su ignorisani. Master dizajni i mokupovi nisu menjani.

## Tačan sledeći korak

Instalirati **0.1.4 preko postojeće aplikacije**, bez deinstaliranja ili brisanja podataka. Na S23 Ultra proveriti širinu PLAY, novu zaštitu, visinu protivnika, smer čuvara, čitljivost sjaja spremnih moći i utisak pada/eksplozije pri pobedi i porazu.

Fizički telefon, baterija i dugotrajan FPS nisu mereni. Srpski rečnik i težina generatora ostaju za korisnički test. Nema dodatno zaključane monetizacije niti iOS isporuke.

## Nastavak na drugom računaru

Pročitati AGENTS.md i ovaj fajl, sačuvati eventualni lokalni rad i proveriti remote/upstream, zatim:

```powershell
git fetch origin --prune
git switch codex/shields-defeat-ready-effects
git pull --ff-only
```

Ako grana nije lokalna: git switch --track origin/codex/shields-defeat-ready-effects. Aktivni projekat je game/project.godot. docs/setup.md i docs/android.md opisuju alate. Signing ključ i instalacije nisu u Git-u; main još nije aktivna grana igre.

## Istorija

- codex/impact-enemies-music, 210e1a2, v0.1.3-android-preview: šteta pri udaru, 12 protivnika, muzika, mapa/dnevnik i odmah primenjivo slobodno povezivanje.
- codex/ornate-ui-combat-effects, bac0e4b, v0.1.2-android-preview: ukrašeni UI, efekti i početno slobodno povezivanje.
- codex/battle-polish-serbian, a499b75, v0.1.1-android-preview: srpski rečnik i dorada borbe.
- codex/android-playable, 0942094, v0.1.0-android-preview: prva igriva Android verzija.
- design/: šest usvojenih statičnih dizajna. V3 mokup/ i mockups/ sačuvani.
