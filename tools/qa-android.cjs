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
async function waitDictionaryLoads(count){const pid=adb('shell','pidof',pkg);for(let i=0;i<30;i++){const log=adb('logcat','-d','--pid='+pid,'-s','godot');if((log.match(/WarOfWords: ready/g)||[]).length>=count){await sleep(1200);return;}await sleep(1000);}throw Error('Dictionary loading did not finish within 30 seconds');}
let dictionary=[];
function loadDictionary(code){const zlib=require('node:zlib');const raw=code==='sr'?zlib.gunzipSync(fs.readFileSync('game/data/serbian.txt.gz')).toString('utf8'):fs.readFileSync('game/data/english.txt','utf8');dictionary=raw.trim().toUpperCase().split(/\r?\n/).sort();}
loadDictionary('en');
function lowerBound(word){let l=0,r=dictionary.length;while(l<r){const m=(l+r)>>>1;if(dictionary[m]<word)l=m+1;else r=m;}return l;}
function bestPath(b,accent=false){let best=[],bestScore=0;function dfs(i,str,path,mask){if(path.length>=9||(mask&(1<<i)))return;str+=b.letters[i];const index=lowerBound(str);if(index>=dictionary.length||!dictionary[index].startsWith(str))return;path=path.concat(i);mask|=1<<i;const score=path.length+(accent&&/[ČĆŠĐŽ]|LJ|NJ/.test(str)?30:0);if(path.length>=3&&dictionary[index]===str&&!b.used[str]&&score>bestScore){best=path;bestScore=score;}for(let j=0;j<28;j++)if(j!==i&&Math.abs(j%7-i%7)<=1&&Math.abs(Math.floor(j/7)-Math.floor(i/7))<=1)dfs(j,str,path,mask);}for(let i=0;i<28;i++)dfs(i,'',[],0);return best;}
async function main(){
 check(adb('shell','getprop','ro.kernel.qemu')==='1','target is our emulator');
 adb('shell','am','force-stop',pkg);
 adb('shell','pm','clear',pkg);
 await start(); await shot('home');
 await tap(1730,615);await shot('campaign');
 await tap(2080,905);await shot('powers');
 await tap(2110,983);await shot('help');
 await tap(1200,855);
 adb('shell','input','swipe','761','533','1346','533','1200');await sleep(800);
 await tap(1862,1004);await tap(1200,80);
 let s=save();check(s.battle.used.STONE&&s.battle.words===1&&s.battle.foe===65,'drag forms STONE, refills and damages');
 check(s.battle.boost_used,'power-up consumed');
 const snapshot=JSON.stringify(s.battle);
 adb('shell','am','force-stop',pkg);await start();
 await tap(1730,966);await shot('resume');
 s=save();check(JSON.stringify(s.battle)===snapshot,'force-stop/relaunch preserves battle');
 await sleep(1200);check(JSON.stringify(save().battle)===snapshot,'resumed duel remains paused');
 await tap(1590,855);await tap(496,781);await tap(496,1004);await shot('battle');await tap(1200,80);
 s=save();if(JSON.parse(snapshot).energy[1]>=5)check(s.battle.shield===20&&s.battle.energy[1]===0,'touch fires charged Aegis');
 for(let step=0;step<12;step++){
  s=save();if(!s.battle.letters)break;
  const path=bestPath(s.battle);check(path.length>=3,'board has playable word');
  console.log('PLAY '+path.map(i=>s.battle.letters[i]).join(''));
  await tap(1590,855);
  for(const i of path){adb('shell','input','tap',String(Math.round(761.25+(i%7)*146.25)),String(Math.round(533.25+Math.floor(i/7)*146.25)));await sleep(110);}
  await tap(1667,407);s=save();
  if(!s.battle.letters)break;
  if(s.battle.energy[0]>=4)await tap(496,531);
  s=save();if(!s.battle.letters)break;
  if(s.battle.energy[2]>=7)await tap(1904,531);
  s=save();if(!s.battle.letters)break;
  if(s.battle.energy[3]>=5&&s.battle.hp<100)await tap(1904,781);
  await tap(1200,80);
 }
 s=save();check(s.wins['0']>=1&&s.unlocked===1&&s.coins===300,'actual touch gameplay wins, awards coins and unlocks mission');await sleep(1600);await shot('victory');
 await tap(1150,855);await shot('upgrades-before');await tap(1810,780);await shot('upgrades');
 s=save();check(s.levels[0]===2&&s.coins===140,'upgrade spends 160 coins');
 adb('shell','am','force-stop',pkg);await start();s=save();check(s.levels[0]===2&&s.coins===140&&s.unlocked===1,'campaign and upgrades persist after restart');
 // Separate interface and dictionary settings, using real Android taps.
 await tap(175,90);await tap(2040,366);
 s=save();check(s.ui_language==='sr'&&s.word_language==='en','Serbian interface independent of English dictionary');
 await tap(550,263);await tap(550,380);await tap(550,497);await tap(550,614);
 await tap(2040,620);await waitDictionaryLoads(2);await shot('settings-serbian');
 s=save();check(s.word_language==='sr'&&!s.sound&&!s.music&&!s.haptics&&s.calm,'dictionary and all four toggles persist');
 await tap(120,90);await tap(1730,615);await tap(2080,905);await tap(2110,983);await tap(1200,80);
 s=save();check(s.battle.dictionary_code==='sr'&&s.battle.letters.length===28,'new Android duel uses Serbian dictionary');
 loadDictionary('sr');const srPath=bestPath(s.battle,true);const srWord=srPath.map(i=>s.battle.letters[i]).join('');check(srPath.length>=3,'Serbian board has a valid path');
 console.log('SERBIAN PLAY '+srWord);await tap(1590,855);
 for(const i of srPath){adb('shell','input','tap',String(Math.round(761.25+(i%7)*146.25)),String(Math.round(533.25+Math.floor(i/7)*146.25)));await sleep(110);}
 await shot('battle-serbian-tap');await tap(1667,407);await tap(1200,80);
 s=save();check(s.battle.used[srWord]&&s.battle.words===1,'Serbian word accepted via tap and confirmation');
 const srSnapshot=JSON.stringify(s.battle);
 adb('shell','am','force-stop',pkg);await start();await tap(1730,966);s=save();
 check(JSON.stringify(s.battle)===srSnapshot&&s.ui_language==='sr'&&s.word_language==='sr','Serbian battle and settings survive restart');
 await tap(1060,855); // pause -> settings
 await tap(1491,366);await tap(1491,620);await sleep(1300);await tap(120,90);await tap(1730,966);
 s=save();check(s.word_language==='en'&&s.ui_language==='en'&&s.battle.dictionary_code==='sr','saved Serbian duel keeps dictionary after switching menus and new duels to English');
 await tap(1590,855);await shot('battle-serbian-english-ui');await tap(1200,80);
 const pid=adb('shell','pidof',pkg);const log=adb('logcat','-d','--pid='+pid,'-s','godot','Godot','AndroidRuntime');fs.writeFileSync('.local/android-final-logcat.txt',log);check(!/SCRIPT ERROR|E godot.*ERROR:|FATAL EXCEPTION/.test(log),'latest Android launch has no engine/script error');
 console.log('ANDROID QA PASSED');
}
main().catch(e=>{console.error('FAIL '+e.message);process.exitCode=1;});
