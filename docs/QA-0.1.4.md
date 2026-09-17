# Provera Android verzije 0.1.4 — 2026-09-17

## Paket

- Godot 4.7.2; `com.sinisamedic.warofwords`; versionName **0.1.4**, versionCode **5**.
- `exports/WarOfWords-0.1.4-android.apk`, **86.562.301 bajt**.
- SHA256: `8471ea007dcb9279d3cab6563915b81a7529e2a7a86a141714a985d3a29f4200`.
- ARM64 + x86_64, minimum API 24, target 36. VIBRATE bez INTERNET dozvole.
- Potpis proveren: `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`, isti kao prethodna izdanja.

## Godot i izgled

**269 PASS / 0 FAIL** u završnom build-u. Novi slučajevi proveravaju:

- svih 12 protivnika ostaju na liniji tla u različitim fazama disanja;
- Bridge Guardian i portret su obrnuti ka igraču;
- prelazak na punu energiju pokreće sjaj, a aktiviranje ga uklanja;
- smrtonosni udar prvo pokreće animaciju, rezultat dolazi posle nje;
- nagrada se dodeljuje jednom, pobednik ostaje vidljiv, sledeća borba vraća lika;
- CPU završni udar animira heroja; Reduced Motion koristi fade bez pada;
- smrt tokom držanja prsta čisti započeti gest i ostavlja komande upotrebljivim.

Prethodne provere rečnika, Đ, slobodnog povezivanja, čuvanja projektila, udara, muzike, stranica i napredovanja takođe prolaze. Završni import/export bez script/engine grešaka. Prvi ograničeni desktop test prijavio je zabranu pisanja Godot loga van workspace-a; ponovljeni završni build sa odgovarajućim pristupom nema te greške.

Pravi Godot renderi na **1708 × 960** i **1280 × 576**: uže PLAY dugme, štit sa mrežom i amblemom, sjaj četiri moći, Bridge Guardian, kontakt sa tlom, pad protivnika i heroja, mirniji režim. Odabrani renderi: `docs/screenshots/0.1.4/`. Master dizajni nisu menjani.

## Android

Nadogradnja **0.1.3 → 0.1.4** na emulatoru čuva ceo postojeći save. Nastavljena borba zadržava tablu, reči, rečnik i pravilo. SHA256 instaliranog `base.apk` jednak je gore navedenom izlaznom APK-u. `UPGRADE QA PASSED`.

Poseban test na stvarnom APK-u koristi privremeno otključanog Bridge Guardian-a: aktivan štit, pune moći, Pulse, pobeda i sledeća misija, CPU poraz tokom dugog dodira i Retry. Nagrade se ne ponavljaju. Posle testa vraćen je originalni glavni save. `ANDROID COMBAT QA PASSED`; svi logovi tih scena bez script/engine/Android fatal grešaka.

Puna partija preko novog PLAY dugmeta: STONE prevlačenjem, Freeze, restart/pauza, pobeda preko SEAPLANES i UPREARED, 300 novčića i unapređenje od 160 koje opstaje posle restarta. Srpski RASPARAĆE prihvaćen dodirima i potvrdom; odvojeni jezici, sva četiri prekidača, čuvanje borbe i vraćanje srpske borbe sa engleskim menijem. `ANDROID QA PASSED`; završni runtime log bez grešaka.

Ponovljive komande, namenski emulator 2400 × 1080:

```powershell
node tools/qa-android-upgrade.cjs --serial emulator-5554 --apk exports/WarOfWords-0.1.4-android.apk
node tools/qa-android-combat.cjs --serial emulator-5554 --temporary-fixture
node tools/qa-android.cjs --serial emulator-5554 --reset-test-data
```

Prvi test čuva podatke pri nadogradnji. Drugi čuva originalni glavni save u `.local/` i vraća ga u `finally`. Treći briše samo testne podatke ove igre na emulatoru. Skripte odbijaju fizički telefon. Godot import/export i ADB testove pokretati uzastopno, jer izlazak editora može prekinuti ADB vezu.

## Granice

Nema merenja na fizičkom S23 Ultra niti dugotrajnog FPS/baterijskog testa. Animacije su 2D transformacije i energetski efekti, bez skeletne animacije. Srpski rečnik i balans nisu menjani. APK instalirati preko postojeće igre, bez deinstaliranja.
