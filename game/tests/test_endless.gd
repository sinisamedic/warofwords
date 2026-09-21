extends SceneTree
var g
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if not ok: failures+=1; push_error("FAIL: "+label)
	else: print("PASS: "+label)
func run() -> void:
	create_timer(80).timeout.connect(func(): push_error("Endless test timeout"); quit(2))
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/test-endless.json"; root.add_child(g)
	while g.loading: await process_frame
	if is_instance_valid(g.age_screen): g.age_screen.kind="info"; g.age_screen.leave()
	await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.age_group="adult"; g.save.data.tutorial=true
	for ch in "ČĆŠŽĐčćšžđ": check(g.font.has_char(ch.unicode_at(0)),"Lora glyph "+ch)
	for w in 25:
		var mission: int=g.Endless.opponent(w+1)
		check((mission%4==3)==((w+1)%5==0),"boss cadence wave %d" % (w+1))
	await g.start_battle()
	g.hp=83; g.persist_battle()
	var campaign: Dictionary=g.save.data.battle.duplicate(true)
	var coins: int=g.save.data.coins
	g.change_screen("endless_prepare"); await g.start_endless()
	check(g.endless_mode and g.endless_wave==1,"new run starts at wave one")
	check(g.save.data.battle==campaign,"starting run preserves campaign snapshot")
	g.lex.letters.assign(Array("STONESTREAMLINEPLANETCARDSEN".split("")))
	g.path.assign([0,1,2,3,4]); g.submit_word()
	check(g.endless_score>0,"accepted word scores points")
	g.hp=61; g.energy.assign([2,3,4,1]); g.boost_used=true; g.shield=10
	g.finish(true)
	var score: int=g.endless_score
	g.finish(true); check(score==g.endless_score,"win scored once")
	check(g.save.data.wins.is_empty() and g.save.data.coins==coins,"arena does not unlock campaign or award campaign coins")
	check(g.save.data.endless.checkpoint,"transition persisted before animation ends")
	await g.advance_endless()
	check(g.endless_wave==2 and not g.ended and g.hp==61,"next opponent preserves health")
	check(g.energy==[2,3,4,1] and g.shield==10 and g.boost_used,"energy shield and consumed boost persist")
	check(g.word_count==0 and g.endless_words==1,"wave stats move into run total")
	# Exercise the real animation completion path, not just the transition helper.
	g.finish(true); g.result_delay=.01; g._process(.02)
	check(g.endless_wave==3 and not g.ended,"victory animation automatically advances ordinary wave")
	g.persist_battle(); var saved: Dictionary=g.save.data.endless.duplicate(true)
	g.change_screen("home"); await g.restore_battle(true)
	check(g.overlay=="pause" and g.hp==61 and g.endless_score==saved.score,"resume restores active run paused")
	check(g.save.data.battle==campaign,"resume keeps campaign snapshot intact")
	# Victory checkpoint survives disk serialization and never grants the score twice.
	g.endless_wave=5; g.mission=g.Endless.opponent(5); g.ended=false; g.finish(true)
	var boss_score: int=g.endless_score
	g.save.load_game(); g.change_screen("home"); await g.restore_battle(true)
	check(g.ended and g.won and g.overlay=="endless_boss","boss checkpoint survives reload")
	check(g.endless_score==boss_score,"restore does not repeat boss reward")
	g.back(); check(g.screen=="home" and not g.save.data.endless.is_empty(),"Back from boss preserves checkpoint")
	await g.restore_battle(true)
	g.dispatch("endless_power",2); await g.advance_endless()
	check(g.endless_wave==6 and not g.boost_used and g.save.data.selected_power==2,"boss allows new power with one fresh use")
	g.power_up(); check(g.boost_used and g.surge,"existing overcharge works in arena")
	g.hp=0; g.finish(false)
	check(g.endless_continue_pending and g.save.data.endless_outbox.is_empty(),"defeat waits for continue decision without score draft")
	g.finalize_endless()
	check(g.save.data.endless.is_empty(),"defeat clears only run")
	check(not g.endless_record().is_empty(),"record stored for run category")
	check(g.save.data.battle==JSON.parse_string(JSON.stringify(campaign)),"campaign remains after arena defeat and JSON reload")
	g.change_screen("home"); await g.restore_battle()
	check(not g.endless_mode and g.hp==83,"campaign can resume independently")
	g.save.data.endless={"wave":-3}; await g.restore_battle(true)
	check(g.save.data.endless.is_empty() and not g.save.data.battle.is_empty(),"invalid arena snapshot rejected without campaign loss")
	print("ENDLESS FAILURES: ",failures)
	g.queue_free(); await process_frame; await create_timer(.2).timeout; quit(1 if failures else 0)
