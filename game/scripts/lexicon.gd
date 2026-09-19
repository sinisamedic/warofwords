extends RefCounted

var words := PackedStringArray()
var prefixes: Dictionary = {}
var language := "en"
var pool := PackedStringArray()
var rng := RandomNumberGenerator.new()
var seeds: Array[String] = ["STONE","STREAM","PLANET","BRIDGE","SILVER","GARDEN","ORANGE","CANDLE","STORM","CROWN","RIVER","SPARK","DREAM","LIGHT","OCEAN","FLAME","SHIELD","THUNDER","WINTER","FOREST","CASTLE","MIRROR","CRYSTAL","HUNTER","WONDER","SWORD","EARTH","SPRING","NIGHT","POWER"]
var letters: Array[String] = []
var types: Array[int] = []
var solutions: Dictionary = {}
var adjacent_only := true
var joker_enabled := false
var alphabet: Array[String] = []
var search_nodes := 0
const FREE_SEARCH_BUDGET := 18000
const REFILL_SEARCH_BUDGET := 10000
var refill_candidates: Array[Dictionary] = []
var refill_nodes := 0
var last_refill_words: Array[String] = []
var refill_consumed: Dictionary = {}
var last_refill_routes: Array = []
var neighbors: Array[Array] = []

func _init(load_now: bool = true, code: String = "en") -> void:
	rng.randomize()
	language = code
	pool = "EEEEEEEEEEEAAAAAAAIIIIIIIOOOOOOONNNNNNRRRRRRTTTTTTLLLLSSSSUUUUDDDDGGGBCMPFHVWYJKQZ".split("")
	if language == "sr":
		pool = "AAAAAAAEEEEEEEIIIIIIIOOOOOOOUUUNNNNRRRRSSSTTTTVVVLLLDDMMKKPPBGZJČĆŠĐŽFHC".split("")
		pool.append_array(["LJ","NJ","DŽ"])
		seeds.assign(["KAMEN","REKA","VODA","VATRA","ŠTIT","SNAGA","ZEMLJA","NEBO","OBLAK","SVETLO","ISKRA","IGRA","REČNIK","ČOVEK","PTICA","SREĆA","LJUBAV","NJEGA","DŽEPOVI","ŠUMA","ZVEZDA","MESEC","SUNCE","MOST","GRAD","ZLATO","MISLI","VETAR"])
	if load_now:
		load_dictionary()
	for tile in pool:
		if tile not in alphabet: alphabet.append(tile)
	alphabet.sort()
	for i in 28:
		var around: Array[int]=[]
		for j in 28:
			if adjacent(i,j): around.append(j)
		neighbors.append(around)

func load_dictionary() -> void:
	var content: String
	if language == "sr":
		var packed := FileAccess.get_file_as_bytes("res://data/serbian.txt.gz")
		content = packed.decompress_dynamic(32*1024*1024,FileAccess.COMPRESSION_GZIP).get_string_from_utf8()
	else:
		content = FileAccess.get_file_as_string("res://data/english.txt")
	words = content.replace("\r","").to_upper().split("\n",false)
	words.sort()
	# A short prefix index + binary search avoids millions of Dictionary allocations.
	for word in words:
		for n in range(1,mini(3,word.length())+1): prefixes[word.left(n)] = true
	# Familiar construction words guide the refill, but the full dictionary still validates play.
	var familiar: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/refill-words.json"))
	refill_candidates.clear()
	for word in str(familiar.get(language,"")).split(" ",false):
		var tiles := tokens(word)
		if tiles.size()>=4 and tiles.size()<=8 and contains(word):
			refill_candidates.append({"word":word,"tiles":tiles})
			if tiles.size()<=7 and word not in seeds: seeds.append(word)

func contains(word: String) -> bool:
	var index := words.bsearch(word)
	return index < words.size() and words[index] == word

func has_prefix(prefix: String) -> bool:
	if prefix.length() <= 3: return prefixes.has(prefix)
	var index := words.bsearch(prefix)
	return index < words.size() and words[index].begins_with(prefix)

