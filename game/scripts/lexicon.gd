extends RefCounted

var words: Dictionary = {}
var prefixes: Dictionary = {}
var rng := RandomNumberGenerator.new()
var seeds: Array[String] = ["STONE","STREAM","PLANET","BRIDGE","SILVER","GARDEN","ORANGE","CANDLE","STORM","CROWN","RIVER","SPARK","DREAM","LIGHT","OCEAN","FLAME","SHIELD","THUNDER","WINTER","FOREST","CASTLE","MIRROR","CRYSTAL","HUNTER","WONDER","SWORD","EARTH","SPRING","NIGHT","POWER"]
var letters: Array[String] = []
var types: Array[int] = []
var solutions: Dictionary = {}

func _init(load_now: bool = true) -> void:
	rng.randomize()
	if load_now:
		load_dictionary()

func load_dictionary() -> void:
	var file := FileAccess.open("res://data/english.txt", FileAccess.READ)
	if file == null:
		return
	while not file.eof_reached():
		var word := file.get_line().strip_edges().to_upper()
		if word.length() < 3:
			continue
		words[word] = true
		for n in range(1, mini(word.length(), 12) + 1):
			prefixes[word.left(n)] = true

func adjacent(a: int, b: int) -> bool:
	return a != b and absi(a % 7 - b % 7) <= 1 and absi(a / 7 - b / 7) <= 1

func generate(used: Dictionary = {}) -> void:
	var pool := "EEEEEEEEEEEAAAAAAAIIIIIIIOOOOOOONNNNNNRRRRRRTTTTTTLLLLSSSSUUUUDDDDGGGBCMPFHVWY"
	letters.clear()
	types.clear()
	for i in 28:
		letters.append(pool[rng.randi_range(0, pool.length()-1)])
		types.append(rng.randi_range(0, 3))
	# Disjoint row seeds make the board approachable; the solver also finds diagonals.
	for row in 4:
		var options: Array[String] = []
		for word in seeds:
			if word.length() <= 7 and not used.has(word):
				options.append(word)
		if options.is_empty():
			options = seeds
		var seed_word: String = options[rng.randi_range(0,options.size()-1)]
		seed_word = seed_word.left(7)
		if rng.randf() > 0.5:
			seed_word = seed_word.reverse()
		var offset := rng.randi_range(0,7-seed_word.length())
		for j in seed_word.length():
			letters[row*7+offset+j] = seed_word[j]
	find_words(used)

func refill(path: Array[int], used: Dictionary) -> bool:
	var pool := "EEEEAAAAIIIOOONNNRRRTTTLLSSUUDBGCMFPHWY"
	for i in path:
		letters[i] = pool[rng.randi_range(0,pool.length()-1)]
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
	if not prefixes.has(word):
		return
	var next_path := path.duplicate()
	next_path.append(i)
	if words.has(word) and not used.has(word):
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
	return word if words.has(word) and word.length() >= 3 else ""
