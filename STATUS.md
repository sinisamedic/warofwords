# Trenutno stanje

Ažurirano: 2026-09-16. **Aktivna grana: `codex/android-playable`.**

## Aktuelno — igriva Android verzija 0.1.0

Korisnik je usvojio šest dizajna i izričito odobrio celu igru za probu na Android telefonu, uz slobodu rešavanja detalja. Godot je aktivni engine. Ranija zabrana implementacije više ne važi.

- Projekat: **game/project.godot**, Godot 4.7.2 standard, originalna 2D grafika; Blender nije potreban.
- Šest osnovnih ekrana + pomoć, pauza, pobeda/poraz, kraj kampanje, opcije i dnevnik reči.
- Engleski interfejs, landscape, 7 × 4 susedna slova sa dijagonalama i dopunom. Tipovi slova pune četiri sposobnosti. Brzo prevlačenje i tap + ✓.
- Offline SCOWL rečnik od 76.802 reči, generator sa proverom rešenja, Hint, bonus za duge reči.
- 12 računarskih protivnika/susreta, tri poglavlja sa boss susretima, novčići, zvezdice, otključavanje i unapređenja do nivoa 8. Tri power-upa, jedan besplatno po duelu.
- Lokalni trajni napredak i nastavak tačno sačuvane borbe, uključujući tablu i potrošeni power-up. Nastavak je pauziran. Rezervna kopija za oštećen save. Učitavanje rečnika u pozadini sa vidljivim ekranom učitavanja.
- Sintetisani zvučni efekti, vibracija i reduced motion opcije. Nema naloga, mreže, analitike, reklama ili monetizacije.
- APK: **exports/WarOfWords-0.1.0-android.apk**, debug potpis, ARM64 i x86_64, minimum API 24 / target 36. Build izlaz i hash su ignorisani; distribucija je predviđena kroz GitHub pre-release assets.
- Poreklo asset-a, tačni ImageGen promptovi, licence Godota/fontova/rečnika i reprodukcija rečnika su u `game/`. Novi binarni izvori su pojedinačno ispod 10 MiB; LFS nije potreban za njih. APK se ne dodaje u Git istoriju.

## Završene provere

- Godot import i **91 uspešna automatska provera**, uključujući solver/generator, brzo prevlačenje, energiju, CPU/štit/lečenje, jednokratne nagrade, JSON round-trip, oštećen save i završivost misija 1/4/8/12.
- Šest ekrana renderovano u Godotu; pregledani 16:9, 2:1 i Android široki prikaz. Snimci su u `docs/screenshots/`.
- **Konačni APK instaliran i testiran stvarnim dodirima u Android emulatoru API 36, 2400 × 1080.** Prošli meni → kampanja → power-up → borba, STONE prevlačenjem, Freeze, gašenje/nastavak iste pauzirane borbe, Aegis/Hint, reči i napadi do pobede, nagrada/otključavanje, unapređenje i čuvanje posle novog restarta. Završni log nema GDScript/engine ERROR niti fatalni pad; javlja se benigno upozorenje shader keša pri rekompajliranju.
- APK izvoz potvrđuje potpis i njegovu verifikaciju. Manifest i SHA256 provereni. Detalji i granice: **docs/QA-0.1.0.md**.
- Fizički Samsung S23 Ultra nije dostupan za test. Zvuk/vibracija nisu provereni slušanjem/osećajem na fizičkom uređaju. Balans, baterija i duže partije treba da se provere rukom.
- SwiftShader emulator nije radio; uspešan test koristi NVIDIA host OpenGL, `-feature -Vulkan -no-snapshot`. Ne pripisivati ovaj rezultat svim Android drajverima.

## Tačan sledeći korak

Na Samsung telefonu preuzeti APK iz GitHub izdanja, instalirati i odigrati prve četiri misije. **Play → Prepare → Battle**; na prvoj tabli postoji STONE. Proveriti udobnost povezivanja, čitljivost, tempo CPU napada, zvuk i nastavak posle zaključavanja. Na osnovu tog testa podesiti balans; ne širiti sadržaj pre te povratne informacije.

Uputstvo za instalaciju i build: **docs/android.md**. Aktivne odluke/balans: **docs/game-design.md**. Ovo je prva kompletna kampanja za probu, ne Play Store izdanje; dva lika dele se kroz susrete, bez skeletne animacije i muzike. iOS, cloud save i monetizacija nisu urađeni.

## Nastavak na drugom računaru

Pročitati AGENTS.md, zaštititi eventualne lokalne izmene i proveriti remote/Git stanje, pa:

```powershell
git fetch origin --prune
git switch codex/android-playable
git pull --ff-only
```

Ako grana nije lokalna: `git switch --track origin/codex/android-playable`. Importovati `game/project.godot`; za Android instalirati Godot 4.7.2/JDK/SDK/export templates prema `docs/android.md`. MCP nije potreban. Potpisni ključevi ostaju van Git-a; na drugom računaru koristiti isti privatni ključ za kompatibilno ažuriranje postojeće instalacije.

Ovaj status beleži provereni sadržaj pripremljen za handoff. Ishod push-a, SHA i stvarni URL izdanja potvrđuju se zasebno kroz Git/GitHub i završnu poruku, ne unapred ovim tekstom.

## Sačuvana istorija

- `design/`: šest usvojenih statičnih ImageGen dizajna, galerija i specifikacija. Osnovni commit ove grane: 2a5a1c7 sa grane `codex/screen-mockups`.
- `V3 mokup/`: ranija interaktivna simulacija, sačuvana bez izmena.
- `mockups/`: raniji V2 atlas (493600d); V1 portrait istorija 40c1588.
- `setup-probe/`, `tools/godot-mcp/`: ranija tehnička proba i licencirani MCP izvor, nevezani za runtime ove igre.
