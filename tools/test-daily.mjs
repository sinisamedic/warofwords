import {readFileSync} from 'node:fs';
import {gunzipSync} from 'node:zlib';
import assert from 'node:assert/strict';
import {DailyRules,dictionaryContains} from '../supabase/functions/daily/rules.mjs';
const root=new URL('../',import.meta.url);
const fixtures=JSON.parse(readFileSync(new URL('.local/daily-fixtures.json',root),'utf8'));
for(const language of ['en','sr']) {
  const text=gunzipSync(readFileSync(new URL(`.local/daily-dictionaries/${language}-daily-v1.txt.gz`,root))).toString();
  const sample=text.split('\n');
  for(const index of [0,1,Math.floor(sample.length/2),sample.length-2]) assert(dictionaryContains(text,sample[index]));
  for(const word of ['','ZZZZZZZZZZZZ','NOT_A_WORD','0']) assert(!dictionaryContains(text,word));
  for(const fixture of fixtures.filter(f=>f.language===language)) {
    const rules=new DailyRules(fixture.seed,language,fixture.adjacent);
    assert.deepEqual(rules.letters,fixture.initial);
    for(const step of fixture.steps) {
      assert(rules.accept(step.path,step.ms,word=>dictionaryContains(text,word)));
      assert.deepEqual(rules.letters,step.letters);
      assert.equal(rules.score,step.score);
    }
    const before=JSON.stringify(rules.letters);
    for(const [path,ms] of [[[0,0,1],20000],[[0,1,2],120000],[[0,1,99],30000],[[0,1,2],NaN],[[0,1.5,2],30000],[[0,1,2],-1]]) assert(!rules.accept(path,ms,()=>true));
    assert.equal(JSON.stringify(rules.letters),before);
    console.log(`PASS: server/Godot parity and invalid moves — ${language} ${fixture.adjacent?'adjacent':'free'}`);
  }
}
// Digraph scoring counts tiles, not Unicode characters.
const sr=new DailyRules(1,'sr',false); sr.letters.splice(0,3,'NJ','I','H');
assert(sr.accept([0,1,2],1000,w=>w==='NJIH')); assert.equal(sr.score,30);
assert(!sr.accept([0,1,2],1100,()=>true));
console.log('PASS: Serbian digraph scoring and minimum move interval');

const legacy=JSON.parse(readFileSync(new URL('tools/fixtures/daily-v1.json',root),'utf8'));
for(const fixture of legacy) {
 const rules=new DailyRules(fixture.seed,fixture.language,fixture.adjacent,'daily-v1');
 assert.deepEqual(rules.letters,fixture.initial);
 for(const step of fixture.steps) {
  assert(rules.accept(step.path,step.ms,()=>true));
  assert.deepEqual(rules.letters,step.letters); assert.equal(rules.score,step.score);
 }
}
console.log('PASS: frozen v1 replays remain compatible');
