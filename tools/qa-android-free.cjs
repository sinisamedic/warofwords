// Continue the dedicated emulator's UI QA without injecting or clearing game data.
const {execFileSync}=require('node:child_process');const fs=require('node:fs');
const index=process.argv.indexOf('--serial'),serial=index>=0?process.argv[index+1]:'';
if(!/^emulator-\d+$/.test(serial))throw Error('Pass --serial emulator-5554; physical phones are not test targets.');
const pkg='com.sinisamedic.warofwords';
const adb=(...a)=>execFileSync('adb',['-s',serial,...a],{encoding:'utf8',windowsHide:true,timeout:45000}).trim();
const wait=ms=>new Promise(r=>setTimeout(r,ms)),save=()=>JSON.parse(adb('shell','run-as',pkg,'cat','files/progress.json'));
const check=(ok,msg)=>{if(!ok)throw Error(msg);console.log('PASS '+msg);};
const tap=async(x,y)=>{adb('shell','input','tap',''+x,''+y);await wait(800);};
async function ready(count=1){const pid=adb('shell','pidof',pkg);for(let i=0;i<40;i++){if((adb('logcat','-d','--pid='+pid,'-s','godot').match(/WarOfWords: ready/g)||[]).length>=count){await wait(1300);return;}await wait(1000);}throw Error('Dictionary readiness timeout');}
async function start(){adb('shell','am','start','-W','-n',pkg+'/com.godot.game.GodotAppLauncher');await ready();}
async function capture(name){adb('shell','screencap','-p','/sdcard/wow-free.png');adb('pull','/sdcard/wow-free.png','.local/android-free-'+name+'.png');}
function scattered(b){const words=fs.readFileSync('game/data/english.txt','utf8').toUpperCase().trim().split(/\r?\n/);let found=[];
 for(const word of words){if(word.length<5||word.length>9||b.used[word])continue;const path=[];for(const char of word){let i=b.letters.findIndex((x,j)=>x===char&&!path.includes(j));if(i<0)break;path.push(i);}if(path.length!==word.length)continue;const jumps=path.slice(1).some((i,j)=>Math.abs(i%7-path[j]%7)>1||Math.abs(Math.floor(i/7)-Math.floor(path[j]/7))>1);if(jumps&&path.length>found.length)found=path;if(found.length===9)break;}return found;
}
async function main(){
 check(adb('shell','getprop','ro.kernel.qemu')==='1','target is an emulator');
 adb('shell','am','force-stop',pkg);const initial=save();await start();
 await tap(175,90);await tap(1491,366);await tap(1491,620);await ready(initial.word_language==='en'?1:2);
 let s=save();if(!s.sound)await tap(352,330);if(!s.haptics)await tap(352,560);if(s.calm)await tap(907,560);
 await tap(907,815);s=save();check(!s.adjacent_only,'free linking selected through Android settings');
 const expected=structuredClone(initial.battle);if(Object.keys(expected).length)expected.adjacent_only=false;
 check(JSON.stringify(s.battle)===JSON.stringify(expected),'rule changes immediately while preserving the rest of the saved duel');await capture('settings');
 await tap(120,90);await tap(1730,615);await tap(2080,905);await tap(2110,983);
 if(Object.keys(initial.battle).length)await tap(1470,855);
 await tap(1200,80);s=save();check(s.battle.adjacent_only===false&&s.battle.dictionary_code==='en','new battle starts with free English rules');
 const path=scattered(s.battle),word=path.map(i=>s.battle.letters[i]).join('');check(path.length>=5,'board offers a long scattered word');console.log('FREE WORD '+word+' '+JSON.stringify(path));
 await tap(1590,855);for(const i of path){adb('shell','input','tap',''+Math.round(761.25+i%7*146.25),''+Math.round(533.25+Math.floor(i/7)*146.25));await wait(120);}
 await capture('word');await tap(1667,407);await tap(1200,80);s=save();check(s.battle.used[word]&&s.battle.words===1,'nonadjacent Android taps submit the long word');
 await tap(1590,855);await tap(496,1004);await capture('hint');await tap(1200,80);
 const before=save();adb('shell','am','force-stop',pkg);await start();await tap(1730,966);
 check(JSON.stringify(save().battle)===JSON.stringify(before.battle),'free duel survives process restart');
 await tap(1060,855);await tap(353,815);await tap(120,90);await tap(1730,966);
 s=save();check(s.adjacent_only&&s.battle.adjacent_only===true&&s.battle.used[word],'switching back to adjacent immediately updates the saved duel without losing words');
 await tap(1590,855);await capture('battle');await wait(1200);await tap(1200,80);
 const pid=adb('shell','pidof',pkg),log=adb('logcat','-d','--pid='+pid,'-s','godot','AndroidRuntime');fs.writeFileSync('.local/android-free-logcat.txt',log);
 check(!/SCRIPT ERROR|E godot.*ERROR:|FATAL EXCEPTION/.test(log),'free-mode Android run has no runtime errors');console.log('FREE ANDROID QA PASSED');
}
main().catch(e=>{console.error('FAIL '+e.message);process.exitCode=1;});