func tokens(word: String) -> Array[String]:
	var result: Array[String] = []
	var i := 0
	while i < word.length():
		var pair := word.substr(i,2)
		if language == "sr" and pair in ["LJ","NJ","DŽ"]:
			result.append(pair); i += 2
		else:
			result.append(word[i]); i += 1
	return result

func valid_tile(letter: String) -> bool:
	if joker_enabled and letter=="*": return true
	return (letter.length()==1 and letter>="A" and letter<="Z") if language=="en" else letter in pool

func tile_options(tile: String) -> Array[String]:
	return alphabet if joker_enabled and tile=="*" else [tile]

func add_joker(cells: Array[int], chance: float) -> void:
	if joker_enabled and not cells.is_empty() and "*" not in letters and rng.randf()<chance:
		letters[cells[rng.randi_range(0,cells.size()-1)]]="*"

func adjacent(a: int, b: int) -> bool:
	return a != b and absi(a % 7 - b % 7) <= 1 and absi(a / 7 - b / 7) <= 1

func generate(used: Dictionary = {}) -> void:
	letters.clear()
	types.clear()
	for i in 28:
		letters.append(pool[rng.randi_range(0, pool.size()-1)])
		types.append(rng.randi_range(0, 3))
	# Disjoint row seeds make the board approachable; the solver also finds diagonals.
	for row in 4:
		var options: Array[String] = []
		for word in seeds:
			if tokens(word).size() <= 7 and not used.has(word) and contains(word):
				options.append(word)
		if options.is_empty():
			options = seeds
		var seed_word := tokens(options[rng.randi_range(0,options.size()-1)])
		if rng.randf() > 0.5:
			seed_word.reverse()
		var offset := rng.randi_range(0,7-seed_word.size())
		for j in seed_word.size():
			letters[row*7+offset+j] = seed_word[j]
	var cells: Array[int]=[]
	cells.assign(range(28)); add_joker(cells,1.0)
	find_words(used)

func refill(path: Array[int], used: Dictionary) -> bool:
	var writable: Dictionary={}
	last_refill_words.clear(); refill_nodes=0
	last_refill_routes.clear(); refill_consumed.clear()
	for i in path:
		letters[i] = balanced_letter()
		types[i] = rng.randi_range(0,3)
		writable[i]=true
		refill_consumed[i]=true
	# Find words through fixed existing letters and the just-consumed wildcard cells.
	# Lock assignments after each word so a second word cannot destroy the first.
	var order: Array[int]=[]
	for i in refill_candidates.size():
		if not used.has(refill_candidates[i].word): order.append(i)
	for i in range(order.size()-1,0,-1):
		var j := rng.randi_range(0,i); var swap := order[i]; order[i]=order[j]; order[j]=swap
	for minimum in [5,4]:
		for index in order:
			if refill_nodes>=REFILL_SEARCH_BUDGET or writable.is_empty() or last_refill_words.size()>=1: break
			var candidate: Dictionary=refill_candidates[index]
			if candidate.tiles.size()<minimum or candidate.word in last_refill_words: continue
			var fit := fit_refill_word(candidate.tiles,writable)
			if fit.is_empty(): continue
			for n in fit.size():
				if writable.has(fit[n]):
					letters[fit[n]]=candidate.tiles[n]; writable.erase(fit[n])
			last_refill_words.append(candidate.word)
			last_refill_routes.append(fit.duplicate())
	add_joker(path,.15)
	find_words(used)
	if solutions.is_empty():
		generate(used)
		return true
	return false

func balanced_letter() -> String:
	var vowels := 0
	for letter in letters:
		if letter in ["A","E","I","O","U"]: vowels+=1
	var choices := PackedStringArray()
	for letter in pool:
		var vowel := letter in ["A","E","I","O","U"]
		if (vowels<9 and vowel) or (vowels>14 and not vowel) or (vowels>=9 and vowels<=14): choices.append(letter)
	return choices[rng.randi_range(0,choices.size()-1)]

func fit_refill_word(tiles: Array[String], writable: Dictionary) -> Array[int]:
	# Fixed matching starts first; this grows words from the surviving board.
	for blank_start in [false,true]:
		for i in 28:
			if writable.has(i)!=blank_start: continue
			if refill_nodes>=REFILL_SEARCH_BUDGET: return []
			var found := fit_refill_step(tiles,writable,i,0,0,[],false)
			if not found.is_empty(): return found
	return []

