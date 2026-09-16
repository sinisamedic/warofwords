# Android — instalacija i razvoj

## Probaj na telefonu

1. Preuzmi **WarOfWords-0.1.0-android.apk** na Android telefon (ili ga kopiraj sa računara u Downloads preko USB kabla).
2. Otvori APK u Downloads / My Files. Ako Android zatraži, dozvoli instalaciju tom browseru ili upravljaču fajlovima, pa izaberi Install.
3. Otvori **War of Words**. Igra se automatski postavlja vodoravno. Internet i nalog nisu potrebni.
4. **Play → Prepare → Battle → Got it**. Prva tabla ima STONE u prvom redu. Prevuci S–T–O–N–E i pusti. Boje pune odgovarajuće sposobnosti; kada piše READY, dodirni sposobnost.
5. Probaj Hint, štit Aegis i Freeze. Posle pobede otvori Upgrades. Zatvori aplikaciju i proveri Continue Duel za nedovršenu borbu.

Ovo je razvojna verzija 0.1.0 potpisana debug ključem. Nije Play Store izdanje. Čuvanje je lokalno na telefonu; brisanje podataka ili deinstaliranje briše napredak. Za buduća ažuriranja treba sačuvati isti potpisni ključ van Git-a ili preći na kontrolisano release potpisivanje. Instalacija debug paketa sa drugog računara može tražiti uklanjanje ranijeg paketa ako se ključevi razlikuju.

## Pokreni izvor u Godotu

Godot **4.7.2 standard**, bez .NET. Importuj `game/project.godot` i F6/F5 (glavna scena je `main.tscn`). Miš radi kao dodir. Escape otvara pauzu/povratak. Blender, MCP server i Node nisu potrebni za igru.

## Izgradi APK na drugom računaru

1. Instaliraj Godot 4.7.2, JDK 17+ i Android SDK. Provereno: JDK 21.0.6, SDK platform 35, build-tools 36.0.0.
2. U Godot Editor Settings → Export → Android unesi lokalne putanje Android SDK-a i Java SDK-a.
3. Preuzmi zvanični [Godot 4.7.2 export templates](https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz). To je ZIP arhiva. Iz nje izdvoji `templates/android_debug.apk` i `templates/android_release.apk` u **`.local/templates/`**. Sačuvani export preset koristi te relativne putanje. Instalacije i arhiva ne idu u Git.
4. Iz korena repoa:

```powershell
./tools/build-android.ps1 -Godot 'C:/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe'
```

Može i `GODOT_EXECUTABLE`, ili `godotExecutable` u ignorisanom `.local/machine.json`. Rezultat i SHA256 idu u `exports/`. Skripta prvo uvozi resurse i pokreće testove. Samo provere: dodati `-TestOnly`.

Paket sadrži ARM64 za Samsung S23 Ultra i druge moderne telefone, kao i x86_64 za emulator. Minimum Android 7 (API 24), cilj API 36 — provereno iz finalnog Android manifesta. Compatibility renderer, landscape, immersive. Jedina tražena funkcionalna dozvola je vibracija; nema mrežnih poziva, analitike, reklama ili kupovina.

Zvanično uputstvo za alat: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html.

## Razvojna Android provera

```powershell
adb devices
adb -s emulator-5554 install --no-incremental -r exports/WarOfWords-0.1.0-android.apk
adb -s emulator-5554 shell am start -W -n com.sinisamedic.warofwords/com.godot.game.GodotAppLauncher
adb -s emulator-5554 logcat -d -s godot Godot AndroidRuntime
```

U komandi izabrati stvarni uređaj iz `adb devices`; ne instalirati automatski na tuđ uređaj. Startovati launcher aktivnost, ne internu neizvezenu GodotApp aktivnost. Emulator pokretati bez starih snapshotova ako imaju neispravno stanje grafike. SwiftShader 4.0 u ovom starijem emulatoru odbija Godot-ove shader uniforme; to je poznato [ograničenje ove kombinacije](https://github.com/godotengine/godot/issues/109550). Ovde radi `-gpu host -feature -Vulkan -no-snapshot` (NVIDIA OpenGL). To je podešavanje testnog emulatora, ne uslov za Samsung.

Ponovljivi test dodirima zahteva Node i namenski emulator sa 2400 × 1080 landscape prikazom, na kome je instaliran debug APK. **Briše podatke samo ove igre na izabranom emulatoru**, zatim prolazi novu partiju, restart, pobedu i unapređenje:

```powershell
node tools/qa-android.cjs --serial emulator-5554 --reset-test-data
```

Skripta odbija fizički telefon i zahteva izričitu opciju brisanja testnih podataka. Log i snimci idu u `.local/`. Za drugačiju rezoluciju prilagoditi koordinate testnog harness-a; sama igra se prilagođava bez tih izmena.

## Raspored izvora

- `game/scripts/game.gd`: šest ekrana, dodir, borba, napredovanje, efekti i lifecycle.
- `lexicon.gd`: lokalni rečnik, generator i pretraga susednih polja.
- `save_data.gd`: validacija, privremeni zapis i rezervna kopija.
- `actor.gd`, `sound.gd`: zasebni likovi i sintetisani zvučni efekti.
- `game/tests/test_game.gd`: provere stvarnih funkcija igre i završivosti normalnih/boss susreta.
- `game/assets/`, `game/licenses/`: verzionisani materijali i poreklo.

Vizuelna razvojna provera: pokrenuti Godot sa `--path game -- --qa`. Slike šest ekrana renderer snima u `.local/game-qa/`; nije deo toka za igrača. Izveštaj konkretno završenih provera: `docs/QA-0.1.0.md`.
