extends SceneTree
var g
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, what: String) -> void:
	if ok: print("PASS: "+what)
	else: failures+=1; push_error("FAIL: "+what)
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/test-age.json"; g.online_writes_enabled=false
	var seed=load("res://scripts/save_data.gd").new(); seed.path=g.save.path; seed.data=seed.defaults(); seed.save_game()
	root.add_child(g)
	while g.loading: await process_frame
	await process_frame
	check(is_instance_valid(g.age_screen) and g.age_screen.selected==-1,"first launch has no preselected age")
	check(not g.online_allowed() and not g.rewarded.supported(),"unknown age denies online and ads")
	var blocked: Dictionary=await g.daily_screen.service.request_json("/must-not-connect",{})
	check(blocked.has("error") and g.daily_screen.service.get_child_count()==0,"unknown direct HTTP blocked before HTTPRequest")
	g.age_screen.selected=0; g.age_screen.confirm_age()
	check(g.save.data.age_group=="under13" and not g.online_allowed(),"child selection persisted")
	g.age_screen.leave(); await process_frame
	g.save.load_game(); check(g.save.data.age_group=="under13","age survives restart")
	g.change_screen("daily"); g.daily_screen.open()
	await g.daily_screen.start_ranked(); await g.daily_screen.refresh_leaderboard()
	check(not g.daily_screen.ranked and not g.daily_screen.requesting,"child ranked and refresh actions blocked")
	await g.daily_screen.start_practice(); g.daily_screen.rules.score=71; g.daily_screen.finish_run()
	check(g.save.data.practice_records.values().has(71),"practice result kept locally")
	g.daily_screen.close_screen()
	await g.start_endless(); g.endless_score=234; g.hp=0; g.finish(false)
	check(g.endless_finalized and not g.endless_continue_pending,"child defeat ends run without continue")
	check(g.save.data.endless_outbox.is_empty() and g.endless_record().score==234,"child record local and never queued for upload")
	g.rewarded.request(); g.rewarded_finished(true)
	check(g.hp==0 and g.rewarded.backend==null,"direct ad request and forged reward cannot revive child")
	g.open_rankings(true); await process_frame
	check(g.age_screen.kind=="records","child receives local records screen")
	g.age_screen.leave(); await process_frame
	# Restore a previous adult build's defeated pending run as a child.
	g.save.data.age_group="adult"; await g.start_endless(); g.hp=0; g.finish(false)
	check(g.endless_continue_pending,"adult has continue offer")
	g.save.data.age_group="under13"; g.save.save_game(); await g.restore_battle(true)
	check(not g.endless_continue_pending and g.endless_finalized,"legacy pending defeat cannot bypass child rule")
	for group in ["teen","adult"]:
		g.save.data.age_group=group; check(g.online_allowed(),"online permitted "+group)
		check(g.AgePolicy.minor(g.save.data)==(group!="adult"),"conservative ad treatment "+group)
	g.save.data.age_group="invalid"; g.save.save_game(); g.save.load_game()
	check(g.save.data.age_group=="" and not g.online_allowed(),"invalid saved group fails closed")
	var languages=load("res://scripts/languages.gd")
	for locale in ["sr_RS","sr-Latn-RS","de_DE","fr_CA","es_MX","it_IT","en_US"]:
		check(languages.device_language(locale)==locale.left(2),"device locale "+locale)
	check(languages.device_language("ja_JP")=="en","unsupported locale falls back to English")
	for old in ["13_15","16_17","adult"]:
		g.save.data.age_group=old; g.save.data.ui_language="it"; g.save.data.word_language="de"; g.save.save_game(); g.save.load_game()
		check(g.save.data.age_group==("adult" if old=="adult" else "teen") and g.online_allowed(),"legacy age migrates "+old)
		check(g.save.data.ui_language=="it" and g.save.data.word_language=="de","saved languages preserved")
	g.save.data.age_group="13plus"; g.save.save_game(); g.save.load_game()
	check(g.save.data.age_group=="" and not g.online_allowed(),"ambiguous binary preview age requires fresh choice")
	var isolated=load("res://scripts/daily_service.gd").new(); root.add_child(isolated)
	check(not isolated.configured(),"unbound service fails closed")
	isolated.queue_free(); g.queue_free(); await process_frame; await process_frame
	print("AGE FAILURES: ",failures); quit(failures)
