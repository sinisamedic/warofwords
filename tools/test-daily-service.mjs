// Exercise the actual Edge handler with mocked provider boundaries, without credentials.
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
const packed=readFileSync(new URL('../.local/daily-dictionaries/en-daily-v1.txt.gz',import.meta.url));
const digest=createHash('sha256').update(packed).digest('hex');
let handler;
globalThis.Deno={env:{get:name=>({SUPABASE_URL:'https://test.invalid',SUPABASE_SERVICE_ROLE_KEY:'test-only',DAILY_DICTIONARY_EN_SHA256:digest})[name]},serve:fn=>handler=fn};
let attempt={id:'12345678-1234-1234-1234-123456789abc',user_id:'owner',language:'en',adjacent:true,version:'daily-v2',seed:123456,started_at:new Date(Date.now()-125000).toISOString(),finished_at:null};
let patches=0;
globalThis.fetch=async(url,options={})=>{
  if(url.endsWith('/auth/v1/user')) return options.headers.Authorization==='Bearer valid'?Response.json({id:'owner'}):Response.json({}, {status:401});
  if(url.includes('/storage/')) return new Response(packed);
  if(url.includes('/daily_attempts?')) {
    assert(url.includes('user_id=eq.owner'));
    if(options.method==='PATCH') {patches++; assert(url.includes('finished_at=is.null')); attempt={...attempt,...JSON.parse(options.body)};}
    return Response.json([attempt]);
  }
  if(url.endsWith('/rpc/daily_leaderboard_versioned') || url.endsWith('/rpc/daily_leaderboard')) return Response.json({rows:[],total:0});
  if(url.endsWith('/rpc/daily_start_versioned') || url.endsWith('/rpc/daily_start')) return Response.json({...attempt,day:'2026-09-17'});
  throw Error('Unexpected request');
};
await import('../supabase/functions/daily/index.ts');
const call=(body,token='valid')=>handler(new Request('https://test.invalid/functions/v1/daily',{method:'POST',headers:{Authorization:`Bearer ${token}`},body:JSON.stringify({version:'daily-v2',language:'en',adjacent:true,...body})}));
assert.equal((await call({action:'leaderboard'},'bad')).status,401);
assert.equal((await call({action:'leaderboard',language:'xx'})).status,400);
assert.equal((await call({action:'leaderboard',version:'daily-v99'})).status,400);
assert.equal((await call({action:'start',nickname:'<script>'})).status,400);
assert.equal((await call({action:'start',nickname:'Tester'})).status,200);
assert.equal((await call({action:'submit',id:attempt.id,moves:[{path:[0,0,1],ms:1000}]})).status,400);
assert.equal(patches,0);
attempt.started_at=new Date(Date.now()-5000).toISOString();
assert.equal((await call({action:'submit',id:attempt.id,moves:[]})).status,409);
attempt.started_at=new Date(Date.now()-160000).toISOString();
assert.equal((await call({action:'submit',id:attempt.id,moves:[]})).status,410);
attempt.started_at=new Date(Date.now()-125000).toISOString();
const fixtures=JSON.parse(readFileSync(new URL('../.local/daily-fixtures.json',import.meta.url),'utf8'));
const fixture=fixtures.find(f=>f.language==='en'&&f.adjacent);
const moves=fixture.steps.map(s=>({path:s.path,ms:s.ms}));
let result=await call({action:'submit',id:attempt.id,moves,score:999999999});
assert.equal(result.status,200); assert.equal((await result.json()).score,fixture.steps.at(-1).score); assert.equal(patches,1);
result=await call({action:'submit',id:attempt.id,moves:[],score:1});
assert.equal((await result.json()).score,fixture.steps.at(-1).score); assert.equal(patches,1);
assert.equal((await call({action:'leaderboard',padding:'X'.repeat(51000)})).status,413);
console.log('PASS: auth, category/version, nickname, replay validation, server deadline, forged score ignored, idempotent submission, payload limit');

assert.equal((await call({action:'leaderboard',version:'daily-v1'})).status,200);
assert.equal((await call({action:'submit',version:'daily-v1',id:attempt.id,moves:[]})).status,400);
