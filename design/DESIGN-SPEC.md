# Specifikacija dizajna — šest osnovnih ekrana

Status: vizuelni predlog za korisnikov pregled. Cilj kasnije implementacije: Godot. Trenutni isporučeni materijal: statične slike i dokumentacija; bez scena, skripti ili simulacije igre.

## 1. Zajednički vizuelni jezik

Svet: sunčane peščane ruševine opservatorije, nebeskoplava daljina, zrele proporcije likova. Interfejs: tamnoplavi emajl, mesingane ivice, krem tekst, izražen zlatni glavni poziv na akciju. Svet je svetao; tamnije površine služe kontrastu slova i komandi. Ornamenti ne nose informaciju i mogu se pojednostaviti na malim uređajima.

### Boje za budući UI

Ovo su predloženi semantički tokeni, ne tvrdnja da svaki slikani piksel ima istu boju.

| Token | Predlog | Primena |
| --- | --- | --- |
| surface | #10283B | unutrašnjost ploča |
| surface-raised | #20445F | izdvojeno dugme/panel |
| text-primary | #FFF3D4 | veliki naslovi i brojevi |
| text-secondary | #DCE6E9 | pomoćni tekst |
| brass | #C7994D | ivice i ukrasi |
| action | #FFD363 | glavna akcija, izabrano |
| pulse | #FFD56D | zlato, simbol munje |
| aegis | #91D8FA | plavo, dijamant/štit |
| arc | #C4A0F6 | ljubičasto, talas/električni kalem |
| mend | #8CDDB8 | mint, plus/injektor |
| health | #83D66C | zdravlje igrača |
| danger | #F17C5E | protivnički napad/šteta |

Tip nije kodiran samo bojom: slovo ima mali simbol, sposobnost ima prepoznatljivu ikonu i naziv. Sjaj ne sme da prekrije tekst.

### Tipografija

Dizajn slika koristi slikanu serifnu tipografiju. Nije isporučen niti identifikovan font fajl. Pri pripremi pravih UI elemenata izabrati licenciran čitljiv serif za velike naslove i ujednačen čitljiv font za brojke/kratke opise. Ne oslanjati se na OCR ili sečenje reči iz PNG-a.

Ciljevi u logičkim jedinicama interfejsa: naziv ekrana 28–34, glavno dugme 24–30, nazivi sposobnosti 18–22, slova na tabli 28–34, kratak opis 18, sporedni podatak najmanje 16. Dati prednost čitljivosti u stvarnoj veličini telefona nad doslovnim kopiranjem sitnih ukrasnih detalja.

## 2. Mobilni format i raspored

- Svih šest rastera: **1774 × 887 px, 2:1 landscape**. To je izvoz alata, ne rezolucija uređaja niti obavezan Godot viewport.
- Predložena projektna logička referenca: **960 × 480**. Pri implementaciji proveriti 16:9 i šire telefone do oko 20:9; ne rastezati likove i krugove.
- Bezbedne ivice: najmanje 24 logičke jedinice sa strane i 12 gore/dole, uvećano prema stvarnoj OS safe area zoni. Slikani ornament može do ivice; važan dodir ne sme pod kameru ili sistemske komande.
- Aktivne dodirne površine najmanje **48 × 48** logičkih jedinica. Vizuelno manje ikonice imaju veći nevidljivi hitbox. Susede razdvojiti najmanje 4–8 jedinica.
- Ne umanjivati ceo PNG do stanja u kom dugmad ili slova postaju sitna. U Godotu se pravi prilagodljiv raspored. Na užem telefonu prvo smanjiti dekoraciju i prazne margine, pa visinu arene; veličina dodira ima prednost.
- Glavni ekrani staju bez skrola. Portretni režim van ovih šest ekrana: poruka za okretanje; ne pokušavati ugurati celu landscape igru.
- Slike su pregledane kao rasteri. **Nisu izvršeni testovi na fizičkom telefonu niti validacija stvarnih touch hitbox-ova.** Te provere pripadaju narednom odobrenom koraku.

## 3. Ekrani i hijerarhija

### 01 — Glavni meni

**Prvo vidljivo:** naziv igre i Play. Leva polovina pripada protagonistkinji, desna naslovu i akcijama. Valuta i Settings su gore desno. Arsenal i Upgrades su ispod glavne akcije.

Predviđene veze: Play → Campaign; Arsenal → Arsenal; Upgrades → Upgrades. Settings otvara mali prozor, nije dodatni osnovni ekran ove isporuke.

