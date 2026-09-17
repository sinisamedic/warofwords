import { DailyRules, VERSION, DURATION_MS, MAX_MOVES, dictionaryContains } from './rules.mjs';

const url=Deno.env.get('SUPABASE_URL')!;
const serviceKey=Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const serverHeaders={apikey:serviceKey,Authorization:`Bearer ${serviceKey}`,'Content-Type':'application/json'};
const dictionaries=new Map<string,string>();
const respond=(value:unknown,status=200)=>Response.json(value,{status});
async function database(path:string,body?:unknown,method='POST') {
  const response=await fetch(`${url}/rest/v1/${path}`,{method,headers:{...serverHeaders,Prefer:'return=representation'},body:body===undefined?undefined:JSON.stringify(body)});
  if(!response.ok) throw Error('Database unavailable');
  return response.status===204?null:response.json();
}
async function dictionary(language:string) {
  if(dictionaries.has(language)) return dictionaries.get(language)!;
  const expected=Deno.env.get(`DAILY_DICTIONARY_${language.toUpperCase()}_SHA256`);
  if(!expected) throw Error('Dictionary not configured');
  const response=await fetch(`${url}/storage/v1/object/authenticated/daily-dictionaries/${language}-daily-v1.txt.gz`,{headers:serverHeaders});
  if(!response.ok) throw Error('Dictionary unavailable');
  const packed=await response.arrayBuffer();
  const digest=Array.from(new Uint8Array(await crypto.subtle.digest('SHA-256',packed))).map(v=>v.toString(16).padStart(2,'0')).join('');
  if(digest!==expected) throw Error('Dictionary version mismatch');
  const stream=new Blob([packed]).stream().pipeThrough(new DecompressionStream('gzip'));
  const text=await new Response(stream).text();
  dictionaries.set(language,text);
  return text;
}

Deno.serve(async(request:Request)=>{
  if(request.method!=='POST') return respond({error:'Method not allowed'},405);
  try {
    const bearer=request.headers.get('Authorization')||'';
    if(!bearer.startsWith('Bearer ')) return respond({error:'Sign in required'},401);
    const auth=await fetch(`${url}/auth/v1/user`,{headers:{apikey:serviceKey,Authorization:bearer}});
    if(!auth.ok) return respond({error:'Session expired'},401);
    const user=await auth.json();
    if(!user.id) return respond({error:'Sign in required'},401);
    // Bound both announced and streamed request sizes before parsing/replaying.
    if(Number(request.headers.get('content-length')||0)>50000) return respond({error:'Request too large'},413);
    const reader=request.body?.getReader(); let raw=''; let length=0;
    const decoder=new TextDecoder();
    if(reader) while(true) {
      const chunk=await reader.read(); if(chunk.done) break;
      length+=chunk.value.length;
      if(length>50000) { await reader.cancel(); return respond({error:'Request too large'},413); }
      raw+=decoder.decode(chunk.value,{stream:true});
    }
    raw+=decoder.decode();
    let input; try { input=JSON.parse(raw); } catch { return respond({error:'Invalid request'},400); }
    if(!input||typeof input!=='object') return respond({error:'Invalid request'},400);
    if(!['en','sr'].includes(input.language)||typeof input.adjacent!=='boolean'||input.version!==VERSION) return respond({error:'Unsupported rules'},400);
    if(input.action==='leaderboard') return respond(await database('rpc/daily_leaderboard',{p_user:user.id,p_language:input.language,p_adjacent:input.adjacent}));
    if(input.action==='start') {
      if(typeof input.nickname!=='string'||!/^[\p{L}\p{N} _-]{3,20}$/u.test(input.nickname.trim())) return respond({error:'Nickname must have 3–20 letters, numbers, spaces, _ or -'},400);
      // Load and verify the dictionary before consuming the player's daily attempt.
      await dictionary(input.language);
      const day=new Date().toISOString().slice(0,10);
      const digest=new Uint8Array(await crypto.subtle.digest('SHA-256',new TextEncoder().encode(`${serviceKey}:${day}:${input.language}:${input.adjacent}:${VERSION}`)));
      const seed=new DataView(digest.buffer).getUint32(0)%2147483646+1;
      const attempt=await database('rpc/daily_start',{p_user:user.id,p_language:input.language,p_adjacent:input.adjacent,p_nickname:input.nickname.trim(),p_seed:seed});
      return respond({id:attempt.id,day:attempt.day,seed:attempt.seed,version:attempt.version,started_at:attempt.started_at,remaining_ms:Math.max(0,Date.parse(attempt.started_at)+DURATION_MS-Date.now()),score:attempt.score,finished:!!attempt.finished_at});
    }
    if(input.action!=='submit'||typeof input.id!=='string'||!/^[0-9a-f-]{36}$/i.test(input.id)) return respond({error:'Invalid action'},400);
    const rows=await database(`daily_attempts?id=eq.${input.id}&user_id=eq.${user.id}&select=*`,undefined,'GET');
    const attempt=rows[0];
    if(!attempt) return respond({error:'Attempt not found'},404);
    if(attempt.language!==input.language||attempt.adjacent!==input.adjacent||attempt.version!==VERSION) return respond({error:'Attempt category mismatch'},400);
    if(attempt.finished_at) return respond({score:attempt.score,word_count:attempt.word_count,verified:true});
    const age=Date.now()-Date.parse(attempt.started_at);
    if(age<DURATION_MS) return respond({error:'Challenge still running'},409);
    if(age>DURATION_MS+30000) return respond({error:'Submission window expired'},410);
    if(!Array.isArray(input.moves)||input.moves.length>MAX_MOVES) return respond({error:'Invalid moves'},400);
    const text=await dictionary(attempt.language);
    const rules=new DailyRules(attempt.seed,attempt.language,attempt.adjacent);
    for(const move of input.moves) if(!move||!rules.accept(move.path,move.ms,(word:string)=>dictionaryContains(text,word))) return respond({error:'Invalid move'},400);
    // Atomic first write: concurrent retries never replace an already verified score.
    const updated=await database(`daily_attempts?id=eq.${attempt.id}&user_id=eq.${user.id}&finished_at=is.null`,{score:rules.score,word_count:rules.moves.length,finished_at:new Date().toISOString()},'PATCH');
    const result=updated[0]||(await database(`daily_attempts?id=eq.${attempt.id}&user_id=eq.${user.id}&select=score,word_count`,undefined,'GET'))[0];
    return respond({score:result.score,word_count:result.word_count,verified:true});
  } catch {
    // Never return tokens, SQL details, user records or raw provider errors.
    return respond({error:'Service unavailable. Please try again.'},503);
  }
});
