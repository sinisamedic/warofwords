// Creates and deletes ONLY its own disposable guest profile. No existing profile is loaded.
import assert from 'node:assert/strict';
import {readFileSync,writeFileSync} from 'node:fs';
import {randomUUID} from 'node:crypto';
if(!process.argv.includes('--live-delete-test')) throw Error('Explicit --live-delete-test required');
const config=JSON.parse(readFileSync(new URL('../game/online_config.json',import.meta.url),'utf8'));
async function request(path,body,token) {
 const r=await fetch(config.url+path,{method:'POST',headers:{apikey:config.publishable_key,'Content-Type':'application/json',...(token?{Authorization:`Bearer ${token}`}:{})},body:JSON.stringify(body),signal:AbortSignal.timeout(20000)});
 return {status:r.status,body:await r.json()};
}
const session=await request('/auth/v1/signup',{}); assert.equal(session.status,200);
const token=session.body.access_token; assert(token);
// Preserve only this test's credential locally until success, for recovery after a network failure.
const file=new URL('../.local/deletion-qa-session.json',import.meta.url);
writeFileSync(file,JSON.stringify(session.body));
const api=(body)=>request('/functions/v1/daily',body,token);
const start=await api({action:'start',version:'daily-v2',language:'en',adjacent:true,nickname:'QA deletion'}); assert.equal(start.status,200);
const run=randomUUID();
const score=await request('/rest/v1/rpc/endless_finish',{p_run:run,p_language:'en',p_adjacent:true,p_nickname:'QA deletion',p_score:1,p_wave:1,p_words:1,p_seconds:1},token);
assert.equal(score.status,200); assert(score.body.saved);
const before=await request('/rest/v1/rpc/endless_attempt_leaderboard',{p_adjacent:true,p_run:run},token); assert.equal(before.status,200);
assert(JSON.stringify(before.body).includes(run)||JSON.stringify(before.body).includes('QA deletion'));
const unconfirmed=await api({action:'delete_profile'}); assert.equal(unconfirmed.status,400);
const deleted=await api({action:'delete_profile',confirm:'DELETE_MY_PROFILE'}); assert.equal(deleted.status,200); assert.equal(deleted.body.deleted,true);
const after=await api({action:'leaderboard',version:'daily-v2',language:'en',adjacent:true}); assert.equal(after.status,401);
const refreshed=await request('/auth/v1/token?grant_type=refresh_token',{refresh_token:session.body.refresh_token}); assert.equal(refreshed.status,400);
writeFileSync(file,JSON.stringify({deleted:true,verifiedAt:new Date().toISOString()}));
console.log('PASS live: disposable Daily/Endless profile created, confirmation enforced, deletion succeeded, old access and refresh rejected.');
