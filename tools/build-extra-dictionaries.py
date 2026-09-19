"""Build standalone word-game dictionaries from pinned LibreOffice Hunspell sources.

Requires spylls==0.1.7 (build tool only). Enumerates stems, affixes,
continuations and prefix/suffix cross-products, then validates every candidate.
No arbitrary compounds, spaces, punctuation, abbreviations or proper names
(except German capitalization, which is grammatical). Accents are preserved;
German sharp s becomes SS and French ligatures become OE/AE on the board.
"""
from pathlib import Path
import sys, gzip, json, unicodedata
ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT / '.local/dictionary-tools'))
from spylls.hunspell import Dictionary
from spylls.hunspell.data.aff import Prefix

FILES = {'de':'de_DE_frami', 'fr':'fr', 'es':'es_ANY', 'it':'it_IT'}
def normalized(word):
    return unicodedata.normalize('NFC', word).replace('œ','oe').replace('Œ','OE').replace('æ','ae').replace('Æ','AE').replace('ß','ss').replace('ẞ','SS').upper()

def apply(word, affix):
    if not affix.cond_regexp.search(word): return None
    if isinstance(affix, Prefix):
        if affix.strip and not word.startswith(affix.strip): return None
        return affix.add + word[len(affix.strip):]
    if affix.strip and not word.endswith(affix.strip): return None
    return (word[:-len(affix.strip)] if affix.strip else word) + affix.add

for language, stem in FILES.items():
    dictionary = Dictionary.from_files(str(ROOT / 'tools/dictionaries' / language / stem))
    aff = dictionary.aff
    result = set()
    checked = set()
    for entry in dictionary.dic.words:
        if aff.FORBIDDENWORD in entry.flags or aff.ONLYINCOMPOUND in entry.flags: continue
        if language != 'de' and not entry.stem.islower(): continue
        prefixes = [a for flag in entry.flags for a in aff.PFX.get(flag, [])]
        suffixes = [a for flag in entry.flags for a in aff.SFX.get(flag, [])]
        candidates = {entry.stem}
        for first in prefixes + suffixes:
            form = apply(entry.stem, first)
            if form is None: continue
            candidates.add(form)
            seconds = [a for flag in first.flags for a in aff.PFX.get(flag, []) + aff.SFX.get(flag, [])]
            if first.crossproduct:
                seconds += [a for a in (suffixes if isinstance(first, Prefix) else prefixes) if a.crossproduct]
            for second in seconds:
                other = apply(form, second)
                if other: candidates.add(other)
        for word in candidates:
            if word in checked: continue
            checked.add(word)
            upper = normalized(word)
            if not 3 <= len(upper) <= 12 or not upper.isalpha(): continue
            if dictionary.lookup(word): result.add(upper)
    text = '\n'.join(sorted(result)) + '\n'
    (ROOT / f'game/data/{language}.txt.gz').write_bytes(gzip.compress(text.encode(), compresslevel=9, mtime=0))
    print(language, len(result), 'words', flush=True)
