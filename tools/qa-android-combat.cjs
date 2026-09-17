// Real APK: ready/shield presentation, victory and death while holding a gesture.
// Temporary emulator fixtures are always replaced with the original save afterwards.
const {execFileSync}=require('node:child_process');
const fs=require('node:fs');
const i=process.argv.indexOf('--serial'),serial=i<0?'':process.argv[i+1];
if(!/^emulator-\d+$/.test(serial)||!process.argv.includes('--temporary-fixture'))throw Error('Use --serial emulator-5554 --temporary-fixture; physical phones are refused.');
const pkg='com.sinisamedic.warofwords';
const adb=(...a)=>execFileSync('adb',['-s',serial,...a],{encoding:'utf8',windowsHide:true,timeout:60000}).trim();
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const check=(ok,msg)=>{if(!ok)throw Error(msg);console.log('PASS '+msg);};
const save=()=>JSON.parse(adb('shell','run-as',pkg,'cat','files/progress.json'));
const tap=async(x,y,delay=1000)=>{adb('shell','input','tap',''+x,''+y);await wait(delay);};
function installSave(file){adb('push',file,'/data/local/tmp/wow-combat-fixture.json');adb('shell','run-as',pkg,'cp','/data/local/tmp/wow-combat-fixture.json','files/progress.json');}
function capture(name){adb('shell','screencap','-p','/sdcard/wow-combat.png');adb('pull','/sdcard/wow-combat.png','.local/android-combat-'+name+'.png');}
function logs(name){const pid=adb('shell','pidof',pkg),log=adb('logcat','-d','--pid='+pid,'-s','godot','AndroidRuntime');fs.writeFileSync('.local/android-combat-'+name+'.log',log);check(!/SCRIPT ERROR|E godot.*ERROR:|FATAL EXCEPTION/.test(log),name+' has no runtime errors');}
async function launch(){
 adb('shell','am','start','-W','-n',pkg+'/com.godot.game.GodotAppLauncher');
 const pid=adb('shell','pidof',pkg);
 for(let n=0;n<40;n++){
  if(adb('logcat','-d','--pid='+pid,'-s','godot').includes('WarOfWords: ready')){await wait(1400);return;}
  await wait(1000);
 }
 throw Error('Launch timeout');
}
async function main(){
 adb('wait-for-device');check(adb('shell','getprop','ro.kernel.qemu')==='1','combat fixture is restricted to emulator');
 adb('shell','am','force-stop',pkg);
 const original=adb('shell','run-as',pkg,'cat','files/progress.json');
 const backup='.local/combat-original.json';fs.writeFileSync(backup,original);
 async function scenario(name,overrides){
  adb('shell','am','force-stop',pkg);
  const fixture=JSON.parse(original);
  Object.assign(fixture,{ui_language:'en',word_language:'en',sound:false,music:false,calm:false,tutorial:true,unlocked:Math.max(6,fixture.unlocked)});
  fixture.battle={adjacent_only:true,dictionary_code:'en',mission:6,hp:100,foe:150,max:150,energy:[4,5,7,5],shield:20,countdown:60,freeze:0,surge:false,boost_used:false,used:{STONE:1},words:1,best:'STONE',duration:10,letters:('STONEXX'+'BRIDGEX'+'GUARDXX'+'POWERXX').split(''),types:Array.from({length:28},(_,n)=>n%4),attacks:0,power:0,projectiles:[],...overrides};
  fs.writeFileSync('.local/combat-fixture.json',JSON.stringify(fixture));installSave('.local/combat-fixture.json');
  await launch();await tap(1730,966);await tap(1590,855,200);
  return fixture;
 }
 try {
  await scenario('ready',{});capture('shield-ready');
  await tap(496,531);await tap(1200,80);
  check(save().battle.foe<150&&save().battle.energy[0]===0&&save().battle.shield===20,'ready Pulse fires while shield remains active');
  logs('ready');
  const victory=await scenario('victory',{foe:1,shield:0});
  await tap(496,531,2400);capture('victory');
  const won=save();check(won.wins['6']>=1&&Object.keys(won.battle).length===0&&won.coins>victory.coins,'lethal Pulse completes victory and saves reward');
  await tap(1600,855);await tap(2110,983);await tap(1200,80);
  check(save().battle.mission===7,'Next button starts the following duel after defeat animation');
  check(save().coins===won.coins,'leaving result does not duplicate victory reward');logs('victory');
  const defeat=await scenario('defeat',{hp:1,shield:0,countdown:1.0});
  // Death happens during this held touch; releasing after it must not lock result input.
  adb('shell','input','swipe','761','533','907','533','3200');await wait(2200);capture('defeat');
  const lost=save();check(Object.keys(lost.battle).length===0&&lost.coins===defeat.coins+2,'CPU lethal hit finishes defeat during held gesture');
  await tap(1600,855);await tap(2110,983);await tap(1200,80);
  check(save().battle.mission===6&&save().battle.hp===100,'Retry works after death interrupted a touch');
  check(save().coins===lost.coins,'retry does not repeat defeat reward');logs('defeat');
 } finally {
  adb('shell','am','force-stop',pkg);installSave(backup);
  check(adb('shell','run-as',pkg,'cat','files/progress.json')===original,'original emulator save restored after combat fixture');
 }
 console.log('ANDROID COMBAT QA PASSED');
}
main().catch(e=>{console.error('FAIL '+e.message);process.exitCode=1;});
