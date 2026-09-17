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
	get_tree_watchdog()
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
	scene.music.set_enabled(false)
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
	check(scene.foe_hp==72,"word launch does not remove health")
	scene.advance_combat(.40)
	check(scene.foe_hp==72,"health stays unchanged during flight")
	scene.advance_combat(.03)
	check(scene.foe_hp==65,"five-letter word does seven damage on arrival")
	scene.advance_combat(.5)
	check(scene.foe_hp==65,"arrival damage cannot repeat")
	scene.lex.letters.assign(Array("STONESTREAMLINEPLANETCARDSEN".split("")))
	scene.path.assign([0,1,2,3,4]); scene.submit_word()
	check(scene.word_count==1,"repeat rejected per duel")
	scene.energy.assign([4,5,7,5])
	scene.fire(1); scene.enemy_attack()
	check(scene.hp==100 and scene.shield==20,"CPU launch does not consume shield or health")
	scene.advance_combat(.43)
	check(scene.hp==100 and scene.shield==0,"shield blocks and consumes")
	scene.enemy_attack(); scene.advance_combat(.43); check(scene.hp==88,"CPU damage on impact")
	scene.fire(3); check(scene.hp==100 and scene.energy[3]==0,"heal and energy spending")
	scene.countdown=1; scene.fire(2)
	check(scene.countdown==1,"Arc does not interrupt before arrival")
	scene.advance_combat(.43)
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
			scene.advance_combat(.43)
		check(scene.ended and scene.won,"playable completion mission %d" % (level+1))
	# Old progress and in-progress English duels survive independent locale changes.
	scene.mission=0; scene.start_battle(); scene.persist_battle()
	var old_duel: Dictionary = scene.save.data.battle.duplicate(true)
	old_duel.erase("dictionary_code")
	check(scene.valid_snapshot(old_duel),"0.1.0 duel accepted without dictionary field")
	scene.change_screen("settings")
	scene.dispatch("ui_language",1)
	check(scene.t("OPTIONS")=="PODEŠAVANJA" and scene.lex.language=="en","UI language does not change dictionary")
	var sr_started := Time.get_ticks_msec()
	await scene.dispatch("word_language",1)
	print("Serbian load: %d ms; %d entries" % [Time.get_ticks_msec()-sr_started,scene.lex.words.size()])
	check(scene.lex.words.size()==1740276,"complete licensed Serbian inflections loaded")
	for word in ["REČ","REČI","ŠTIT","ŠTITA","LJUBAV","NJEGA","DŽEP","KUĆA","KUĆE","ĐAK","ŽIVOT"]:
		check(scene.lex.contains(word),"Serbian dictionary: "+word)
	check(not scene.lex.contains("EXTRAORDINARY") and not scene.lex.contains("KUCAAA"),"Serbian rejects foreign or invalid words")
	check(scene.lex.tokens("LJUBAV")==["LJ","U","B","A","V"] and scene.lex.tokens("DŽEP")==["DŽ","E","P"],"Serbian digraphs occupy one tile")
	for n in 10:
		scene.lex.generate()
		check(scene.lex.letters.size()==28 and scene.lex.solutions.size()>=4,"Serbian playable board %d" % n)
	scene.save.data.tutorial=false
	await scene.start_battle()
	var kamen: Array[int] = [0,1,2,3,4]
	check(scene.lex.letters.size()==28 and scene.lex.validate_path(kamen)=="KAMEN","Serbian guided board and swipe")
	scene.overlay=""; scene.path.clear()
	await process_frame
	await process_frame
	scene.buttons_state="home|"
	scene.press(scene.tile_center(0)); scene.release(scene.tile_center(0))
	check(scene.path.is_empty(),"input waits for the new screen to be drawn")
	# Headless tests do not render; acknowledge the current screen as a real draw does.
	scene.buttons_state=scene.screen+"|"+scene.overlay
	scene.press(scene.tile_center(0)); scene.release(scene.tile_center(0))
	await process_frame
	check(scene.tap_composition and scene.path==[0] and scene.word_count==0,"tap waits for explicit confirmation")
	scene.press(scene.tile_center(0)); scene.move(scene.tile_center(4))
	await process_frame
	check(not scene.tap_composition and not scene.buttons.any(func(b): return b.id=="submit"),"slide hides confirmation controls")
	scene.release(scene.tile_center(4))
	check(scene.used.has("KAMEN") and scene.path.is_empty(),"Serbian slide automatically submits")
	scene.advance_combat(.43)
	scene.lex.letters.assign(["DŽ","E","P","K","A","M","E","R","E","Č","I","G","R","A","Š","T","I","T","LJ","U","B","A","V","NJ","E","G","A","Đ"])
	scene.path.assign([0,1,2]); var old_hp: int=scene.foe_hp
	scene.submit_word()
	scene.advance_combat(.43)
	check(scene.used.has("DŽEP") and scene.foe_hp==old_hp-3,"digraph damage counts tiles not code points")
	scene.persist_battle()
	check(scene.valid_snapshot(scene.save.data.battle),"Serbian snapshot accepts accented and digraph tiles")
	scene.change_screen("home"); await scene.restore_battle()
	check(scene.lex.language=="sr" and scene.overlay=="pause" and scene.used.has("DŽEP"),"Serbian duel resumes paused with same dictionary")
	scene.change_screen("home"); scene.save.data.battle=old_duel
	await scene.restore_battle()
	check(scene.lex.language=="en" and scene.save.data.word_language=="sr" and scene.save.data.ui_language=="sr","old English duel keeps dictionary despite Serbian settings")
	scene.persist_battle(); persistence.load_game()
	check(persistence.data.word_language=="sr" and persistence.data.ui_language=="sr","both language settings persist")
	var invalid: Dictionary = old_duel.duplicate(true)
	invalid.letters[0]="Č"
	check(not scene.valid_snapshot(invalid),"English snapshot rejects Serbian-only tile")
	scene.change_screen("home")
	invalid=old_duel.duplicate(true); invalid.dictionary_code=[]
	scene.save.data.battle=invalid
	await scene.restore_battle()
	check(scene.save.data.battle.is_empty() and scene.screen=="home","malformed dictionary code is rejected before loading")
	# Optional free linking: input, validation, hints, persistence and legacy rules.
	scene.save.data.word_language="en"; scene.save.data.tutorial=true
	scene.dispatch("link_rule",1)
	await scene.start_battle()
	check(not scene.lex.adjacent_only,"new duel adopts free linking preference")
	scene.lex.letters.assign(Array("XXXXXXXXXXXXXXXXXXXXXXXXXXXX".split("")))
	var scattered: Array[int] = [0,20,7,25,3]
	for i in 5: scene.lex.letters[scattered[i]]="STONE"[i]
	check(scene.lex.validate_path(scattered)=="STONE","nonadjacent word accepted in free mode")
	var repeated: Array[int]=[0,20,0]
	check(scene.lex.validate_path(repeated).is_empty(),"free mode still forbids tile reuse")
	scene.path.clear()
	for index in scattered: scene.add_letter(index)
	check(scene.path==scattered,"tap composition can jump across the board")
	scene.add_letter(25)
	check(scene.path==scattered.slice(0,4),"free jump supports backtracking")
	scene.lex.adjacent_only=true
	check(scene.lex.validate_path(scattered).is_empty(),"adjacent mode rejects the same scattered word")
	scene.path.clear(); scene.add_letter(0); scene.add_letter(20)
	check(scene.path==[0],"adjacent input rejects jumps")
	scene.lex.adjacent_only=false
	var free_started := Time.get_ticks_msec()
	scene.lex.find_words()
	check(scene.lex.solutions.has("STONE"),"free hint solver discovers a scattered word")
	check(scene.lex.search_nodes<=scene.lex.FREE_SEARCH_BUDGET+1,"free search has a fixed work budget")
	print("Free English search: %d ms" % (Time.get_ticks_msec()-free_started))
	for word in scene.lex.solutions:
		var valid_free: Array[int]=[]; valid_free.assign(scene.lex.solutions[word])
		if scene.lex.validate_path(valid_free)!=word: check(false,"invalid free hint: "+word)
	scene.path.assign(scattered); scene.submit_word(); scene.persist_battle()
	check(scene.used.has("STONE") and not scene.save.data.battle.adjacent_only,"free word and rule are saved")
	scene.change_screen("settings"); scene.dispatch("link_rule",0)
	await scene.restore_battle()
	check(scene.lex.adjacent_only and scene.save.data.adjacent_only,"rule changes apply immediately to the saved duel")
	scene.change_screen("home"); old_duel.erase("adjacent_only")
	scene.save.data.battle=old_duel; await scene.restore_battle()
	check(scene.lex.adjacent_only,"legacy duel defaults to adjacency")
	invalid=old_duel.duplicate(true); invalid.adjacent_only="false"
	check(not scene.valid_snapshot(invalid),"malformed link rule rejected")
	scene.save.data.word_language="sr"; scene.save.data.adjacent_only=false
	await scene.start_battle()
	scene.lex.letters.assign(Array("ČČČČČČČČČČČČČČČČČČČČČČČČČČČČ".split("")))
	scene.lex.letters[0]="Đ"; scene.lex.letters[10]="A"; scene.lex.letters[27]="K"
	var djak: Array[int]=[0,10,27]
	check(scene.lex.validate_path(djak)=="ĐAK","Serbian free linking preserves Đ")
	free_started=Time.get_ticks_msec(); scene.lex.find_words()
	check(scene.lex.solutions.has("ĐAK"),"Serbian free hint finds ĐAK across board")
	print("Free Serbian search: %d ms" % (Time.get_ticks_msec()-free_started))
	scene.lex.generate()
	check(scene.lex.solutions.size()>=4,"free mode generates playable boards")
	for glyph in "ĐđČčĆćŠšŽž":
		check(scene.title_font.has_char(glyph.unicode_at(0)) and scene.font.has_char(glyph.unicode_at(0)),"both shipped fonts contain "+glyph)
	var effects = load("res://scripts/combat_fx.gd").new()
	effects.launch(true,"pulse",scene.GOLD)
	check(effects.advance(.40).is_empty(),"impact waits for projectile arrival")
	check(effects.advance(.03).size()==1 and effects.shots.is_empty(),"one impact emitted at arrival")
	check(effects.advance(.5).is_empty(),"impact sound/haptic cannot repeat")
	for i in 30: effects.launch(false,"enemy",scene.GOLD,12)
	check(effects.shots.size()==30 and effects.bursts.size()<=16,"cosmetic cap never discards live attacks")
	check(effects.advance(.43).size()==30,"rapid attacks all reach impact exactly once")
	effects.clear()
	check(effects.shots.is_empty() and effects.bursts.is_empty(),"leaving battle clears effects")
	check(scene.sfx.streams.size()==13 and scene.sfx.streams.values().all(func(stream): return stream!=null),"all thirteen sound assets load")
	scene.sfx.enabled=true; scene.sfx.play("flight"); scene.sfx.enabled=false
	check(scene.sfx.voices.all(func(voice): return not voice.playing),"muting stops current sounds immediately")
	scene.save.save_game(); persistence.load_game()
	check(not persistence.data.adjacent_only,"connection preference survives reload")
	# A paid-for projectile survives pause, process restart and JSON serialization.
	scene.save.data.word_language="en"; scene.save.data.tutorial=true; scene.mission=0
	await scene.start_battle()
	scene.energy[0]=4; scene.fire(0); scene.advance_combat(.2)
	scene.dispatch("pause")
	var flying: Dictionary=JSON.parse_string(JSON.stringify(scene.save.data.battle))
	check(flying.foe==72 and flying.energy[0]==0 and flying.projectiles.size()==1,"save stores spent energy with unapplied in-flight damage")
	check(scene.valid_snapshot(flying),"projectile snapshot survives JSON round trip")
	for bad_field in ["time","damage","color","player"]:
		var damaged: Dictionary=flying.duplicate(true)
		damaged.projectiles[0][bad_field]=[]
		check(not scene.valid_snapshot(damaged),"malformed projectile rejected: "+bad_field)
	scene.change_screen("home"); scene.save.data.battle=flying
	await scene.restore_battle()
	scene._process(.05)
	check(scene.foe_hp==72 and scene.fx.shots.size()==1 and is_equal_approx(scene.fx.shots[0].time,.2),"paused restored projectile does not advance")
	scene.dispatch("resume"); scene.advance_combat(.21)
	check(scene.foe_hp==72,"restored flight preserves remaining travel time")
	scene.advance_combat(.02)
	check(scene.foe_hp==72-scene.effect(0) and scene.fx.shots.is_empty(),"restored projectile damages once without charging again")
	var impact_hp: int=scene.foe_hp
	scene.change_screen("home"); await scene.restore_battle(); scene.dispatch("resume"); scene.advance_combat(1)
	check(scene.foe_hp==impact_hp,"reloading after impact does not replay damage")
	# A shield raised while the enemy projectile is travelling must protect on impact.
	scene.hp=100; scene.shield=0; scene.enemy_attack(); scene.advance_combat(.2)
	scene.energy[1]=5; scene.fire(1); scene.advance_combat(.23)
	check(scene.hp==100 and scene.shield==0,"shield activated during flight blocks at arrival")
	check(scene.hero_recoil>0 and scene.hero_hit_strength>0,"impact starts a target hit reaction")
	scene.enemy_recoil=.48; scene.enemy_hit_strength=25; scene.hero_recoil=0; scene.save.data.calm=false
	scene.update_actors()
	check(scene.enemy_actor.position.x>scene.size.x*.8+15,"strong hit visibly displaces the target")
	scene.save.data.calm=true; scene.update_actors()
	check(is_equal_approx(scene.enemy_actor.position.x,scene.size.x*.8),"reduced motion removes target shake")
	scene.save.data.calm=false
	# Lethal arrivals have a deterministic winner and cannot grant two rewards.
	scene.foe_hp=1; scene.hp=1; scene.fx.clear()
	scene.launch_attack(true,"pulse",scene.GOLD,24); scene.fx.advance(.1)
	scene.launch_attack(false,"enemy",scene.GOLD,12)
	var coins_before: int=scene.save.data.coins
	scene.advance_combat(.5)
	check(scene.ended and scene.won and scene.hp==1 and scene.foe_hp==0,"earlier lethal arrival ends duel before later projectile")
	var coins_after: int=scene.save.data.coins
	scene.advance_combat(1)
	check(coins_after>coins_before and scene.save.data.coins==coins_after and scene.fx.shots.is_empty(),"lethal impact rewards exactly once and clears pending attacks")
	# Swipes work alongside arrows, and are constrained to available pages.
	scene.save.data.unlocked=11; scene.mission=0; scene.change_screen("campaign")
	scene.buttons_state="campaign|"; scene.press(Vector2(600,180)); scene.move(Vector2(300,185)); scene.release(Vector2(300,185))
	check(scene.chapter==1 and scene.mission==4,"campaign left swipe advances chapter")
	scene.buttons_state="campaign|"; scene.press(Vector2(300,180)); scene.release(Vector2(600,185))
	check(scene.chapter==0,"campaign right swipe returns")
	scene.save.data.unlocked=0; scene.dispatch("chapter",2)
	check(scene.chapter==0,"swipe cannot bypass chapter locks")
	scene.change_screen("journal"); scene.save.data.dictionary.clear()
	for i in 41: scene.save.data.dictionary.append("WORD"+str(i))
	scene.buttons_state="journal|"; scene.press(Vector2(600,180)); scene.move(Vector2(300,185)); scene.release(Vector2(300,185))
	check(scene.journal_page==1,"journal swipe advances by twenty entries")
	scene.dispatch("journal_page",99)
	check(scene.journal_page==2,"journal final partial page clamps correctly")
	scene.buttons_state="journal|"; scene.press(Vector2(500,180)); scene.move(Vector2(510,330)); scene.release(Vector2(510,330))
	check(scene.journal_page==2,"vertical gesture does not paginate")
	scene.dispatch("journal_page",0)
	check(scene.journal_page==0,"journal arrows still navigate")
	# Real music streams, independent mute, ducking and Android lifecycle handling.
	check(scene.music.TRACKS.all(func(track): return track.get_length()>60),"both music recordings exceed one minute")
	print("Music durations: %.2f / %.2f seconds" % [scene.music.TRACKS[0].get_length(),scene.music.TRACKS[1].get_length()])
	scene.music.set_enabled(true); scene.music.backgrounded=false; scene.music.battle=false; scene.music._process(.5)
	check(scene.music.players[0].playing and not scene.sfx.enabled,"music plays independently of muted sound effects")
	scene.music.set_enabled(false)
	check(scene.music.players.all(func(player): return not player.playing or player.stream_paused),"music toggle immediately silences both recordings")
	scene.music.set_enabled(true); scene.music._notification(Node.NOTIFICATION_APPLICATION_PAUSED); scene.music._process(.5)
	check(scene.music.players.all(func(player): return not player.playing or player.stream_paused),"backgrounding pauses music")
	scene.music._notification(Node.NOTIFICATION_APPLICATION_RESUMED); scene.music.battle=true; scene.music._process(.5)
	check(scene.music.players[1].playing and not scene.music.players[1].stream_paused,"battle music resumes after backgrounding")
	scene.music.set_enabled(false); scene.save.data.music=false; scene.save.save_game(); persistence.load_game()
	check(not persistence.data.music,"music preference survives restart")
	for encounter in 12:
		scene.mission=encounter; scene.screen="battle"; scene.update_actors()
		check(scene.enemy_actor.get_meta("encounter")==encounter and scene.enemy_actor.texture==scene.EnemyArt.ATLAS,"distinct enemy sprite and portrait for encounter %d" % encounter)
	print("RESULT: %d failures" % failures)
	quit(1 if failures else 0)

func get_tree_watchdog() -> void:
	await create_timer(60).timeout
	push_error("Test watchdog expired")
	quit(1)
