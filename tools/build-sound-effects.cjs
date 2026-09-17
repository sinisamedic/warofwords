// Original deterministic sound synthesis. No sampled third-party recordings.
const fs=require('fs'),path=require('path');
const dir=path.resolve(__dirname,'../game/assets/audio');fs.mkdirSync(dir,{recursive:true});
const rate=24000,TAU=Math.PI*2;
const lengths={tap:.12,word:.48,shot:.46,flight:.44,hit:.58,explosion:.85,shield:.64,arc:.55,heal:.8,freeze:.85,win:1.35,lose:1.0,upgrade:1.05};
let seed=7432189;const random=()=>{seed=(Math.imul(seed,1664525)+1013904223)>>>0;return seed/4294967296*2-1;};
const report=[];
for(const [key,duration] of Object.entries(lengths)){
 const count=Math.ceil(duration*rate),data=new Float64Array(count);let low=0,phase=0;
 for(let i=0;i<count;i++){
  const t=i/rate,u=t/duration,n=random();low+=.11*(n-low);const high=n-low;
  const env=(decay,attack=.003)=>Math.min(1,t/attack)*Math.exp(-t*decay);let v=0;
  if(key==='shot'){
   phase+=TAU*(95+740*Math.exp(-t*18))/rate;
   v=.72*Math.sin(phase)*env(11)+.50*low*env(14)+.18*high*env(38)+.18*Math.sin(TAU*53*t)*env(12);
  }else if(key==='flight'){
   phase+=TAU*(1200*Math.exp(-t*5)+125)/rate;
   v=(.42*high+.30*Math.sin(phase+.7*Math.sin(TAU*93*t)))*Math.pow(Math.sin(Math.PI*u),1.7)*.55;
  }else if(key==='hit'||key==='explosion'){
   phase+=TAU*(48+130*Math.exp(-t*26))/rate;
   v=.63*Math.sin(phase)*env(8)+.75*low*env(key==='explosion'?4:10)+.22*high*env(24)+.18*Math.sin(TAU*117*t)*env(14);
  }else if(key==='shield'){
   v=(Math.sin(TAU*780*t)+.5*Math.sin(TAU*1175*t)+.18*Math.sin(TAU*1910*t))*env(8)*.33+high*env(30)*.2+Math.sin(TAU*160*t)*env(18)*.28;
  }else if(key==='arc'){
   phase+=TAU*(190+2000*Math.exp(-t*15))/rate;
   v=Math.sin(phase+Math.sin(TAU*57*t)*2)*env(8)*.48+high*env(11)*(.2+.15*Math.sin(TAU*90*t));
  }else if(key==='freeze'){
   v=high*env(5,.025)*.23;
   for(let j=0;j<5;j++)v+=Math.sin(TAU*[1318,1760,2093,2637,3136][j]*t)*env(5+j,.02)*.055;
  }else if(key==='tap'){
   phase+=TAU*(1700-800*u)/rate;v=Math.sin(phase)*env(40)*.22+high*env(70)*.07;
  }else{
   const notes=key==='lose'?[293.66,261.63,220,146.83]:key==='heal'?[523.25,659.25,783.99,1046.5]:[392,493.88,587.33,783.99];
   for(let j=0;j<4;j++){const dt=t-j*duration*.14;if(dt>=0)v+=(Math.sin(TAU*notes[j]*dt)+.22*Math.sin(TAU*notes[j]*2*dt))*Math.exp(-dt*5)*Math.min(1,dt/.008)*.19;}
   v+=low*env(15)*.08;
  }
  data[i]=v*Math.min(1,(duration-t)/.035);
 }
 const echo=Math.floor(.062*rate);for(let i=count-1;i>=echo;i--)data[i]+=data[i-echo]*.17;
 let peak=0;for(const x of data)peak=Math.max(peak,Math.abs(x));
 const gain=(key==='tap'?.36:.82)/Math.max(.01,peak),wav=Buffer.alloc(44+count*2);
 wav.write('RIFF');wav.writeUInt32LE(wav.length-8,4);wav.write('WAVEfmt ',8);wav.writeUInt32LE(16,16);wav.writeUInt16LE(1,20);wav.writeUInt16LE(1,22);wav.writeUInt32LE(rate,24);wav.writeUInt32LE(rate*2,28);wav.writeUInt16LE(2,32);wav.writeUInt16LE(16,34);wav.write('data',36);wav.writeUInt32LE(count*2,40);
 let rms=0;for(let i=0;i<count;i++){const x=data[i]*gain*Math.min(1,(count-i)/240);wav.writeInt16LE(Math.round(x*32767),44+i*2);rms+=x*x;}
 fs.writeFileSync(path.join(dir,key+'.wav'),wav);report.push({key,seconds:duration,peak:+(peak*gain).toFixed(3),rms:+Math.sqrt(rms/count).toFixed(3)});
}
console.log(JSON.stringify(report,null,2));
