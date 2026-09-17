import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
import {gzipSync,gunzipSync} from 'node:zlib';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
const root=new URL('../',import.meta.url);
const out=new URL('.local/daily-dictionaries/',root);
mkdirSync(out,{recursive:true});
const manifest={version:'daily-v1',files:{}};
for(const language of ['en','sr']) {
  const source=readFileSync(new URL(`game/data/${language==='en'?'english.txt':'serbian.txt.gz'}`,root));
  const text=(language==='sr'?gunzipSync(source):source).toString('utf8');
  const words=[...new Set(text.replaceAll('\r','').toUpperCase().split('\n').filter(Boolean))].sort();
  const packed=gzipSync(words.join('\n')+'\n',{level:9});
  const name=`${language}-daily-v1.txt.gz`;
  writeFileSync(new URL(name,out),packed);
  const hash=createHash('sha256').update(packed).digest('hex');
  manifest.files[language]={name,words:words.length,bytes:packed.length,sha256:hash};
  console.log(`${name}: ${words.length} words, ${packed.length} bytes`);
  console.log(`DAILY_DICTIONARY_${language.toUpperCase()}_SHA256=${hash}`);
}
writeFileSync(new URL('manifest.json',out),JSON.stringify(manifest,null,2)+'\n');
console.log(fileURLToPath(out));
