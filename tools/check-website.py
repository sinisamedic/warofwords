"""Check static website paths, HTML anchors and package sizes without dependencies."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit, unquote
import re

root = Path(__file__).resolve().parents[1] / 'website' / 'wow'
errors = []
class Page(HTMLParser):
    def __init__(self, path):
        super().__init__(); self.path=path; self.links=[]; self.ids=set(); self.lang=False; self.title=False
    def handle_starttag(self, tag, attrs):
        a=dict(attrs)
        if tag == 'html': self.lang=a.get('lang') == 'en'
        if tag == 'title': self.title=True
        if 'id' in a: self.ids.add(a['id'])
        for name in ['src', 'href', 'data-full']:
            if name in a: self.links.append(a[name])
        if tag == 'img' and 'alt' not in a: errors.append(f'{self.path}: missing alt')

pages={}
for path in root.rglob('*.html'):
    page=Page(path); page.feed(path.read_text(encoding='utf-8')); pages[path.resolve()]=page
    if not page.lang or not page.title: errors.append(f'{path}: missing language/title')
count=0
for path,page in pages.items():
    for link in page.links:
        url=urlsplit(link)
        if url.scheme or url.netloc: continue
        target=(path.parent / unquote(url.path)).resolve() if url.path else path
        if target.is_dir(): target=target/'index.html'
        if not target.is_file(): errors.append(f'{path.name}: missing {link}')
        elif url.fragment and target in pages and url.fragment not in pages[target].ids: errors.append(f'{path.name}: missing anchor {link}')
        count+=1
for css in root.rglob('*.css'):
    for link in re.findall(r'url\([\'"]?([^\)\'\"]+)',css.read_text(encoding='utf-8')):
        if link.startswith('#'):
            for path,page in pages.items():
                uses_css=any((path.parent/urlsplit(ref).path).resolve() == css.resolve() for ref in page.links)
                if uses_css and link[1:] not in page.ids:
                    errors.append(f'{path}: missing CSS fragment {link}')
            continue
        if not (css.parent/link).is_file(): errors.append(f'Missing CSS asset {link}')
files=[p for p in root.rglob('*') if p.is_file()]
large=[str(p.relative_to(root)) for p in files if p.stat().st_size>10*1024*1024]
if large: errors.append('Review files above 10 MiB: '+', '.join(large))
if errors:
    print('\n'.join(errors)); raise SystemExit(1)
print(f'PASS: {len(pages)} pages, {count} local references, all CSS assets, image alt text, page titles and English language.')
print(f'Package: {len(files)} files, {sum(p.stat().st_size for p in files)/1024/1024:.2f} MiB. No file above 10 MiB.')
