"""Run with Pillow and imageio-ffmpeg. Original layouts; existing project assets only."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageOps
import sys, json, shutil, subprocess, hashlib, html
from functools import lru_cache
ROOT=Path(__file__).resolve().parents[3]
OUT=ROOT/'marketing/first-eight'
SRC=OUT/'source'
sys.path.insert(0,str(ROOT/'.local/social-python'))
import imageio_ffmpeg
FF=imageio_ffmpeg.get_ffmpeg_exe()
NAVY='#202C46'; IVORY='#F5F1E9'; ORANGE='#F27622'; MUTED='#BFC6D3'
ART=ROOT/'game/assets/art'; FONT=ROOT/'game/assets/fonts'
@lru_cache(maxsize=64)
def font(n,serif=False): return ImageFont.truetype(str(FONT/('Lora.ttf' if serif else 'Lato-Bold.ttf')),n)
@lru_cache(maxsize=64)
def source_image(path): return Image.open(path).convert('RGBA')
def text(im,xy,s,n=40,fill=IVORY,serif=False): ImageDraw.Draw(im).text(xy,s,font=font(n,serif),fill=fill,spacing=10)
def lines(im,xy,s,n=40,width=900,fill=IVORY,serif=False):
    x,y=xy; d=ImageDraw.Draw(im); line=''
    for word in s.split():
        test=(line+' '+word).strip()
        if d.textlength(test,font=font(n,serif))>width and line:
            text(im,(x,y),line,n,fill,serif); y+=n+13; line=word
        else: line=test
    if line: text(im,(x,y),line,n,fill,serif); y+=n+13
    return y
def fit(im,path,box,cover=False):
    a=source_image(str(path)) if not isinstance(path,Image.Image) else path.convert('RGBA')
    x,y,w,h=box
    a=ImageOps.fit(a,(w,h),method=Image.Resampling.LANCZOS) if cover else ImageOps.contain(a,(w,h),method=Image.Resampling.LANCZOS)
    im.paste(a,(x+(w-a.width)//2,y+(h-a.height)//2),a)
def base(h=1350,light=False,tag='WAR OF WORDS'):
    im=Image.new('RGB',(1080,h),IVORY if light else NAVY); d=ImageDraw.Draw(im)
    color=NAVY if light else IVORY
    d.rectangle((0,0,1080,14),fill=ORANGE)
    fit(im,SRC/('symbol-light.png' if light else 'symbol-dark.png'),(68,66,62,62))
    text(im,(148,73),'GottaPlay',34,color)
    text(im,(68,175),tag,24,ORANGE)
    d.line((68,h-156,1012,h-156),fill=ORANGE,width=2)
    text(im,(68,h-128),'WAR OF WORDS',23,color)
    text(im,(68,h-89),'Android • In development',23,color)
    return im
def heading(im,s,light=False,n=74): return lines(im,(68,225),s,n,910,NAVY if light else IVORY,True)
def footnote(im,s,h=1350): lines(im,(68,h-247),s,31,910)
def save(im,folder,name):
    p=OUT/folder/name; p.parent.mkdir(parents=True,exist_ok=True); im.save(p); return p
POSTS=[
 dict(id='01',slug='meet-the-game',title='Your next weapon is a word.',goal='Predstaviti igru i GottaPlay kroz njen svet i osnovnu petlju.',hook='Your next weapon is a word.',cta='What word would you open with?',caption='Your next weapon is a word. Link letters, charge abilities and face the next opponent in War of Words, an Android game in development from GottaPlay. What word would you open with?',short='Words become attacks. Meet War of Words, our Android game in development. What word would you open with?',tags='#WarOfWords #GottaPlay #WordGame #IndieGame',kind='Reel / Short, 12 s',day='1. nedelja • utorak',alt='War of Words fantasy artwork, followed by a real development gameplay clip of the word STONE.'),
 dict(id='02',slug='one-real-move',title='Watch STONE become an attack.',goal='Pokazati stvarni potez i jasnu vezu između reči i borbe.',hook='Watch STONE become an attack.',cta='Which word did you spot next?',caption='One real move from the current War of Words development build: S → T → O → N → E. The word is accepted, an attack lands, and the used tiles refill. Desktop Godot capture of our Android game in development. Which word did you spot next?',short='S → T → O → N → E. One word, one real attack. Which word did you spot next? War of Words is in development for Android.',tags='#WarOfWords #Gameplay #WordGame #AndroidGaming',kind='Reel / Short, 9 s',day='1. nedelja • četvrtak',alt='Actual tutorial gameplay. Five adjacent letters form STONE; the attack reduces the Training Sentinel from 72 to 65 HP.'),
 dict(id='03',slug='find-five',title='Find a five-letter word.',goal='Dobiti konkretne odgovore publike bez izmišljene društvene potvrde.',hook='Find a five-letter word.',cta='Comment before the reveal.',caption='Your turn: find a five-letter English word on this War of Words board. Connect neighboring tiles, including diagonals. Use each tile only once in your word. Comment your answer before swiping for one solution. This is a still from our development build.',short='Find a five-letter word. Neighboring tiles, diagonals allowed, no tile twice. Pause and comment before the answer!',tags='#WordChallenge #WordPuzzle #WarOfWords #GottaPlay',kind='Instagram karusel, 2 slajda; video 12 s',day='1. nedelja • subota',alt='Unchanged tutorial letter board, followed by the real STONE selection as one valid answer.'),
 dict(id='04',slug='choose-your-mode',title='What kind of word player are you?',goal='Prikazati tri postojeća režima bez sugerisanja PvP-a.',hook='What kind of word player are you?',cta='Campaign, Endless or Daily?',caption='Three ways to play in the current War of Words development build. Campaign: progress through encounters and unlock equipment. Endless: face waves of opponents, with a boss every fifth wave. Daily Challenge: a 120-second word challenge, with offline practice and an online ranked attempt. Which would you try first: Campaign, Endless or Daily? In development for Android.',short='Campaign progress, Endless waves or a 120-second Daily Challenge? Which would you try first? War of Words • Android • In development.',tags='#WarOfWords #WordGame #MobileGaming #IndieDev',kind='Instagram karusel, 3 slajda; video 15 s',day='2. nedelja • utorak',alt='Three existing mode illustrations: campaign hero, endless portal and daily hourglass, with accurate mode summaries.'),
 dict(id='05',slug='read-the-colors',title='Read the colors, too.',goal='Objasniti strategiju punjenja sposobnosti, proverenu u kodu.',hook='Read the colors, too.',cta='Would you build an attack or charge a shield?',caption='A word does more than deal damage in War of Words. The colors of its tiles charge matching ability slots. Words of six or more tiles double that energy gain. So your next word can help prepare your next ability, too. Would you build an attack or charge a shield? Current development rules; balance may change.',short='Read the colors, too. Matching tiles charge abilities; 6+ tiles double the energy gain. Attack or shield next? War of Words • In development.',tags='#WarOfWords #GameStrategy #WordGame #IndieGame',kind='Instagram karusel, 2 slajda; video 12 s',day='2. nedelja • četvrtak',alt='Real STONE selection and a second card explaining matching color energy and the six-tile energy bonus.'),
 dict(id='06',slug='behind-the-hero',title='This hero moves in pieces.',goal='Kratak konkretan pogled iza kulisa kroz stvarni atlas i animaciju.',hook='This hero moves in pieces.',cta='What should we show behind the scenes next?',caption='A small look behind War of Words: this character starts as separate illustrated parts. In Godot, the head, arms, body and coat move through a 2D rig, while the feet stay grounded during the idle animation. Here is the source sheet and the character in the running game. What should we show behind the scenes next? Android game in development.',short='From separate art pieces to a moving 2D hero in Godot. What should we show behind the scenes next? War of Words • In development.',tags='#GameDev #Godot #BehindTheScenes #WarOfWords',kind='Reel / Short, 12 s',day='2. nedelja • subota',alt='Original character parts sheet followed by the hero animated in actual Godot gameplay.'),
 dict(id='07',slug='find-six',title='Can you find six?',goal='Drugi, teži izazov vezan za prethodno objašnjenu mehaniku.',hook='Can you find six?',cta='Comment a six-letter word and its path.',caption='Back to the board. Can you find a six-letter English word? Connect neighboring tiles, diagonals included, and do not use any tile twice. Comment your word and path before swiping for one answer. In the game, words of 6+ tiles double matching-color energy. War of Words is in development for Android.',short='Can you find a six-letter word? Neighboring tiles, diagonals allowed, no tile twice. Pause before the answer and leave your path!',tags='#WordChallenge #BrainTeaser #WarOfWords #WordGame',kind='Instagram karusel, 2 slajda; video 12 s',day='3. nedelja • utorak',alt='Tutorial board challenge, followed by the answer PLANET along row three, columns two through seven.'),
 dict(id='08',slug='pick-your-language',title='Which language would you play in?',goal='Predstaviti postojeći izbor šest jezika i pozvati publiku da prati razvoj.',hook='Which language would you play in?',cta='Which language would you play in?',caption='English, German, French, Spanish, Italian or Serbian? War of Words currently supports all six, and the menu language and word dictionary can be selected separately. Which language would you play in? Follow GottaPlay for more from our Android game in development.',short='Six word languages. Separate menu and dictionary choices. Which would you play in? Follow GottaPlay for War of Words development.',tags='#WarOfWords #WordGames #AndroidGaming #GottaPlay',kind='Instagram slika; video 10 s',day='3. nedelja • četvrtak',alt='Real English settings screen with separate interface and dictionary selections for six languages.'),
]
def card01(h=1350):
    im=base(h,tag='MEET THE GAME'); heading(im,'Your next weapon\nis a word.'.replace('\n',' '))
    fit(im,ART/'endless/mode-campaign.png',(68,445,944,h-750),True)
    footnote(im,'Link letters. Charge abilities. Face your opponent.',h); return im
def boardcard(title,answer=False,six=False,h=1350):
    im=base(h,True,'WORD CHALLENGE'); heading(im,title,True,70)
    board=Image.open(SRC/('stone-selected.png' if answer and not six else 'board.png')).crop((285,305,990,709))
    fit(im,board,(68,430,944,542),True)
    if answer:
        s='PLANET • row 3, columns 2–7' if six else 'STONE • row 1, columns 1–5'
        lines(im,(68,1000),s,39,940,NAVY)
        text(im,(68,1060),'One valid answer. What else did you find?',29,NAVY)
    else:
        lines(im,(68,1000),'Neighboring tiles • Diagonals allowed',32,940,NAVY)
        text(im,(68,1055),'No tile twice. Comment before the reveal.',29,NAVY)
    return im
def modecard(mode,desc,asset,h=1350):
    im=base(h,tag='THREE WAYS TO PLAY'); heading(im,mode)
    fit(im,ART/('endless/'+asset+'.png'),(68,355,944,640),True)
    lines(im,(68,1020),desc,35,935); return im
def strategy(second=False,h=1350):
    im=base(h,tag='A LITTLE STRATEGY'); heading(im,'Six tiles. Double energy.' if second else 'Read the colors, too.')
    if second:
        for i,(label,col) in enumerate([('PULSE  /  Attack','#ffd053'),('AEGIS  /  Shield','#78bfff'),('ARC  /  Interrupt','#b896f5'),('MEND  /  Heal','#62dcb5')]):
            y=480+i*115; ImageDraw.Draw(im).ellipse((70,y+10,114,y+54),fill=col); text(im,(145,y),label,43)
        lines(im,(68,1010),'Words of 6+ tiles double matching-color energy gain.',37,920)
    else:
        fit(im,SRC/'stone-selected.png',(0,455,1080,608))
        lines(im,(68,1070),'Tile colors charge matching abilities.',33,920)
    return im
def behind(h=1350):
    im=base(h,True,'BEHIND THE SCENES'); heading(im,'This hero moves in pieces.',True)
    fit(im,ART/'hero-parts.png',(68,430,590,680))
    hero=Image.open(SRC/'board.png').crop((140,70,370,275))
    fit(im,hero,(685,540,327,390),True)
    text(im,(680,960),'IN GODOT',27,NAVY)
    text(im,(68,1105),'Original parts → animated character',30,NAVY); return im
def languages(h=1350):
    im=base(h,tag='PLAY WITH YOUR WORDS'); heading(im,'Which language would you play in?',n=66)
    fit(im,SRC/'settings.png',(0,435,1080,608))
    lines(im,(68,1060),'Six languages. Separate menu and dictionary choices.',32,930); return im
@lru_cache(maxsize=8)
def cached_video_shell(pid,hook):
    im=base(1920,tag=['MEET THE GAME','REAL GAMEPLAY','WORD CHALLENGE','CHOOSE YOUR MODE','A LITTLE STRATEGY','BEHIND THE SCENES','WORD CHALLENGE','PLAY WITH YOUR WORDS'][int(pid)-1])
    heading(im,hook,n=77)
    text(im,(68,1675),'Android • In development',27)
    # Bottom 220 px reserved; main CTA remains above common UI overlays.
    return im
def video_frame(post,t):
    pid=int(post['id']); im=cached_video_shell(post['id'],post['hook']).copy()
    if pid in [1,2,6]:
        if pid==1 and t<3:
            fit(im,ART/'endless/mode-campaign.png',(68,480,944,970),True)
            text(im,(68,1490),'A word battle from GottaPlay.',37)
        elif pid==6 and t<3:
            fit(im,ART/'hero-parts.png',(68,460,944,990)); text(im,(68,1500),'Separate art. One moving character.',36)
        else:
            bt=t-(3 if pid in [1,6] else 0); index=min(269,int(bt*30))
            frame=Image.open(ROOT/f'.local/social-capture/battle/{index:04d}.png')
            fit(im,frame,(0,560,1080,608))
            if pid==6:
                fit(im,frame.crop((140,70,370,275)),(315,1215,450,380),True)
                text(im,(68,1215),'HERO\nDETAIL',28)
            else:
                board=frame.crop((285,305,990,709))
                fit(im,board,(185,1210,710,405))
                text(im,(68,1175),'BOARD DETAIL',21,MUTED)
            label=('Head, arms, body and coat.' if bt<4 else 'A 2D rig in the running game.') if pid==6 else ('Connect S → T → O → N → E' if bt<4 else 'Word accepted. Attack lands. Tiles refill.')
            if bt>=7: label=post['cta']
            lines(im,(68,465),label,33,930)
            text(im,(68,1640),'Actual Godot development capture',24,MUTED)
    else:
        folder=post['folder']; cards=sorted((OUT/folder).glob('ig-*.png'))
        per=post['seconds']/len(cards); idx=min(len(cards)-1,int(t/per))
        # Reuse visual content only, leaving independently composed 9:16 headings and CTA.
        card=Image.open(cards[idx]); crop=card.crop((40,400,1040,1145))
        fit(im,crop,(40,550,1000,850))
        if pid in [3,7]:
            label='Pause here. Find your word.' if idx==0 else ('One answer: STONE' if pid==3 else 'One answer: PLANET')
        elif pid==4: label=['CAMPAIGN','ENDLESS','DAILY CHALLENGE'][idx]
        elif pid==5: label=['Matching tiles charge abilities.','6+ tiles = double energy gain.'][idx]
        else: label='English • German • French\nSpanish • Italian • Serbian'
        lines(im,(68,1440),label,41,930)
    lines(im,(68,1570 if pid not in [1,2,6] else 430),post['cta'] if pid not in [1,2,6] else '',32,930)
    return im
def main():
    brand=ROOT.parent/'WoW Website/brand/palette-b'
    for style in ['dark','light']: shutil.copyfile(brand/f'gottaplay-symbol-{style}.png',SRC/f'symbol-{style}.png')
    cards=[[card01()],[base()], [boardcard('Find a five-letter word.'),boardcard('Did you find STONE?',True)],
       [modecard('Campaign','Progress through encounters. Unlock equipment.','mode-campaign'),modecard('Endless','Waves of opponents. Every fifth wave is a boss.','mode-endless'),modecard('Daily Challenge','120 seconds. Offline practice or an online ranked attempt.','mode-daily')],
       [strategy(),strategy(True)],[behind()],[boardcard('Can you find six?'),boardcard('One answer: PLANET',True,True)],[languages()]]
    cards[1]=[base()]; heading(cards[1][0],'Watch STONE become an attack.',n=70); fit(cards[1][0],SRC/'stone-selected.png',(0,460,1080,608)); text(cards[1][0],(68,1080),'One real move in the development build.',31)
    for p,ims,sec in zip(POSTS,cards,[12,9,12,15,12,12,12,10]):
        p['folder']=p['id']+'-'+p['slug']; p['seconds']=sec
        for j,im in enumerate(ims): save(im,p['folder'],f'ig-{j+1:02d}.png')
        save(video_frame(p,0),p['folder'],'cover-9x16.jpg')
    (OUT/'posts.json').write_text(json.dumps(POSTS,ensure_ascii=False,indent=2),encoding='utf-8')
    for p in POSTS:
        if '--only' in sys.argv and p['id'] not in sys.argv[sys.argv.index('--only')+1].split(','): continue
        dest=OUT/p['folder']/'video-9x16.mp4'
        command=[FF,'-y','-f','rawvideo','-vcodec','rawvideo','-pix_fmt','rgb24','-s','1080x1920','-r','30','-i','-','-an','-c:v','libx264','-preset','fast','-crf','23','-pix_fmt','yuv420p','-movflags','+faststart',str(dest)]
        proc=subprocess.Popen(command,stdin=subprocess.PIPE,stderr=subprocess.DEVNULL)
        # Still cards need no repeated rendering; gameplay frames are real 30 fps.
        cache={}
        for i in range(p['seconds']*30):
            t=i/30; moving=int(p['id']) in [1,2,6] and (p['id']=='02' or t>=3)
            key=i if moving else (-1 if int(p['id']) in [1,6] else int(t/(p['seconds']/len(cards[int(p['id'])-1]))))
            if key not in cache:
                data=video_frame(p,t).tobytes()
                if not moving: cache[key]=data
            else: data=cache[key]
            proc.stdin.write(data)
        proc.stdin.close(); assert proc.wait()==0
        subprocess.run([FF,'-y','-v','error','-i',str(dest),'-vf','scale=540:960,fps=15','-c:v','libvpx-vp9','-deadline','realtime','-cpu-used','8','-b:v','0','-crf','35','-an',str(dest.with_name('preview.webm'))],check=True)
        print('EXPORTED',p['id'],dest.stat().st_size,flush=True)
    # Contact sheet for quick review.
    sheet=Image.new('RGB',(1440,1000),NAVY)
    for i,p in enumerate(POSTS):
        thumb=Image.open(OUT/p['folder']/'ig-01.png'); thumb.thumbnail((342,428))
        x=12+(i%4)*360; y=12+(i//4)*500
        sheet.paste(thumb,(x,y)); text(sheet,(x,y+437),p['id']+' / '+p['slug'],18)
    sheet.save(OUT/'overview.jpg',quality=92)
    make_docs()
def make_docs():
    blocks=['# GottaPlay — prvih osam objava\n\nPredlog za pregled, 2026-09-20. Ništa nije objavljeno niti zakazano. Svi tekstovi za publiku su na engleskom.\n\n## Predlog ritma\n\nTri objave nedeljno: utorak, četvrtak, subota; poslednje dve utorak i četvrtak treće nedelje. Dan 1 znači prvi odabrani utorak posle pregleda, ne obećani datum. Predlog termina: 19:00 Europe/Belgrade; probni urednički termin, bez tvrdnje da je optimalan za algoritam. Isti paket može na tri mreže istog dana.\n\nInstagram: @gotta.play_games. TikTok: @gottaplaygames. YouTube: @gottaplay_games.\n\nZa IG 01/02/06 koristiti Reel, za 03/04/05/07 karusel po numeraciji, za 08 jednu sliku. Sve objave imaju zaseban 1080×1920 MP4 za TikTok/Shorts/Reels i 1080×1350 PNG. Statične adaptacije su namerno mirne video-kartice; gameplay je samo u 01/02/06. Bez muzike, govora i zvučnih efekata: svi MP4 su namerno nemi i imaju ugrađen tekst.\n']
    page=['<!doctype html><html lang="sr"><meta charset="utf-8"><meta name="viewport" content="width=device-width"><title>GottaPlay · 8 objava za pregled</title><style>body{margin:0;background:#202c46;color:#f5f1e9;font:18px system-ui}main{max-width:1200px;margin:auto;padding:40px}h1{font-size:48px}h2{color:#f27622}section{border-top:1px solid #687184;padding:30px 0}.media{display:flex;gap:20px;overflow:auto}video{width:270px;max-height:480px;background:#111}img{width:280px;object-fit:contain}p{max-width:900px;line-height:1.6}a{color:#ffae73}pre{white-space:pre-wrap;background:#162139;padding:20px;border-radius:12px}.muted{color:#c7cbd4}</style><main><h1>GottaPlay / War of Words</h1><p>Osam gotovih objava za pregled. Nije objavljeno niti zakazano. Video-snimci su namerno bez zvuka. Preuzmi MP4 i otvori ga u lokalnom video plejeru; ugrađeni browser je tokom provere padao pri reprodukciji.</p><p><a href="CONTENT-AND-SCHEDULE.md">Svi tekstovi i raspored</a> · <a href="PROVENANCE.md">Poreklo i provere</a></p>']
    for p in POSTS:
        folder=p['folder']; youtube=p['short'] if p['id'] in ['03','07'] else p['caption']; igkind='Reel' if p['id'] in ['01','02','06'] else 'slika' if p['id']=='08' else 'karusel'
        blocks.append(f"\n## {p['id']}. {p['title']}\n\n- **Ideja i cilj:** {p['goal']}\n- **Hook:** {p['hook']}\n- **Raspored:** {p['day']} • 19:00 (predlog)\n- **Format:** {p['kind']}\n- **Fajlovi:** `{folder}/ig-*.png`, `{folder}/video-9x16.mp4`, `{folder}/cover-9x16.jpg`.\n\n**Instagram ({igkind}) — gotov opis:**\n\n{p['caption']}\n\n{p['tags']}\n\n**TikTok — gotov opis uz vertikalni MP4:**\n\n{p['short']}\n\n{p['tags']}\n\n**YouTube Shorts — naslov:** {p['title']}\n\n**YouTube Shorts — opis:**\n\n{youtube}\n\n{p['tags']} #Shorts\n\n**Poziv na reakciju:** {p['cta']}\n\n**Alt tekst za IG:** {p['alt']}\n")
        page.append(f'<section><h2>{p["id"]}. {html.escape(p["title"])}</h2><p>{p["day"]} · {p["kind"]}</p><p>{p["goal"]}</p><div class="media"><div><a href="{folder}/video-9x16.mp4" download><img src="{folder}/cover-9x16.jpg" alt="Video naslovna slika"></a><p><a href="{folder}/video-9x16.mp4" download>Preuzmi MP4 za mreže</a><br><a href="{folder}/preview.webm" download>Preuzmi manji WebM pregled</a></p></div>')
        for file in sorted((OUT/folder).glob('ig-*.png')): page.append(f'<a href="{folder}/{file.name}"><img loading="lazy" src="{folder}/{file.name}" alt="{html.escape(p["alt"])}"></a>')
        page.append(f'</div><p>Instagram — tekst za kopiranje:</p><pre>{html.escape(p["caption"])}\n\n{p["tags"]}</pre><p>TikTok:</p><pre>{html.escape(p["short"])}\n\n{p["tags"]}</pre><p>YouTube naslov: <b>{html.escape(p["title"])}</b>. Opis:</p><pre>{html.escape(youtube)}\n\n{p["tags"]} #Shorts</pre></section>')
    page.append('</main></html>')
    (OUT/'index.html').write_text(''.join(page),encoding='utf-8')
    (OUT/'CONTENT-AND-SCHEDULE.md').write_text('\n'.join(blocks),encoding='utf-8')
if __name__=='__main__': main()
