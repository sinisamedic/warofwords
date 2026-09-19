"""Bundle corresponding dictionary source and licenses alongside the generated data."""
from pathlib import Path
import zipfile
root=Path(__file__).resolve().parent.parent
files=[]
for language in ['de','fr','es','it']:
    files.extend(p for p in (root/'tools/dictionaries'/language).iterdir() if p.is_file())
files.extend([root/'tools/build-extra-dictionaries.py',root/'tools/dictionaries/EXTRA-PROVENANCE.md',root/'game/licenses/Serbian-MPL-2.0.txt'])
with zipfile.ZipFile(root/'game/licenses/dictionary-sources.zip','w',zipfile.ZIP_DEFLATED,compresslevel=9) as archive:
    for path in sorted(files):
        info=zipfile.ZipInfo(path.relative_to(root).as_posix(),date_time=(2026,9,19,0,0,0))
        info.compress_type=zipfile.ZIP_DEFLATED
        archive.writestr(info,path.read_bytes())
print('Packaged corresponding dictionary sources and licenses')
