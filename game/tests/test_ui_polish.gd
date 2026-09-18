extends SceneTree
class FakeService extends Node:
	var calls := 0
	var enabled := true
	var fail := false
	var payload: Dictionary = {}
	func configured() -> bool: return enabled
	func call_api(_action: String, data: Dictionary) -> Dictionary:
		calls+=1; payload=data.duplicate()
		await get_tree().process_frame
		return {"error":"Offline"} if fail else {"rows":[{"nickname":"Test","score":123,"position":1,"is_me":false}],"total":1,"day":"2026-09-18"}
var g
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if ok: print("PASS: "+label)
	else: failures+=1; push_error(label)
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/ui-polish-test.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=23
	for mission in [2,3,5,7,9,12,14,16,19]:
		g.mission=mission; g.change_screen("campaign")
		var before: String=JSON.stringify(g.save.data)
		g.dispatch("reward_info")
		check(g.overlay=="reward_info","reward details open on level %d" % (mission+1))
		g.back()
		check(g.overlay.is_empty() and g.screen=="campaign","back returns to map")
		check(JSON.stringify(g.save.data)==before,"viewing reward does not grant or equip it")
	g.mission=0; g.dispatch("reward_info"); check(g.overlay.is_empty(),"no reward dialog on ordinary level")
	var daily=g.daily_screen
	daily.service.queue_free(); var fake=FakeService.new(); daily.add_child(fake); daily.service=fake
	await daily.open()
	check(fake.calls==1 and daily.leaderboard.get("total",0)==1,"opening daily fetches results automatically")
	daily.close_screen(); await daily.open()
	check(fake.calls==2,"reopening fetches fresh results")
	await daily.toggle_language(); check(fake.calls==3 and fake.payload.language==daily.language,"language change refreshes correct category")
	await daily.toggle_rule(); check(fake.calls==4 and fake.payload.adjacent==daily.adjacent,"rule change refreshes correct category")
	fake.fail=true; await daily.refresh_leaderboard()
	check(not daily.requesting and not daily.status.is_empty(),"failed refresh restores controls and shows error")
	fake.enabled=false; var count=fake.calls; daily.close_screen(); await daily.open()
	check(fake.calls==count and not daily.requesting,"offline configuration does not request results")
	daily.close_screen(); g.queue_free(); await process_frame; await create_timer(.5).timeout
	print("UI POLISH RESULT: %d failures" % failures); quit(1 if failures else 0)
