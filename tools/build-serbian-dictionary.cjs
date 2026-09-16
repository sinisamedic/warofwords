// Reproducible MPL-2.0 word-list adaptation of the pinned LibreOffice Serbian dictionary.
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const zlib = require('node:zlib');
const root = path.resolve(__dirname, '..');
const source = path.join(__dirname, 'dictionaries/sr');
for (const [file, expected] of Object.entries({
  'sr-Latn.aff':'38b99cae0005ff20b015d829580a0f3533ffabc1f889a54144a74e90069548e6',
  'sr-Latn.dic':'f51950195e5bd0aaf155d3488517d4dbc4c8fbc772ecbafbf9131e69a257b1ff'
})) {
  const actual=crypto.createHash('sha256').update(fs.readFileSync(path.join(source,file))).digest('hex');
  if(actual!==expected) throw Error('Upstream file changed: '+file);
}
const rules = {SFX: new Map(), PFX: new Map()};
for (const line of fs.readFileSync(path.join(source, 'sr-Latn.aff'), 'utf8').split(/\r?\n/)) {
  const [type, flag, strip, add, condition] = line.trim().split(/\s+/);
  if (!['SFX', 'PFX'].includes(type)) continue;
  if (strip === 'Y' || strip === 'N') {
    if (strip !== 'Y') throw Error('Unexpected non-cross-product rule');
    rules[type].set(flag, []); continue;
  }
  if (condition || add.includes('/')) throw Error('Unsupported upstream affix change');
  rules[type].get(flag).push({strip: strip === '0' ? '' : strip, add: add === '0' ? '' : add});
}
const words = new Set();
function accept(word) {
  if (!/^[a-zčćšđž]+$/.test(word)) return;
  const length = word.replace(/lj|nj|dž/g, '@').length;
  if (length >= 3 && length <= 12) words.add(word);
}
function apply(word, rule, prefix) {
  if (prefix) return word.startsWith(rule.strip) ? rule.add + word.slice(rule.strip.length) : null;
  return word.endsWith(rule.strip) ? word.slice(0, word.length - rule.strip.length) + rule.add : null;
}
for (const line of fs.readFileSync(path.join(source, 'sr-Latn.dic'), 'utf8').split(/\r?\n/).slice(1)) {
  const [stem, flags = ''] = line.split('/');
  // Proper names, abbreviations, punctuation and foreign Latin letters are excluded.
  if (!/^[a-zčćšđž]+$/.test(stem)) continue;
  const ids = flags.split(',');
  const suffixes = ids.flatMap(id => rules.SFX.get(id) || []);
  const prefixes = ids.flatMap(id => rules.PFX.get(id) || []);
  accept(stem);
  const bases = [stem, ...suffixes.map(r => apply(stem, r, false)).filter(Boolean)];
  for (const base of bases) {
    accept(base);
    for (const r of prefixes) { const form = apply(base, r, true); if (form) accept(form); }
  }
}
const output = [...words].sort().join('\n') + '\n';
fs.writeFileSync(path.join(root, 'game/data/serbian.txt.gz'), zlib.gzipSync(output, {level: 9}));
console.log(JSON.stringify({entries: words.size, bytes: Buffer.byteLength(output), sha256: crypto.createHash('sha256').update(output).digest('hex')}, null, 2));
