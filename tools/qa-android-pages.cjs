// Exercise paging on the actual APK with temporary data, restoring the emulator save in finally.
const {execFileSync}=require('node:child_process');
const fs=require('node:fs'),crypto=require('node:crypto');
const index=process.argv.indexOf('--serial'),serial=index<0?'':process.argv[index+1];
if(!/^emulator-\d+$/.test(serial)||!process.argv.includes('--temporary-fixture'))throw Error('Use --serial emulator-5554 --temporary-fixture; physical phones are refused.');
const pkg='com.sinisamedic.warofwords';
const adb=(...a)=>execFileSync('adb',['-s',serial,...a],{encoding:'utf8',windowsHide:true,timeout:60000}).trim();
const wait=ms=>new Promise(r=>setTimeout(r,ms));
const check=(ok,msg)=>{if(!ok)throw Error(msg);console.log('PASS '+msg);};
const tap=async(x,y)=>{adb('shell','input','tap',''+x,''+y);await wait(1000);};
async function launch(){adb('shell','am','start','-W','-n',pkg+'/com.godot.game.GodotAppLauncher');const pid=adb('shell','pidof',pkg);for(let i=0;i<40;i++){if(adb('logcat','-d','--pid='+pid,'-s','godot').includes('WarOfWords: ready')){await wait(1400);return;}await wait(1000);}throw Error('Launch timeout');}
async function swipe(left){adb('shell','input','swipe',left?'1800':'650','540',left?'650':'1800','550','450');await wait(1000);}
function installSave(file){adb('push',file,'/data/local/tmp/wow-pages-fixture.json');adb('shell','run-as',pkg,'cp','/data/local/tmp/wow-pages-fixture.json','files/progress.json');}
function capture(name){const path='.local/android-pages-'+name+'.png';adb('shell','screencap','-p','/sdcard/wow-pages.png');adb('pull','/sdcard/wow-pages.png',path);return crypto.createHash('sha256').update(fs.readFileSync(path)).digest('hex');}
async function main(){
 adb('wait-for-device');check(adb('shell','getprop','ro.kernel.qemu')==='1','page fixture is restricted to emulator');
 adb('shell','am','force-stop',pkg);
 const original=adb('shell','run-as',pkg,'cat','files/progress.json'),backup='.local/pages-original.json';fs.writeFileSync(backup,original);
 const fixture=JSON.parse(original);fixture.ui_language='en';fixture.word_language='en';fixture.unlocked=11;
 fixture.dictionary=['STONE','SUNLIGHT','BRIDGE','GUARDIAN','TEMPEST','JOURNEY','ASTRAL','COPPER','ARCHIVE','THUNDER','WORDSMITH','SENTINEL','WARDEN','CRESCENT','ORBIT','CRYSTAL','FORGE','AETHER','SKYLINE','RADIANCE','BLADE','LIGHT','STORM','BOOK','SWORD','ARMOR','SHIELD','MUSIC','SPELL','GOLD','SILVER','FIRE','EARTH','WATER','WIND','TOWER','GATE','CROWN','KNIGHT','POWER','EXTRAORDINARY'];
 fixture.total_words=41;fixture.longest='EXTRAORDINARY';fs.writeFileSync('.local/pages-fixture.json',JSON.stringify(fixture));
 try {
  installSave('.local/pages-fixture.json');await launch();
  await tap(590,90);const page1=capture('journal-1');
  await swipe(true);const page2=capture('journal-2');check(page1!==page2,'journal left swipe changes the twenty-word page');
  await swipe(false);check(capture('journal-return')===page1,'journal right swipe restores exactly the first page');
  await tap(2268,992);check(capture('journal-arrow')===page2,'journal arrow and swipe reach the same page');
  await swipe(true);const page3=capture('journal-3');check(page3!==page2,'last partial journal page is reachable');
  await swipe(true);check(capture('journal-limit')===page3,'journal cannot swipe beyond its final page');
  await tap(120,90);await tap(1730,615);await tap(109,245);await tap(109,245);
  const map1=capture('campaign-1');await swipe(true);check(capture('campaign-2')!==map1,'campaign swipe changes the map chapter');
  await swipe(false);check(capture('campaign-return')===map1,'campaign reverse swipe restores map and selected mission');
  const pid=adb('shell','pidof',pkg),log=adb('logcat','-d','--pid='+pid,'-s','godot','AndroidRuntime');fs.writeFileSync('.local/android-pages-logcat.txt',log);
  check(!/SCRIPT ERROR|E godot.*ERROR:|FATAL EXCEPTION/.test(log),'paging has no runtime errors');
 } finally {
  adb('shell','am','force-stop',pkg);installSave(backup);
  check(adb('shell','run-as',pkg,'cat','files/progress.json')===original,'original emulator progress restored after temporary fixture');
 }
 console.log('ANDROID PAGING QA PASSED');
}
main().catch(e=>{console.error('FAIL '+e.message);process.exitCode=1;});
