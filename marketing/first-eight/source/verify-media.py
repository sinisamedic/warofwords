"""Validate deliverables, decode every video, and create review contact sheets."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json, subprocess, hashlib, sys, re
ROOT=Path(__file__).resolve().parents[3]; OUT=ROOT/'marketing/first-eight'
sys.path.insert(0,str(ROOT/'.local/social-python'))
import imageio_ffmpeg
ff=imageio_ffmpeg.get_ffmpeg_exe()
qa=ROOT/'.local/social-qa'; qa.mkdir(exist_ok=True)
posts=json.loads((OUT/'posts.json').read_text(encoding='utf-8'))
report=[]; thumbs=[]
for p in posts:
    folder=OUT/p['folder']; video=folder/'video-9x16.mp4'
    reader=imageio_ffmpeg.read_frames(str(video),pix_fmt='rgb24')
    metadata=next(reader)
    assert metadata['size']==(1080,1920),metadata
    assert abs(metadata['fps']-30)<.01
    assert abs(metadata['duration']-p['seconds'])<.1
    reader.close()
    check=subprocess.run([ff,'-v','error','-i',str(video),'-f','null','-'],capture_output=True)
    assert check.returncode==0 and not check.stderr,check.stderr
    stream=subprocess.run([ff,'-hide_banner','-i',str(video)],capture_output=True,text=True).stderr
    assert 'Audio:' not in stream
    for img in folder.glob('ig-*.png'):
        assert Image.open(img).size==(1080,1350)
    # Inspect early and late frames of every final encoded stream.
    for t in [1,p['seconds']-1]:
        frame=qa/f'{p["id"]}-{t}.jpg'
        subprocess.run([ff,'-y','-v','error','-ss',str(t),'-i',str(video),'-frames:v','1',str(frame)],check=True)
        im=Image.open(frame); im.thumbnail((216,384)); thumbs.append((p['id']+f' / {t}s',im.copy()))
    report.append({'id':p['id'],'size':metadata['size'],'fps':metadata['fps'],'duration':metadata['duration'],'audio':False,'full_decode':'PASS','bytes':video.stat().st_size})
sheet=Image.new('RGB',(8*230,2*430),'#202C46'); d=ImageDraw.Draw(sheet)
font=ImageFont.truetype(str(ROOT/'game/assets/fonts/Lato-Bold.ttf'),19)
for i,(label,im) in enumerate(thumbs):
    col=i//2; row=i%2; x=col*230+7; y=row*430+6; sheet.paste(im,(x,y)); d.text((x,y+390),label,font=font,fill='white')
sheet.save(qa/'video-review.jpg',quality=94)
pngs=list(OUT.glob('*/ig-*.png')); sheet=Image.new('RGB',(5*260,3*365),'#202C46'); d=ImageDraw.Draw(sheet)
for i,f in enumerate(pngs):
    im=Image.open(f); im.thumbnail((250,313)); x=(i%5)*260; y=(i//5)*365; sheet.paste(im,(x,y)); d.text((x,y+320),f.parent.name[:2]+' / '+f.stem,font=font,fill='white')
sheet.save(qa/'all-slides.jpg',quality=95)
files=[p for p in OUT.rglob('*') if p.is_file() and '__pycache__' not in str(p) and p.name not in ['MANIFEST.json','QA.json']]
oversize=[str(f.relative_to(OUT)) for f in files if f.stat().st_size>10*1024*1024]
assert not oversize,oversize
manifest=[{'path':str(f.relative_to(OUT)).replace('\\','/'),'bytes':f.stat().st_size,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in files]
(OUT/'MANIFEST.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
(OUT/'QA.json').write_text(json.dumps({'videos':report,'instagram_slides':len(pngs),'files_over_10_MiB':oversize},indent=2),encoding='utf-8')
print(json.dumps({'videos':len(report),'slides':len(pngs),'max_bytes':max(f.stat().st_size for f in files),'total_bytes':sum(f.stat().st_size for f in files),'decode':'ALL PASS'}))
