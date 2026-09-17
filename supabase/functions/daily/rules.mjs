// Portable daily-v2 rules, with frozen v1 replay support for existing clients.
export const VERSION = 'daily-v2';
export const DURATION_MS = 120000;
export const MAX_MOVES = 240;
const POOLS = {
  en: 'EEEEEEEEEEEAAAAAAAIIIIIIIOOOOOOONNNNNNRRRRRRTTTTTTLLLLSSSSUUUUDDDDGGGBCMPFHVWYJKQZ',
  sr: 'AAAAAAAEEEEEEEIIIIIIIOOOOOOOUUUNNNNRRRRSSSTTTTVVVLLLDDMMKKPPBGZJČĆŠĐŽFHC',
};
const STARTERS = {
  en: ['STONE','STREAM','PLANET','BRIDGE','SILVER','GARDEN','ORANGE','CANDLE','STORM','CROWN','RIVER','SPARK'],
  sr: ['KAMEN','REKA','VODA','VATRA','SNAGA','ZEMLJA','NEBO','OBLAK','SVETLO','ISKRA','IGRA','MOST'],
};
export class DailyRules {
  constructor(seed, language, adjacent, version=VERSION) {
    if (!Number.isInteger(seed) || seed<1 || seed>2147483646 || !POOLS[language] || typeof adjacent!=='boolean') throw Error('Invalid rules');
    if(!['daily-v1',VERSION].includes(version)) throw Error('Unsupported rules');
    this.version=version; this.state=seed; this.language=language; this.adjacent=adjacent;
    this.used=new Set(); this.moves=[]; this.score=0;
    this.letters=Array.from({length:28},()=>this.randomLetter());
    const options=[...STARTERS[language]];
    for(let row=0;row<4;row++) {
      const word=this.tiles(options.splice(this.randomIndex(options.length),1)[0]);
      if(this.randomIndex(2)===1) word.reverse();
      const offset=this.randomIndex(8-word.length);
      word.forEach((tile,j)=>this.letters[row*7+offset+j]=tile);
    }
  }
  randomIndex(count) { this.state=(this.state*48271)%2147483647; return this.state%count; }
  tiles(word) { return this.language==='sr' ? word.match(/LJ|NJ|DŽ|./gu) : [...word]; }
  randomLetter() {
    const pool=[...POOLS[this.language]];
    if(this.language==='sr') pool.push('LJ','NJ','DŽ');
    return pool[this.randomIndex(pool.length)];
  }
  wordAt(path) {
    if(!Array.isArray(path)||path.length<3||path.length>28) return '';
    const seen=new Set(); let word='';
    for(let n=0;n<path.length;n++) {
      const i=path[n];
      if(!Number.isInteger(i)||i<0||i>=28||seen.has(i)) return '';
      if(this.adjacent&&n>0) {
        const prev=path[n-1];
        if(Math.abs(i%7-prev%7)>1||Math.abs(Math.floor(i/7)-Math.floor(prev/7))>1) return '';
      }
      seen.add(i); word+=this.letters[i];
    }
    return this.used.has(word)?'':word;
  }
  accept(path,ms,contains) {
    if(!Number.isInteger(ms)||ms<0||ms>=DURATION_MS||this.moves.length>=MAX_MOVES) return false;
    if(this.moves.length&&ms<this.moves.at(-1).ms+250) return false;
    const word=this.wordAt(path);
    if(!word||!contains(word)) return false;
    this.used.add(word); this.score+=path.length*10+Math.max(0,path.length-4)*5;
    this.moves.push({path:[...path],ms});
    for(const i of path) this.letters[i]=this.randomLetter();
    if(this.version==='daily-v1') {
      const candidates=STARTERS[this.language].filter(w=>!this.used.has(w)&&this.tiles(w).length<=path.length);
      if(candidates.length) this.tiles(candidates[this.randomIndex(candidates.length)]).forEach((tile,n)=>this.letters[path[n]]=tile);
    } else this.refillCrossing(path);
    return true;
  }
  refillCrossing(consumed) {
    this.refillNodes=0; this.lastRefillRoute=[];
    const candidates=STARTERS[this.language];
    const offset=this.randomIndex(candidates.length),start=this.randomIndex(28);
    for(let n=0;n<candidates.length;n++) {
      const word=candidates[(offset+n)%candidates.length];
      if(this.used.has(word)) continue;
      const tiles=this.tiles(word);
      for(let j=0;j<28;j++) {
        const route=this.fitCrossing(tiles,consumed,(start+j)%28,[],0,0);
        if(route.length) {
          route.forEach((cell,k)=>{if(consumed.includes(cell)) this.letters[cell]=tiles[k];});
          this.lastRefillRoute=route; return;
        }
        if(this.refillNodes>=4000) return;
      }
    }
  }
  fitCrossing(tiles,consumed,cell,route,fixedCount,freshCount) {
    this.refillNodes++;
    if(this.refillNodes>4000||route.includes(cell)) return [];
    const fresh=consumed.includes(cell);
    if(!fresh&&this.letters[cell]!==tiles[route.length]) return [];
    const fixed=fixedCount+(fresh?0:1),changed=freshCount+(fresh?1:0),next=[...route,cell];
    if(next.length===tiles.length) return fixed>=2&&changed>=1?next:[];
    if(fixed+tiles.length-next.length<2) return [];
    for(let neighbor=0;neighbor<28;neighbor++) {
      if(this.adjacent&&(Math.abs(cell%7-neighbor%7)>1||Math.abs(Math.floor(cell/7)-Math.floor(neighbor/7))>1)) continue;
      if(this.refillNodes>=4000) break;
      const found=this.fitCrossing(tiles,consumed,neighbor,next,fixed,changed);
      if(found.length) return found;
    }
    return [];
  }
}

// Sorted newline-separated uppercase dictionary. No million-entry Set in the edge runtime.
export function dictionaryContains(text, word) {
  let lo=0, hi=text.length;
  while(lo<hi) {
    const middle=Math.floor((lo+hi)/2);
    const start=text.lastIndexOf('\n',middle-1)+1;
    let end=text.indexOf('\n',middle); if(end<0) end=text.length;
    const candidate=text.slice(start,end);
    if(candidate===word) return true;
    if(candidate<word) lo=end+1; else hi=start;
  }
  return false;
}
