# Nastavak rada — War of Words

> **Dopuna 2026-09-18:** korisnik je probao 0.1.13 i odobrio proširenje. Na `codex/campaign-wave-two` implementirani su 24 nivoa / šest lokacija i Žar, Rezonator, Bastion, Crpljenje: ukupno 12 uređaja + dva artefakta. Prioriteti 2 i 3 ispod sada su sprovedeni za obim od 24 nivoa. Sledeća je korisnička proba desktop pregleda i balansa; APK nije pravljen. Ostaju predlozi četiri uređaja i četiri artefakta. Korisnik prihvata deinstalaciju pri budućem APK-u sa drugim potpisom. Ostatak stranice je pregled prethodnog objavljenog izdanja 0.1.13.

Ažurirano 2026-09-18. Aktivna grana: **`codex/equipment-wave-one`**. Poslednji objavljeni paket: **0.1.13 / code 14**. Izvor tog APK-a: `53230bb`; kasniji commit-i dokumentacije ne zahtevaju novi build. [Izdanje i APK](https://github.com/sinisamedic/warofwords/releases/tag/v0.1.13-android-preview).

## Šta je završeno

- Godot 4.7.2, mobilna landscape igra protiv računara; engleski/srpski interfejs i rečnik, nezavisan izbor jezika, susedno ili slobodno povezivanje slova.
- Dvanaest susreta u tri lokacije sa svojim pozadinama, animiranim prelazima i različitim protivnicima. Tipovi protivnika: teški napadači, iscelitelji i oklopljeni protivnici, uz uvodnu obuku.
- Osam uređaja: Puls, Proboj, Egida, Ogledalo, Luk, Pečat, Isceljenje i Obnova. Dva artefakta: Pečat leksikona i Rezervna ćelija. Arsenal, opremanje i zajednička unapređenja po boji rade.
- Otključavanje opreme prema pobedama/podvigu, trajno sačuvan red dijaloga novih nagrada, velika nagrada na mapi i ukrašen bedž kada je osvojena.
- Jasno istaknuto odabrano pojačanje pre borbe, broj završenog nivoa na pobedi i medaljoni bez crnog donjeg oboda. Korisnik je pregledao i odobrio ove izmene pre APK-a.
- Ilustrovani meniji, W ikonica aplikacije, detaljan Proboj, štitovi, punjenje oko medaljona, projektili sa štetom na udaru, zvuk, muzika, vibracija i Reduced Motion. Heroj ima artikulisanu animaciju u borbi; na naslovnoj ostaje cela ilustracija.
- Dnevni izazov, offline vežba, nadimak i globalna rang-lista postoje. Server proverava poteze i bodove; ovo još nije trajni nalog sa oporavkom i sinhronizacijom.
- Čuvanje napretka i nastavak nedovršene borbe. Android nadogradnja 0.1.12 → 0.1.13 u emulatoru čuva ceo progress fajl.

Detaljna aktivna pravila: [game-design.md](game-design.md). Poslednje provere: [QA-0.1.13.md](QA-0.1.13.md): **1.570 PASS / 0 FAIL**, refill benchmark, vizuelni pregled i Android dodiri. To nije zamena za dužu probu na Samsungu.

## Od čega nastaviti kod kuće

1. Pročitati `AGENTS.md` i najnoviji odeljak `STATUS.md`, proveriti stanje i nastaviti istu granu. [Prenos i podešavanje](setup.md).
2. Probati objavljenu 0.1.13 na Samsungu, instalacijom preko 0.1.12 bez deinstalacije. Posebno pogledati nagrade za nivoe 3/4/6/8/10, sva tri pojačanja i broj nivoa na rezultatu.
3. Zabeležiti konkretne primere: broj nivoa, jezik/rečnik, pravilo povezivanja, opremu, dužinu borbe i eventualni problem. Ako postoje novi screenshotovi ili primedbe, oni imaju prednost nad predlozima ispod.
4. Ako je prikaz dobar, sledeći preporučeni posao je **balans prvog talasa i kvalitet dopune u dužoj partiji**. Uporediti Egidu/Ogledalo protiv jakog napadača, Luk/Pečat protiv iscelitelja i Isceljenje/Obnovu u dužoj borbi. Proveriti i duge reči na oba jezika i oba načina povezivanja.

Sve tražene izmene do 0.1.13 su završene. Nema poznatog nedovršenog zahteva iz poslednjeg pregleda; povratna informacija sa fizičkog telefona još se očekuje. Novi razvoj ispod je **predlog**, ne automatski odobren obim sledećeg APK-a.

## Šta bismo mogli dalje — predloženi redosled

| Prioritet | Predlog | Konkretan rezultat |
| --- | --- | --- |
| 1 | Balans opreme i dopune | Upoređene alternative imaju različitu korisnu ulogu; zabeleženi problematični nivoi i nizovi tabli, pa male ciljane korekcije. Ne obećavati garantovanu dugu reč na svakoj tabli. |
| 2 | Drugi talas opreme | Žar, Rezonator, Bastion i Crpljenje, prema postojećem predlogu kolekcije. Najpre potvrditi izbor i način otključavanja; zatim dizajn, efekti i test međusobnih uticaja. |
| 3 | Duža kampanja | Predlog 24–30 susreta, nove lokacije, protivnici i boss faze. Rasporediti nove nagrade tako da imaju smisla u napredovanju; broj nivoa još nije odobren. |
| 4 | Animacije protivnika i povratna informacija | Prave poze/animacije za odabrane protivnike, jasniji aktivni statusi Pečata, Obnove i Ogledala. Prvo jedan protivnik za pregled, pa ostali. |
| 5 | Trajni profil i oporavak napretka | Dogovoriti prijavu/povezivanje postojećeg anonimnog profila, oporavak posle reinstalacije i pravila sinhronizacije više uređaja. Trenutni nadimak nije takav nalog. |
| 6 | Dnevni izazov i prijatelji | Istorija ličnih rezultata, zatim eventualno izazov prijatelju na istoj tabli. Duel uživo je zaseban veći posao; još nije implementiran. |
| 7 | Rečnik i dnevnik reči | Pregled neprihvaćenih/čudnih oblika, omiljene reči i eventualna kratka objašnjenja uz licenciran izvor. Ne menjati puni rečnik ili pravila rangiranja bez dogovora. |
| 8 | Priprema za šire testiranje | Izmeriti start, FPS, memoriju i potrošnju na fizičkim uređajima; smanjiti APK gde ima koristi; pripremiti oporavak naloga, moderaciju/ograničenja za javnu rang-listu i završne podatke o izvorima. |

### Ostatak kolekcije

[equipment-collection.md](equipment-collection.md) opisuje predlog **16 uređaja i šest artefakata ukupno**, a ne toliko novih predmeta. Aktivno je **8 + 2**, pa ostaje još **8 uređaja + 4 artefakta**:

- Drugi talas: Žar, Rezonator, Bastion, Crpljenje.
- Kasniji talas: Kontraštit, Peščanik, Gravitacija, Životna rezerva.
- Preostali artefakti: Prizmatično sočivo, Čuvarev pečat, Žiroskop fokusa, Feniksov amblem.

Brojke, kombinacije i otključavanja za neimplementirane predmete su predlozi. Monetizacija, iOS i konačno javno izdanje nisu dogovoreni.

## Šta se ne prenosi običnim pull-om

- **Android signing ključ i lozinka:** ostaju van Git-a. Za nadogradnju postojeće instalacije koristiti isti ključ kao 0.1.10–0.1.13, sertifikat SHA256 `a071affaa411155113450b13d9ffaa9b7bf51312cb0a23087ca685680d18d276`. Kućni potpis 0.1.7–0.1.9 je drugačiji. Pre novog builda proveriti potpis; ne generisati drugi ključ bez dogovora. Ključ treba zasebno bezbedno preneti, a ovaj commit ga ne prenosi.
- **`game/online_config.json`:** ignorisana javna klijentska konfiguracija (URL + publishable key), potrebna za rangirani dnevni izazov. Preneti/podesiti zasebno prema [daily-online.md](daily-online.md); nikada ne stavljati serverski secret u igru. Postojeći Supabase servis ne treba ponovo kreirati/deploy-ovati samo zato što je promenjen računar.
- **Godot, SDK, JDK i export šabloni:** instalacije i lokalne putanje nisu u Git-u. [Android uputstvo](android.md).
- **`.local/` i `exports/`:** lokalni logovi, interaktivni pregled, snimci i build izlazi nisu verzionisani. APK se preuzima sa Releases. Izvor, slike/zvukovi, izveštaji provera i render skripte jesu u Git-u.

Za ponovljiv vizuelni pregled na drugom računaru koristiti `game/tests/render_campaign_polish.gd` kroz Godot; prethodne F1–F4 prečice bile su deo lokalne preview skripte, ne same igre.
