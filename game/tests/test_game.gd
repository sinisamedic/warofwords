extends SceneTree

var failures := 0

func check(condition: bool, label: String) -> void:
	if not condition:
		failures+=1
		push_error("FAIL: "+label)
	else:
		print("PASS: "+label)

func _initialize() -> void:
	call_deferred("run_tests")

func run_tests() -> void:
	var scene = load("res://main.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	while scene.loading:
		await process_frame
	scene.set_process(false)
	scene.save.path="res://../.local/test-progress.json"
	scene.save.data=scene.save.defaults()
	scene.save.data.tutorial=true
	scene.sfx.enabled=false
	check(scene.lex.words.size()>70000,"licensed dictionary loaded")
	check(scene.lex.words.has("STONE") and scene.lex.words.has("EXTRAORDINARY"),"ordinary and advanced vocabulary")
	check(scene.lex.adjacent(0,8) and not scene.lex.adjacent(6,7),"diagonals allowed; no row wrapping")
	var began := Time.get_ticks_msec()
	for n in 30:
		scene.lex.generate()
		check(scene.lex.solutions.size()>=4,"board %d has several words" % n)
		for word in scene.lex.solutions:
			var p: Array[int] = []
			p.assign(scene.lex.solutions[word])
			check(scene.lex.validate_path(p)==word,"solver path valid: "+word)
			break
	print("30 generated boards + solvers: %d ms" % (Time.get_ticks_msec()-began))
	scene.mission=0
	scene.start_battle()
	scene.lex.letters.assign(Array("STONESTREAMLINEPLANETCARDSEN".split("")))
	scene.lex.types.assign([0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3])
	scene.energy.assign([0,0,0,0])
	scene.add_letter(0); scene.add_letter(8); scene.add_letter(0)
	check(scene.path==[0],"backtracking removes last letter")
	scene.path.assign([0,1,2,3,4])
	scene.hitboxes.clear()
	for i in 28: scene.hitboxes.append(Rect2(scene.tile_center(i)-Vector2(29,29),Vector2(58,58)))
	scene.path.assign([0])
	scene.dragging=true; scene.drag_position=scene.tile_center(0)
	scene.move(scene.tile_center(4))
	check(scene.path==[0,1,2,3,4],"fast swipe includes crossed letters without skipped events")
	scene.dragging=false
	var untouched: Array = scene.lex.letters.slice(5)
	scene.submit_word()
	check(scene.used.has("STONE") and scene.word_count==1,"word accepted")
	check(scene.energy==[2,1,1,1],"each color charges its own ability")
	check(scene.lex.letters.slice(5)==untouched,"only used cells refill")
	check(scene.foe_hp==65,"five-letter word does seven direct damage")
	scene.lex.letters.assign(Array("STONESTREAMLINEPLANETCARDSEN".split("")))
	scene.path.assign([0,1,2,3,4]); scene.submit_word()
	check(scene.word_count==1,"repeat rejected per duel")
	scene.energy.assign([4,5,7,5])
	scene.fire(1); scene.enemy_attack()
	check(scene.hp==100 and scene.shield==0,"shield blocks and consumes")
	scene.enemy_attack(); check(scene.hp==88,"CPU damage")
	scene.fire(3); check(scene.hp==100 and scene.energy[3]==0,"heal and energy spending")
	scene.countdown=1; scene.fire(2)
	check(scene.countdown>10 and scene.energy[2]==0,"Arc interrupts incoming attack")
	scene.power_up(); check(scene.freeze==8 and scene.boost_used,"power-up applied")
	scene.freeze=3; scene.power_up(); check(scene.freeze==3,"power-up cannot be reused")
	scene.persist_battle()
	var snapshot: Dictionary = scene.save.data.battle.duplicate(true)
	check(scene.valid_snapshot(snapshot),"saved battle schema")
	check(scene.valid_snapshot(JSON.parse_string(JSON.stringify(snapshot))),"JSON round-trip snapshot valid")
	var malformed: Dictionary = snapshot.duplicate(true)
	malformed.hp=[]
	check(not scene.valid_snapshot(malformed),"invalid save numeric type rejected")
	malformed=JSON.parse_string(JSON.stringify(snapshot))
	malformed.types[0]="invalid"
	check(not scene.valid_snapshot(malformed),"invalid saved tile type rejected")
	scene.change_screen("home"); scene.restore_battle()
	check(scene.overlay=="pause" and scene.word_count==1 and scene.hp==100,"resume restores and stays paused")
	check(scene.lex.letters==snapshot.letters and scene.boost_used,"resume keeps board and consumed power-up")
	var before: int = scene.save.data.coins
	scene.finish(true)
	var after: int = scene.save.data.coins
	scene.finish(true)
	check(after==before+120 and scene.save.data.coins==after,"victory reward only once")
	check(scene.save.data.unlocked==1 and scene.save.data.battle.is_empty(),"unlock and completed-save cleanup")
	scene.selected=0
	var cost: int = scene.upgrade_cost(0)
	scene.upgrade()
	check(scene.save.data.levels[0]==2 and scene.save.data.coins==after-cost,"upgrade spends actual cost")
	var persistence = load("res://scripts/save_data.gd").new()
	persistence.path=scene.save.path
	persistence.load_game()
	check(persistence.data.levels[0]==2 and persistence.data.unlocked==1,"save reload")
	scene.save.save_game()
	var bad := FileAccess.open(scene.save.path,FileAccess.WRITE)
	bad.store_string("{broken"); bad.close()
	persistence.load_game()
	check(persistence.data.levels[0]==2,"corrupted save recovers from backup")
	# Both normal and boss missions must be winnable through real solver-selected words.
	for level in [0,3,7,11]:
		scene.save.data.unlocked=11
		scene.mission=level
		scene.start_battle()
		for step in 80:
			if scene.ended: break
			scene.lex.find_words(scene.used)
			if scene.lex.solutions.is_empty(): scene.lex.generate(scene.used)
			var best := ""
			for word in scene.lex.solutions:
				if word.length()>best.length(): best=word
			scene.path.assign(scene.lex.solutions[best])
			scene.submit_word()
			for i in [0,2]:
				if not scene.ended and scene.energy[i]>=scene.COSTS[i]: scene.fire(i)
			if step%3==2 and not scene.ended:
				if scene.energy[1]>=5: scene.fire(1)
				scene.enemy_attack()
				if scene.energy[3]>=5: scene.fire(3)
		check(scene.ended and scene.won,"playable completion mission %d" % (level+1))
	print("RESULT: %d failures" % failures)
	quit(1 if failures else 0)
