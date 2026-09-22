import assert from 'node:assert/strict';
let handler, deleted=[], reject=false;
globalThis.Deno={env:{get:n=>({SUPABASE_URL:'https://test.invalid',SUPABASE_SERVICE_ROLE_KEY:'server-test-key'})[n]},serve:fn=>handler=fn};
globalThis.fetch=async(url,options={})=>{
 if(url.endsWith('/auth/v1/user')) return options.headers.Authorization==='Bearer owner-token'?Response.json({id:'verified-owner'}):Response.json({}, {status:401});
 if(url.includes('/auth/v1/admin/users/')) {
  assert.equal(options.method,'DELETE'); assert.equal(options.headers.apikey,'server-test-key');
  assert.equal(JSON.parse(options.body).should_soft_delete,false);
  if(reject) return Response.json({}, {status:500});
  deleted.push(url); return Response.json({id:'verified-owner'});
 }
 throw Error('Unexpected request');
};
await import('../supabase/functions/daily/index.ts');
const call=(body,token='owner-token')=>handler(new Request('https://test.invalid/functions/v1/daily',{method:'POST',headers:{Authorization:`Bearer ${token}`},body:JSON.stringify(body)}));
assert.equal((await call({action:'delete_profile',confirm:'DELETE_MY_PROFILE'},'other-token')).status,401);
assert.equal((await call({action:'delete_profile'})).status,400);
assert.equal(deleted.length,0);
let result=await call({action:'delete_profile',confirm:'DELETE_MY_PROFILE',user_id:'victim'});
assert.equal(result.status,200); assert.deepEqual(await result.json(),{deleted:true});
assert.deepEqual(deleted,['https://test.invalid/auth/v1/admin/users/verified-owner']);
reject=true; assert.equal((await call({action:'delete_profile',confirm:'DELETE_MY_PROFILE'})).status,503);
console.log('PASS: authenticated deletion, mandatory confirmation, payload cannot select another user, provider failure not reported as success');
