// Portable daily-v1 rules; intentionally no engine-specific RNG or client score input.
export const VERSION = 'daily-v1';
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
  constructor(seed, language, adjacent) {
    if (!Number.isInteger(seed) || seed<1 || seed>2147483646 || !POOLS[language] || typeof adjacent!=='boolean') throw Error('Invalid rules');
    this.state=seed; this.language=language; this.adjacent=adjacent;
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
    const candidates=STARTERS[this.language].filter(w=>!this.used.has(w)&&this.tiles(w).length<=path.length);
    if(candidates.length) this.tiles(candidates[this.randomIndex(candidates.length)]).forEach((tile,n)=>this.letters[path[n]]=tile);
    return true;
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
