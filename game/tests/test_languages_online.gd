extends SceneTree
## Isolated anonymous session; creates unfinished daily attempts only, never publishes QA scores.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/languages-online.json"; root.add_child(g)
	while g.loading: await process_frame
	var service=g.daily_screen.service
	service.session_path="res://../.local/languages-online-session.json"; service.session={}
	var failed:=false
	var reference: Dictionary=await g.rankings.leaderboard("daily","en",true)
	for code in ["de","fr","es","it"]:
		var board: Dictionary=await g.rankings.leaderboard("daily",code,true)
		if board.has("error") or board!=reference: push_error("FAIL shared daily ranking "+code); failed=true
		else: print("PASS live shared daily ranking "+code)
		var started: Dictionary=await service.call_api("start",{"language":code,"adjacent":true,"nickname":"QA languages"})
		if started.has("error") or not started.has("seed"): push_error("FAIL live dictionary/start "+code+": "+str(started.get("error","missing seed"))); failed=true
		else: print("PASS live verified dictionary and daily start "+code)
		var endless: Dictionary=await g.rankings.leaderboard("endless",code,true)
		if endless.has("error"): failed=true; push_error("FAIL live endless ranking "+code)
		else: print("PASS live endless ranking "+code)
	g.queue_free(); await process_frame; quit(1 if failed else 0)
