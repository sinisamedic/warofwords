const {execFileSync}=require('node:child_process');
const fs=require('node:fs');
// Explicitly opt in: this test clears only this game's data on the chosen emulator.
const serialIndex=process.argv.indexOf('--serial');
const serial=serialIndex>=0?process.argv[serialIndex+1]:'';
if(!/^emulator-\d+$/.test(serial)||!process.argv.includes('--reset-test-data')){
 console.error('Usage: node tools/qa-android.cjs --serial emulator-5554 --reset-test-data (requires 2400x1080 landscape)');
 process.exit(1);
}
const pkg='com.sinisamedic.warofwords';
const adb=(...args)=>execFileSync('adb',['-s',serial,...args],{encoding:'utf8',windowsHide:true,timeout:45000}).trim();
const sleep=ms=>new Promise(r=>setTimeout(r,ms));
const tap=async(x,y)=>{adb('shell','input','tap',String(x),String(y));await sleep(750);};
const save=()=>JSON.parse(adb('shell','run-as',pkg,'cat','files/progress.json'));
function check(ok,msg){if(!ok)throw Error(msg);console.log('PASS '+msg);}
async function shot(name){await sleep(350);adb('shell','screencap','-p','/sdcard/wow-qa.png');adb('pull','/sdcard/wow-qa.png','.local/android-'+name+'.png');}
async function start(){adb('shell','am','start','-W','-n',pkg+'/com.godot.game.GodotAppLauncher');const pid=adb('shell','pidof',pkg);for(let i=0;i<30;i++){await sleep(1000);if(adb('logcat','-d','--pid='+pid,'-s','godot').includes('WarOfWords: ready')){await sleep(1200);return;}}throw Error('Game did not become ready within 30 seconds');}
const dictionary=new Set(fs.readFileSync('game/data/english.txt','utf8').trim().toUpperCase().split(/\r?\n/));
const prefixes=new Set();for(const w of dictionary)for(let n=1;n<=Math.min(w.length,10);n++)prefixes.add(w.slice(0,n));
function bestPath(b){let best=[];function dfs(i,str,path,mask){if(path.length>=10||(mask&(1<<i)))return;str+=b.letters[i];if(!prefixes.has(str))return;path=path.concat(i);mask|=1<<i;if(dictionary.has(str)&&!b.used[str]&&path.length>best.length)best=path;for(let j=0;j<28;j++)if(j!==i&&Math.abs(j%7-i%7)<=1&&Math.abs(Math.floor(j/7)-Math.floor(i/7))<=1)dfs(j,str,path,mask);}for(let i=0;i<28;i++)dfs(i,'',[],0);return best;}
async function main(){
 check(adb('shell','getprop','ro.kernel.qemu')==='1','target is our emulator');
 adb('shell','am','force-stop',pkg);
 adb('shell','pm','clear',pkg);
 await start(); await shot('home');
 await tap(1730,615);await shot('campaign');
 await tap(2080,905);await shot('powers');
 await tap(2110,983);await shot('help');
 await tap(1200,855);
 adb('shell','input','swipe','781','554','1340','554','1200');await sleep(800);
 await tap(1875,995);await tap(1200,80);
 let s=save();check(s.battle.used.STONE&&s.battle.words===1&&s.battle.foe===65,'drag forms STONE, refills and damages');
 check(s.battle.boost_used,'power-up consumed');
 const snapshot=JSON.stringify(s.battle);
 adb('shell','am','force-stop',pkg);await start();
 await tap(1730,940);await shot('resume');
 s=save();check(JSON.stringify(s.battle)===snapshot,'force-stop/relaunch preserves battle');
 await sleep(1200);check(JSON.stringify(save().battle)===snapshot,'resumed duel remains paused');
 await tap(1590,855);await tap(520,810);await tap(520,993);await shot('battle');await tap(1200,80);
 s=save();if(JSON.parse(snapshot).energy[1]>=5)check(s.battle.shield===20&&s.battle.energy[1]===0,'touch fires charged Aegis');
 for(let step=0;step<12;step++){
  s=save();if(!s.battle.letters)break;
  const path=bestPath(s.battle);check(path.length>=3,'board has playable word');
  console.log('PLAY '+path.map(i=>s.battle.letters[i]).join(''));
  await tap(1590,855);
  for(const i of path){adb('shell','input','tap',String(Math.round(781.5+(i%7)*139.5)),String(Math.round(553.5+Math.floor(i/7)*139.5)));await sleep(110);}
  await tap(1610,440);s=save();
  if(!s.battle.letters)break;
  if(s.battle.energy[0]>=4)await tap(530,594);
  s=save();if(!s.battle.letters)break;
  if(s.battle.energy[2]>=7)await tap(1870,594);
  s=save();if(!s.battle.letters)break;
  if(s.battle.energy[3]>=5&&s.battle.hp<100)await tap(1870,810);
  await tap(1200,80);
 }
 s=save();check(s.wins['0']>=1&&s.unlocked===1&&s.coins===300,'actual touch gameplay wins, awards coins and unlocks mission');await shot('victory');
 await tap(1150,855);await shot('upgrades-before');await tap(1810,780);await shot('upgrades');
 s=save();check(s.levels[0]===2&&s.coins===140,'upgrade spends 160 coins');
 adb('shell','am','force-stop',pkg);await start();s=save();check(s.levels[0]===2&&s.coins===140&&s.unlocked===1,'campaign and upgrades persist after restart');
 const pid=adb('shell','pidof',pkg);const log=adb('logcat','-d','--pid='+pid,'-s','godot','Godot','AndroidRuntime');fs.writeFileSync('.local/android-final-logcat.txt',log);check(!/SCRIPT ERROR|E godot.*ERROR:|FATAL EXCEPTION/.test(log),'latest Android launch has no engine/script error');
 console.log('ANDROID QA PASSED');
}
main().catch(e=>{console.error('FAIL '+e.message);process.exitCode=1;});
