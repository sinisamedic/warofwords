extends SceneTree

const Lexicon=preload("res://scripts/lexicon.gd")
var failures := 0

func check(ok: bool, label: String) -> void:
	if not ok: failures+=1; push_error(label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for language in ["en","sr"]:
		var lex := Lexicon.new(true,language)
		check(lex.refill_candidates.size()>100,"common refill vocabulary loads for "+language)
		for adjacent in [true,false]:
			lex.adjacent_only=adjacent
			var measurements: Array=[]
			for smart in [false,true]:
				var long_boards := 0; var sum_longest := 0; var preserved := true; var planted := 0; var elapsed := 0; var maximum := 0; var short_turns := 0
				for seed_value in range(8):
					lex.rng.seed=9200+seed_value
					var used: Dictionary={}; lex.generate(used)
					for turn in 12:
						var choice := ""
						for word in lex.solutions:
							var candidate_length: int=lex.solutions[word].size()
							var current_length: int=lex.solutions.get(choice,[]).size()
							if choice.is_empty() or (seed_value%2==0 and candidate_length<current_length) or (seed_value%2==1 and candidate_length>current_length): choice=word
						check(not choice.is_empty(),"every turn has a valid solution")
						if choice.is_empty(): break
						var path: Array[int]=[]; path.assign(lex.solutions[choice]); used[choice]=true
						if path.size()<=4: short_turns+=1
						var old := lex.letters.duplicate(); var old_types := lex.types.duplicate()
						var started := Time.get_ticks_usec(); var shuffled := false
						if smart:
							shuffled=lex.refill(path,used); planted+=lex.last_refill_words.size()
							check(lex.refill_nodes<=lex.REFILL_SEARCH_BUDGET,"construction search respects its work budget")
							for route in lex.last_refill_routes:
								var survivors := 0
								for cell in route:
									if cell not in path: survivors+=1
								check(survivors>=2,"constructed words leave the consumed path")
						else:
							for cell in path:
								lex.letters[cell]=lex.pool[lex.rng.randi_range(0,lex.pool.size()-1)]
								lex.types[cell]=lex.rng.randi_range(0,3)
							lex.find_words(used)
							if lex.solutions.is_empty(): lex.generate(used); shuffled=true
						var took := Time.get_ticks_usec()-started; elapsed+=took; maximum=maxi(maximum,took)
						if not shuffled:
							for cell in 28:
								if cell not in path and (lex.letters[cell]!=old[cell] or lex.types[cell]!=old_types[cell]): preserved=false
						var longest := 0
						for word in lex.solutions:
							longest=maxi(longest,lex.solutions[word].size())
							var route: Array[int]=[]; route.assign(lex.solutions[word])
							check(not used.has(word) and lex.validate_path(route)==word,"refill solver returns legal unused paths")
						if longest>=5: long_boards+=1
						sum_longest+=longest
				check(preserved,"unconsumed letters and colors remain unchanged")
				measurements.append(long_boards)
				print(JSON.stringify({"language":language,"adjacent":adjacent,"smart":smart,"turns":96,"short_word_turns":short_turns,"boards_with_5plus":long_boards,"average_longest":sum_longest/96.0,"average_refill_ms":elapsed/96000.0,"worst_refill_ms":maximum/1000.0,"planted_words":planted}))
			check(measurements[1]>=measurements[0],"smart refill maintains more long-word boards than random refill")
	print("REFILL RESULT: %d failures" % failures)
	quit(1 if failures else 0)
