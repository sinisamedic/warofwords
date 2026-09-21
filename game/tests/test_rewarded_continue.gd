extends SceneTree
var g
var failures := 0
class FakeAd extends Node:
	signal phase(value: String)
	signal reward
	signal closed
	signal failed
	func begin(_test, _id): phase.emit("loading")
	func stop(): pass
func _initialize(): call_deferred("run")
func check(ok: bool, label: String):
	if not ok: failures+=1; push_error("FAIL: "+label)
	else: print("PASS: "+label)
func run():
	create_timer(90).timeout.connect(func(): push_error("Rewarded test timeout"); quit(2))
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false
	g.save.path="res://../.local/test-rewarded.json"; root.add_child(g)
	while g.loading: await process_frame
	if is_instance_valid(g.age_screen): g.age_screen.kind="info"; g.age_screen.leave()
	await process_frame
	g.set_process(false); g.save.data=g.save.defaults(); g.save.data.age_group="adult"; g.save.data.tutorial=true; g.save.data.age_group="adult"
	g.save.data.sound=false; g.save.data.music=false
	g.rewarded.backend_factory=func(): return FakeAd.new()
	await g.start_battle(); g.hp=73; g.persist_battle()
	var campaign=g.save.data.battle.duplicate(true)
	await g.start_endless(); g.endless_score=321; g.foe_hp=47
	for attempt in 3:
		g.hp=0; g.finish(false)
		check(g.endless_continue_pending and g.save.data.endless_outbox.is_empty(),"no draft before continue %d" % attempt)
		g.save.load_game(); await g.restore_battle(true)
		check(g.ended and g.hp==0 and g.overlay=="endless_continue" and g.endless_continues==attempt,"pending defeat restores safely")
		g.rewarded.request(); var fake=g.rewarded.backend; var token=g.rewarded.token
		g.rewarded.request(); check(g.rewarded.backend==fake,"double tap does not start another ad")
		fake.phase.emit("showing"); fake.closed.emit()
		check(g.hp==0 and g.endless_continues==attempt,"dismiss without reward cannot revive")
		g.rewarded.request(); fake=g.rewarded.backend
		fake.failed.emit()
		check(g.endless_continues==attempt and g.ended,"load/show failure consumes nothing")
		g.rewarded.request(); fake=g.rewarded.backend
		g.rewarded._process(31)
		check(not g.rewarded.busy() and g.ended,"load timeout returns control")
		g.rewarded._reward(token); g.rewarded._closed(token)
		check(g.ended,"late callback ignored")
		g.rewarded.request(); fake=g.rewarded.backend; fake.phase.emit("showing")
		fake.reward.emit(); fake.reward.emit()
		check(g.ended,"reward waits for ad dismissal")
		fake.closed.emit(); fake.closed.emit()
		check(g.hp==100 and not g.ended and g.endless_continues==attempt+1,"one revive per earned reward")
		check(g.endless_score==321 and g.foe_hp==47 and g.overlay=="pause","score opponent and paused return preserved")
		check(g.save.data.endless_outbox.is_empty(),"continued run has no provisional score")
		g.save.load_game(); await g.restore_battle(true)
		check(g.endless_continues==attempt+1 and g.hp==100,"continue budget survives save reload")
		g.overlay=""
	g.hp=0; g.finish(false); g.finalize_endless()
	check(g.endless_finalized and g.save.data.endless.is_empty(),"fourth defeat finalizes run")
	check(g.save.data.endless_outbox.size()==1 and g.save.data.endless_outbox[0].score==321,"one final draft with accumulated score")
	check(g.save.data.battle==JSON.parse_string(JSON.stringify(campaign)),"campaign untouched")
	await g.start_endless(); g.endless_score=789; g.hp=0; g.finish(false)
	g.rewarded.request(); var stale=g.rewarded.token; g.rewarded.cancel(); g.finalize_endless()
	g.rewarded._reward(stale); g.rewarded._closed(stale)
	check(g.ended and g.endless_finalized and g.save.data.endless_outbox.size()==2,"decline cancels late reward and creates exactly one final draft")
	var invalid={"mode":"endless","wave":1,"mission":g.Endless.opponent(1),"score":0,"run_words":0,"run_seconds":0,"continues":4}
	check(not g.Endless.valid_meta(invalid),"invalid saved continue count rejected")
	check(g.rewarded.TEST_ADS,"development uses test ads")
	print("REWARDED FAILURES: ",failures)
	g.queue_free(); await process_frame; await create_timer(.2).timeout; quit(1 if failures else 0)
