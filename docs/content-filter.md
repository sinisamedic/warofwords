# Filter rečnika — 0.1.25

Korisnik je 2026-09-22 odobrio filter neprikladnih reči za svih šest jezika radi pripreme igre za publiku 9+. Filter važi jednako za sve uzraste, lokalnu igru i rangirani dnevni izazov. Konačna IARC ocena nije određena samim filterom.

`tools/content-filter-rules.json` je projektni spisak obrazaca za psovke, vulgarne seksualne izraze uvredljive nazive i reference na ilegalne droge. `python tools/build-content-filter.py` pretražuje postojeće licencirane rečnike i generiše tačne isključene oblike u `game/data/blocked-words.json` i serverski `supabase/functions/daily/content-filter.mjs`. Ne menja originalne rečnike ni njihove licence. Obrasci i generator priloženi su u arhivi odgovarajućih izvora rečnika.

| Jezik | Isključeni oblici |
| --- | ---: |
| en | 308 |
| sr | 7577 |
| de | 866 |
| fr | 656 |
| es | 843 |
| it | 3480 |

Ukupno 13.730. To je početni održavani spisak, ne tvrdnja da je sav regionalni žargon otkriven. Dvosmislene vulgarne reči mogu biti isključene i kada imaju neutralno značenje; prijavljene pogrešne zabrane pregledati pojedinačno. Testovi čuvaju obične reči poput ASSASSIN/CLASS/COCKPIT, DISPUTE/DISPUTER/IMPUTER i SERUM/SERUMA/SERUMIMA.

Godot uklanja blokirane oblike pre pravljenja indeksa. Zato isti filter važi za validaciju poteza, automatska rešenja/hintove, zamenu džokera i izbor reči za dopunu/generisanje. Slova se i dalje nasumično raspoređuju: nije obećano odsustvo svake slučajne kombinacije slova, ali blokirana kombinacija nije prihvaćena niti ponuđena kao reč. Filter nije moderacija korisničkih nadimaka na rang-listi i ne briše istorijske zapise; to ostaje zaseban posao pre javne objave.

Serverski `DailyRules.accept` proverava isti spisak pre bodovanja, čak i kada sirovi rečnik prihvata reč. Originalni server dictionary objekti i hash pinovi ostaju isti. Replay v1/v2 algoritmi nisu menjani, ali blokirani potezi više nisu dozvoljeni ni starom klijentu. `tools/bundle-daily-function.mjs` uključuje filter u jednodatotečni deployment za dashboard.

Provere: `test_content_filter.gd`, `tools/test-content-filter.mjs`, postojeći Godot testovi i Node daily/six-languages/service provere. `tools/check-apk-dictionaries.ps1` sada izvlači i proverava i filter iz finalnog APK-a; odsutan filter je greška. Pre novog izdanja regenerisati oba filtera i `tools/package-dictionary-sources.py`, proveriti diff, zatim objaviti funkciju i napraviti pakete. Nikada ne slati ovaj interni dokument sa primerima kao tekst prodavnice.
