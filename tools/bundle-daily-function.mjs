import {readFileSync,writeFileSync,mkdirSync} from 'node:fs';
const root=new URL('../',import.meta.url);
const rules=readFileSync(new URL('supabase/functions/daily/rules.mjs',root),'utf8');
const handler=readFileSync(new URL('supabase/functions/daily/index.ts',root),'utf8').replace(/^import[^\n]+\n/,'');
mkdirSync(new URL('.local/',root),{recursive:true});
writeFileSync(new URL('.local/supabase-daily.ts',root),rules+'\n'+handler);
console.log('Prepared .local/supabase-daily.ts for the Supabase dashboard editor. No credentials embedded.');