Odvojeni slojevi za kasnije: pozadina, protagonistkinja, logo, dugme primarno, dugme sekundarno, ikone, valuta, tekst. Logo može biti ilustracija; funkcionalni natpisi moraju biti pravi tekst.

### 02 — Kampanja

**Prvo vidljivo:** mapa i trenutni čvor 03. Završen čvor: zlatna kvačica. Trenutni: obod i istaknuti marker. Zaključan: prigušeno plavo i katanac. Desno dole detalj izabranog protivnika sa oznakom CPU i nagradom.

Prepare → Power-ups, zadržava izabrani susret. Back → Main Menu. Dodir završenog čvora može prikazati njegov detalj; dodir zaključanog kratko objašnjava uslov otključavanja. Ti dodatni sadržaji nisu nacrtani kao posebni ekrani.

Odvojiti ilustraciju mape od linije putanje, čvorova, ikona i detalja susreta. Ne ugraditi stanje kampanje u samu teksturu mape.

### 03 — Arsenal

**Prvo vidljivo:** četiri sposobnosti i njihovi nivoi. Trenutno odabrana ima zlatni obod; Equipped je zasebno stanje, tako da i ostale mogu biti opremljene. Prikaz pokazuje početni komplet od četiri opremljene sposobnosti.

Dodir ploče bira sposobnost za pregled; tekst u donjoj traci i akcija Upgrade odnose se na tu selekciju. Upgrade → Upgrades za istu sposobnost. Power-ups → priprema. Back → Main Menu.

Četiri sposobnosti ostaju vizuelno iste u arsenalu, unapređenjima i borbi. Velika ilustracija opreme i pojednostavljena borbena ikona imaju zajedničku siluetu/boju, ne moraju imati identičan nivo detalja.

### 04 — Power-upovi

**Prvo vidljivo:** tri izbora i jedan Equipped. Time Freeze je primer selekcije, druge ploče nude +. Broj ×1 je zaliha. Opis je kratak i staje u jedan red na referentnoj širini.

Battle → susret sa izabranim dodatkom. Arsenal → pregled opreme. Back → Campaign, čuva izbor. Izbor drugog dodatka pomera Equipped; ne troši predmet dok borba ne počne/efekat se ne upotrebi (tačan trenutak potrošnje potvrditi kasnije).

Bez zalihe: ploča prigušena, oznaka ×0 i bez aktivnog +. Predloženi efekti: Time Freeze 8s; Fresh Board preslaganje; Overcharge dvostruka energija sledeće reči. Brojevi su ilustracija, ne zaključan balans.

### 05 — Unapređenja

**Prvo vidljivo:** oružje i promena pre/posle. Pulse: nivo 3 → 4, šteta 28 → 30, punjenje 6, cena 180, saldo 480 → 300. Brojevi na slici su međusobno konzistentni.

Četiri kružna selektora menjaju predmet na istom ekranu. Upgrade menja nivo i saldo i daje kratku vizuelnu potvrdu. Back vraća na mesto odakle je ekran otvoren (meni ili arsenal), uz očuvanu selekciju.

Za druga tri predmeta isti raspored, ali naziv statistike zavisi od efekta: Aegis Protection, Arc Damage/Delay po konačnom balansu, Mend Healing. Nedovoljno novca: neaktivno dugme, jasan iznos koji nedostaje; maksimalni nivo: Max level umesto strelice. Nema tih šest novih ekrana; to su stanja istog panela.

### 06 — Borba

**Prvo vidljivo:** tabla i napunjena sposobnost. Duel gore ima oba borca, zdravlje, oznaku CPU i centralnu pauzu. Tabla dole ima 28 krugova u 7 × 4. Po dve sposobnosti su uz levu i desnu ivicu table. Jednokratni power-up je ispod desne grupe.

U ovom masteru arena je približno gornjih 43%, a tabla i sposobnosti donjih 57%. To je stvarni vizuelni rezultat, ne ranije razmatrani odnos 34/66. Na telefonu sa malom visinom arenu smanjiti prema približno trećini, da slova ostanu najmanje 48 jedinica i borci ne budu isečeni.

Prikazan je trenutak spajanja STONE, pre puštanja: putanja ide kroz prvih pet susednih polja, slova su čitljiva. Reč u traci potvrđuje šta igrač sastavlja. Prikazani Pulse READY je već napunjen iz prethodnih poteza; trenutna još nepotvrđena reč ne dodeljuje energiju unapred.

