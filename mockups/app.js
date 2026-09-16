/* Portable UI concept. No network requests, accounts, persistent saves or engine. */
const $ = s => document.querySelector(s);
const esc = s => String(s ?? '').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const byId = id => SCREENS.find(s=>s.id===id);
const ui = name => document.querySelector(`#workspace .game [data-ui="${name}"]`);
let current = byId(location.hash.slice(1))?.id || 'battle';
let view='play', filter='', settingsReturn='home', selectedModule='guard';
let cpuTimer=null, drag=null, battleSaved=null, lastResult=null, playerName='Alex';
let demo;
const MODULES={
  strike:{name:'Strike',icon:'ϟ',cost:6,role:'OFFENCE',description:'A focused energy shot. Deals 14 damage to the computer opponent.',target:'ability-strike',stat:'14 damage'},
  guard:{name:'Guard',icon:'◇',cost:5,role:'DEFENCE',description:'Absorbs 8 damage from the next impact. A second activation does not stack.',target:'ability',stat:'8 protection'},
  disrupt:{name:'Disrupt',icon:'〰',cost:10,role:'CONTROL',description:'Cancels an incoming charge and resets the computer attack cycle. Recovery: 15 seconds.',target:'ability-disrupt',stat:'15s recovery'}
};
const buttons = (actions=[], cls='') => `<div class="actions ${cls}">${actions.map(([label,to],i)=>`<button class="game-btn ${i===0?'primary':''}" ${to.startsWith('@')?`data-action="${to.slice(1)}"`:`data-go="${to}"`}>${esc(label)}</button>`).join('')}</div>`;
const titleLines = text => esc(text).split('\n').map(t=>`<span>${t}</span>`).join('');
const card = ([title,body,to]) => `<${to?'button':'section'} class="data-card ${to?'link':''}" ${to?(to.startsWith('@')?`data-action="${to.slice(1)}"`:`data-go="${to}"`):''}><h3>${esc(title)}</h3><p>${esc(body)}</p></${to?'button':'section'}>`;
function gameTop(title,back='home',tag=''){return `<header class="game-top"><button class="back" data-go="${back}" aria-label="Back">‹</button><h2>${esc(title)}</h2>${tag?`<span class="tag">${esc(tag)}</span>`:''}<span class="currency">◈ 240 DUST</span><button class="back" data-go="settings" aria-label="Settings">⚙</button></header>`;}
function footer(active='home'){return `<nav class="game-footer" aria-label="Game navigation">${[['home','BASE'],['map','EXPEDITION'],['collection','MODULES'],['workshop','WORKSHOP'],['codex','JOURNAL'],['training','PRACTICE']].map(([id,label])=>`<button data-go="${id}" class="${active===id?'active':''}">${label}</button>`).join('')}</nav>`;}
function miniLoadout(){return `<div class="mini-loadout">${Object.values(MODULES).map(m=>`<button data-go="${m.target}"><b>${m.icon}</b>${m.name} · ${m.cost}</button>`).join('')}</div>`;}
function plate(key='guard'){const m=MODULES[key];return `<div class="module-plate"><div class="module-symbol ${key}">${m.icon}</div><h2>${m.name.toUpperCase()}</h2><p>${m.role} MODULE</p></div>`;}
function makeDemo(s){const d=s.data;return {letters:[...BOARDS[d.alternate?1:0]],energy:d.energy??13,hp:d.hp??100,enemy:d.enemy??(d.boss?120:80),maxEnemy:d.boss?120:80,used:d.used?[...d.used]:[],allWords:[],chosen:d.selected?[...d.selected]:[],shield:!!d.shield,remaining:10,cooldown:d.cooldown||0,live:false,training:false,board:d.alternate?1:0,word:d.word||'',message:d.message||'A short word opens a move. A longer word opens more options.',error:!!d.error,attacks:0,guards:0,disrupts:0};}
function battle(d={},tutorialStep=0){
 const letters=d.alternate?BOARDS[1]:BOARDS[0], selected=d.selected||[], hp=d.hp??100, energy=d.energy??13;
 return `<section class="battle" aria-label="Landscape battle against computer">
  <div class="arena">
   <div class="battle-hud"><section class="health-panel"><div class="health-heading"><span>${esc(playerName.toUpperCase())}</span><small>PLAYER</small></div><div class="hp-track"><i data-ui="player-bar" style="width:${hp}%"></i></div><div class="health-num" data-ui="player-hp">${hp} / 100</div></section><button class="pause-button" data-go="pause" aria-label="Pause encounter">Ⅱ</button><section class="health-panel enemy"><div class="health-heading"><span>${d.boss?'ARCHIVE WARDEN':'COPPER SENTINEL'}</span><small>COMPUTER</small></div><div class="hp-track"><i data-ui="enemy-bar" style="width:${(d.enemy??(d.boss?120:80))/(d.boss?120:80)*100}%"></i></div><div class="health-num" data-ui="enemy-hp">${d.enemy??(d.boss?120:80)} / ${d.boss?120:80}</div></section></div>
   <div class="arena-zone"><span>SUNWARD RUINS · ${d.boss?'BOSS ENCOUNTER':'ENCOUNTER 03'}</span></div>
   <div class="attack-warning" data-ui="warning">△ ${d.warning||'NEXT COMPUTER ATTACK · 10s'}</div>
   <div class="guard-effect" data-ui="guard-effect" ${d.shield?'':'hidden'}></div>
   <div class="damage-effect" data-ui="damage">${d.effect||''}</div>
  </div>
  <div class="battle-console">
   <aside class="battle-side"><div class="energy-head"><span>WORD ENERGY</span><strong data-ui="energy">${energy}<small>/30</small></strong></div><div class="energy-track"><i data-ui="energy-bar" style="width:${energy/30*100}%"></i></div>${Object.entries(MODULES).map(([key,m])=>`<button class="ability-button ${key}" data-action="${key}" aria-label="${m.name}, ${m.cost} energy" aria-disabled="${energy<m.cost||!!(d.cooldown&&key==='disrupt')}"><b>${m.icon}</b><span class="ability-copy"><strong>${m.name}</strong><small>${key==='strike'?'Direct damage':key==='guard'?'Protect next impact':'Cancel a charge'}</small></span><em data-ui="cost-${key}">${key==='disrupt'&&d.cooldown?'15s':m.cost+' ✧'}</em></button>`).join('')}<button class="computer-control" data-action="cpu" data-ui="cpu-button">▶ Start computer demo</button><p class="fine">Solo encounter · ${tutorialStep?'tutorial paused':'preview paused until started'}</p></aside>
   <div class="board-main"><div class="word-strip"><strong class="word-value" data-ui="word">${d.word||'FIND YOUR WORD'}</strong><span class="word-info" data-ui="word-length">EN · 35 LETTERS</span></div><div class="letter-board" aria-label="35 English letters, seven columns and five rows"><svg class="letter-line" aria-hidden="true"><polyline/></svg>${letters.map((l,i)=>`<button class="letter ${selected.includes(i)?'selected':''}" data-letter="${i}" aria-label="${l}, row ${Math.floor(i/7)+1}, column ${i%7+1}" aria-pressed="${selected.includes(i)}">${l}</button>`).join('')}</div></div>
   <aside class="battle-side"><h3>YOUR NEXT MOVE</h3><div class="word-message ${d.error?'error':''}" data-ui="message" role="status">${esc(d.message||'A short word opens a move. A longer word opens more options.')}</div><div class="found-label"><span>WORDS THIS BOARD</span><strong data-ui="found-count">${d.used?.length||0} / 5</strong></div><div class="word-chips" data-ui="found-words">${d.used?.length?d.used.map(w=>`<span>${esc(w)}</span>`).join(''):'<span>Find your first word</span>'}</div><div class="board-tools"><button data-action="shuffle">↻ Shuffle</button><button data-action="replace">New board</button></div><button class="submit-word" data-action="submit">Enter word ↵</button><div class="vocab-goal">WORD POWER · 3 letters: +3<br>5: +8 · 6: +12 · 7: +17 · 8+: +22</div><p class="fine">Connect any unused circle.<br>Trace back to undo · release to submit.</p></aside>
  </div>
 </section>`;
}
function detail(s){const d=s.data;return `${gameTop(s.title)}<div class="detail-layout"><div class="module-plate"><div class="module-symbol">${esc(d.symbol||'◇')}</div><span class="eyeline">${s.scope.toUpperCase()}</span></div><div class="detail-content"><span class="eyeline">WAR OF WORDS</span><h1>${titleLines(d.heading)}</h1><p class="lead">${esc(d.body)}</p>${d.cards?`<div class="data-cards">${d.cards.map(card).join('')}</div>`:''}${buttons(d.actions)}</div></div>`;}
function render(s){const d=s.data;switch(s.type){
 case 'battle':return battle(d);
 case 'hero':return `<section class="hero"><div class="hero-copy"><span class="eyeline">${esc(d.kicker)}</span><h1>${titleLines(d.heading)}</h1><p class="lead">${esc(d.body)}</p>${buttons(d.actions)}</div><div class="hero-note">SOLO WORD COMBAT · ENGLISH · LANDSCAPE</div></section>`;
 case 'home':return `${gameTop('SUNWARD OBSERVATORY','splash','LOCAL PROFILE · '+playerName.toUpperCase())}<div class="home-layout"><div class="home-scene"><div class="home-label"><span class="eyeline">THE NEXT CHAPTER IS YOURS TO FIND</span><h1>Words open worlds.</h1></div></div><aside class="home-panel"><span class="eyeline">CONTINUE EXPEDITION</span><h2>The sentinel<br>at the old bridge.</h2><p class="lead">Sunward Ruins · Encounter 03</p>${buttons([['Continue expedition →','map']],'vertical')}<span class="eyeline">YOUR LOADOUT</span>${miniLoadout()}<button class="home-objective" data-go="quests"><strong>Field objective →</strong><small>Discover 10 different English words.</small></button></aside></div>${footer()}`;
 case 'map':return `${gameTop('SUNWARD RUINS','home','REGION 01')}<section class="map-stage"><div class="map-title"><span class="eyeline">EXPEDITION ROUTE</span><h1>The archive is within reach.</h1></div><svg class="map-path" viewBox="0 0 1024 450" aria-hidden="true"><path d="M87 310C176 316 198 216 290 227S415 319 516 238S665 240 746 173S845 177 935 121" fill="none" stroke="#698994" stroke-width="4" stroke-dasharray="6 10"/></svg>${[[59,282,'✓'],[184,221,'✓'],[290,211,'3'],[448,235,'4'],[585,192,'5'],[733,143,'6'],[908,93,'♜']].map(([x,y,n],i)=>`<button class="map-node ${i===2?'next':i>2?'locked':''}" style="left:${x}px;top:${y}px" data-go="${i>2?'region-locked':'encounter'}" aria-label="Encounter ${i+1}${i>2?', locked':''}">${n}</button>`).join('')}<span class="map-label" style="left:52px;top:351px">Observatory</span><span class="map-label" style="left:267px;top:287px">Old Bridge</span><span class="map-label" style="left:823px;top:165px">Archive Warden</span><div class="map-actions">${buttons([['Encounter 03 · Old Bridge','encounter'],['World atlas','world']])}</div></section>${footer('map')}`;
 case 'encounter':return `${gameTop('ENCOUNTER BRIEFING','map','SOLO · COMPUTER OPPONENT')}<div class="encounter-scene"><span class="tag purple">COPPER SENTINEL · 80 HEALTH</span><span class="arena-caption">SUNWARD RUINS / OLD BRIDGE</span></div><section class="briefing"><div><span class="eyeline">ENCOUNTER 03</span><h1>Think beyond the obvious.</h1><p class="lead">Several words hide in the same 35-letter board. Turn the right word into the right move.</p></div><div><span class="eyeline">COMPUTER PATTERN</span><div class="module-line"><strong>Charged shot</strong><span>10s cycle</span></div><div class="module-line"><strong>Impact</strong><span>12 damage</span></div><p class="fine" style="margin-top:12px">Guard the impact or disrupt the charge. The computer does not race you to spell words.</p></div><div><span class="eyeline">YOUR EQUIPMENT</span>${miniLoadout()}<p class="fine">First clear: 60 dust + blueprint</p>${buttons([['Enter encounter','battle'],['Edit loadout','team']])}</div></section>`;
 case 'boss':return `${gameTop('THE ARCHIVE WARDEN','map','COMPUTER BOSS')}<div class="encounter-scene"><span class="tag purple">120 HEALTH · TWO PHASES</span><span class="arena-caption">THE LAST GATE / SUNWARD RUINS</span></div><section class="briefing"><div><span class="eyeline">BOSS ENCOUNTER</span><h1>A tougher mind to read.</h1><p class="lead">The Warden guards the archive. Your vocabulary gives you the tools to break its pattern.</p></div><div><span class="eyeline">AT HALF HEALTH</span><h2>Double impact.</h2><p class="lead" style="margin-top:13px">A charged sequence replaces the single shot. Guard or Disrupt; neither is the only answer.</p></div><div><span class="eyeline">PREPARE YOUR ANSWER</span>${miniLoadout()}${buttons([['Face the Warden','boss-phase'],['Back to the route','map']])}</div></section>`;
 case 'language':return `${gameTop('LANGUAGE & DICTIONARY','splash','VERSION ONE')}<div class="detail-layout"><div class="art-panel"><span class="art-label">Words are your advantage.</span></div><div class="detail-content"><span class="eyeline">THE FIRST EDITION</span><h1>English. From the first word.</h1><p class="lead">Menus and word validation use English. Other languages can be added after the core game is tested.</p><label class="form-label">Interface language<select class="game-select"><option>English</option></select></label><label class="form-label">Battle dictionary<select class="game-select"><option>English · installed demo list</option></select></label><p class="fine">Production spelling variants and dictionary licensing are still to be selected. This mockup includes a small authored English list.</p>${buttons([['Continue','profile'],['Read word rules','dictionary']])}</div></div>`;
 case 'form':return `${gameTop(s.title,s.id==='reset-confirm'?'save':'home')}<div class="detail-layout"><div class="art-panel"><span class="art-label">${s.id==='profile'?'Your next chapter.':'Every detail matters.'}</span></div><div class="detail-content"><span class="eyeline">${s.id==='profile'?'LOCAL PROFILE':'PREVIEW ONLY'}</span><h1>${titleLines(d.heading)}</h1><p class="lead">${esc(d.body)}</p><label class="form-label">${esc(d.label)}${d.multiline?`<textarea class="game-input" data-ui="form-input" rows="4" maxlength="1000" placeholder="${esc(d.placeholder)}"></textarea>`:`<input class="game-input" data-ui="form-input" maxlength="${d.action==='profile'?16:40}" placeholder="${esc(d.placeholder)}" value="${d.action==='profile'?esc(playerName):''}" autocomplete="off">`}</label>${buttons([[d.action==='reset'?'Preview reset':d.action==='profile'?'Begin expedition':'Preview your note','@'+d.action],['Back',s.id==='reset-confirm'?'save':'home']])}</div></div>`;
 case 'story':return `${gameTop(s.title,'map')}<div class="detail-layout"><div class="art-panel"><span class="art-label">SUNWARD RUINS · FIELD NOTES</span></div><div class="detail-content"><span class="eyeline">${esc(d.kicker)}</span><h1>${titleLines(d.heading)}</h1><p class="lead">${esc(d.body)}</p>${buttons(d.actions)}</div></div>`;
 case 'tutorial':return `${battle({},d.step)}<aside class="tutorial-note"><span class="tag gold">LESSON ${d.step} / 3 · PAUSED</span><h3>${esc(d.heading)}</h3><p>${esc(d.body)}</p>${buttons([[d.step===3?'Ready for the expedition':'Next lesson',d.step===1?'tutorial-energy':d.step===2?'tutorial-defense':'home'],['Skip tutorial','home']],'vertical')}</aside>`;
 case 'modal':return `${render(byId(d.base))}<div class="modal-shade"><section class="modal" role="dialog" aria-modal="true" aria-label="${esc(d.heading)}"><div class="modal-symbol">${d.symbol}</div><h1>${esc(d.heading)}</h1><p>${esc(d.body)}</p>${buttons(d.actions)}</section></div>`;
 case 'detail':return detail(s);
 case 'cards':return `${gameTop(s.title)}<section class="cards-page"><div class="page-intro"><h1>${titleLines(d.heading)}</h1><p class="lead">${esc(d.body)}</p></div><div class="data-cards">${d.cards.map(card).join('')}</div>${buttons([[s.id==='workshop'?'Back to base':'Continue expedition',s.id==='workshop'?'home':'map']])}</section>`;
 case 'team':case 'collection':return `${gameTop(s.type==='team'?'YOUR LOADOUT':'MODULE COLLECTION','home',s.type==='team'?'3 EQUIPPED':'3 DISCOVERED')}<section class="cards-page"><div class="page-intro"><h1>${s.type==='team'?'Three tools. Your strategy.':'Equipment with a purpose.'}</h1><p class="lead">Word energy is shared. Pick the moment to strike, protect or disrupt.</p></div><div class="module-cards">${Object.entries(MODULES).map(([key,m])=>`<article class="module-card"><span class="tag ${key==='disrupt'?'purple':key==='strike'?'gold':''}">${m.role}</span><div class="module-symbol ${key}">${m.icon}</div><h2>${m.name}</h2><p>${m.description}</p><strong>${m.cost} ENERGY</strong>${buttons([['Inspect module',m.target]])}</article>`).join('')}</div>${buttons(s.type==='team'?[['Confirm loadout','encounter'],['Browse modules','collection']]:[['Edit loadout','team'],['Undiscovered modules','collection-locked'],['Unequipped filter','collection-empty']])}</section>`;
 case 'ability':{const m=MODULES[d.module];return `${gameTop(m.name.toUpperCase()+' MODULE','collection',m.role)}<div class="detail-layout">${plate(d.module)}<div class="detail-content"><span class="eyeline">EQUIPPED · LEVEL ${d.module==='guard'?2:1}</span><h1>${d.module==='guard'?'Hold your ground.':d.module==='strike'?'Make a word hit home.':'Change the next move.'}</h1><p class="lead">${m.description}</p><div class="data-cards">${card(['Activation cost',m.cost+' energy'])}${card(['Effect',m.stat])}</div>${buttons(d.module==='guard'?[['Compare tactical branches','upgrade-choice'],['Preview upgrade','upgrade-cost']]:[['Review loadout','team'],['Open workshop','workshop']])}</div></div>`;}
 case 'choice':return `${gameTop('GUARD · TACTICAL BRANCH','ability')}<section class="cards-page"><div class="page-intro"><h1>What kind of defence?</h1><p class="lead">Both branches change how you approach an encounter. Choose one.</p></div><div class="data-cards" style="grid-template-columns:1fr 1fr"><article class="data-card"><span class="eyeline">RELIABILITY</span><h2 style="margin:12px 0">Reinforced Barrier</h2><p>Protection increases from 8 to 10. Energy cost remains 5. A safer answer to heavy impacts.</p>${buttons([['Choose reinforced protection','upgrade-strong-confirm']])}</article><article class="data-card"><span class="eyeline">TIMING</span><h2 style="margin:12px 0">Countercharge</h2><p>A timely Guard returns 2 energy. Protection remains 8. Precise timing creates your next opportunity.</p>${buttons([['Choose energy return','upgrade-confirm']])}</article></div><p class="fine" style="margin-top:20px">Branch reset rules are not yet decided. Both options are design proposals.</p></section>`;
 case 'result':{const win=d.win;return `${gameTop('ENCOUNTER COMPLETE','map',win?'VICTORY · VS COMPUTER':'DEFEAT · VS COMPUTER')}<div class="result-layout"><div class="result-art ${win?'':'loss'}"><span class="tag gold">SUNWARD RUINS / 03</span></div><section class="result-panel"><span class="eyeline">${win?'THE WAY IS OPEN':'READ. ADAPT. RETURN.'}</span><h1>${win?'A well-chosen victory.':'There is another answer.'}</h1><p class="lead">${win?'The Sentinel falls silent. The archive is one encounter closer.':'The charged shot broke through. Save 5 energy for Guard, or 10 to cancel the next charge.'}</p><div class="stat-row"><div><strong>${lastResult?.words||'12'}</strong><small>different words</small></div><div><strong>${lastResult?.longest||'BRIDGE'}</strong><small>longest word</small></div></div><p class="fine">${win?'First clear: 60 archive dust + module blueprint.':'Earlier campaign rewards remain safe. Retry without a fee.'}</p>${buttons(win?[['Discover your reward','reward'],['Encounter analysis','battle-summary']]:[['Try again','battle'],['Review loadout','team'],['Return to map','map']])}</section></div>`;}
 case 'summary':return `${gameTop('ENCOUNTER ANALYSIS','victory')}<div class="detail-layout"><div class="module-plate"><div class="module-symbol">Aa</div><h2>${lastResult?.longest||'STREAMLINE'}</h2><p>LONGEST WORD</p></div><div class="detail-content"><span class="eyeline">WORDS & TACTICS</span><h1>A broader set of answers.</h1><table class="summary-table"><thead><tr><th>MEASURE</th><th>RESULT</th></tr></thead><tbody><tr><td>Different words</td><td>${lastResult?.words||12}</td></tr><tr><td>Strikes activated</td><td>${lastResult?.attacks||4}</td></tr><tr><td>Guards activated</td><td>${lastResult?.guards||3}</td></tr><tr><td>Charges disrupted</td><td>${lastResult?.disrupts||1}</td></tr></tbody></table><p class="fine">${lastResult?'Results from your demo encounter.':'Illustrative result: STONE · CRAFT · PLANE · BRIDGE · STREAM · STREAMLINE.'}</p>${buttons([['Continue','reward'],['Suggest a missing word','word-report']])}</div></div>`;
 case 'reward':return `${gameTop(s.title,'victory')}<div class="detail-layout">${plate('disrupt')}<div class="detail-content"><span class="eyeline">GUARANTEED FIRST-CLEAR DISCOVERY</span><h1>${titleLines(d.heading)}</h1><p class="lead">${esc(d.body)}</p><div class="data-cards">${card(['Discovery','A new tactical option'])}${card(['Source','Earned through the solo campaign'])}</div>${buttons(d.actions)}</div></div>`;
 case 'quests':return `${gameTop('EXPEDITION OBJECTIVES')}<section class="cards-page"><div class="page-intro"><h1>Expand your repertoire.</h1><p class="lead">Permanent objectives. No daily streak and no countdown.</p></div><div class="data-cards">${card(['A broader vocabulary','Find 10 different words · 10 / 10','quest-reward'])}${card(['Beyond the obvious','Find 3 words with 7+ letters · 1 / 3','challenge'])}${card(['Keep your composure','Guard 5 charged shots · 3 / 5','map'])}</div>${buttons([['Continue expedition','map'],['View completed objectives','quests-empty']])}</section>`;
 case 'settings':return `${gameTop('SETTINGS',settingsReturn)}<div class="detail-layout"><div class="detail-content"><span class="eyeline">AUDIO & FEEDBACK</span>${[['Music','No audio in this mockup'],['Sound effects','No audio in this mockup'],['Haptics','Device implementation pending']].map(([label,sub])=>`<label class="settings-row"><span>${label}<small>${sub}</small></span><input type="checkbox" class="toggle" checked></label>`).join('')}${buttons([['Back',settingsReturn]])}</div><div class="detail-content"><div class="data-cards">${[['Accessibility','Contrast, text and input','accessibility'],['English dictionary','Version one · English','language'],['Profile & saves','Local campaign','save'],['Help & field guide','Rules and feedback','help']].map(card).join('')}</div><p class="fine">Changes here only affect this preview.</p></div></div>`;
 case 'accessibility':return `${gameTop('ACCESSIBILITY','settings')}<div class="detail-layout"><div class="module-plate"><div class="module-symbol">Aa</div><h2>Read. Reach. Respond.</h2><p>DESIGNED FOR YOUR PACE</p></div><div class="detail-content">${[['large-text','Larger supporting text','Main board letters stay large and clear.'],['high-contrast','Higher contrast','Words, labels and icons reinforce colour.'],['reduced-motion','Reduced motion','No screen shake or looping decorative effects.']].map(([key,label,sub])=>`<label class="settings-row"><span>${label}<small>${sub}</small></span><input type="checkbox" class="toggle" data-setting="${key}" ${document.body.classList.contains(key)?'checked':''}></label>`).join('')}<p class="lead" style="margin-top:18px">Tap letters and use Enter word, or connect with a drag. Keyboard: Tab and Enter; Escape clears a word.</p>${buttons([['Try free practice','training']])}</div></div>`;
 case 'dictionary':return `${gameTop('ENGLISH WORD RULES','help','OFFLINE VALIDATION')}<section class="cards-page"><div class="page-intro"><h1>A rich vocabulary. Clear rules.</h1><p class="lead">35 letters. Several words in the same board. Every accepted word powers an ability.</p></div><div class="data-cards">${card(['At least 3 letters','Connect any circle to any other. Each circle can be used once per word. Repeated letters need separate circles.'])}${card(['One reward per board','A repeated word earns no additional energy. Shuffling preserves found words. Five different words trigger a new board — a proposed cadence.'])}${card(['English comes first','STONE, CRAFT, PLANE, BRIDGE, STREAM and STREAMLINE are available examples. Proper names and spelling variants need production rules.'])}</div><p class="fine" style="margin-top:18px">This preview contains ${DEMO_WORDS.size} authored English entries. It is not a complete dictionary. Word length rewards are illustrative; there is no network or AI word judge.</p>${buttons([['Suggest a word','word-report'],['Try the board','training']])}</section>`;
 default:return detail(s);
}}

