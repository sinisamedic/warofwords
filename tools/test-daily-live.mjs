// Opt-in remote smoke test. Uses only the public app key and a dedicated guest QA session.
import {readFileSync,writeFileSync,existsSync,mkdirSync} from 'node:fs';
import {gunzipSync} from 'node:zlib';
import assert from 'node:assert/strict';
import {DailyRules,dictionaryContains,VERSION} from '../supabase/functions/daily/rules.mjs';
if(!process.argv.includes('--live-daily')) throw Error('Pass --live-daily to create real QA records.');
const root=new URL('../',import.meta.url), config=JSON.parse(readFileSync(new URL('game/online_config.json',root),'utf8'));
const sessionFile=new URL(process.argv.includes('--fresh-profile')?`.local/daily-node-session-${Date.now()}.json`:'.local/daily-node-session.json',root);
let session=existsSync(sessionFile)?JSON.parse(readFileSync(sessionFile,'utf8')):{};
async function request(path,body,token) {
  const response=await fetch(config.url+path,{method:'POST',headers:{apikey:config.publishable_key,'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify(body),signal:AbortSignal.timeout(20000)});
  const result=await response.json();
  if(!response.ok) throw Error(`HTTP ${response.status}: ${result.error||result.message||'request rejected'}`);
  return result;
}
if(session.project_url!==config.url) session={};
if(!session.access_token||session.expires_at*1000<Date.now()+60000) {
  session=await request(session.refresh_token?'/auth/v1/token?grant_type=refresh_token':'/auth/v1/signup',session.refresh_token?{refresh_token:session.refresh_token}:{});
  session.project_url=config.url; writeFileSync(sessionFile,JSON.stringify(session));
}
const api=(action,language,extra={})=>request('/functions/v1/daily',{version:VERSION,action,language,adjacent:true,...extra},session.access_token);
const cases=[];
for(const language of ['en','sr']) {
  const attempt=await api('start',language,{nickname:'QA provera'});
  assert(attempt.id&&attempt.seed);
  const retry=await api('start',language,{nickname:'QA provera'});
  assert.equal(attempt.id,retry.id); assert.equal(attempt.seed,retry.seed);
  if(attempt.finished) { console.log(`PASS: ${language} existing verified result ${attempt.score}`); continue; }
  const text=gunzipSync(readFileSync(new URL(`.local/daily-dictionaries/${language}-daily-v1.txt.gz`,root))).toString();
  const rules=new DailyRules(attempt.seed,language,true);
  // Find one actual dictionary word on the board by scanning legal row subpaths.
  let found=false;
  for(let row=0;row<4&&!found;row++) for(let from=0;from<5&&!found;from++) for(let length=3;length<=7-from&&!found;length++) {
    const path=Array.from({length},(_,i)=>row*7+from+i);
    for(const route of [path,[...path].reverse()]) {
      const word=rules.wordAt(route);
      if(word&&dictionaryContains(text,word)) { assert(rules.accept(route,1000,w=>dictionaryContains(text,w))); found=true; break; }
    }
  }
  assert(found);
  cases.push({language,attempt,rules,deadline:Date.now()+attempt.remaining_ms+1500});
  console.log(`PASS: ${language} authenticated start, unique attempt, dictionary word and canonical seed`);
}
while(cases.some(c=>Date.now()<c.deadline)) {
  const remaining=Math.max(...cases.map(c=>c.deadline-Date.now()));
  console.log(`LIVE: ${Math.ceil(remaining/1000)} seconds until server deadlines`);
  await new Promise(resolve=>setTimeout(resolve,Math.min(30000,Math.max(1,remaining))));
}
const report=[];
for(const test of cases) {
  const result=await api('submit',test.language,{id:test.attempt.id,moves:test.rules.moves,score:999999});
  assert(result.verified); assert.equal(result.score,test.rules.score);
  const duplicate=await api('submit',test.language,{id:test.attempt.id,moves:[],score:999999});
  assert.equal(duplicate.score,result.score);
  console.log(`PASS: ${test.language} server-computed score ${result.score}, replay validation, duplicate cannot overwrite`);
}
for(const language of ['en','sr']) {
  const board=await api('leaderboard',language);
  const own=board.rows.find(row=>row.own);
  assert(own); assert.equal(own.nickname,'QA provera');
  report.push({language,day:board.day,total:board.total,score:own.score,rank:own.position});
  console.log(`PASS: ${language} global list contains verified own placement`);
}
// Requests without a user session must fail even when the public key is known.
const noAuth=await fetch(config.url+'/functions/v1/daily',{method:'POST',headers:{apikey:config.publishable_key,'Content-Type':'application/json'},body:JSON.stringify({action:'leaderboard',version:VERSION,language:'en',adjacent:true})});
assert.equal(noAuth.status,401);
for(const table of ['daily_attempts','daily_challenges']) {
  const response=await fetch(config.url+`/rest/v1/${table}?select=*`,{headers:{apikey:config.publishable_key,Authorization:`Bearer ${session.access_token}`}});
  assert([401,403].includes(response.status));
}
writeFileSync(new URL('.local/daily-live-report.json',root),JSON.stringify({verifiedAt:new Date().toISOString(),project:config.url,report},null,2));
console.log('LIVE DAILY PASSED: online results, authenticated endpoint, direct database access denied');
