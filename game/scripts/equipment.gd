extends RefCounted
## Stable IDs are shared by inventory, battle snapshots and the localized Arsenal.
const SLOTS := [["pulse","breach"],["aegis","mirror"],["arc","seal"],["mend","bloom"],["lexicon","reserve"]]
const DEFAULTS := ["pulse","aegis","arc","mend"]
const DATA := {
	"pulse":{"name":"PULSE","cost":4,"base":24,"step":8,"win":-1,"desc":["A direct energy blast.","Fast, reliable damage."],"sr":["Direktan energetski udar.","Brza, pouzdana šteta."]},
	"breach":{"name":"BREACH","cost":4,"base":18,"step":8,"win":3,"desc":["Breaks armor on impact.","6 less damage than Pulse."],"sr":["Razbija oklop pri udaru.","6 manje štete od Pulsa."]},
	"aegis":{"name":"AEGIS","cost":5,"base":20,"step":5,"win":-1,"desc":["Absorbs the next attack.","Unused protection expires."],"sr":["Upija sledeći napad.","Višak zaštite se gubi."]},
	"mirror":{"name":"MIRROR","cost":6,"base":14,"step":5,"win":7,"desc":["Shields the next attack.","Reflects half the absorbed hit."],"sr":["Štiti od sledećeg napada.","Vraća pola upijene štete."]},
	"arc":{"name":"ARC","cost":7,"base":18,"step":6,"win":-1,"desc":["Strikes and delays the enemy.","Interrupts a pending heal."],"sr":["Udara i odlaže potez.","Prekida najavljeno lečenje."]},
	"seal":{"name":"SEAL","cost":5,"base":8,"step":3,"win":5,"desc":["Marks the enemy for 20s.","Cancels their next healing turn."],"sr":["Obeležava protivnika na 20 s.","Poništava sledeće lečenje."]},
	"mend":{"name":"MEND","cost":5,"base":24,"step":6,"win":-1,"desc":["Restores health immediately.","Best when danger is close."],"sr":["Odmah vraća zdravlje.","Za trenutke velike opasnosti."]},
	"bloom":{"name":"BLOOM","cost":5,"base":30,"step":6,"win":2,"desc":["Heals now and every 2s for 8s.","Recasting refreshes the effect."],"sr":["Leči odmah, pa na 2 s tokom 8 s.","Ponavljanje obnavlja efekat."]},
	"lexicon":{"name":"LEXICON SEAL","cost":0,"win":-2,"desc":["Words of 7+ tiles deal +4 damage.","Passive. Campaign duels only."],"sr":["Reč od 7+ pločica: +4 štete.","Pasivno. Samo u kampanji."]},
	"reserve":{"name":"RESERVE CELL","cost":0,"win":9,"desc":["Stores 2 excess energy per color.","Returns it after firing that ability."],"sr":["Čuva 2 viška energije po boji.","Vraća ih po aktiviranju te moći."]}
}

static func unlocked(id: String, data: Dictionary) -> bool:
	if id=="none": return true
	if not DATA.has(id): return false
	var win: int=DATA[id].win
	if win==-2: return data.get("lexicon_earned",false)
	return win==-1 or data.get("wins",{}).has(str(win))

static func mission_reward(mission: int) -> String:
	for id in DATA:
		if int(DATA[id].win)>=0 and int(DATA[id].win)==mission: return id
	return ""

static func slot_of(id: String) -> int:
	for i in SLOTS.size():
		if id in SLOTS[i]: return i
	return -1

static func loadout(data: Dictionary) -> Array:
	var result: Array=DEFAULTS.duplicate()
	var saved: Variant=data.get("loadout",[])
	for i in 4:
		var id: String=str(saved[i]) if saved is Array and saved.size()==4 else (str(data.get("weapon","pulse")) if i==0 else DEFAULTS[i])
		if id in SLOTS[i] and unlocked(id,data): result[i]=id
	return result

static func valid_loadout(value: Variant) -> bool:
	if not value is Array or value.size()!=4: return false
	for i in 4:
		if value[i] not in SLOTS[i]: return false
	return true

static func amount(id: String, level: int) -> int:
	return int(DATA[id].get("base",0))+maxi(0,level-1)*int(DATA[id].get("step",0))

static func valid_state(b: Dictionary) -> bool:
	if not valid_loadout(b.get("loadout",[b.get("weapon","pulse"),"aegis","arc","mend"])): return false
	if b.get("artifact","none") not in ["none","lexicon","reserve"]: return false
	if b.get("shield_kind","aegis") not in ["aegis","mirror"]: return false
	var reserves: Variant=b.get("reserves",[0,0,0,0])
	if not reserves is Array or reserves.size()!=4: return false
	for n in reserves:
		if not finite_number(n) or n<0 or n>2 or int(n)!=n: return false
	for key in ["seal_time","bloom_time","bloom_ticks","bloom_amount","best_tiles"]:
		var n: Variant=b.get(key,0)
		if not finite_number(n) or n<0: return false
	if b.get("seal_time",0)>20 or b.get("bloom_time",0)>2: return false
	for key in ["bloom_ticks","bloom_amount","best_tiles"]:
		if int(b.get(key,0))!=b.get(key,0): return false
	return b.get("bloom_ticks",0)<=4 and b.get("bloom_amount",0)<=13 and b.get("best_tiles",0)<=28

static func finite_number(n: Variant) -> bool:
	return (n is int or n is float) and is_finite(float(n))
