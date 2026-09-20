# Jezici u verziji 0.1.19

Redosled: English, Deutsch, Français, Español, Italiano, Srpski. Meniji i reči biraju se nezavisno. Novo ime je lokalni podrazumevani nadimak za sledeće slanje, ne trajni nalog. Kampanja i Beskraj čuvaju jezik/povezivanje započete partije u snapshot-u.

## Rečnici

EN/SCOWL i SR/LibreOffice ostaju nepromenjeni. DE/FR/ES/IT su obrađeni iz LibreOffice repozitorijuma, revizija `5fe575dbcfeb789e2ab2d9731b88ac0dacc4f453`. Izvori i licence: `tools/dictionaries/EXTRA-PROVENANCE.md`. GPL rečnici su odvojeni podaci; odgovarajući izvori, priprema i licence isporučuju se i unutar APK-a, u `licenses/dictionary-sources.zip`. Licenca celog projekta nije ovim promenjena.

| Kod | Oblici | Datoteka |
|---|---:|---|
| de | 343335 | game/data/de.txt.gz |
| fr | 341043 | game/data/fr.txt.gz |
| es | 578122 | game/data/es.txt.gz |
| it | 1164157 | game/data/it.txt.gz |

Generisanje: Python sa `spylls==0.1.7` instaliranim u ignorisani `.local/dictionary-tools`, zatim `tools/build-extra-dictionaries.py` i `tools/package-dictionary-sources.py`. Godot ne zahteva Python. Izvodi se ograničena ekspanzija Hunspell afiksa i cross-product kombinacija; svaki kandidat proverava parser. Zadržavaju se alfabetne reči 3–12 slova, bez proizvoljnih složenica, razmaka, crtica i vlastitih imena (osim nemačkih velikih početnih slova). To nije potpuna zamena za Hunspell pravopisnu proveru.

Akcenti ostaju posebna slova. ß/ẞ → SS, œ/Œ → OE, æ/Æ → AE. SR digrafi LJ/NJ/DŽ ostaju jedna pločica. `languages.gd` definiše redosled, nazive i jezike za obnavljanje partija. `refill-words.json` sadrži poznate reči za dopunu; puna lista proverava unos igrača.

## Android pakovanje — ispravka 0.1.22

Gradle APK 0.1.21 raspakovao je pet `.txt.gz` rečnika u `assets/data/*.txt`, dok je stari loader tražio samo `.gz`. Zbog toga EN radi, a SR/DE/FR/ES/IT odbijaju reči. APK 0.1.20 ima originalne `.gz` putanje. Poređenjem bajtova potvrđeno je da sadržaj rečnika nije promenjen.

Loader od 0.1.22 prihvata običan tekst i gzip. `tools/check-apk-dictionaries.ps1` izvlači svih šest rečnika iz gotovog APK-a, a Godot `test_packaged_dictionaries.gd` poredi sve učitane reči sa izvornim listama i proverava generisanje table i prihvatanje putanje. Provera je obavezan završni korak `tools/build-android.ps1`; samo desktop testovi ne otkrivaju promene putanja pri Android pakovanju.

## Prevodi

`tools/translations.tsv` sadrži EN ključeve i DE/FR/ES/IT prevode. `tools/build-translations.py` proverava formatne parametre i ažurira `game/data/translations.json`; postojeći SR prevodi ostaju u katalogu. Tehnički nazivi i licence se ne prevode. Novi jezici imaju tekstualni zlatni natpis pobede nad bossom, dok EN/SR zadržavaju već usvojene ilustracije.

## Server i provere

Migracija `202609190005_six_languages.sql` samo proširuje dozvoljene jezike četiri postojeće tabele. `daily` koristi identične pool-ove/početne reči kao Godot; EN/SR deterministički tokovi nisu promenjeni. `tools/prepare-daily-dictionaries.mjs` pravi privatne gzip datoteke za bucket `daily-dictionaries`. Četiri nova SHA256 pina su javne konstante u funkciji; stari EN/SR pinovi ostaju u postojećoj konfiguraciji.

Za buduće izmene ponoviti: Godot `test_languages.gd`, `test_daily.gd`, Node `tools/test-daily.mjs`, `tools/test-daily-service.mjs`, `tools/test-six-languages.mjs`. `test_languages_online.gd` koristi zasebnu anonimnu sesiju, proverava početak dnevnih pokušaja i liste, ne objavljuje rezultate. `render_settings.gd` pravi šest stvarnih rendera u `.local/`.
