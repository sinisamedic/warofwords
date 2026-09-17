// Preserve existing progress and verify the installed bytes, not only versionName.
const {execFileSync}=require('node:child_process');const fs=require('node:fs'),crypto=require('node:crypto');
const arg=name=>process.argv[process.argv.indexOf(name)+1];
const serial=arg('--serial'),apk=arg('--apk');
if(!process.argv.includes('--serial')||!/^emulator-\d+$/.test(serial)||!process.argv.includes('--apk')||!fs.existsSync(apk))throw Error('Use --serial emulator-5554 --apk exports/WarOfWords-0.1.4-android.apk');
const pkg='com.sinisamedic.warofwords',adb=(...a)=>execFileSync('adb',['-s',serial,...a],{encoding:'utf8',windowsHide:true,timeout:60000}).trim();
const wait=ms=>new Promise(r=>setTimeout(r,ms)),save=()=>JSON.parse(adb('shell','run-as',pkg,'cat','files/progress.json'));
const check=(ok,msg)=>{if(!ok)throw Error(msg);console.log('PASS '+msg);};
const tap=async(x,y)=>{adb('shell','input','tap',''+x,''+y);await wait(1100);};
async function ready(count){const pid=adb('shell','pidof',pkg);for(let i=0;i<40;i++){if((adb('logcat','-d','--pid='+pid,'-s','godot').match(/WarOfWords: ready/g)||[]).length>=count){await wait(1400);return;}await wait(1000);}throw Error('Game/dictionary loading timed out');}
async function main(){
 adb('wait-for-device');check(adb('shell','getprop','ro.kernel.qemu')==='1','upgrade target is the emulator');
 adb('shell','am','force-stop',pkg);const before=save();fs.writeFileSync('.local/upgrade-before.json',JSON.stringify(before,null,2));
 check(adb('install','--no-incremental','-r',apk).includes('Success'),'APK installation succeeded');
 check(JSON.stringify(save())===JSON.stringify(before),'install preserves complete progress file');
 const installed=adb('shell','pm','path',pkg).replace(/^package:/,'');
 if(!installed.startsWith('/data/app/')||!installed.endsWith('/base.apk'))throw Error('Unexpected installed APK path');
 const hash=crypto.createHash('sha256').update(fs.readFileSync(apk)).digest('hex');
 check(adb('shell','sha256sum',installed).split(/\s/)[0]===hash,'installed APK SHA256 matches publish artifact: '+hash);
 adb('shell','am','start','-W','-n',pkg+'/com.godot.game.GodotAppLauncher');await ready(1);
 if(Object.keys(before.battle).length){
  await tap(1730,966);await ready((before.battle.dictionary_code||'en')===(before.word_language||'en')?1:2);
  check(JSON.stringify(save().battle)===JSON.stringify(before.battle),'continue preserves board, words, dictionary and rule');
  await tap(1590,855);await tap(496,1004);await tap(1200,80);
 }
 const pid=adb('shell','pidof',pkg),log=adb('logcat','-d','--pid='+pid,'-s','godot','AndroidRuntime');
 fs.writeFileSync('.local/android-upgrade-logcat.txt',log);
 check(!/SCRIPT ERROR|E godot.*ERROR:|FATAL EXCEPTION/.test(log),'exact installed APK has no runtime errors');
 console.log('UPGRADE QA PASSED');
}
main().catch(e=>{console.error('FAIL '+e.message);process.exitCode=1;});