Tipovi: zlato/munja → Pulse; plavo/dijamant → Aegis; ljubičasto/talas → Arc; zeleno/plus → Mend. Mešanje tipova u jednoj reči dozvoljeno. Korišćena polja nestaju tek po prihvatanju reči, pa dolazi dopuna. Detalji gravitacije/dopune nisu određeni slikom.

Nemoj slepo kopirati složenu svetlosnu putanju preko karaktera slova: u engine-u je staviti ispod slova i iznad pozadine kruga. Invalidna reč: kratka poruka uz traku, bez kazne skrivene od igrača. Potvrđena reč: sažeta povratna informacija i energija ka odgovarajućim ikonama. Ne otvarati dijalog tokom svakog poteza.

### Tabla iz prikazanog stanja

```text
S T O N E S T
R E A M L I N
E P L A N E T
C A R D S E N
```

Primeri vidljivih susednih nizova: STONE i STONES u prvom redu; PLANE i PLANET u trećem. To je namerno oblikovana tabla za dizajn, ne rezultat produkcionog generatora.

## 4. Stanja zajedničkih komponenti

| Komponenta | Default | Selected / ready | Pressed | Disabled / locked |
| --- | --- | --- | --- | --- |
| Glavna akcija | zlatna ploča, taman tekst | dodatni svetli obod samo kad treba | kratak utisnut okvir | prigušena ploča + jasan razlog |
| Sekundarna akcija | plava ploča, krem tekst | tanki zlatni obod | smanjena svetlina unutrašnjosti | niži kontrast, ostaje čitljivo |
| Ploča opreme | obod mesing, ikona tipa | istaknut obod; selekcija odvojena od Equipped | kratki odsjaj | katanac/tekst, ne samo boja |
| Slovo | boja tipa + simbol + veliko slovo | svetli prsten, putanja ispod karaktera | neposredna vizuelna povratna informacija | ne postoji trajno disabled u ovom primeru |
| Sposobnost | delimični prsten + x/y | pun prsten + READY | odsjaj, pražnjenje prstena | nedovoljna energija: x/y, kratak odgovor |
| Power-up | ikona + količina | Equipped u pripremi | kratki odsjaj | ×0 ili Used |

Stanja su ovde opisana za buduću izradu, nisu dodatni generisani sprite-ovi. Za smanjeno kretanje zadržati promenu boje i brojke, izostaviti treperenje i potresanje.

## 5. Plan slojeva za Godot — dokumentacija, ne implementacija

| Grupa | Pripremiti posle usvajanja | Način prikaza |
| --- | --- | --- |
| Pozadine | meni, mapa, radionica, arena, bez UI teksta | pozadinski sloj sa prilagodljivim kadriranjem |
| Likovi | explorer, sentinel, portreti, animacije | odvojeni sprite-ovi; ne isečeni iz celog screenshot-a |
| Okviri | panel, naslovna traka, dugme, čvor, okvir kruga | skalabilni UI delovi, 9-slice gde odgovara |
| Ikone | četiri sposobnosti, tri power-upa, navigacija, valuta | zasebne transparentne teksture ili vektori |
| Dinamički UI | slova, tekst, HP, nivoi, saldo, ring fill | pravi tekst, kontrole i shader/maska prstena |
| Efekti | putanja, odsjaj, punjenje, projektili | odvojeni efekti, ne deo statične pozadine |

Glavni raspored zasnovati na anchor-ima, container-ima i safe-area marginama. Podlogu proširivati na širem telefonu, a table i kružne komande zadržati pravilnih proporcija. Produkcioni asset-i, fontovi i licence pripremaju se tek posle potvrde ovog smera. Ne pretpostavljati da šest spljoštenih slika već predstavlja gotov UI kit.

## 6. Pregled i preostale potvrde

Pregledano svih šest rastera: ujednačeni likovi/svet, ključni engleski natpisi, boje, iste četiri sposobnosti, 28 slova, putanja STONE, valuta i matematika unapređenja. Svi fajlovi su 2:1; nijedan ne prelazi 10 MiB.

Pre produkcione izrade: korisnik potvrđuje umetnički smer i čitljivost na telefonu, zatim se po potrebi uklanjaju sitni ukrasi i ujednačavaju fontovi, safe area i hitbox-ovi. Pozadinska natpisna tabla na ilustraciji unapređenja je dekoracija i nije predviđena kao UI element. Sledeći korak nije automatsko pokretanje Godot implementacije; korisnik je trenutno tražio samo dizajn.
