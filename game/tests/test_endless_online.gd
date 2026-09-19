extends SceneTree
var g
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/endless-online-test.json"; root.add_child(g)
	while g.loading: await process_frame
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.ui_language="sr"
	g.daily_screen.service.session_path="res://../.local/endless-online-session.json"
	g.daily_screen.service.session={}
	g.daily_screen.profile_path="res://../.local/endless-online-profile.json"
	var board=load("res://scripts/endless_board.gd").new(); board.host=g; g.add_child(board)
	while board.busy: await process_frame
	assert(not board.empty.text.contains("Nema veze"))
	assert(board.status.text=="TOP 10 · SVE PARTIJE")
	print("PASS: live authenticated leaderboard loaded")
	for category in ["endless","daily"]:
		var sr: Dictionary=await g.rankings.leaderboard(category,"sr",true)
		var en: Dictionary=await g.rankings.leaderboard(category,"en",true)
		assert(not sr.has("error") and not en.has("error") and sr==en)
		print("PASS: live ",category," ranking combines both languages")
	var response: Dictionary=await g.rankings.call_rank_api("endless_finish",{"p_run":"10000000-0000-0000-0000-000000000099","p_language":"sr","p_adjacent":true,"p_nickname":"QA provera","p_score":-1,"p_wave":1,"p_words":1,"p_seconds":1})
	assert(response.has("error")); print("PASS: live invalid score rejected")
	board.mode="daily"; board.rebuild(); await board.refresh(); assert(not board.empty.text.contains("Nema veze")); print("PASS: live daily leaderboard loaded")
	board.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../.local/endless-online-board.png")
	board.leave(); await process_frame; assert(not g.endless_board_open)
	print("PASS: closing leaderboard restores game input")
	await g.start_endless(); g.endless_score=123; g.word_count=3; g.duration=12; g.finish(false)
	assert(g.save.data.endless_outbox.size()==1)
	var reloaded=load("res://scripts/save_data.gd").new(); reloaded.path=g.save.path; reloaded.load_game()
	assert(reloaded.data.endless_outbox[0].score==123)
	print("PASS: pending result survives reload")
	g.queue_free(); await process_frame; quit()
