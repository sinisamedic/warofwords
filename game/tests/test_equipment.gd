extends SceneTree
var failures := 0
var g
func check(ok: bool, label: String) -> void:
	if not ok: failures+=1; push_error("FAIL: "+label)
	else: print("PASS: "+label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/equipment-test-save.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.path="res://../.local/equipment-test-save.json"
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=11
	check(g.Equipment.loadout(g.save.data)==["pulse","aegis","arc","mend"],"fresh install keeps the familiar starting equipment")
	g.change_screen("arsenal"); g.arsenal_slot=1; g.arsenal_choice=1; g.dispatch("gear_equip")
	check(g.Equipment.loadout(g.save.data)[1]=="aegis","locked Mirror cannot equip")
	for n in [2,3,5,7,9]: g.save.data.wins[str(n)]=3
	check(g.Equipment.unlocked("mirror",g.save.data) and g.Equipment.unlocked("seal",g.save.data) and g.Equipment.unlocked("bloom",g.save.data) and g.Equipment.unlocked("reserve",g.save.data),"existing campaign wins unlock the first wave retroactively")
	g.dispatch("gear_equip")
	g.arsenal_slot=2; g.dispatch("gear_equip")
	g.arsenal_slot=3; g.dispatch("gear_equip")
	g.arsenal_slot=4; g.dispatch("gear_equip")
	check(g.save.data.loadout==["pulse","mirror","seal","bloom"] and g.save.data.artifact=="reserve","Arsenal equips one device per color and one artifact")
	g.mission=1; await g.start_battle()
	g.energy[1]=6; g.fire(1)
	var before: int=g.foe_hp
	g.launch_attack(false,"enemy",g.GOLD,20)
	check(g.hp==100 and g.foe_hp==before,"Mirror and incoming damage wait for contact")
	g.advance_combat(.43)
	check(g.hp==94 and g.shield==0 and g.foe_hp==before,"Mirror absorbs fourteen before reflecting")
	check(g.fx.shots.size()==1 and g.fx.shots[0].kind=="mirror" and g.fx.shots[0].damage==7,"Mirror launches half of actual absorbed damage")
	g.persist_battle(); g.restore_battle(); g.overlay=""
	g.advance_combat(.43)
	check(g.foe_hp==before-7,"reflected projectile survives a save and damages only on arrival")
	g.energy[1]=6; g.fire(1); g.launch_attack(false,"enemy",g.GOLD,5); g.advance_combat(.43)
	check(g.fx.shots[0].damage==2,"reflection rounds down and uses actual absorption, not shield capacity")
	g.fx.clear(); g.shield=0; g.hp=1; g.energy[1]=6; g.fire(1)
	g.launch_attack(false,"enemy",g.GOLD,20); g.advance_combat(.43)
	check(g.ended and g.fx.shots.is_empty(),"lethal impact cannot leave a posthumous reflection")
	g.mission=2; await g.start_battle(); g.enemy_attacks=1; g.foe_hp=50
	g.energy[2]=5; g.fire(2)
	check(g.seal_time==0 and g.foe_hp==50,"Seal begins only when projectile hits")
	g.advance_combat(.43); check(g.seal_time==20 and g.foe_hp==42,"Seal deals eight and marks for twenty seconds")
	g.enemy_attack(); check(g.foe_hp==42 and g.seal_time==0 and g.enemy_attacks==2,"Seal consumes exactly one healing turn")
	g.enemy_attack(); g.fx.clear(); g.enemy_attack()
	check(g.foe_hp==60,"later healing works after the mark is consumed")
	g.seal_time=1; g.advance_equipment(1.1); check(g.seal_time==0,"unused Seal expires")
	g.hp=40; g.energy[3]=5; g.fire(3)
	check(g.hp==46 and g.bloom_ticks==4,"Bloom heals six immediately and schedules four ticks")
	g.advance_equipment(1.9); check(g.hp==46,"Bloom cannot heal before its tick")
	g.advance_equipment(.1); check(g.hp==52 and g.bloom_ticks==3,"Bloom heals every two seconds")
	g.overlay="pause"; g._process(.05)
	check(g.bloom_time==2,"pause freezes regeneration")
	g.overlay=""; g.advance_equipment(1)
	g.persist_battle(); g.change_screen("arsenal")
	g.arsenal_slot=1; g.arsenal_choice=0; g.dispatch("gear_equip"); g.dispatch("artifact_clear")
	g.restore_battle(); g.overlay=""
	check(g.battle_loadout[1]=="mirror" and g.battle_artifact=="reserve","saved duel keeps its own equipment despite inventory edits")
	g.advance_equipment(1); check(g.hp==58 and g.bloom_ticks==2,"regeneration resumes at saved tick boundary")
	g.energy[3]=5; g.fire(3); check(g.bloom_ticks==4 and g.hp==64,"recasting refreshes rather than stacks Bloom")
	g.advance_equipment(8); check(g.hp==88 and g.bloom_ticks==0,"Bloom completes four ticks and stops")
	g.hp=99; g.energy[3]=5; g.fire(3); g.advance_equipment(8)
	check(g.hp==100,"regeneration cannot exceed maximum health")
	g.energy.assign([3,5,4,4]); g.reserves.assign([0,0,0,0]); g.gain_energy([9,9,9,9])
	check(g.energy==[4,6,5,5] and g.reserves==[2,2,2,2],"Reserve caps each independent overflow bank at two")
	g.fire(0); check(g.energy[0]==2 and g.reserves==[0,2,2,2],"activation spends main charge and restores only its own reserve")
	g.persist_battle(); check(g.valid_snapshot(g.save.data.battle),"first-wave state validates with projectiles and reserves")
	var snapshot: Dictionary=g.save.data.battle.duplicate(true)
	for key in ["loadout","artifact","reserves","shield_kind","seal_time","bloom_time","bloom_ticks","bloom_amount","best_tiles"]: snapshot.erase(key)
	snapshot.energy=[4,5,7,5]
	check(g.valid_snapshot(snapshot),"pre-equipment battle snapshots remain compatible")
	for invalid in [{"loadout":["pulse","seal","arc","mend"]},{"reserves":[0,3,0,0]},{"seal_time":NAN},{"bloom_ticks":5},{"artifact":"unknown"},{"energy":[0,NAN,0,0]}]:
		var broken: Dictionary=g.save.data.battle.duplicate(true); broken.merge(invalid,true)
		check(not g.valid_snapshot(broken),"corrupted equipment state rejected: "+str(invalid.keys()[0]))
	g.fx.clear(); g.finish(false); var health: int=g.hp; g.advance_equipment(8)
	check(g.hp==health,"regeneration stops after defeat")
	g.save.data.loadout=g.Equipment.DEFAULTS.duplicate(); g.save.data.artifact="none"
	g.mission=0; await g.start_battle()
	g.lex.letters.assign(Array("STREAMSAAAAAAAAAAAAAAAAAAAAA".split("")))
	g.path.assign([0,1,2,3,4,5,6]); g.submit_word()
	check(g.best_tiles==7 and not g.save.data.lexicon_earned,"seven-tile word alone does not award victory artifact")
	g.finish(true); check(g.save.data.lexicon_earned and "lexicon" in g.new_equipment,"winning with seven tiles awards Lexicon Seal once")
	g.save.data.artifact="lexicon"; await g.start_battle()
	g.lex.letters.assign(Array("STREAMSAAAAAAAAAAAAAAAAAAAAA".split("")))
	g.path.assign([0,1,2,3,4,5,6]); g.submit_word()
	check(g.fx.shots.size()==1 and g.fx.shots[0].damage==17,"Lexicon adds four only to qualifying word projectile")
	g.path.assign([0,1,2,3,4,5,6]); g.lex.letters.assign(Array("STREAMSAAAAAAAAAAAAAAAAAAAAA".split(""))); g.submit_word()
	check(g.fx.shots.size()==1,"duplicate word cannot trigger artifact again")
	g.best_tiles=6; g.save.data.lexicon_earned=false; g.best_word="LJUBLJEN"; g.finish(true)
	check(not g.save.data.lexicon_earned,"artifact achievement counts tiles, not Serbian digraph characters")
	# Legacy save migrates gold weapon; inventory remains independent of battle payload.
	var legacy: Dictionary=g.save.defaults(); legacy.erase("loadout"); legacy.weapon="breach"; legacy.wins={"3":3}
	g.save.data=legacy; g.save.save_game(); g.save.load_game()
	check(g.save.data.loadout==["breach","aegis","arc","mend"],"legacy Breach selection migrates on disk")
	g.queue_free(); await process_frame; await create_timer(.5).timeout
	print("EQUIPMENT RESULT: %d failures" % failures); quit(1 if failures else 0)
