extends SceneTree
var g
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.online_autosubmit=false; g.save.path="res://../.local/rank-test.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.save.data=g.save.defaults(); g.save.data.tutorial=true
	g.daily_screen.profile_path="res://../.local/rank-test-profile.json"; g.daily_screen.local_nickname=""
	g.rankings.queue_free(); var service=load("res://tests/mock_rank_service.gd").new(); service.host=g; g.add_child(service); g.rankings=service; g.online_autosubmit=true
	service.enqueue({"score":1400,"wave":3,"words":14,"seconds":80,"language":"sr","adjacent":true})
	await service.flush(); assert(service.calls.is_empty()); assert(g.save.data.endless_outbox.size()==1)
	assert(not service.remember_nickname("ab")); assert(service.remember_nickname("Čuvar 7"))
	service.offline=true; await service.flush(); assert(g.save.data.endless_outbox.size()==1)
	var saved=load("res://scripts/save_data.gd").new(); saved.path=g.save.path; saved.load_game(); assert(saved.data.endless_outbox[0].id==g.save.data.endless_outbox[0].id)
	var id: String=g.save.data.endless_outbox[0].id
	service.offline=false; await service.flush(); assert(g.save.data.endless_outbox.is_empty()); assert(service.calls.back().payload.p_run==id)
	assert(service.remember_nickname("Novo ime")); await service.rename_player(); assert(service.calls.back().payload.p_nickname=="Novo ime")
	assert(JSON.parse_string(FileAccess.get_file_as_string(g.daily_screen.profile_path)).nickname=="Novo ime")
	service.offline=true; service.remember_nickname("Bez mreze"); await service.rename_player(); assert(g.save.data.endless_name_dirty)
	saved.load_game(); assert(saved.data.endless_name_dirty)
	service.offline=false; await service.flush(); assert(not g.save.data.endless_name_dirty)
	service.rename_player(); service.remember_nickname("Novo ime"); await service.changed; assert(g.save.data.endless_name_dirty)
	await service.flush(); assert(not g.save.data.endless_name_dirty and service.calls.back().payload.p_nickname=="Novo ime")
	print("PASS: offline rename and edits during upload are retried")
	print("PASS: missing name, validation, offline persistence, stable retry ID, remembered edited name")
	await g.start_endless(); g.endless_score=140; g.word_count=3; g.duration=12; g.finish(false)
	assert(g.save.data.endless_outbox.size()==1)
	var count: int=g.save.data.endless_outbox.size(); g.finish(false); assert(g.save.data.endless_outbox.size()==count)
	print("PASS: each completed run queues once")
	g.open_rankings(true); await process_frame; await process_frame
	var board=g.get_children().back(); assert(board.result_mode); assert(board.nickname.text=="Novo ime")
	while service.busy or board.busy: await process_frame
	assert(g.save.data.endless_outbox.is_empty()); assert(board.rows_view.rows.size()==22)
	board.leave(); await process_frame; assert(not g.endless_board_open)
	g.dispatch("records"); await process_frame; board=g.get_children().back()
	while board.busy: await process_frame
	assert(not board.result_mode); board.mode="daily"; board.rebuild(); await board.refresh(); assert(board.rows_view.daily and board.rows_view.rows.size()==22)
	board.refresh(); board.mode="endless"; board.rebuild(); board.refresh()
	while board.busy: await process_frame
	assert(board.cached_category.begins_with("endless") and not board.rows_view.daily)
	print("PASS: rapid category switch keeps the newest response")
	board.leave(); await process_frame
	print("PASS: automatic result upload, embedded list, global records tabs and close")
	await g.start_battle(true); assert(g.lex.joker_enabled and g.lex.letters.count("*")==1)
	g.persist_battle(); assert(g.valid_snapshot(g.save.data.endless))
	var letters: Array=g.lex.letters.duplicate(); await g.restore_battle(true); assert(g.lex.letters==letters and g.lex.joker_enabled)
	print("PASS: Joker saved duel resumes")
	g.queue_free(); await process_frame; quit()
