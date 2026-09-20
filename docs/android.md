# Android — instalacija i razvoj

**Razvojni APK 0.1.21 / code 22:** `exports/WarOfWords-0.1.21-android.apk`, AdMob testni oglasi i tri nastavka u Beskraju. Isti potpis kao 0.1.20; instalira se preko nje. Desktop provere i Android paket su provereni; stvarni test oglasa na telefonu još predstoji. [Integracija i produkcioni uslovi](admob.md).

Od ove verzije potreban je **Gradle export**. Pre prvog build-a pokrenuti `tools/prepare-android-gradle.ps1 -TemplatesArchive <zvanicni-Godot-4.7.2-tpz>`; build skripta to automatski radi ako je arhiva u `.local/downloads/godot-templates.tpz`. Potrebni su SDK platform 36 i build-tools 36.1.0. Maven/Gradle keš i `game/android/` su lokalni. Na ovom računaru Java koristi Windows-ROOT trust store zbog postojeće HTTPS inspekcije (bez isključivanja TLS validacije). Prvi build preuzima zavisnosti. Ako Godot console wrapper ostane otvoren posle `[ DONE ] export`, završiti namenski Gradle daemon (`gradlew.bat --stop` uz isti GRADLE_USER_HOME).

**Najnoviji lokalni APK: 0.1.20 / code 21**, `exports/WarOfWords-0.1.20-android.apk` — odobreni redizajn podešavanja i ikonica autora/licenci na naslovnoj. Isti potpis kao 0.1.19; instalirati preko nje. Provere i SHA256 u STATUS.md. Niže su istorijske verzije.

**Najnoviji lokalni APK: 0.1.18 / code 19**, `exports/WarOfWords-0.1.18-android.apk` — Joker u Kampanji/Beskraju, novi Rekordi i poraz, slanje rezultata sa nadimkom, zajedničke jezičke liste. Isti potpis kao 0.1.14–0.1.17, instalirati preko njih. Provere i SHA256 u STATUS.md. Nije objavljen na Releases; niže su istorijske verzije.

**Najnoviji lokalni APK: 0.1.17 / code 18**, `exports/WarOfWords-0.1.17-android.apk` — Beskraj reči, nova naslovna, detaljan poraz i globalna beta lista. Isti potpis kao 0.1.14–0.1.16; instalirati preko njih bez deinstalacije. Globalna lista je beta sa klijentski prijavljenim rezultatima. Provere i SHA256 u STATUS.md. Paket nije objavljen na Releases; niže su istorijske verzije.

**Aktivni lokalni APK: 0.1.16 / code 17**, `exports/WarOfWords-0.1.16-android.apk`. Oštriji okviri i pravilne proporcije dugmadi. Isti potpis kao 0.1.14/0.1.15; instalirati preko njih bez deinstalacije. [Provere](../STATUS.md). Ostatak verzionih napomena je istorija.

**Aktivni lokalni paket: 0.1.15 / code 16**, `exports/WarOfWords-0.1.15-android.apk`. Isti potpis kao 0.1.14, instalira se preko nje bez deinstalacije. Detalji/provere u [STATUS.md](../STATUS.md). Sledeći odeljci su prethodne verzije.

**Aktivni lokalni paket: 0.1.14 / code 15.** `exports/WarOfWords-0.1.14-android.apk`, proširena kampanja i četiri nova uređaja. Postojeći kućni potpis razlikuje se od 0.1.13; pre instalacije ukloniti 0.1.13, što briše lokalni napredak (korisnik odobrio). Provere i SHA256: [STATUS.md](../STATUS.md). Nije objavljen na Releases.

**Prethodni objavljeni paket: 0.1.13 / code 14.** Velike nagrade sa bedžom osvojenog, jasniji izbor pojačanja, broj završenog nivoa na pobedi i medaljoni bez crnog donjeg oboda. Instalira se preko **0.1.12, 0.1.11 ili 0.1.10 bez deinstalacije**, sa istim lokalnim potpisom; prelazak sa 0.1.12 i očuvanje celog progress fajla provereni u emulatoru. Za prelazak sa kućnih 0.1.7–0.1.9 potpis se razlikuje kao u 0.1.10 i potrebna je deinstalacija, uz gubitak lokalnog napretka. Kampanja i vežba rade offline, rangirani dnevni izazov zahteva internet. Ključ čuvati i preneti bezbedno van Git-a. [Provere](QA-0.1.13.md), [stanje objave](../STATUS.md). Niži odeljci o ranijim paketima su istorija.

