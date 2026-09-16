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
	return (letter.length()==1 and letter>="A" and letter<="Z") if language=="en" else letter in pool

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
	find_words(used)

func refill(path: Array[int], used: Dictionary) -> bool:
	for i in path:
		letters[i] = pool[rng.randi_range(0,pool.size()-1)]
		types[i] = rng.randi_range(0,3)
	find_words(used)
	if solutions.is_empty():
		generate(used)
		return true
	return false

func find_words(used: Dictionary = {}) -> Dictionary:
	solutions.clear()
	for i in letters.size():
		_search(i,"",0,[],used)
	return solutions

func _search(i: int, prefix: String, mask: int, path: Array, used: Dictionary) -> void:
	if solutions.size() >= 180 or path.size() >= 12 or mask & (1 << i):
		return
	var word := prefix + letters[i]
	if not has_prefix(word):
		return
	var next_path := path.duplicate()
	next_path.append(i)
	if next_path.size() >= 3 and contains(word) and not used.has(word):
		solutions[word] = next_path
	var next_mask := mask | (1 << i)
	for dy in [-1,0,1]:
		for dx in [-1,0,1]:
			var x: int = i % 7 + dx
			var y: int = i / 7 + dy
			if x >= 0 and x < 7 and y >= 0 and y < 4 and (dx != 0 or dy != 0):
				_search(y*7+x,word,next_mask,next_path,used)

func validate_path(path: Array[int]) -> String:
	var visited: Dictionary = {}
	var word := ""
	for j in path.size():
		var i := path[j]
		if i < 0 or i >= 28 or visited.has(i):
			return ""
		if j > 0 and not adjacent(path[j-1],i):
			return ""
		visited[i] = true
		word += letters[i]
	return word if contains(word) and path.size() >= 3 else ""
