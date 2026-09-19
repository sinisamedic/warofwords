extends SceneTree
var g
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/endless-online-test.json"; root.add_child(g)
	while g.loading: await process_frame
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.ui_language="sr"
	g.daily_screen.service.session_path="res://../.local/endless-online-session.json"
	g.daily_screen.service.session={}
	g.daily_screen.profile_path="res://../.local/endless-online-profile.json"
	var board=load("res://scripts/endless_board.gd").new(); board.host=g; g.add_child(board)
	while board.busy: await process_frame
	assert(not board.status.text.contains("nije učitana"))
	assert(board.status.text.contains("igrača"))
	print("PASS: live authenticated leaderboard loaded")
	var response: Dictionary=await board.call_rank_api("endless_submit",{"p_language":"sr","p_adjacent":true,"p_nickname":"QA provera","p_score":-1,"p_wave":1,"p_words":1,"p_seconds":1})
	assert(response.has("error")); print("PASS: live invalid score rejected")
	board.queue_redraw(); await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../.local/endless-online-board.png")
	board.leave(); await process_frame; assert(not g.endless_board_open)
	print("PASS: closing leaderboard restores game input")
	await g.start_endless(); g.endless_score=123; g.word_count=3; g.duration=12; g.finish(false)
	assert(g.save.data.endless_pending.size()==1)
	var reloaded=load("res://scripts/save_data.gd").new(); reloaded.path=g.save.path; reloaded.load_game()
	assert(reloaded.data.endless_pending.values()[0].score==123)
	print("PASS: pending result survives reload")
	g.queue_free(); await process_frame; quit()