**0.1.8 / code 9:** instalira se preko 0.1.7, bez deinstalacije i uz isti potpis. Nova dopuna u kampanji/dnevnom režimu, zvuk i vibracija pri spajanju dnevnih slova i katanac umesto teksta. Novi dnevni rezultati koriste odvojenu v2 rang-listu; v1 podaci ostaju sačuvani. SHA256 APK-a: `62d6e86ba22dceb6c786cecdcb11b210a3731716103968226fe598be8d94bf28`, veličina 94.893.374 bajta. Sledeći odeljak beleži promenu potpisa koja se desila u 0.1.7.

**Istorija: testni paket 0.1.7 / code 8**, sa dnevnim izazovom, globalnom listom i novim izgledom. Koristi novi potpis koji je korisnik izričito odobrio: **deinstalirati 0.1.6 ili stariju verziju jednom, zatim instalirati 0.1.7; lokalni napredak se briše.** Naredni paketi treba da koriste isti novi ključ. Ranija uputstva ispod za 0.1.6 ostaju istorijska.

Novi ključ i lozinka čuvaju se u ignorisanom .local/signing/. .local/machine.json poljem androidSigningConfig pokazuje na lokalni signing.json (path, alias, password), koji build skripta učitava bez ispisa tajni. Na drugi računar preneti taj folder bezbednim kanalom, van Git-a, i prilagoditi lokalne putanje. Sertifikat SHA256: 429a2d1b4700535f04c7252e8b28c0f8c4bb584a6cd8b7d863cd08070eff0abc.

APK SHA256: 118ad610bbba0e84a687975e4f11d4e0531244412fc978ae9b0357723bbf2d36; veličina 94.889.278 bajtova. Instalacija na telefonu još nije proverena; desktop testovi i verifikacija potpisa/poravnanja prolaze.


## Probaj na telefonu

1. Preuzmi aktuelni **WarOfWords-0.1.13-android.apk** prema linku u README-u (ili ga kopiraj iz `exports/` u Downloads telefona).
2. Otvori APK u Downloads / My Files. Ako Android zatraži, dozvoli instalaciju tom browseru ili upravljaču fajlovima, pa izaberi Install.
3. Otvori **War of Words**. Igra se automatski postavlja vodoravno. Kampanja radi bez interneta; globalna rang-lista zahteva internet.
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

Za potpisani build postaviti `GODOT_ANDROID_KEYSTORE_DEBUG_PATH` na postojeći ključ; obavezno i `GODOT_ANDROID_KEYSTORE_DEBUG_USER` i `GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD`. Ključ/lozinke ostaju van Git-a. Skripta odbija potpisivanje bez eksplicitne putanje, da novi računar ne bi slučajno koristio drugi potpis. Na prethodnom računaru proveriti Godot Editor Settings → Export → Android → Debug Keystore; tipične lokacije su `%APPDATA%/Godot/keystores/debug.keystore` i `%APPDATA%/Godot/android/debug.keystore`. APK kontrolna suma sa GitHub Releases nije potpisni ključ i ne može ga zameniti.

Bez ključa, `./tools/build-android.ps1 -UnsignedCheck` proverava import/testove/izvoz u `.local/WarOfWords-0.1.8-UNSIGNED-CHECK.apk`. To nije instalaciono izdanje. Skripta privremeno isključuje potpisivanje i u `finally` vraća identičan preset; ne pokretati paralelan editor/export tokom ove provere. Posle nasilnog prekida proveriti da je `package/signed=true`.

Na drugom Windows računaru 2026-09-17 instalirani su Microsoft OpenJDK 21.0.12.1, Android command-line tools 15859902, platform-tools 37.0.1, platform 35/rev 2 i build-tools 36.0.0. Zvanični Godot 4.7.2 Android šabloni su u `.local/templates/`, alati u `.local/toolchains/`; putanje su upisane u lokalni machine.json i Godot Editor Settings. Arhive su proverene prema objavljenim SHA256 vrednostima. NDK/CMake/Android Studio nisu potrebni za ovaj izvoz gotovog APK šablona bez Gradle-a.

Na ovom računaru SDK preuzimanja traže Windows CA skladište zbog Avast HTTPS inspekcije: za proces SDK menadžera korišćen je `JAVA_TOOL_OPTIONS=-Djavax.net.ssl.trustStoreType=Windows-ROOT -Djavax.net.ssl.trustStore=NONE`. TLS validacija ostaje uključena. Zasebni Godot/mbedTLS problem rešen je korisnikovim Avast izuzetkom ograničenim na host projekta; stvarni Godot mrežni test potom je prošao svih 8 provera.

Paket sadrži ARM64 za Samsung S23 Ultra i druge moderne telefone, kao i x86_64 za emulator. Minimum Android 7 (API 24), cilj API 36 — provereno iz finalnog Android manifesta. Compatibility renderer, landscape, immersive. Dozvole su INTERNET i VIBRATE. Online pozivi služe dnevnom izazovu; nema reklama ili kupovina.

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
