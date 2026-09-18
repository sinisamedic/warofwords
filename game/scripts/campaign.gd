extends RefCounted
## One source of truth for progression, navigation and restored saves.
const COUNT := 24
const CHAPTERS := 6
const REGIONS := ["SUNWARD RUINS","THE SKY BRIDGES","THE OBSERVATORY","THE ASH FORGE","THE EMERALD GARDENS","THE MOON CITADEL"]
const NAMES := ["Training Sentinel","Copper Scout","Gatekeeper","BRONZE WARDEN","Sky Watcher","Storm Sentinel","Bridge Guardian","TEMPEST WARDEN","Astral Sentinel","Archive Keeper","Sunforged Elite","THE LAST WARDEN",
	"Cinder Musketeer","Furnace Alchemist","Obsidian Defender","THE FORGE TYRANT","Verdant Lancer","Orchid Keeper","Jade Stag","THE ANCIENT ROOT","Silver Duelist","Lunar Seer","Pearl Juggernaut","THE ECLIPSE MONARCH"]
const STYLES := ["training","heavy","healer","armored","heavy","healer","armored","heavy","healer","armored","heavy","armored",
	"heavy","healer","armored","armored_heavy","heavy","healer","armored","armored_healer","heavy","healer","armored","eclipse"]

static func armored(mission: int) -> bool:
	return STYLES[mission] in ["armored","armored_heavy","armored_healer","eclipse"]

static func action(mission: int, turn: int) -> String:
	var style: String=STYLES[mission]
	if style=="eclipse":
		return "HEAL" if turn%3==2 else "HEAVY HIT" if turn%3==0 else "ATTACK"
	if style in ["healer","armored_healer"] and turn%2==0: return "HEAL"
	if style in ["heavy","armored_heavy"] and turn%2==0: return "HEAVY HIT"
	return "ATTACK"

static func health(mission: int) -> int:
	return 72+mission*13+(35 if mission%4==3 else 0)

static func damage(mission: int) -> int:
	# Later chapters get longer duels, not a sudden doubling of incoming damage.
	return 12+mission if mission<12 else 24+(mission-12)/2

static func interval(mission: int) -> float:
	return maxf(8,14-mission*.42) if mission<12 else maxf(8,10-(mission-12)*.16)
