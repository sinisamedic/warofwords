# Android — instalacija i razvoj

**Radna grana 0.1.7-dev:** novi preset/build skripta pripremaju `WarOfWords-0.1.7-android.apk` (code 8) sa INTERNET dozvolom za dnevni izazov. Paket još nije napravljen ni objavljen. Pre build-a dodati javni `game/online_config.json` prema [online uputstvu](daily-online.md), a za nadogradnju koristiti prethodni potpisni ključ. Sledeći odeljak opisuje poslednji objavljeni 0.1.6.

## Probaj na telefonu

1. Preuzmi **WarOfWords-0.1.6-android.apk** na Android telefon (ili ga kopiraj sa računara u Downloads preko USB kabla).
2. Otvori APK u Downloads / My Files. Ako Android zatraži, dozvoli instalaciju tom browseru ili upravljaču fajlovima, pa izaberi Install.
3. Otvori **War of Words**. Igra se automatski postavlja vodoravno. Internet i nalog nisu potrebni.
4. **Play → Prepare → Battle → Got it**. Prva tabla ima STONE u prvom redu. Prevuci S–T–O–N–E i pusti. Boje pune odgovarajuće sposobnosti; kada piše READY, dodirni sposobnost.
5. **Options** je na glavnom ekranu i u pauzi. Podesi Sound Effects, Music, Haptics, Reduced Motion, Interface Language i Word Dictionary. **Letter Connection → Any letters** (srpski: **Povezivanje slova → Bilo koja**) omogućava udaljena slova. Pravilo važi odmah i za sačuvanu borbu, uz očuvanje njenog napretka. Srpski je latinica; novi rečnik važi za nove borbe, sačuvane zadržavaju svoj. Probaj sijalicu (Hint), štit Aegis i pahuljicu (Freeze). Posle pobede otvori Upgrades. Zatvori aplikaciju i proveri Continue Duel za nedovršenu borbu.

APK 0.1.6 koristi isti paket i potpis kao objavljeni 0.1.0, uz versionCode 7. Instaliraj ga **preko postojeće aplikacije**, bez deinstaliranja ili brisanja podataka. Očuvanje kompletnog save-a provereno je u emulatoru. Ovo je razvojna verzija 0.1.6 potpisana debug ključem. Nije Play Store izdanje. Čuvanje je lokalno na telefonu; brisanje podataka ili deinstaliranje briše napredak. Za buduća ažuriranja treba sačuvati isti potpisni ključ van Git-a ili preći na kontrolisano release potpisivanje. Instalacija debug paketa sa drugog računara može tražiti uklanjanje ranijeg paketa ako se ključevi razlikuju.

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
adb -s emulator-5554 install --no-incremental -r exports/WarOfWords-0.1.6-android.apk
adb -s emulator-5554 shell am start -W -n com.sinisamedic.warofwords/com.godot.game.GodotAppLauncher
adb -s emulator-5554 logcat -d -s godot Godot AndroidRuntime
```

U komandi izabrati stvarni uređaj iz `adb devices`; ne instalirati automatski na tuđ uređaj. Startovati launcher aktivnost, ne internu neizvezenu GodotApp aktivnost. Emulator pokretati bez starih snapshotova ako imaju neispravno stanje grafike. SwiftShader 4.0 u ovom starijem emulatoru odbija Godot-ove shader uniforme; to je poznato [ograničenje ove kombinacije](https://github.com/godotengine/godot/issues/109550). Ovde radi `-gpu host -feature -Vulkan -no-snapshot` (NVIDIA OpenGL). To je podešavanje testnog emulatora, ne uslov za Samsung.

Ponovljivi test dodirima zahteva Node i namenski emulator sa 2400 × 1080 landscape prikazom, na kome je instaliran debug APK. **Briše podatke samo ove igre na izabranom emulatoru**, zatim prolazi novu partiju, restart, pobedu, unapređenje, nezavisne jezike i srpsku borbu:

```powershell
node tools/qa-android.cjs --serial emulator-5554 --reset-test-data
```

Skripta odbija fizički telefon i zahteva izričitu opciju brisanja testnih podataka. Log i snimci idu u `.local/`. Za drugačiju rezoluciju prilagoditi koordinate testnog harness-a; sama igra se prilagođava bez tih izmena.

Provera 0.1.6 uključuje `tools/qa-android-upgrade.cjs`, `tools/qa-android-pages.cjs`, punu partiju preko `tools/qa-android.cjs` i završetke borbe preko `tools/qa-android-combat.cjs`; rezultati su u [QA-0.1.6.md](QA-0.1.6.md). Posebna skripta za slobodno povezivanje ostaje dostupna. Sačekati da `adb shell getprop sys.boot_completed` vrati `1` pre čitanja save-a. Import/export Godota i Android dodirne testove pokretati uzastopno radi stabilne ADB veze.

## Raspored izvora

- `game/scripts/game.gd`: šest ekrana, dodir, borba, napredovanje, efekti i lifecycle.
- `lexicon.gd`: lokalni rečnik, generator i pretraga susednih ili udaljenih polja.
- `save_data.gd`: validacija, privremeni zapis i rezervna kopija.
- `actor.gd`, `hero_rig.gd`, `hero_leg.gd`, `combat_fx.gd`, `sound.gd`: likovi, zglobovi i deformacija heroja, efekti projektila/udaraca i slojeviti zvuk.
- `game/tests/test_game.gd`: provere stvarnih funkcija igre i završivosti normalnih/boss susreta.
- `game/assets/`, `game/licenses/`: verzionisani materijali i poreklo.

Vizuelna razvojna provera: pokrenuti Godot sa `--path game -- --qa`. Slike osnovnih ekrana, obe metode povezivanja i srpskih podešavanja renderer snima u `.local/game-qa/`; nije deo toka za igrača. Izveštaj konkretno završenih provera: `docs/QA-0.1.6.md`.

Dodatni test slobodnog povezivanja posle osnovnog Android QA (ne briše podatke, kroz UI započinje novu testnu borbu):

```powershell
node tools/qa-android-free.cjs --serial emulator-5554
```
