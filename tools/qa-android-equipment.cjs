// Real APK touch flow. Fixtures are allowed only on an explicitly selected emulator.
const fs=require('node:fs');
const {execFileSync}=require('node:child_process');
const at=process.argv.indexOf('--serial'),serial=process.argv[at+1];
if(at<0||!/^emulator-\d+$/.test(serial)||!process.argv.includes('--temporary-fixture'))throw Error('Use --serial emulator-5554 --temporary-fixture. Physical devices are refused.');
const pkg='com.sinisamedic.warofwords';
const adb=(...args)=>execFileSync('adb',['-s',serial,...args],{encoding:'utf8',windowsHide:true,timeout:60000}).trim();
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const check=(ok,label)=>{if(!ok)throw Error(label);console.log('PASS '+label);};
const saved=()=>JSON.parse(adb('shell','run-as',pkg,'cat','files/progress.json'));
const tap=async(x,y)=>{adb('shell','input','swipe',String(Math.round(x)),String(Math.round(y)),String(Math.round(x)),String(Math.round(y)),'180');await wait(1500);};
const W=2400,H=1080,S=H/480,V=W/S;
const point=async(x,y)=>tap(x*S,y*S);
async function launch(){
 adb('shell','am','start','-W','-n',pkg+'/com.godot.game.GodotAppLauncher');
 const pid=adb('shell','pidof',pkg);
 for(let i=0;i<45;i++){
  if(adb('logcat','-d','--pid='+pid,'-s','godot').includes('WarOfWords: ready')){await wait(2000);return;}
  await wait(1000);
 }
 throw Error('Launch timed out');
}
function install(data){
 adb('shell','am','force-stop',pkg);
 fs.writeFileSync('.local/equipment-android-fixture.json',JSON.stringify(data));
 adb('push','.local/equipment-android-fixture.json','/data/local/tmp/wow-equipment.json');
 adb('shell','run-as',pkg,'cp','/data/local/tmp/wow-equipment.json','files/progress.json');
}
function shot(name){adb('shell','screencap','-p','/sdcard/wow-equipment.png');adb('pull','/sdcard/wow-equipment.png','.local/android-equipment-'+name+'.png');}
async function equip(slot,choice){
 await point(24+(slot+.5)*(V-48)/5-4,106);
 const width=(V*.48-34)/2;
 await point(24+choice*(width+10)+width/2,255);
 await point((V*.51+V-24)/2,347);
}
async function main(){
 check(adb('shell','getprop','ro.kernel.qemu')==='1','dedicated emulator confirmed');
 check(adb('shell','dumpsys','package',pkg).includes('versionName=0.1.10'),'installed version is 0.1.10');
 const original=saved(); fs.writeFileSync('.local/equipment-android-original.json',JSON.stringify(original));
 try{
  const fixture={...original,sound:false,music:false,haptics:false,calm:false,tutorial:true,ui_language:'en',word_language:'en',unlocked:11,wins:{},levels:[1,1,1,1],battle:{},artifact:'none',loadout:['pulse','aegis','arc','mend'],weapon:'pulse',lexicon_earned:false};
  install(fixture); await launch(); await point(V*.60,350); await equip(1,1);
  check(saved().loadout[1]==='aegis','locked Mirror ignores equip touch');shot('locked');
  for(let n=0;n<12;n++)fixture.wins[n]=3;
  fixture.lexicon_earned=true; install(fixture); await launch(); await point(V*.60,350);
  for(let slot=0;slot<5;slot++)await equip(slot,1);
  check(JSON.stringify(saved().loadout)===JSON.stringify(['breach','mirror','seal','bloom']),'all four devices equip through real touch targets');
  check(saved().artifact==='reserve','Reserve Cell equips through artifact tab');shot('arsenal');
  await point(V/2,441); check(saved().artifact==='none','artifact can be removed');
  await equip(4,0); check(saved().artifact==='lexicon','Lexicon Seal equips separately');
  await equip(4,1);
  // Use an in-progress battle to verify exact equipment and timers on Android.
  const battle={adjacent_only:true,dictionary_code:'en',mission:5,hp:40,foe:137,max:137,energy:[4,6,5,5],shield:0,countdown:60,freeze:0,surge:false,boost_used:false,used:{},words:0,best:'',duration:0,letters:'STONESTREAMLINEPLANETCARDSEN'.split(''),types:Array.from({length:28},(_,i)=>i%4),attacks:1,power:0,projectiles:[],foe_guard:false,weapon:'breach',loadout:['breach','mirror','seal','bloom'],artifact:'reserve',reserves:[2,2,2,2],shield_kind:'aegis',seal_time:0,bloom_time:0,bloom_ticks:0,bloom_amount:0,best_tiles:0};
  const current=saved();current.battle=battle;current.ui_language='sr';install(current);await launch();
  await point(V*.72,440); await point(V/2+172,382); // Continue -> Resume
  await point(V/2-313,347); // Mirror
  await point(V/2+313,236); // Seal
  await point(V/2+313,347); // Bloom
  await point(V/2,33); // Pause forces a snapshot even on slow emulators.
  let b=saved().battle;
  check(b.shield_kind==='mirror'&&b.shield===14,'Android Mirror activation creates its actual shield');
  check(b.energy[1]===2&&b.energy[2]===2&&b.energy[3]===2,'Android activation restores banked energy per color');
  check(b.bloom_ticks>0&&b.hp>40,'Android Bloom heals and persists remaining ticks');
  check(b.seal_time>0||b.projectiles.some(x=>x.kind==='seal'),'Android Seal is marked or still in flight');
  const snapshot=JSON.stringify(b);await wait(1500);check(JSON.stringify(saved().battle)===snapshot,'paused effects do not advance');shot('pause');
  await point(V/2+172,382);await wait(2000);shot('battle');
  await point(V/2,33);const resumed=saved().battle;
  check(resumed.loadout[1]==='mirror'&&resumed.artifact==='reserve','Android battle preserves captured loadout');
  adb('shell','am','force-stop',pkg);await launch();await point(V*.72,440);
  check(JSON.stringify(saved().battle)===JSON.stringify(resumed),'force-stop and continue preserve equipment state');
  const pid=adb('shell','pidof',pkg),logs=adb('logcat','-d','--pid='+pid,'-s','godot','AndroidRuntime');
  fs.writeFileSync('.local/android-equipment-runtime.log',logs);
  check(!/SCRIPT ERROR|E godot.*ERROR:|FATAL EXCEPTION/.test(logs),'Android has no script errors or crash');
  console.log('ANDROID EQUIPMENT QA PASSED');
 }finally{install(original);await launch();}
}
main().catch(e=>{console.error(e.stack);process.exitCode=1;});
