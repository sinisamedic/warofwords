# Plan igre — početni predlog

Datum istraživanja: 15. septembar 2026.
Status: predlog za razgovor, bez implementacije.

Ovo je sačuvano početno istraživanje. Aktuelne odluke su u [game-design.md](game-design.md), stanje u [../STATUS.md](../STATUS.md), a aktivno podešavanje u [setup.md](setup.md). Poslednja korisnička instrukcija: engine još nije konačno izabran.

## 1. Potvrđeni zahtevi korisnika

- Originalna mobilna igra za Android i iOS; komunikacija na srpskom.
- Slova u krugovima; prevlačenje prstom sastavlja postojeće reči.
- Prihvaćene reči daju resurse; aktiviranje napada/sposobnosti troši resurse.
- Osećaj borbe i napredovanja nalik Slugterra, verovatno Slugterra: Slug it Out 2. Tačno izdanje treba potvrditi.
- Originalan svet, likovi, nazivi, grafika i identitet; raniji vitezovi i grafički testovi nisu deo projekta.
- Prvo istraživanje i dogovor osnovne mehanike i tehnologije, zatim mali igrivi prototip.
- Prioritet: dodir, čitljivost, zanimljive odluke, besplatni alati i mali početni troškovi.
- Posle dogovora samostalno obavljati rutinske, reverzibilne korake.

## 2. Referenca — šta je provereno

Istraživanje je zasnovano na javnim opisima izdavača i beleškama izdanja. Nije obavljeno direktno igranje niti merenje balansa referentne igre.