function artboard(s){return `<div class="game" data-screen="${s.id}">${render(s)}</div>`;}
function renderList(){
 $('#count').textContent=SCREENS.length;
 $('#screen-list').innerHTML=GROUPS.map(g=>{
  const matches=SCREENS.filter(s=>s.group===g&&(s.title+' '+s.note).toLowerCase().includes(filter));
  return matches.length?`<section class="screen-group"><div class="group-title">${g}<span>${matches.length}</span></div>${matches.map(s=>`<button class="screen-link ${s.id===current?'active':''}" data-go="${s.id}" ${s.id===current?'aria-current="page"':''}><span>${String(SCREENS.indexOf(s)+1).padStart(2,'0')}</span>${s.title}</button>`).join('')}</section>`:'';
 }).join('')||'<p class="empty-search">No matching screens.</p>';
 const picker=$('#mobile-picker');picker.innerHTML=GROUPS.map(g=>`<optgroup label="${g}">${SCREENS.filter(s=>s.group===g&&(s.title+' '+s.note).toLowerCase().includes(filter)).map(s=>`<option value="${s.id}" ${s.id===current?'selected':''}>${s.title}</option>`).join('')}</optgroup>`).join('');
}
function inspector(s){$('#inspector').innerHTML=`<section class="inspector-box"><span class="number-label">${String(SCREENS.indexOf(s)+1).padStart(2,'0')} / ${SCREENS.length}</span><h2>${s.title}</h2><span class="scope-tag">${s.scope} · layout proposal</span><p>${s.note}</p></section><section class="inspector-box"><h3>EXPLORE RELATED SCREENS</h3>${s.links.map(id=>`<button class="route" data-go="${id}">${byId(id).title}<span>↗</span></button>`).join('')}</section><section class="inspector-box"><h3>REVISION 02</h3><ul class="note-list"><li>Landscape · English · player vs computer.</li><li>35-letter board; several possible words.</li><li>Brighter art, adult explorer, tactical modules.</li><li>Board size, pacing and setting remain proposals.</li></ul></section>`;}
let resizeObserver=new ResizeObserver(entries=>{for(const entry of entries){const game=entry.target.querySelector('.game');if(game)game.style.transform=`scale(${entry.target.clientWidth/1024})`;}});
function scaleArtboards(){resizeObserver.disconnect();document.querySelectorAll('.game-viewport,.atlas-preview').forEach(el=>{const game=el.querySelector('.game');game.style.transform=`scale(${el.clientWidth/1024})`;resizeObserver.observe(el);});}
function draw(){
 const s=byId(current);renderList();
 document.querySelectorAll('[data-view]').forEach(b=>{b.classList.toggle('active',b.dataset.view===view);b.setAttribute('aria-pressed',String(b.dataset.view===view));});
 $('#studio').classList.toggle('atlas-mode',view!=='play');
 if(view==='play'){
  $('#workspace').innerHTML=`<div class="stage-head"><div><h1>${s.title}</h1><p>${s.group} / ${s.scope} · landscape 16:9</p></div><div class="stage-nav"><button class="small-btn" data-action="prev" aria-label="Previous screen">←</button><button class="small-btn" data-action="next" aria-label="Next screen">→</button><button class="small-btn" data-action="focus">${document.body.classList.contains('focus-mode')?'Exit focus':'Focus view'}</button></div></div><div class="portrait-hint">↔ Okreni telefon vodoravno za veći prikaz table.</div><div class="device-shell"><div class="game-viewport">${artboard(s)}</div></div><div class="stage-caption"><span>INTERACTIVE MOCKUP · ENGLISH · COMPUTER OPPONENT</span><span>Layout, controls and illustrative gameplay — not a finished game</span></div>`;
  inspector(s);const modal=$('#workspace .modal');if(modal){[...$('#workspace .game').children].filter(el=>!el.classList.contains('modal-shade')).forEach(el=>el.inert=true);}
 }else if(view==='atlas'){
  const matches=SCREENS.filter(s=>(s.title+' '+s.note).toLowerCase().includes(filter));
  $('#workspace').innerHTML=`<div class="stage-head"><div><h1>Landscape screen atlas</h1><p>${matches.length} screens and states · select a title to explore</p></div></div><div class="atlas-grid">${matches.map(s=>`<section class="atlas-item"><div class="atlas-preview" data-open="${s.id}">${artboard(s)}</div><h2><button data-go="${s.id}">${String(SCREENS.indexOf(s)+1).padStart(2,'0')} · ${s.title}</button></h2><p>${s.group} · ${s.scope}</p></section>`).join('')}</div>`;
  document.querySelectorAll('.atlas-preview .game').forEach(g=>{g.inert=true;g.setAttribute('aria-hidden','true');});
 }else{
  $('#workspace').innerHTML=`<div class="stage-head"><div><h1>Eight paths through the game</h1><p>Every step opens its landscape mockup.</p></div></div><div class="flow-lanes">${FLOWS.map(([title,body,ids])=>`<section class="flow-lane"><h2>${title}</h2><p>${body}</p><div class="flow-chain">${ids.map((id,i)=>`${i?'<span>→</span>':''}<button data-go="${id}">${byId(id).title}</button>`).join('')}</div></section>`).join('')}</div>`;
 }
 scaleArtboards();if(view==='play'&&byId(current).type==='battle'&&demo.chosen.length)requestAnimationFrame(updateSelection);
 $('#announcement').textContent=s.title;
}
function stopCPU(){if(cpuTimer){clearInterval(cpuTimer);cpuTimer=null;}if(demo)demo.live=false;}
function go(id){
 if(!byId(id))return;
 const previous=current,previousType=byId(current).type;
 if((previousType==='battle'||previousType==='tutorial')&&['pause','resume','quit'].includes(id))battleSaved=structuredClone(demo);
 if(id==='settings')settingsReturn=['pause','battle','resume'].includes(current)?'pause':'home';
 const resume=id==='battle'&&['pause','resume','quit'].includes(previous)&&battleSaved;
 stopCPU();drag=null;current=id;view='play';history.replaceState(null,'','#'+id);
 demo=resume?structuredClone(battleSaved):makeDemo(byId(id));const restart=resume&&demo.live;demo.live=false;
 draw();if(resume){refreshBattle();updateSelection();if(restart)startCPU();}
}
function message(text,error=false){demo.message=text;demo.error=error;const el=ui('message');if(el){el.textContent=text;el.classList.toggle('error',error);}$('#announcement').textContent=text;}
function toast(text){const game=$('#workspace .game');game?.querySelector('.toast')?.remove();if(game){const el=document.createElement('div');el.className='toast';el.setAttribute('role','status');el.textContent=text;game.append(el);setTimeout(()=>el.remove(),3200);}}
function updateSelection(){
 const board=$('#workspace .letter-board');if(!board)return;
 demo.word=demo.chosen.map(i=>demo.letters[i]).join('');
 if(ui('word'))ui('word').textContent=demo.word||'FIND YOUR WORD';
 if(ui('word-length'))ui('word-length').textContent=demo.chosen.length?demo.chosen.length+' LETTERS':'EN · 35 LETTERS';
 const rect=board.getBoundingClientRect(),sx=board.clientWidth/rect.width,sy=board.clientHeight/rect.height;
 const coords=[];
 board.querySelectorAll('[data-letter]').forEach(b=>{const i=Number(b.dataset.letter);b.classList.toggle('selected',demo.chosen.includes(i));b.setAttribute('aria-pressed',String(demo.chosen.includes(i)));const r=b.getBoundingClientRect();coords[i]=`${(r.x+r.width/2-rect.x)*sx},${(r.y+r.height/2-rect.y)*sy}`;});
 board.querySelector('polyline').setAttribute('points',demo.chosen.map(i=>coords[i]).join(' '));
}
function selectLetter(i){
 if(demo.chosen.at(-2)===i)demo.chosen.pop();else if(!demo.chosen.includes(i))demo.chosen.push(i);
 updateSelection();
}
function refreshBattle(){
 if(!ui('energy'))return;
 ui('energy').innerHTML=demo.energy+'<small>/30</small>';ui('energy-bar').style.width=demo.energy/30*100+'%';
 ui('player-hp').textContent=demo.hp+' / 100';ui('player-bar').style.width=demo.hp+'%';
 ui('enemy-hp').textContent=demo.enemy+' / '+demo.maxEnemy;ui('enemy-bar').style.width=demo.enemy/demo.maxEnemy*100+'%';
 ui('guard-effect').hidden=!demo.shield;
 for(const [key,m] of Object.entries(MODULES)){const b=$(`#workspace [data-action="${key}"]`);b?.setAttribute('aria-disabled',String(demo.energy<m.cost||(key==='disrupt'&&demo.cooldown>0)||(key==='guard'&&demo.shield)));const cost=ui('cost-'+key);if(cost)cost.textContent=key==='disrupt'&&demo.cooldown>0?Math.ceil(demo.cooldown)+'s':m.cost+' ✧';}
 ui('found-count').textContent=demo.used.length+' / 5';ui('found-words').innerHTML=demo.used.length?demo.used.map(w=>`<span>${w}</span>`).join(''):'<span>Find your first word</span>';
 document.querySelectorAll('#workspace [data-letter]').forEach((b,i)=>{b.textContent=demo.letters[i];b.setAttribute('aria-label',`${demo.letters[i]}, row ${Math.floor(i/7)+1}, column ${i%7+1}`);});
 ui('cpu-button').textContent=demo.training?'Practice · computer disabled':demo.live?'Ⅱ Pause computer demo':'▶ Start computer demo';
 if(demo.training)ui('warning').textContent='FREE PRACTICE · NO INCOMING ATTACKS';
 message(demo.message,demo.error);
}
function newBoard(){demo.board++;demo.letters=[...BOARDS[demo.board%BOARDS.length]];demo.used=[];demo.chosen=[];refreshBattle();updateSelection();}
function submit(){
 const word=demo.chosen.map(i=>demo.letters[i]).join(''),length=demo.chosen.length;
 if(length<3){message('Use at least 3 letters.',true);demo.chosen=[];return;}
 if(!DEMO_WORDS.has(word)){message('Not in the demo dictionary. Try another English word.',true);demo.chosen=[];return;}
 if(demo.used.includes(word)){message(word+' already earned energy on this board.',true);demo.chosen=[];return;}
 const gain=length>=8?22:({3:3,4:5,5:8,6:12,7:17})[length],added=Math.min(gain,30-demo.energy);
 demo.energy+=added;demo.used.push(word);demo.allWords.push(word);demo.chosen=[];
 message(`${word} · +${added} energy${added<gain?' (capacity reached)':''} · ${demo.used.length}/5 words`);refreshBattle();
 if(demo.used.length===5){newBoard();message(`${word} · +${added} energy. Five words found — fresh board ready.`);}
}
function finish(win){
 lastResult={words:new Set(demo.allWords).size,longest:demo.allWords.reduce((best,w)=>w.length>best.length?w:best,'—'),attacks:demo.attacks,guards:demo.guards,disrupts:demo.disrupts};
 const training=demo.training;stopCPU();go(training?'training-results':win?'victory':'defeat');
}
function startCPU(){
 if(demo.training){toast('Practice has no incoming attacks.');return;}if(cpuTimer)return;
 demo.live=true;refreshBattle();let previous=performance.now();
 cpuTimer=setInterval(()=>{
  const now=performance.now(),delta=Math.min(1,(now-previous)/1000);previous=now;
  if(document.hidden)return;
  demo.remaining-=delta;demo.cooldown=Math.max(0,demo.cooldown-delta);
  const warning=ui('warning');if(!warning){stopCPU();return;}
  warning.textContent=`△ ${demo.remaining<=3?'CHARGED SHOT':'NEXT COMPUTER ATTACK'} · ${Math.max(0,Math.ceil(demo.remaining))}s`;
  warning.classList.toggle('urgent',demo.remaining<=3);
  if(demo.remaining<=0){const damage=demo.shield?4:12;demo.hp=Math.max(0,demo.hp-damage);demo.shield=false;demo.remaining=10;message(`Computer shot landed · −${damage} health. Your current word is unchanged.`);if(!demo.hp){finish(false);return;}}
  refreshBattle();
 },200);
}
function activate(key){
 const m=MODULES[key];if(!ui('energy'))return;
 if(key==='disrupt'&&demo.cooldown>0){message(`Disrupt is recovering · ${Math.ceil(demo.cooldown)}s. Start the computer demo to advance time.`,true);return;}
 if(key==='guard'&&demo.shield){message('Guard is already active. Protection does not stack.');return;}
 if(demo.energy<m.cost){message(`${m.name} needs ${m.cost-demo.energy} more energy.`,true);return;}
 demo.energy-=m.cost;
 if(key==='strike'){demo.attacks++;demo.enemy=Math.max(0,demo.enemy-14);ui('damage').textContent='−14';message('Strike landed · 14 damage to the computer.');if(!demo.enemy){finish(true);return;}}
 if(key==='guard'){demo.guards++;demo.shield=true;message('Guard ready · the next computer impact is reduced by 8.');}
 if(key==='disrupt'){demo.disrupts++;demo.remaining=10;demo.cooldown=15;ui('warning').textContent='CHARGE INTERRUPTED · NEXT ATTACK IN 10s';ui('warning').classList.remove('urgent');message('Charge interrupted · 10 energy spent.');}
 refreshBattle();
}
function formAction(action){
 const input=ui('form-input');const value=input.value.trim();
 if(!value||(action==='reset'&&value!=='RESET')){input.setCustomValidity(action==='reset'?'Type RESET to continue.':'Please complete this field.');input.reportValidity();input.oninput=()=>input.setCustomValidity('');return;}
 if(action==='profile'){playerName=value;go('intro');return;}
 go(action==='report'?'report-saved':action==='feedback'?'feedback-saved':'profile');
}
function action(name){
 if(name==='next'||name==='prev'){const i=SCREENS.findIndex(s=>s.id===current);go(SCREENS[(i+(name==='next'?1:SCREENS.length-1))%SCREENS.length].id);return;}
 if(name==='focus'){document.body.classList.toggle('focus-mode');draw();refreshBattle();return;}
 if(name==='submit'){submit();return;}
 if(Object.hasOwn(MODULES,name)){activate(name);return;}
 if(name==='cpu'){if(byId(current).type==='tutorial'){toast('The computer stays paused during lessons.');return;}if(demo.live){stopCPU();refreshBattle();}else startCPU();return;}
 if(name==='shuffle'){if(drag)return;demo.chosen=[];demo.letters=[...demo.letters.slice(7),...demo.letters.slice(0,7)];refreshBattle();updateSelection();message('Layout shuffled. Previously found words still count.');return;}
 if(name==='replace'){if(drag)return;newBoard();message('A fresh board. Replacement pacing is a design proposal.');return;}
 if(['profile','report','feedback','reset'].includes(name)){formAction(name);return;}
 if(name==='training'){go('battle');demo.training=true;refreshBattle();message('Free practice: find words without incoming attacks.');return;}
 if(name==='older-save'){go('save-choice');$('#workspace .modal p').textContent='Selected: other device, region 01, 12 encounters. A real implementation must back up the newer local version before replacing it.';return;}
}
document.addEventListener('click',e=>{
 const el=e.target.closest('[data-go],[data-action],[data-view],[data-open]');
 if(el){if(el.dataset.go)go(el.dataset.go);else if(el.dataset.open)go(el.dataset.open);else if(el.dataset.view){stopCPU();view=el.dataset.view;document.body.classList.remove('focus-mode');draw();if(view==='play'&&byId(current).type==='battle'){refreshBattle();if(demo.chosen.length)updateSelection();}}else action(el.dataset.action);return;}
 const letter=e.target.closest('#workspace [data-letter]');if(letter&&e.detail===0)selectLetter(Number(letter.dataset.letter));
});
$('#search').addEventListener('input',e=>{filter=e.target.value.toLowerCase();if(view==='atlas')draw();else renderList();});
$('#mobile-picker').addEventListener('change',e=>go(e.target.value));
document.addEventListener('change',e=>{if(e.target.dataset.setting)document.body.classList.toggle(e.target.dataset.setting,e.target.checked);});
window.addEventListener('hashchange',()=>{const id=location.hash.slice(1);if(byId(id)&&id!==current)go(id);});
document.addEventListener('keydown',e=>{
 if(e.key==='Escape'){if(demo?.chosen.length){demo.chosen=[];updateSelection();message('Word cancelled.');}else if(document.body.classList.contains('focus-mode')){document.body.classList.remove('focus-mode');draw();refreshBattle();}}
 if(e.key==='Tab'&&$('#workspace .modal')){const controls=[...$('#workspace .modal').querySelectorAll('button,input,select,textarea')].filter(el=>!el.disabled);if(controls.length){const first=controls[0],last=controls.at(-1);if(e.shiftKey&&document.activeElement===first){last.focus();e.preventDefault();}else if(!e.shiftKey&&document.activeElement===last){first.focus();e.preventDefault();}}}
});
document.addEventListener('pointerdown',e=>{
 const letter=e.target.closest('#workspace [data-letter]');if(!letter||view!=='play'||drag||e.button!==0)return;
 const board=letter.closest('.letter-board');drag={id:e.pointerId,board,moved:false,lastX:e.clientX,lastY:e.clientY};selectLetter(Number(letter.dataset.letter));board.setPointerCapture(e.pointerId);e.preventDefault();
});
document.addEventListener('pointermove',e=>{
 if(!drag||drag.id!==e.pointerId)return;
 const rects=[...drag.board.querySelectorAll('[data-letter]')].map(el=>el.getBoundingClientRect());
 const dx=e.clientX-drag.lastX,dy=e.clientY-drag.lastY,steps=Math.ceil(Math.hypot(dx,dy)/5);
 for(let k=1;k<=steps;k++){const x=drag.lastX+dx*k/steps,y=drag.lastY+dy*k/steps;const i=rects.findIndex(r=>Math.hypot((x-r.x-r.width/2)/(r.width/2),(y-r.y-r.height/2)/(r.height/2))<=1);if(i>=0&&i!==demo.chosen.at(-1)){drag.moved=true;selectLetter(i);}}
 drag.lastX=e.clientX;drag.lastY=e.clientY;
});
document.addEventListener('pointerup',e=>{if(!drag||drag.id!==e.pointerId)return;const moved=drag.moved;drag=null;if(moved)submit();});
document.addEventListener('pointercancel',e=>{if(drag&&e.pointerId===drag.id){drag=null;demo.chosen=[];updateSelection();message('Touch interrupted. No word was submitted.');}});
document.addEventListener('visibilitychange',()=>{if(document.hidden&&demo?.live&&view==='play')go('resume');});
demo=makeDemo(byId(current));draw();
