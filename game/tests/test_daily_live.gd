extends SceneTree
## Opt-in live smoke test. Creates a guest profile and a clearly named QA result.
var failures := 0
func check(ok: bool, label: String) -> void:
	if ok: print("PASS: "+label)
	else: failures+=1; push_error("FAIL: "+label)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	if "--live-daily" not in OS.get_cmdline_user_args():
		push_error("Pass -- --live-daily to create a real QA profile/result."); quit(1); return
	var game=load("res://main.tscn").instantiate(); root.add_child(game)
	while game.loading: await process_frame
	game.music.set_enabled(false); game.sfx.enabled=false
	game.save.path="res://../.local/live-daily-campaign.json"
	game.save.data=game.save.defaults(); game.save.data.ui_language="sr"
	game.dispatch("daily")
	var daily=game.daily_screen
	daily.profile_path="res://../.local/live-daily-profile.json"
	daily.pending_path="res://../.local/live-daily-pending.json"
	daily.nickname.text="QA provera"
	await daily.start_ranked()
	check(daily.ranked and daily.mode=="running","Godot authenticates and starts real ranked attempt")
	if daily.mode!="running": print(daily.status); game.queue_free(); quit(1); return
	var original_id: String=daily.attempt.id
	var retry: Dictionary=await daily.service.call_api("start",{"language":"en","adjacent":true,"nickname":"QA provera"})
	check(retry.get("id","")==original_id and retry.get("seed",0)==daily.attempt.seed,"real server start is idempotent")
	for n in 3:
		daily.lex.letters=daily.rules.letters.duplicate(); daily.lex.adjacent_only=true; daily.lex.find_words(daily.rules.used)
		daily.selection.assign(daily.lex.solutions.values()[0]); daily.submit_word()
		await create_timer(.4).timeout
	check(daily.rules.score>0,"real Godot word submission scores")
	var local_score: int=daily.rules.score
	# Verify the second dictionary is available using another category on the same QA identity.
	var serbian: Dictionary=await daily.service.call_api("start",{"language":"sr","adjacent":true,"nickname":"QA provera"})
	var sr_deadline := Time.get_ticks_msec()+int(serbian.get("remaining_ms",0))+1500
	check(serbian.has("id"),"server loads the full Serbian dictionary")
	print("LIVE: waiting for the real 120-second server deadline")
	var timeout := Time.get_ticks_msec()+150000
	while (daily.mode=="running" or daily.requesting) and Time.get_ticks_msec()<timeout: await process_frame
	check(daily.attempt.get("verified",false) and daily.rules.score==local_score,"real server verifies and stores Godot result")
	var repeated: Dictionary=await daily.service.call_api("submit",{"id":original_id,"language":"en","adjacent":true,"moves":[],"score":999999})
	check(repeated.get("verified",false) and int(repeated.get("score",-1))==local_score,"live duplicate cannot overwrite verified score")
	await daily.refresh_leaderboard()
	var own := false
	for row in daily.leaderboard.get("rows",[]):
		if row.get("own",false) and int(row.score)==local_score: own=true
	check(own,"global ranking returns verified result and own placement")
	if serbian.has("id"):
		var sr_wait := maxi(0,sr_deadline-Time.get_ticks_msec())
		if sr_wait>0: await create_timer(sr_wait/1000.0+2).timeout
		var sr_result: Dictionary=await daily.service.call_api("submit",{"id":serbian.id,"language":"sr","adjacent":true,"moves":[]})
		check(sr_result.get("verified",false),"Serbian category accepts verified completion")
	daily.mode="lobby"; daily.status=""; daily.rebuild()
	if DisplayServer.get_name()!="headless":
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../.local/daily-qa/live-leaderboard.png")
	game.queue_free(); await process_frame
	print("LIVE DAILY RESULT: %d failures" % failures); quit(1 if failures else 0)