- Aktuelni opis izdavača potvrđuje match-3 borbu koja puni tim, ručno tempiranje sposobnosti, više od 100 kolekcionarskih slugova, elemente, nivoe i evoluciju, priču kroz 99 pećina, PvE/PvP i događaje. [Google Play](https://play.google.com/store/apps/details?id=com.dhxmedia.slugitout2&hl=en-GB)
- Likovi i svet uključuju Eli-ja, Dr. Blakk-a i Shadow Clan. Beleške izdanja pominju Burpy-ja i Slicksilver-a; za Slicksilver Megamorph izričito navode usporavanje neprijatelja magnetnim poljem. Potvrđeni su Megamorph unapređenja, artefakti, prizivanje, više sačuvanih timova i zadaci. [App Store](https://apps.apple.com/us/app/slugterra-slug-it-out-2/id1148766137)
- Istorijski opis navodi novčiće, dragulje i kamenje evolucije, nagrade i unapređenja. To nije dokaz današnjih cena niti kompletnog spiska resursa. [Istorijski opis igre](https://toucharcade.com/games/slugterra-slug-it-out-2)
- Arhivirani AMA izdavača iz 2020. govori o balansiranju boss susreta i resursima; označen je kao zastareo. Pitanje o fusion napadima tu nije dokaz da su oni danas implementirani. [AMA](https://nightmarketgames.atlassian.net/wiki/spaces/SUPP/pages/861733196)

Nisu potvrđene precizne vrednosti štete, punjenja, troškovi nadogradnji ni kompletna aktuelna ekonomija. Ne koristiti izmišljene brojke kao podatke reference.

Prenosivi principi (naša procena): slagalica napaja borbu; igrač bira trenutak napada; kombinovanje različitih uloga daje dubinu; nove sposobnosti pružaju motivaciju. Reči zahtevaju više razmišljanja od prepoznavanja boja, pa neprijateljski ritam mora biti sporiji i čitljiviji.

## 3. Predlog osnovne borbe — još nije dogovoren

- Uspravan ekran. Gore borci, zdravlje i jasna najava sledećeg neprijateljskog poteza; sredina energija i tri sposobnosti; dole sedam krugova sa slovima i prikaz sastavljene reči iznad prsta.
- Cilj trajanja borbe 90–150 sekundi; pobeda kada protivnik izgubi zdravlje, poraz kada ga izgubi igrač. Nema ukupnog vremenskog ograničenja u prvom prototipu.
- Sedam slova ostaje na svojim mestima tokom sastavljanja i između prvih nekoliko reči. Svako slovo može da se poveže sa bilo kojim drugim; ukrštanje putanja je dozvoljeno. Jedan krug koristi se jednom po reči; duplirano slovo zahteva dva kruga.
- Povratak preko prethodnog kruga briše poslednje slovo. Puštanje prsta šalje reč. Prekid dodira zbog operativnog sistema otkazuje pokušaj, bez slanja.
- Dovoljno velike dodirne zone, diskretna vibracija/zvuk i jasno osvetljenje izabranih slova. Proveravati presek putanje sa krugom između dva događaja dodira da brz prst ne preskače slova. Bez pomeranja table ili efekata koji zaklanjaju slova tokom poteza.
- Posle tri različite prihvaćene reči menja se ceo skup. Automatska zamena tek posle puštanja prsta; borbeni sat miruje tokom tranzicije. Pamti se istorija skupova da se ne vraćaju odmah.
- Besplatno mešanje menja samo raspored, ne reči. Ručna zamena daje novi skup, ima početni cooldown 12 sekundi i ne zaustavlja neprijateljski sat. Ako nema dovoljno novih rešenja, sistem besplatno menja skup bez kazne. Zamena tokom dodira nije dozvoljena.

### Kako garantovati igriv skup

Za prototip napraviti najmanje 30 ručno pregledanih skupova od sedam slova. Svaki mora imati najmanje osam dozvoljenih reči, od kojih najmanje pet čestih i najmanje dve od pet ili više slova. To su ciljevi kvaliteta koje treba proveriti za izabrani jezik; ako ne prolaze, menjamo veličinu skupa/prag, a ne tvrdimo da su ostvareni.

Za kasniji generator: izabrati osnovnu reč, upotrebiti njena slova i dopuniti skup; izračunati sve reči čiji broj pojavljivanja svakog slova staje u skup. Kandidata prihvatiti samo kada prođe prag broja, dužine i poznatosti reči. Unapred izgraditi banku i imati rezervne skupove. Sam odnos samoglasnika i suglasnika nije dovoljan dokaz igrivosti. Ne generisati teški rečnik usred animacije.

### Rečnik i validacija

- Offline spisak normalizovanih dozvoljenih reči. Unicode NFC i jednako tretiranje velikih/malih slova; dijakritika se ne briše.
- Minimalno tri slova. Svaki zapis mora biti dozvoljen u rečniku i ostvariv raspoloživim krugovima.
- Jedna ista reč daje energiju jednom u trenutnom skupu. Posle zamene sme ponovo: ne kažnjavamo igrača zbog istorije cele borbe. Mešanje rasporeda ne resetuje iskorišćene reči.
- Prihvatati uobičajene padeže, množinu i glagolske oblike koji su eksplicitno uključeni u pripremljeni rečnik. Svaki različiti oblik je zasebna reč u prvom prototipu. Složenije umanjenje nagrade za isti koren uvoditi samo ako testiranje pokaže potrebu.
- Isključiti vlastita imena, skraćenice, reči sa crticama/razmacima i neodgovarajuće izraze prema budućoj publici. Ekavske/ijekavske oblike uključiti kada ih odabrani rečnik podržava i kada su pregledani.
- Nevažeći pokušaj: kratko „Nema u rečniku“, bez gubitka zdravlja/energije; sat nastavlja. Ponovljena reč dobija posebnu poruku. Odbijene pokušaje beležiti lokalno radi pregleda propusta rečnika.
- Ne koristiti AI niti mrežni API kao sudiju reči tokom igranja.

### Energija i odluke

Početne brojke su isključivo hipoteza za testiranje:

| Dužina reči | Energija |
| --- | ---: |
| 3 | 3 |
| 4 | 5 |
| 5 | 8 |
| 6 | 12 |
| 7 | 17 |

Jedna zajednička energija, kapacitet 30; ne prenosi se između borbi. Nema automatskog napada.

- Udarac: 6 energije, direktna šteta.
- Štit: 5 energije, ublažava sledeći pogodak; ne sabira se sam sa sobom.
- Prekid: 10 energije, otkazuje najavljeni napad i pokreće novi ciklus; cooldown 15 sekundi sprečava beskonačno zaključavanje protivnika.

Na primer, reči od četiri i pet slova daju 13 energije: udarac i štit koštaju 11, ili igrač može sačuvati resurs za prekid. U probnom balansu krenuti od 100 zdravlja igrača, 80 protivnika, štete udarca 10, protivničke štete 12 i štita koji ublažava 8; proveriti trajanje i održivost različitih strategija.

Težina nije isto što i retkost: ne nagrađivati opskurne reči velikim bonusima. Prvo nagrađivati samo dužinu. Kasnije probati vidljivo označeno bonus-slovo (+1 energije jednom po reči) ili izazov duge reči. Bonus mora unapred biti razumljiv.

Kasnija opcija: osnovna energija za sve sposobnosti i jedan fokus za svaku reč od najmanje pet slova, najviše tri; specijalni potez troši tri fokusa. Više tipova uvoditi tek ako jedna energija ne daje dovoljno odluka.

### Neprijatelji i pravičnost

- Preporuka: blagi realni tempo; prvi napad posle 12 sekundi, sledeći na 10 sekundi, jasna najava poslednje tri sekunde. Slova ostaju potpuno čitljiva.
- Alternativa za poređenje: isti susret u potezima, protivnik reaguje posle dve prihvaćene reči, bez vremenskog pritiska. Ovo je test opcija, ne dva kompletna režima za produkciju.
- Pauza i odlazak aplikacije u pozadinu zaustavljaju borbu. Neprijateljski udarac ne otkazuje aktivno prevlačenje.
- Bez skrivenog ubrzavanja jer igrač dobro igra. Lakši režim produžava intervale; teži uvodi obrazac napada. Iste početne table koristiti kada poredimo taktike.
- Raznovrsnost dolazi iz oklopa, najavljenog snažnog udara i promene boss faze, ne iz sitnih slova ili obaveznih retkih reči.

## 4. Napredovanje

Prvi prototip: tri sposobnosti, dva obična neprijateljska obrasca i jedan jednostavan boss; jedna nadogradnja koju biramo između susreta.

Primer grane nadogradnje štita: duže čuva zaštitu ili pri pravilnom tempiranju vraća malo energije. Igrač bira jednu granu; obe treba da budu korisne u različitim susretima. Nadogradnja menja odluku, ne samo veličinu broja.

Kasnije:

- Tri opremljena oružja/sposobnosti iz veće kolekcije; kombinacije direktnog napada, odbrane i kontrole.
- Proboj oklopa naspram slabijeg lančanog udarca; jak štit naspram kraćeg reflektujućeg štita; prekid naspram usporavanja.
- Kratke oblasti od nekoliko borbi i boss susreta. Prva pobeda garantuje nacrt nove sposobnosti; obične pobede daju materijal za izabranu nadogradnju.
- Boss menja obrazac pri polovini zdravlja, najavljuje promenu i ostavlja najmanje dva moguća odgovora. Nijedno prethodno neotključano oružje ne sme biti jedini način pobede.
- Nove oblasti uvode jednu novu mehaniku; kozmetičke nagrade i dodatni izazovi tek nakon osnovne kampanje.
- Bez plaćenih nasumičnih nagrada, PvP-a, događaja, servera i reklamne ekonomije u prototipu. Monetizacija nije dogovorena.

## 5. Otvoreni vizuelni pravci

Radni opisi, ne konačni nazivi:

1. Bio-svetleće ekspedicije: istraživači i originalna mala bića na plutajućim ostrvima; reči pobuđuju njihove organe/sposobnosti. Tamne plave podloge, koralni akcenti, zaobljene siluete.
2. Radionice odjeka: mladi pronalazači i modularni roboti; reči su komande koje pune uređaje. Svetle podloge, tirkizna i narandžasta, čiste 2D konture. Najlakša početna produkcija po našoj proceni.
3. Arhipelag mastila: žive ilustracije i čuvari knjiga; reči stvaraju napade od mastila. Papirna tekstura, tamnoplava i jedna jarka boja, animacija isečenih delova.

Nijedna tema nije izabrana. Ne generisati finalne likove niti praviti identitet pre razgovora.

## 6. Tehnologija

Preporuka, ne odluka: Godot 4, GDScript, 2D, Compatibility renderer kao početna opcija. Izabrati konkretnu stabilnu verziju i proveriti izvoze posle dogovora.

| Opcija | Procena za ovu igru |
| --- | --- |
| Godot | Direktni događaji dodira, 2D scene i animacije, jednostavne izmene i dovoljno performansi za mali broj likova. MIT, bez pretplate/royalty naknade. Android SDK/JDK za Android; macOS/Xcode za iOS. Preporuka za mali tim. |
| Unity | Dobar sistem dodira, 2D animacije i veliki ekosistem mobilnih dodataka. Više paketa i podešavanja; smislen ako imamo iskustvo u C# ili plan za mnogo SDK integracija. Personal ima prag prihoda/finansiranja ispod 200.000 USD za prethodnih 12 meseci. |
| Defold | Besplatan, mali runtime, Lua, 2D i mobilni izvoz. Dobar ako prioritet postane veličina aplikacije; procenjujemo da bi nam tražio više ručnog povezivanja interfejsa. |
| Unreal | Može obraditi dodir i ovu borbu, ali procenjujemo da 3D alatni tok i složeniji mobilni build nisu opravdani ovim obimom 2D igre. Standardni model naknade je 5% iznad prvog miliona USD bruto prihoda proizvoda, uz izuzetke/uslove. |

Performanse nisu izmerene ni u jednom engine-u. Cilj je stabilnih 60 fps na dogovorenom telefonu. Pakovanje tekstura, broj providnih slojeva i opterećenje rečnika moraju se testirati na uređaju.

Android prototip: APK direktno na uređaj sa Windows računara, zatim potpisani AAB za Google Play. iOS u Godotu: pristup Mac-u i Xcode-u, potpisivanje i test na iPhone-u; TestFlight za širu probu. Ne odlagati prvi iOS test do završetka grafike.

Troškovi naloga prema trenutno dostupnim zvaničnim stranicama: Google Play 25 USD jednokratno; Apple Developer Program 99 USD godišnje. To nisu ukupni troškovi projekta niti procenat prodaje; Mac pristup i eventualni kupljeni resursi su odvojeni. Zahteve prodavnica proveriti ponovo pri objavljivanju.

Izvori: [Godot mogućnosti](https://godotengine.org/features/), [licenca](https://godotengine.org/license/), [dodir](https://docs.godotengine.org/en/stable/classes/class_inputeventscreendrag.html), [Android](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html), [iOS](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_ios.html), [Unity Personal](https://unity.com/products/unity-personal), [Unity 2D](https://docs.unity3d.com/Manual/Unity2D.html), [Defold](https://defold.com/), [Defold iOS](https://defold.com/manuals/ios/), [Unreal](https://www.unrealengine.com/release), [Apple](https://developer.apple.com/programs/), [Google Play](https://support.google.com/googleplay/android-developer/answer/6112435).

## 7. Dostupni alati i način produkcije

Lokalno provereno:

- Radni folder je na početku sadržao samo .git; nisu pronađeni projektni kod ni AGENTS.md u pretraženom ChatGPT stablu.
- Blender MCP je odgovorio na čitanje scene; scena sadrži Cube, Light i Camera. Nije menjana. Verzija i izvoz nisu testirani.
- Inkscape MCP dijagnostika: Inkscape 1.4.2 dostupan na C:/Program Files/Inkscape/bin/inkscape.COM. Prijavljeni SVG/PNG izvozi i shell podrška; lista akcija nije parsirana, live helper nije pronađen. Ne smatrati upravljanje otvorenim prozorom potvrđenim niti izvoze praktično testiranim.
- AI image-generation alat je dostupan u sesiji; ništa nije generisano i besplatna upotreba nije pretpostavljena.
- adb komanda je pronađena. Godot nije pronađen u PATH-u; to nije dokaz da nije instaliran drugde. SDK/JDK i telefoni nisu provereni. Audacity nije proveravan kao instalacija.

Predlog produkcije: prototip koristi jednostavne vektore, čitljiv font, tri kratka efekta napada i nekoliko sintetičkih zvukova. Posle izbora teme Inkscape za interfejs/ikone, AI za koncepte i moguće pozadine, pa ručno usklađivanje palete i proporcija. Slova uvek renderovati fontom u igri. Likove podeliti u delove i animirati u engine-u (mirovanje, priprema, napad, pogodak). Blender koristiti ako odaberemo 3D modele renderovane u 2D sličice. Za audio preporuka je besplatan [Audacity](https://www.audacityteam.org/) za obradu naših snimaka i sinteze; muzika kasnije. Za svaki spoljašnji materijal sačuvati izvor i licencu.

## 8. Jezik i rečnik — odluka korisnika

- Srpski: najprirodniji za testere kojima je maternji; [hunspell-sr](https://github.com/grakic/hunspell-sr) podržava latinicu i ćirilicu. Izvor navodi izbor LGPL 2.1+, MPL 1.1+, GPL 2+ ili CC BY-SA 3.0. Pre uključivanja izabrati tačnu verziju, licencni put i sačuvati obaveštenja; ne pretpostaviti da licenca alata pokriva sve rečnike.
- Hunspell .dic nije dovoljan spisak svih oblika: obraditi pripadajuća .aff pravila van igre, filtrirati rezultate i ručno proveriti česte reči. Obim morfologije i poznatost reči zahtevaju urednički rad.
- Za srpsku latinicu č, ć, š, ž, đ ostaju odvojena slova. Predlog: LJ, NJ i DŽ kao po jedan krug/slovo; moraju postojati izuzeci za granice morfema, ne slepo spajanje svakog niza znakova. Ćirilica jednostavnije predstavlja ta slova jednim znakom. Bodovanje računati po jezičkim slovima, ne UTF-8 bajtovima ili broju prikazanih latiničnih znakova.
- Engleski: [ESDB, ranije SCOWL](https://github.com/en-wl/wordlist) daje poznatost, varijante pisanja i oblike; repo navodi MIT-like licencu kombinovanog rada i BSD-kompatibilne izvore. Pre distribucije pročitati Copyright tačne verzije. Odabrati američki ili britanski skup i pravilo za česte alternativne zapise.
- Preporuka: jezik koji prvi testeri najbolje poznaju. Engleski pojednostavljuje početnu tehničku pripremu, ali test na slabije poznatom jeziku može dati pogrešan utisak da sama borba nije zabavna.
- Rečnik, pregledani skupovi, konfiguracija bodovanja i licencni tekst spakovani uz aplikaciju omogućavaju rad bez interneta. Jezički paketi moraju imati sopstvene table i balans; prevod interfejsa nije dovoljan.

## 9. Najmanji igrivi prototip i provera

Redosled nakon dogovora:

1. Potvrditi referencu, jezik, engine i test uređaj; zabeležiti odluke ovde.
2. Prazan mobilni projekat; odmah proveriti Android izvoz, a iOS čim je Mac dostupan.
3. Jedan ekran sa sedam slova, pouzdanim prevlačenjem, validacijom i 30 pregledanih skupova.
4. Jedna borba sa tri sposobnosti, energijom, najavom napada i pobedom/porazom.
5. Drugi obrazac protivnika, boss sa dve faze i jedan izbor nadogradnje između susreta; jednostavan ekran sledeće borbe, bez mape.
6. Lokalno čuvanje podešavanja, izabrane nadogradnje i rezultata; bez naloga/servera/reklama. Ponovni početak treba biti trenutan.

Prva korisna proba već posle koraka 4; koraci 5–6 samo minimalno proveravaju raznovrsnost i osećaj napredovanja.

Testovi: multiskup slova sa duplikatima; dijakritika; iskorišćene reči; nepostojeći oblici; svi skupovi imaju potreban broj rešenja; energija se tačno dobija/troši; cooldown; pauza i vraćanje iz pozadine. Na telefonu: brz potez, vraćanje putanje, gubitak dodira, drugi prst, ivice ekrana, duga reč, mali ekran i odbijena reč.

Cilj prvih proba: 3–5 osoba, nekoliko kratkih borbi. Beležiti vreme do reči, odbijene pokušaje, korišćenje zamene i izbor sposobnosti. Gledati da li prevlačenje promašuje nameru, da li postoji odluka napad/odbrana/čekanje i da li poraz ima razumljiv razlog. Ako jedna sposobnost dominira ili svi stalno menjaju slova, prvo menjati balans/ponudu. Uspeh je razumljiv i prijatan unos plus želja za još jednom borbom, ne broj izgrađenih sistema.

## 10. Otvorene odluke

1. Da li je tačna referenca Slugterra: Slug it Out 2?
2. Jezik prototipa; za srpski i pismo.
3. Prihvatanje preporuke za Godot i blagi realni tempo ili izbor alternative.
4. Vizuelni pravac (može ostati otvoren tokom prvog testa dodira).
5. Raspoloživi Android/iPhone uređaji i pristup Mac-u.

## 11. Dnevnik odluka

2026-09-15, nastavak: korisnik je raspakovao i pokrenuo standardni Godot 4.7.2 u `C:/Projects/Godot`. Pripremljen odvojeni probni projekat i praktično proverena MCP veza (kreiranje, izmena, čuvanje, pokretanje, snimak). `godot-local` dodat u Codex konfiguraciju. Detalji i ograničenja: [GODOT-SETUP.md](GODOT-SETUP.md). Ovo potvrđuje pripremu Godot okruženja; jezik, tema i balans još nisu dogovoreni.

2026-09-15: Zabeleženi korisnički zahtevi, izvori i početni predlog. Nije potvrđen nijedan ponuđeni engine, jezik, tema ili konkretan balans. Implementacija nije započeta. Sledeće: korisnički odgovori, pa zapis potvrđenog smera.
