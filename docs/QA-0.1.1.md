# Provera verzije 0.1.1 — 2026-09-16

## Paket

- Godot 4.7.2, Android `com.sinisamedic.warofwords`, versionName **0.1.1**, versionCode **2**.
- `exports/WarOfWords-0.1.1-android.apk`: **72.652.525 bajtova**.
- SHA256: `4287c452dba6a96b0463b7ca25becf669e710da9cd6903e6c38f22249398e3cf`.
- ARM64 + x86_64, minimum API 24 / target 36, landscape. Manifest proveren pomoću aapt. Funkcionalna dozvola: VIBRATE, bez INTERNET.
- `apksigner verify --print-certs` potvrđuje važeći potpis i isti sertifikat kao 0.1.0: SHA256 `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`.
- U APK-u provereni srpski gzip rečnik, puna MPL-2.0 licenca, izvorni README i obaveštenje sa putanjama izvora.

## Automatske provere

Godot import i **129 PASS / 0 FAIL** kroz `tools/build-android.ps1` i `game/tests/test_game.gd`.

Pored prethodnih testova generatora, energije, CPU-a, čuvanja i završivosti kampanje:

- Nezavisnost jezika menija i rečnika; trajno čuvanje oba izbora.
- 1.740.276 srpskih oblika, dijakritici, padežni oblici, LJ/NJ/DŽ kao pločice, početna tabla KAMEN i deset generisanih tabli sa više rešenja.
- Stari snapshot bez jezika ostaje engleski; srpski snapshot čuva slova i rečnik; promena podešavanja ne menja postojeću borbu.
- Dodiri čekaju potvrdu, prevlačenje je šalje automatski; brzi pokreti ne preskaču susedna polja. DŽEP preko tri pločice nanosi tri osnovne štete.
- Zastarele komande prethodnog ekrana ne aktiviraju se pre iscrtavanja novog.
- Reprodukovan srpski rečnik iz verzionisanog izvora, provereni izvorni i izlazni hash-evi.

## Android i izgled

Emulator `Medium_Phone_API_36`, 2400 × 1080, host NVIDIA OpenGL, `-feature -Vulkan -no-snapshot`. `tools/qa-android.cjs` koristi stvarne ADB dodire i odbija fizički telefon; brisanje podataka je eksplicitno ograničeno na namenski emulator.

- Instalacija preko 0.1.0 sačuvala je celu JSON datoteku napretka bez promene: 140 novčića, Pulse nivo 2, otključana misija 2 i dnevnik reči.
- Kompletan tok: meni, kampanja, power-up, STONE prevlačenjem, Freeze, gašenje/nastavak iste pauzirane borbe, reči i sposobnosti do pobede, nagrada i unapređenje, novi restart.
- Srpski meni uz engleski rečnik; sva tri prekidača; prelazak na srpski rečnik; nova srpska borba; **SEVAČKOME** potvrđena dodirima; restart sa istom srpskom borbom; vraćanje menija i izbora za nove borbe na engleski uz očuvan srpski aktivni duel.
- Posle završne dorade debljine prstena, izdvajanja pronađenih reči iz lokalizacije i validacije jezika save-a ponovljeni su izvoz i svih 129 testova. **Baš završni APK** ponovo instaliran, save upoređen, srpska borba nastavljena, sposobnost i Freeze dodirnuti i pregledan novi runtime log.
- Završni Android i Godot logovi bez SCRIPT ERROR, engine ERROR i fatalnog pada. Benigno upozorenje ponovnog kompajliranja shader keša ostaje prisutno u ovom emulatoru.
- Pregledani Godot renderi 16:9 i široki Android prikaz, tap i slide, portreti, energija, dijakritici, srpska podešavanja, ilustracije arsenala i power-upova. Snimci: `docs/screenshots/0.1.1/`.

## Performanse i granice

Ukrasna pozadina, pločice i segmenti punjenja optimizovani su da smanje GPU pozive: uzorci Android battle loga su sa približno 496 pali na 153–165. U emulatoru su posle optimizacije zabeleženi uzorci 19–36 FPS u borbi, do 57 na meniju; to **nije merenje Samsung telefona niti obećanje 60 FPS**. Debug build ispisuje retke FPS uzorke radi sledeće dijagnostike.

Fizički S23 Ultra nije dostupan. Zvuk, osećaj vibracije, baterija, udobnost dužih partija i trajna brzina na telefonu ostaju za korisnikov test. Srpski je probni pravopisni rečnik; nema definicija i nije konačna kurirana lista dozvoljenih reči. Ćirilica nije uključena u ovu doradu.
