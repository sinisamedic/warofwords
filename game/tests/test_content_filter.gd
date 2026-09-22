extends SceneTree
const Lex = preload("res://scripts/lexicon.gd")
const Daily = preload("res://scripts/daily_rules.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1
func _initialize() -> void:
	var cases := {"en":["FUCK","STONE"],"sr":["KURAC","KAMEN"],"de":["FICKEN","STEIN"],"fr":["PUTAIN","PIERRE"],"es":["MIERDA","PIEDRA"],"it":["CAZZO","PIETRA"]}
	var blocked: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/blocked-words.json"))
	var ordinary := {"en":["ASSASSIN","CLASS","COCKPIT"],"fr":["DISPUTE","DISPUTER","IMPUTER"],"sr":["SERUM","SERUMA","SERUMIMA"]}
	for code in cases:
		var lex = Lex.new(true, code)
		check(lex.words.size()>50000, code+" vocabulary retained")
		for word in ordinary.get(code,[]): check(lex.contains(word),code+" innocent substring preserved: "+word)
		var all_excluded := true
		for word in blocked[code]:
			if lex.contains(word): all_excluded=false; break
		check(all_excluded,code+" all blocked entries excluded")
		check(not lex.contains(cases[code][0]) and lex.contains(cases[code][1]),code+" blocked and ordinary word")
		var route: Array[int] = []
		for tile in lex.tokens(cases[code][0]): route.append(route.size())
		for adjacent in [true,false]:
			lex.adjacent_only=adjacent
			lex.letters.assign(lex.tokens(cases[code][0]))
			while lex.letters.size()<28: lex.letters.append("X")
			check(lex.validate_path(route)=="",code+" reject move adjacent="+str(adjacent))
			lex.find_words()
			check(not lex.solutions.has(cases[code][0]),code+" no blocked hint")
			lex.joker_enabled=true; lex.letters[0]="*"
			var resolved := lex.validate_path(route)
			check(resolved=="" or resolved not in blocked[code],code+" joker cannot restore blocked word")
			lex.joker_enabled=false
		var daily = Daily.new()
		daily.begin(123,code,true)
		for i in route: daily.letters[i]=lex.tokens(cases[code][0])[i]
		check(not daily.accept(route,1000,lex) and daily.score==0,code+" daily rejects without score mutation")
		lex.generate()
		check(not lex.solutions.is_empty(),code+" generated board playable")
		for candidate in lex.refill_candidates:
			if candidate.word in blocked[code]: check(false,code+" blocked refill candidate")
	quit(1 if failures else 0)
