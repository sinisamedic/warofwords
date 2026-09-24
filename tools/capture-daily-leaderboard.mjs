import {readFileSync,writeFileSync,readdirSync,statSync} from 'node:fs';
import {VERSION} from '../supabase/functions/daily/rules.mjs';
const root=new URL('../',import.meta.url), local=new URL('.local/',root);
const file=readdirSync(local).filter(n=>/^daily-node-session(-\d+)?\.json$/.test(n)).sort((a,b)=>statSync(new URL(b,local)).mtimeMs-statSync(new URL(a,local)).mtimeMs)[0];
if(!file) throw Error('Run the opt-in live test first.');
const sessionFile=new URL(file,local);
let session=JSON.parse(readFileSync(sessionFile,'utf8'));
const config=JSON.parse(readFileSync(new URL('game/online_config.json',root),'utf8'));
if(session.project_url!==config.url) throw Error('Test session belongs to another project.');
if(!session.access_token||session.expires_at*1000<Date.now()+60000) {
  if(!session.refresh_token) throw Error('The saved test session cannot be refreshed.');
  const refresh=await fetch(config.url+'/auth/v1/token?grant_type=refresh_token',{method:'POST',headers:{apikey:config.publishable_key,'Content-Type':'application/json'},body:JSON.stringify({refresh_token:session.refresh_token}),signal:AbortSignal.timeout(20000)});
  if(!refresh.ok) throw Error(`Session refresh HTTP ${refresh.status}`);
  session={...await refresh.json(),project_url:config.url};
  writeFileSync(sessionFile,JSON.stringify(session));
}
const response=await fetch(config.url+'/functions/v1/daily',{method:'POST',headers:{apikey:config.publishable_key,Authorization:`Bearer ${session.access_token}`,'Content-Type':'application/json'},body:JSON.stringify({action:'leaderboard',language:'en',adjacent:true,version:VERSION}),signal:AbortSignal.timeout(20000)});
if(!response.ok) throw Error(`Leaderboard HTTP ${response.status}`);
const board=await response.json();
writeFileSync(new URL('daily-live-leaderboard.json',local),JSON.stringify(board,null,2));
console.log(`Read-only Supabase leaderboard check passed (${board.rows?.length??0} rows).`);
