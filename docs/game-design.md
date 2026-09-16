# Dizajn igre — odluke i hipoteze

## Usvojeni zahtevi

- Originalna mobilna igra za Android i iOS.
- Slova su u krugovima; igrač prevlačenjem sastavlja postojeće reči.
- Prihvaćene reči daju resurse. Ručno aktivirani napadi/sposobnosti troše resurse.
- Osećaj borbe i napredovanja inspirisan Slugterrom, uz originalne likove, svet, nazive i grafiku. Vitezovi i prethodni grafički testovi ne pripadaju igri.
- Prioritet su dodir, čitljiv ekran i zanimljive odluke; mali početni troškovi.
- Velika implementacija čeka dogovor o osnovnom smeru. Tema i engine nisu zaključani.

## Proverena referenca

Polazna referenca je zasad Slugterra: Slug it Out 2, uz potrebnu korisničku potvrdu. Izdavač opisuje match-3 punjenje tima, tempiranje sposobnosti, kolekciju slugova, nivoe, evoluciju i borbene sadržaje. Istraživanje je čitanje izvora, ne direktno merenje igre. [Google Play](https://play.google.com/store/apps/details?id=com.dhxmedia.slugitout2&hl=en-GB), [App Store](https://apps.apple.com/us/app/slugterra-slug-it-out-2/id1148766137).

Detalji i granice dokaza ostaju u [početnom planu](PLAN.md), odeljak 2. Ne predstavljati naše brojke kao balans reference.

## Predlog najmanjeg prototipa — NIJE usvojeno

Uspravan ekran; borba gore, tri sposobnosti u sredini, sedam slova dole. Jedna offline borba od približno dva minuta, uz trenutno ponovno pokretanje.

- Bilo koji krug može da se poveže sa drugim; svaki jednom po reči. Dva ista slova zahtevaju dva kruga. Povratak poništava poslednje slovo, puštanje šalje reč.
- Pregledani skupovi garantuju više uobičajenih reči. Cilj: 30 skupova, najmanje osam reči po skupu; prag proveriti na stvarnom rečniku.
- Prvi predlog: isti skup kroz tri različite prihvaćene reči, zatim zamena. Besplatno mešanje rasporeda; ručna zamena uz cooldown. Sistem nikada ne menja slova tokom prevlačenja.
- Offline validacija; najmanje tri slova, dijakritika sačuvana. Česti fleksijski oblici dozvoljeni po pripremljenoj listi. Ista reč daje energiju jednom po skupu.
- Jedna energija: reči dužine 3/4/5/6/7 daju 3/5/8/12/17. Udarac 6, štit 5, prekid 10. Sve brojke su hipoteze.
- Blagi realni tempo, najavljen napad približno na 10 sekundi; alternativno testirati potezni tempo bez pritiska sata.
- Prvi test: jedan susret. Tek nakon uspešnog unosa drugi obrazac protivnika, jednostavan boss i jedan izbor nadogradnje.

## Šta test treba da razjasni

1. Da li isti skup kroz više reči pomaže planiranju ili podstiče mehaničko nabrajanje oblika?
2. Da li je 10 sekundi dovoljno za ciljnu publiku? Bez izabranog jezika i prvih testera to ne možemo pouzdano proceniti.
3. Da li igrač ima razloga da bira napad/štit/čekanje umesto stalnog istog dugmeta?
4. Da li duge reči daju koristan bonus bez potpunog potiskivanja kratkih?
5. Da li odbijene reči pokazuju propust rečnika ili nejasno pravilo?

Testirati iste početne skupove kroz varijante kako slučajna ponuda ne bi odlučila rezultat. Beležiti lokalno vreme do prihvaćene reči, nevažeće pokušaje, zamene i korišćenje sposobnosti. Ne uvoditi analitički server za prvi test.

## Kasniji predlozi

- **Vizuelni predlog 2026-09-16:** izrađen [atlas ekrana](../mockups/README.md) i [opis dizajna ekrana](screen-design.md). „Svet odjeka“, ostrva, svetionik, mali odjeci i srpska latinica služe konkretnom mockupu; **nisu usvojene odluke**. Atlas ima 84 ekrana/stanja i osam tokova; nije implementacija igre niti izbor engine-a.

- Grane nadogradnji koje menjaju taktiku: duži štit ili povraćaj energije; proboj oklopa ili više pogodaka; prekid ili usporavanje.
- Oblasti sa novom mehanikom i boss obrascem; garantovane nove sposobnosti za prve pobede.
- Vizuelni pravci: bio-svetleće ekspedicije, radionice odjeka, arhipelag mastila. Nijedan nije usvojen.
- Jezik: srpski latinicom/ćirilicom ili engleski; izbor zavisi od prvih testera. Proveriti konkretnu verziju i licencu rečnika pre uključivanja.

## Otvorene odluke za sledeći razgovor

Prvo engine i jezik/pismo; zatim tempo borbe i ciljna publika. Tema može ostati otvorena tokom tehničke probe dodira. Detaljno objašnjenje opcija, rečnika i napredovanja: [PLAN.md](PLAN.md).
