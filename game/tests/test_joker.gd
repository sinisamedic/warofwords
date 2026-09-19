extends SceneTree
const Lex=preload("res://scripts/lexicon.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	for lang in ["en","sr"]:
		var lex=Lex.new(true,lang); lex.joker_enabled=true
		lex.letters.assign(Array("XXXXXXXXXXXXXXXXXXXXXXXXXXXX".split("")))
		lex.types.assign([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0])
		var route: Array[int]=[0,1,2]
		lex.letters[0]="C" if lang=="en" else "Đ"; lex.letters[1]="*"; lex.letters[2]="T" if lang=="en" else "K"
		var resolved: String=lex.validate_path(route)
		assert(not resolved.is_empty() and lex.contains(resolved))
		assert(lex.validate_path([0,0,1]).is_empty()); assert(lex.validate_path([0,7,2]).is_empty())
		assert(lex.valid_tile("*")); lex.joker_enabled=false; assert(not lex.valid_tile("*")); assert(lex.validate_path(route).is_empty()); lex.joker_enabled=true
		for adjacent in [true,false]:
			lex.adjacent_only=adjacent
			var start := Time.get_ticks_msec()
			lex.find_words()
			assert(not lex.solutions.is_empty())
			for word in lex.solutions:
				var path: Array[int]=[]; path.assign(lex.solutions[word])
				assert(not lex.validate_path(path).is_empty())
			lex.generate(); assert(lex.letters.count("*")==1)
			for attempt in 10:
				lex.refill([0,1,2,3,4,5,6],{})
				assert(lex.letters.count("*")<=1 and not lex.solutions.is_empty())
			print("PASS: Joker ",lang," adjacent=",adjacent," validation, hints, refill: ",Time.get_ticks_msec()-start,"ms")
	var sr=Lex.new(true,"sr"); sr.joker_enabled=true
	sr.letters.assign(Array("XXXXXXXXXXXXXXXXXXXXXXXXXXXX".split("")))
	sr.letters[0]="*"; sr.letters[1]="E"; sr.letters[2]="P"
	assert(sr.contains("DŽEP"))
	var used: Dictionary={}
	for tile in sr.alphabet:
		if tile!="DŽ": used[tile+"EP"]=true
	assert(sr.validate_path([0,1,2],used)=="DŽEP")
	print("PASS: Joker replaces Serbian digraph and prefers unused words")
	quit()
