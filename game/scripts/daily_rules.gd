extends RefCounted
## Portable daily-v2 rules. Keep in sync with supabase/functions/daily/rules.mjs.
const VERSION := "daily-v2"
const DURATION_MS := 120000
const MAX_MOVES := 240
const POOLS := {
	"en":"EEEEEEEEEEEAAAAAAAIIIIIIIOOOOOOONNNNNNRRRRRRTTTTTTLLLLSSSSUUUUDDDDGGGBCMPFHVWYJKQZ",
	"sr":"AAAAAAAEEEEEEEIIIIIIIOOOOOOOUUUNNNNRRRRSSSTTTTVVVLLLDDMMKKPPBGZJČĆŠĐŽFHC"
}
const STARTERS := {
	"en":["STONE","STREAM","PLANET","BRIDGE","SILVER","GARDEN","ORANGE","CANDLE","STORM","CROWN","RIVER","SPARK"],
	"sr":["KAMEN","REKA","VODA","VATRA","SNAGA","ZEMLJA","NEBO","OBLAK","SVETLO","ISKRA","IGRA","MOST"]
}
var state := 1
var language := "en"
var adjacent_only := true
var letters: Array[String] = []
var used: Dictionary = {}
var moves: Array = []
var score := 0
var refill_nodes := 0
var last_refill_route: Array[int] = []

func random_index(count: int) -> int:
	state = (state * 48271) % 2147483647
	return state % count

func tiles(word: String) -> Array[String]:
	var result: Array[String] = []
	var i := 0
	while i < word.length():
		var pair := word.substr(i,2)
		if language=="sr" and pair in ["LJ","NJ","DŽ"]:
			result.append(pair); i+=2
		else:
			result.append(word[i]); i+=1
	return result

func begin(seed_value: int, code: String, adjacent: bool) -> void:
	language=code; adjacent_only=adjacent
	state=clampi(seed_value,1,2147483646)
	letters.clear(); used.clear(); moves.clear(); score=0
	for i in 28: letters.append(random_letter())
	var options: Array=STARTERS[language].duplicate()
	for row in 4:
		var pick := random_index(options.size())
		var word_tiles := tiles(options[pick])
		options.remove_at(pick)
		if random_index(2)==1: word_tiles.reverse()
		var offset := random_index(8-word_tiles.size())
		for j in word_tiles.size(): letters[row*7+offset+j]=word_tiles[j]

func random_letter() -> String:
	var pool: Array[String]=[]
	pool.assign(str(POOLS[language]).split(""))
	if language=="sr": pool.append_array(["LJ","NJ","DŽ"])
	return pool[random_index(pool.size())]

func word_at(path: Array) -> String:
	if path.size()<3 or path.size()>28: return ""
	var seen := {}
	var word := ""
	for n in path.size():
		if not (path[n] is int): return ""
		var i: int=path[n]
		if i<0 or i>=28 or seen.has(i): return ""
		if adjacent_only and n>0:
			var before: int=path[n-1]
			if absi(i%7-before%7)>1 or absi(i/7-before/7)>1: return ""
		seen[i]=true; word+=letters[i]
	return "" if used.has(word) else word

func accept(path: Array, elapsed_ms: int, lexicon: RefCounted) -> bool:
	if elapsed_ms<0 or elapsed_ms>=DURATION_MS or moves.size()>=MAX_MOVES: return false
	if not moves.is_empty() and elapsed_ms<int(moves.back().ms)+250: return false
	var word := word_at(path)
	if word.is_empty() or not lexicon.contains(word): return false
	used[word]=true
	score+=path.size()*10+maxi(0,path.size()-4)*5
	moves.append({"path":path.duplicate(),"ms":elapsed_ms})
	for i in path: letters[i]=random_letter()
	refill_crossing(path)
	return true

func refill_crossing(consumed: Array) -> void:
	refill_nodes=0; last_refill_route.clear()
	var candidates: Array=STARTERS[language].duplicate()
	var offset := random_index(candidates.size())
	var start := random_index(28)
	for n in candidates.size():
		var word: String=candidates[(offset+n)%candidates.size()]
		if used.has(word): continue
		var word_tiles := tiles(word)
		for j in 28:
			var route := fit_crossing(word_tiles,consumed,(start+j)%28,[],0,0)
			if not route.is_empty():
				for k in route.size():
					if route[k] in consumed: letters[route[k]]=word_tiles[k]
				last_refill_route=route; return
			if refill_nodes>=4000: return

func fit_crossing(word_tiles: Array[String], consumed: Array, cell: int, route: Array[int], fixed_count: int, fresh_count: int) -> Array[int]:
	refill_nodes+=1
	if refill_nodes>4000 or cell in route: return []
	var fresh := cell in consumed
	if not fresh and letters[cell]!=word_tiles[route.size()]: return []
	var fixed := fixed_count+(0 if fresh else 1)
	var changed := fresh_count+(1 if fresh else 0)
	var next: Array[int]=route.duplicate(); next.append(cell)
	if next.size()==word_tiles.size():
		if fixed>=2 and changed>=1: return next
		return []
	if fixed+word_tiles.size()-next.size()<2: return []
	for neighbor in 28:
		if adjacent_only and (absi(cell%7-neighbor%7)>1 or absi(cell/7-neighbor/7)>1): continue
		if refill_nodes>=4000: break
		var found := fit_crossing(word_tiles,consumed,neighbor,next,fixed,changed)
		if not found.is_empty(): return found
	return []