func fit_refill_step(tiles: Array[String], writable: Dictionary, cell: int, depth: int, mask: int, route: Array[int], changed: bool) -> Array[int]:
	refill_nodes+=1
	if refill_nodes>REFILL_SEARCH_BUDGET or mask & (1<<cell): return []
	var blank := writable.has(cell)
	if not blank and letters[cell]!=tiles[depth]: return []
	var next: Array[int]=route.duplicate(); next.append(cell)
	if depth==tiles.size()-1:
		var surviving := 0
		for index in next:
			if not refill_consumed.has(index): surviving+=1
		# Cross the old/new boundary; never serve another word inside the cleared path.
		if (changed or blank) and surviving>=2: return next
		return []
	var choices: Array=neighbors[cell] if adjacent_only else range(28)
	for neighbor in choices:
		if refill_nodes>=REFILL_SEARCH_BUDGET: break
		var found := fit_refill_step(tiles,writable,neighbor,depth+1,mask|(1<<cell),next,changed or blank)
		if not found.is_empty(): return found
	return []

func find_words(used: Dictionary = {}) -> Dictionary:
	solutions.clear()
	search_nodes=0
	if not adjacent_only:
		# Seed familiar long hints first, then search unique letter combinations.
		# Equal glyphs are interchangeable in this mode; avoiding their permutations
		# keeps even the 1.7M-word Serbian dictionary responsive on a phone.
		for word in seeds:
			if used.has(word) or not contains(word): continue
			var indices: Array[int] = []
			for tile in tokens(word):
				for i in letters.size():
					if letters[i] == tile and i not in indices:
						indices.append(i); break
			if indices.size() == tokens(word).size(): solutions[word] = indices
		search_nodes = 0
		_search_free("",0,[],used)
		return solutions
	for i in letters.size():
		_search(i,"",0,[],used)
	return solutions

func _search_free(prefix: String, mask: int, path: Array, used: Dictionary) -> void:
	if solutions.size() >= 180 or path.size() >= 12 or search_nodes >= FREE_SEARCH_BUDGET: return
	var seen: Dictionary = {}
	for i in letters.size():
		if mask & (1 << i) or seen.has(letters[i]): continue
		seen[letters[i]] = true
		search_nodes += 1
		if search_nodes > FREE_SEARCH_BUDGET: return
		for tile in tile_options(letters[i]):
			var word := prefix+tile
			if not has_prefix(word): continue
			var next := path.duplicate()
			next.append(i)
			if next.size() >= 3 and contains(word) and not used.has(word): solutions[word] = next
			_search_free(word,mask | (1 << i),next,used)
			if solutions.size() >= 180: return

func _search(i: int, prefix: String, mask: int, path: Array, used: Dictionary) -> void:
	search_nodes+=1
	if solutions.size() >= 180 or path.size() >= 12 or mask & (1 << i) or (joker_enabled and search_nodes>FREE_SEARCH_BUDGET):
		return
	for tile in tile_options(letters[i]):
		var word := prefix + tile
		if not has_prefix(word): continue
		var next_path := path.duplicate()
		next_path.append(i)
		if next_path.size() >= 3 and contains(word) and not used.has(word): solutions[word] = next_path
		var next_mask := mask | (1 << i)
		for neighbor in neighbors[i]: _search(neighbor,word,next_mask,next_path,used)

func validate_path(path: Array[int], used: Dictionary = {}) -> String:
	var visited: Dictionary = {}
	var word := ""
	for j in path.size():
		var i := path[j]
		if i < 0 or i >= 28 or visited.has(i):
			return ""
		if adjacent_only and j > 0 and not adjacent(path[j-1],i):
			return ""
		visited[i] = true
		word += letters[i]
	if path.size()<3: return ""
	if joker_enabled and word.count("*")==1:
		var fallback := ""
		for tile in alphabet:
			var candidate := word.replace("*",tile)
			if contains(candidate):
				if not used.has(candidate): return candidate
				fallback=candidate
		return fallback
	return word if contains(word) else ""
