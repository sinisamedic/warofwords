"""Add licensed game music and reconstructed game SFX; preserve published silent masters."""
from pathlib import Path
import sys, subprocess, json, re
ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'marketing/first-eight'
sys.path.insert(0, str(ROOT / '.local/social-python'))
import imageio_ffmpeg
FF = imageio_ffmpeg.get_ffmpeg_exe()
TMP = ROOT / '.local/social-audio'
TMP.mkdir(exist_ok=True)

def run(args):
    p = subprocess.run([FF, '-hide_banner', '-y', *map(str, args)], capture_output=True, text=True)
    if p.returncode: raise RuntimeError(p.stderr)
    return p.stderr

def measure(path):
    log = run(['-i', path, '-af', 'loudnorm=I=-16:TP=-1.5:LRA=9:print_format=json', '-f', 'null', '-'])
    return json.loads(re.findall(r'\{[^{}]+\}', log)[-1])

report = []
for post in json.loads((OUT / 'posts.json').read_text(encoding='utf-8')):
    pid, duration = int(post['id']), post['seconds']
    folder = OUT / post['folder']
    gameplay = pid in (1, 2, 6)
    track = 'treasure-hunter.mp3' if pid in (1, 2, 4, 5) else 'fantasy-orchestral-theme.mp3'
    start = 0 if track == 'treasure-hunter.mp3' else 25
    args = ['-ss', start, '-i', ROOT / 'game/assets/music' / track]
    filters = [f'[0:a]atrim=duration={duration},asetpts=PTS-STARTPTS,loudnorm=I=-23:TP=-3:LRA=9,aresample=48000,afade=t=in:d=0.18,afade=t=out:st={duration-.65}:d=0.65[music]']
    labels, events = ['[music]'], []
    if gameplay:
        offset = 0 if pid == 2 else 3
        events = [('tap', offset+1.5+i*.5, 1+(i+1)*.035, -15) for i in range(5)]
        events += [(name, offset+4, pitch, gain) for name, pitch, gain in [('word',1,-9),('shot',1.13,-9),('flight',1,-12)]]
        events += [('hit', offset+4.42, 1, -9)]
    for i, (name, time, pitch, gain) in enumerate(events, 1):
        args += ['-i', ROOT / 'game/assets/audio' / (name+'.wav')]
        filters += [f'[{i}:a]asetrate={24000*pitch},aresample=48000,volume={gain}dB,adelay={round(time*1000)}:all=1[s{i}]']
        labels += [f'[s{i}]']
    filters += [''.join(labels)+f'amix=inputs={len(labels)}:normalize=0:duration=first,atrim=duration={duration}[mix]']
    mix = TMP / (post['id']+'.wav')
    run(args + ['-filter_complex', ';'.join(filters), '-map', '[mix]', '-ar',48000,'-ac',2,'-c:a','pcm_s24le',mix])
    stats = measure(mix)
    norm = f"loudnorm=I=-16:TP=-1.5:LRA=9:measured_I={stats['input_i']}:measured_TP={stats['input_tp']}:measured_LRA={stats['input_lra']}:measured_thresh={stats['input_thresh']}:offset={stats['target_offset']}:linear=true"
    dest = folder / 'video-9x16-audio.mp4'
    original = folder / 'video-9x16.mp4'
    run(['-i',original,'-i',mix,'-map','0:v:0','-map','1:a:0','-c:v','copy','-af',norm,'-ar',48000,'-ac',2,'-c:a','aac','-b:a','192k','-t',duration,'-movflags','+faststart',dest])
    run(['-v','error','-i',dest,'-f','null','-'])
    hashes = []
    for p in (original,dest):
        run(['-i',p,'-map','0:v:0','-c:v','copy','-f','hash','-hash','sha256',TMP/'hash.txt'])
        hashes.append((TMP/'hash.txt').read_text().strip())
    assert hashes[0] == hashes[1], 'Video changed'
    measured = measure(dest)
    assert -17 < float(measured['input_i']) < -15
    assert float(measured['input_tp']) < -1
    assert dest.stat().st_size < 10*1024*1024
    report.append(dict(id=post['id'],file=str(dest.relative_to(OUT)).replace('\\','/'),music=track,music_start=start,events=[dict(asset=n,seconds=t,pitch=p,gain_db=g) for n,t,p,g in events],audio='AAC 48 kHz stereo 192 kbps',integrated_lufs=measured['input_i'],true_peak_dbtp=measured['input_tp'],video_sha256=hashes[0],visual_stream_unchanged=True,decode='PASS',bytes=dest.stat().st_size))
    if pid == 1:
        run(['-i',dest,'-vn','-c:a','libmp3lame','-b:a','192k',OUT/'01-audio-preview.mp3'])
    print(post['id'], measured['input_i'], measured['input_tp'], flush=True)
(OUT/'AUDIO-QA.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
