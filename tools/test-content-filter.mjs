import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {contentAllowed} from '../supabase/functions/daily/content-filter.mjs';
import {DailyRules} from '../supabase/functions/daily/rules.mjs';
const blocked=JSON.parse(readFileSync(new URL('../game/data/blocked-words.json',import.meta.url),'utf8'));
const examples={en:['FUCK','STONE'],sr:['KURAC','KAMEN'],de:['FICKEN','STEIN'],fr:['PUTAIN','PIERRE'],es:['MIERDA','PIEDRA'],it:['CAZZO','PIETRA']};
for(const [code,[bad,good]] of Object.entries(examples)) {
  for(const word of blocked[code]) assert.equal(contentAllowed(word,code),false);
  assert.equal(contentAllowed(bad.toLowerCase(),code),false);
  assert.equal(contentAllowed(good,code),true);
  for(const version of ['daily-v1','daily-v2']) {
    const rules=new DailyRules(123,code,true,version);
    const tiles=rules.tiles(bad), path=tiles.map((_,i)=>i);
    tiles.forEach((tile,i)=>rules.letters[i]=tile);
    // Even a permissive/raw server dictionary cannot bypass the filter.
    assert.equal(rules.accept(path,1000,()=>true),false);
    assert.equal(rules.score,0); assert.equal(rules.moves.length,0);
    const safe=rules.tiles(good); safe.forEach((tile,i)=>rules.letters[i]=tile);
    assert.equal(rules.accept(safe.map((_,i)=>i),1000,()=>true),true);
  }
  console.log(`PASS ${code}: shared list, server rejection, ordinary move and legacy replay`);
}
assert.equal(contentAllowed('STONE','unknown'),false);
