// Install test-only dependency under .local/daily-tools, never into the game.
import {PGlite} from '../.local/daily-tools/node_modules/@electric-sql/pglite/dist/index.js';
import {readFileSync} from 'node:fs';
import assert from 'node:assert/strict';
const db=new PGlite();
await db.exec(`create role anon; create role authenticated; create role service_role;
create schema auth; create table auth.users(id uuid primary key);
create schema storage; create table storage.buckets(id text primary key,name text,public boolean,file_size_limit bigint);`);
await db.exec(readFileSync(new URL('../supabase/migrations/202609170001_daily.sql',import.meta.url),'utf8'));
const a='00000000-0000-0000-0000-000000000001', b='00000000-0000-0000-0000-000000000002';
await db.query('insert into auth.users values ($1),($2)',[a,b]);
const start=async(user,language='en',adjacent=true,seed=123)=> (await db.query('select daily_start($1,$2,$3,$4,$5) as result',[user,language,adjacent,'Tester',seed])).rows[0].result;
const first=await start(a); const retry=await start(a,'en',true,456); const other=await start(b,'en',true,789);
assert.equal(first.id,retry.id); assert.equal(first.seed,retry.seed); assert.equal(first.seed,other.seed);
assert.notEqual((await start(a,'sr')).id,first.id);
assert.notEqual((await start(a,'en',false)).id,first.id);
await db.query('update daily_attempts set score=100,word_count=2,finished_at=now() where id=$1 or id=$2',[first.id,other.id]);
let board=(await db.query('select daily_leaderboard($1,$2,$3) as result',[a,'en',true])).rows[0].result;
assert.equal(board.total,2); assert(board.rows.every(r=>r.position===1)); assert.equal(board.rows.filter(r=>r.own).length,1);
assert(!JSON.stringify(board).includes(a));
for(const role of ['anon','authenticated']) {
  await db.exec(`set role ${role}`);
  await assert.rejects(()=>db.query('select * from daily_attempts'));
  await assert.rejects(()=>db.query('select * from daily_challenges'));
  await assert.rejects(()=>db.query('select daily_leaderboard($1,$2,$3)',[a,'en',true]));
  await db.exec('reset role');
}
await db.exec('set role service_role');
board=(await db.query('select daily_leaderboard($1,$2,$3) as result',[a,'en',true])).rows[0].result;
assert.equal(board.total,2); await db.exec('reset role');
await assert.rejects(()=>db.query('update daily_attempts set score=-1 where id=$1',[first.id]));
await db.close();
console.log('PASS: SQL migration, unique attempts, canonical daily seed, category separation, ties, privacy, client access denied, service RPC, constraints');
