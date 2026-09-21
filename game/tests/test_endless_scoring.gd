extends SceneTree
var g
var failures := 0
func check(ok: bool, label: String) -> void:
	if not ok: failures+=1; push_error("FAIL: "+label)
	else: print("PASS: "+label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	create_timer(60).timeout.connect(func(): quit(2))
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/test-endless-scoring.json"; root.add_child(g)
	while g.loading: await process_frame
	if is_instance_valid(g.age_screen): g.age_screen.kind="info"; g.age_screen.leave()
	await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.age_group="adult"; g.save.data.tutorial=true
	await g.start_endless(); g.foe_max=5000; g.foe_hp=5000; g.foe_guard=false
	g.endless_score=0
	g.lex.letters.assign(Array("STONESTREAMLINEPLANETCARDSEN".split("")))
	g.path.assign([0,1,2,3,4]); g.submit_word()
	check(g.endless_score==65,"accepted five-letter word scores before impact")
	g.advance_combat(.5)
	check(g.endless_score==79,"word impact scores actual seven damage once")
	g.advance_combat(.5); check(g.endless_score==79,"resolved shot does not score again")
	g.endless_score=0; g.burn_amount=6; g.burn_ticks=3; g.burn_time=2
	g.advance_equipment(6)
	check(g.endless_score==36,"all three burn ticks count actual damage")
	g.endless_score=0; g.shield=30; g.shield_kind="aegis"
	g.launch_attack(false,"enemy",Color.RED,20); g.advance_combat(.5)
	check(g.endless_score==20 and g.hp==100,"only absorbed damage scores for shield")
	g.endless_score=0; g.hp=95; g.heal_player(40)
	check(g.hp==100 and g.endless_score==5,"healing counts only restored HP")
	g.heal_player(40); check(g.endless_score==5,"full-health healing gives no points")
	g.endless_score=0; g.energy[0]=g.ability_cost(0); g.fire(0)
	check(g.endless_score==10,"valid charged ability scores activation")
	g.fire(0); check(g.endless_score==10,"empty ability cannot farm activation points")
	g.fx.clear(); g.endless_score=0; g.foe_hp=3; g.foe_guard=false
	g.launch_attack(true,"pulse",Color.GOLD,100); g.advance_combat(.5)
	check(g.endless_score==106,"overkill counts remaining HP plus victory bonus")
	check(not g.music.fanfare.playing,"victory music respects music off")
	g.advance_combat(2); check(g.endless_score==106,"victory cannot score twice")
	g.music.backgrounded=false; g.music.set_enabled(true); g.music.victory()
	check(g.music.fanfare.playing,"victory starts musical phrase")
	g.music.set_enabled(false); check(not g.music.fanfare.playing,"music toggle stops victory phrase")
	g.endless_mode=false; g.ended=false; g.hp=90; var before: int=g.endless_score
	g.heal_player(5); g.add_endless_score(100)
	check(g.hp==95 and g.endless_score==before,"campaign healing never changes arena score")
	print("SCORING RESULT: ",failures," failures")
	g.queue_free(); await process_frame; await create_timer(.2).timeout; quit(1 if failures else 0)
