import {PGlite} from '../.local/daily-tools/node_modules/@electric-sql/pglite/dist/index.js';
import {readFileSync,readdirSync} from 'node:fs';
import {gunzipSync} from 'node:zlib';
import assert from 'node:assert/strict';
import {DailyRules} from '../supabase/functions/daily/rules.mjs';
const db=new PGlite();
await db.exec(`create role anon; create role authenticated; create role service_role;
create schema auth; create table auth.users(id uuid primary key);
create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('test.uid',true),'')::uuid $$;
grant usage on schema auth to authenticated; grant execute on function auth.uid() to authenticated;
create schema storage; create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint);`);
for(const file of readdirSync('supabase/migrations').filter(f=>f.endsWith('.sql')).sort()) await db.exec(readFileSync('supabase/migrations/'+file,'utf8').replace(/^\uFEFF/,''));
const uid='00000000-0000-0000-0000-000000000001';
await db.query('insert into auth.users values ($1)',[uid]);
await db.query("select set_config('test.uid',$1,false)",[uid]);
let count=0;
for(const [i,lang] of ['en','de','fr','es','it','sr'].entries()) {
 const started=(await db.query('select daily_start($1,$2,true,$3,123) as r',[uid,lang,'Tester'])).rows[0].r;
 assert(started.id); count++;
 await db.query('select endless_finish($1,$2,true,$3,100,2,3,10)',['10000000-0000-0000-0000-00000000000'+i,lang,'Tester']); count++;
 const words=new Set(lang==='en'?readFileSync('game/data/english.txt','utf8').toUpperCase().split(/\r?\n/):gunzipSync(readFileSync('game/data/'+(lang==='sr'?'serbian':lang)+'.txt.gz')).toString().split('\n'));
 for(let seed=1;seed<=20;seed++) {
  const rules=new DailyRules(seed,lang,true);
  assert.equal(rules.letters.length,28);
  for(const letter of rules.letters) assert(letter.length>0);
  count++;
 }
 if(!['en','sr'].includes(lang)) {
  assert(words.size>50000); count++;
 }
}
await assert.rejects(()=>db.query("select endless_finish('20000000-0000-0000-0000-000000000001','zz',true,'Tester',100,2,3,10)")); count++;
const result=(await db.query('select endless_attempt_leaderboard(true,null) as r')).rows[0].r;
assert.equal(result.total,6); assert.equal(result.rows.length,6); count+=2;
console.log(count+' multilingual server checks passed');
await db.close();
