"""Compile human-authored UTF-8 translation rows, checking printf placeholders."""
from pathlib import Path
import json,re
ROOT=Path(__file__).resolve().parent.parent
path=ROOT/'game/data/translations.json'
catalog=json.loads(path.read_text(encoding='utf-8'))
pattern=r'%(?:\d+\$)?[-+0-9.]*[sdf]'
for line in (ROOT/'tools/translations.tsv').read_text(encoding='utf-8').splitlines()[1:]:
    if not line: continue
    row=line.split('|')
    assert len(row)==5, row
    key=row[0].replace('\\n','\n')
    for language,text in zip(['de','fr','es','it'],row[1:]):
        text=text.replace('\\n','\n')
        assert re.findall(pattern,key)==re.findall(pattern,text),(language,key,text)
        catalog[language][key]=text
path.write_text(json.dumps(catalog,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
missing=[key for key in catalog['sr'] if key not in catalog['de']]
(ROOT/'.local/missing-translations.txt').write_text('\n'.join(missing),encoding='utf-8')
print('Translated:',len(catalog['de']),'Remaining:',len(missing))
