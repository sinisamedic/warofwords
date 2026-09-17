# Provera Android verzije 0.1.2 — 2026-09-17

## Završni paket

- Godot 4.7.2, `com.sinisamedic.warofwords`, versionName **0.1.2**, versionCode **3**.
- APK: `exports/WarOfWords-0.1.2-android.apk`, **77.983.663 bajta**.
- SHA256: `fe93e38858c68e91827fed1869c62d955298e7557319beadc00d72302c0d0f2e`.
- ARM64 + x86_64, minimum API 24, target 36, landscape. Jedina funkcionalna dozvola: VIBRATE; bez INTERNET.
- Važeći potpis, isti sertifikat kao 0.1.0 i 0.1.1: SHA256 `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`.
- Pomoću ADB-a proveren je SHA256 **instaliranog base.apk** i jednak je navedenom otisku izlaznog fajla. Nakon toga su ponovljena oba Android scenarija ispod.
- U paketu provereni uvezeni zvukovi ispaljivanja/eksplozije, srpski rečnik i licenca novog Noto Serif fonta. Prethodne licence ostaju uključene.

## Provere ponašanja

**163 PASS / 0 FAIL** kroz `game/tests/test_game.gd`, u završnom build-u. Obuhvaćene prethodne provere rečnika, generatora, energije, kampanje, autosave-a i jezika, uz:

- Udaljena reč prolazi u Free, a pada u Adjacent režimu. Ista pločica se ne može ponoviti; povratak preko prethodne skraćuje putanju.
- Srpski ĐAK preko udaljenih pločica; solver/pomoć i nova tabla u slobodnom režimu, ograničen rad pretrage.
- Trajna postavka pravila, čuvanje pravila konkretne borbe, stari save bez polja i odbijanje neispravnog tipa podatka.
- Đ/đ/Č/č/Ć/ć/Š/š/Ž/ž postoje u oba aktivna fonta.
- Projektil emituje udar tek pri dolasku i samo jednom. Broj projektila/efekata je ograničen; izlazak iz borbe ih uklanja.
- Svih 13 zvukova se učitava, isključivanje zvuka odmah zaustavlja glasove. Sintesani izvorni WAV fajlovi imaju fade i vrh ispod clipping-a; recept beleži njihove vrhove i RMS.

## Android scenariji

Namenski emulator API 36, 2400 × 1080, NVIDIA host OpenGL. Fizički telefon nije korišćen. Provera nadogradnje prethodi resetovanju testnih podataka.

1. `tools/qa-android-upgrade.cjs`: nadogradnja uz očuvan kompletan progress fajl, SHA instaliranog APK-a, nastavak sa istim rečnikom/pravilom/tablom i runtime log. Posebno je proverena i instalacija 0.1.2 preko ranije 0.1.1 sa novčićima i unapređenjima.
2. `tools/qa-android.cjs`: meni → kampanja → power-up → STONE prevlačenjem → Freeze → restart/nastavak pauzirane borbe → reči i sposobnosti do pobede → 300 novčića i otključana naredna misija → unapređenje (160 novčića) → restart sa 140 novčića i Pulse nivoom 2. Zatim nezavisan srpski meni, sva tri prekidača, srpski rečnik, reč **ŠTEKETATI** dodirima i potvrdom, restart, pa engleski meni uz očuvanu srpsku borbu.
3. `tools/qa-android-free.cjs`: izbor Free kroz stvarne kontrole, nova engleska borba, reč **ABHORRENT** putem `[5,14,8,2,10,17,4,6,0]` (udaljene pločice), prihvatanje, pomoć, restart i zadržavanje Free pravila u sačuvanoj borbi čak i posle promene postavke za nove na Adjacent. Raniji prolaz istog scenarija prihvatio je i ACRIDNESS.

Svi završni scenariji završeni bez SCRIPT ERROR / engine ERROR / fatalnog pada. Emulator pri učitavanju prijavljuje poznato ponovno kompajliranje shader keša; posle toga radi.

## Vizuelni pregled i granice

Pregledani su Godot renderi svih šest ekrana u 16:9, srpski meni/unapređenja, ĐAK i svi dijakritici na tabli, tap/slide, okvir poruka, let/udar impulsa, štit i smanjene animacije. Pregledan i široki Android prikaz. Odabrani neizmenjeni snimci su u `screenshots/0.1.2/`.

U Android logu zabeležen je uzorak **32 FPS / 132 draw calls** u borbi; uzorci tokom učitavanja i automatizovanog snimanja bili su i niži. Ovo nije merenje trajnog FPS-a, niti procena brzine S23 Ultra. Zvuk na fizičkom zvučniku, osećaj vibracije, dugotrajna udobnost i baterija zahtevaju test na telefonu. Novi efekti su proceduralni 2D efekti; likovi ostaju postojeći sprite-ovi. Srpski je i dalje probni pravopisni rečnik, bez definicija i ćirilice.
