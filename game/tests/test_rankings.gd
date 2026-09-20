extends SceneTree
var g
func _initialize() -> void: call_deferred("run")
func touch(control: Control) -> void:
	var event := InputEventScreenTouch.new()
	event.index=0; event.position=root.get_final_transform()*control.get_global_transform_with_canvas()*(control.size/2); event.pressed=true
	Input.parse_input_event(event); await process_frame
	event=event.duplicate(); event.pressed=false; Input.parse_input_event(event); await process_frame
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/rank-test.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.save.data=g.save.defaults(); g.save.data.tutorial=true
	g.daily_screen.profile_path="res://../.local/rank-test-profile.json"; g.daily_screen.local_nickname="Zapamceno ime"
	g.rankings.queue_free(); var service=load("res://tests/mock_rank_service.gd").new(); service.host=g; g.add_child(service); g.rankings=service; g.online_writes_enabled=true
	service.enqueue({"score":1400,"wave":3,"words":14,"seconds":80,"language":"sr","adjacent":true})
	var old_id: String=service.current_run_id
	await g.start_endless(); g.endless_score=140; g.word_count=3; g.duration=12; g.finish(false); g.finalize_endless()
	var run_id: String=service.current_run_id
	g.finish(false); g.finalize_endless(); assert(g.save.data.endless_outbox.size()==2)
	g.open_rankings(true); await process_frame; await process_frame
	var board=g.get_children().back()
	while board.busy: await process_frame
	await process_frame; await process_frame; await process_frame
	assert(board.scroll.scroll_vertical>0 or board.scroll.size.y>=board.rows_view.custom_minimum_size.y)
	assert(service.calls.is_empty() and not board.send_button.disabled and board.nickname.editable)
	assert(board.nickname.text=="Zapamceno ime")
	assert(Input.emulate_mouse_from_touch)
	await touch(board.nickname); assert(board.nickname.has_focus())
	board.nickname.select_all()
	var key := InputEventKey.new(); key.pressed=true; key.unicode=78; key.keycode=KEY_N
	Input.parse_input_event(key); await process_frame
	assert(board.nickname.text=="N")
	board.nickname.insert_text_at_caret("ovo ime"); await process_frame
	board.rebuild(); await process_frame
	assert(board.nickname.text=="Novo ime" and board.nickname.has_focus())
	await create_timer(1.1).timeout
	assert(service.calls.is_empty())
	board.nickname.text_submitted.emit(board.nickname.text); await process_frame
	assert(service.calls.is_empty())
	print("PASS: saved name editable through touch/keyboard; typing, waiting and keyboard Done never upload")
	service.offline=true
	await touch(board.send_button)
	while service.busy: await process_frame
	assert(service.calls.size()==1 and not board.send_button.disabled and board.nickname.editable)
	assert(g.save.data.endless_outbox.size()==2)
	var saved=load("res://scripts/save_data.gd").new(); saved.path=g.save.path; saved.load_game()
	assert(saved.data.endless_outbox[1].id==run_id)
	service.offline=false
	await create_timer(.1).timeout; assert(service.calls.size()==1)
	await touch(board.send_button)
	while service.busy: await process_frame
	assert(service.calls.size()==2 and service.calls[0].payload.p_run==run_id and service.calls[1].payload.p_run==run_id)
	assert(service.calls.back().payload.p_nickname=="Novo ime")
	assert(board.send_button.disabled and service.sent_runs.has(run_id))
	assert(g.save.data.endless_outbox.size()==1 and g.save.data.endless_outbox[0].id==old_id)
	board.send_result(); await process_frame; assert(service.calls.size()==2)
	assert(JSON.parse_string(FileAccess.get_file_as_string(g.daily_screen.profile_path)).nickname=="Novo ime")
	print("PASS: touch Send sends only this lower-scoring run, failure stays editable, explicit retry uses same ID, success disables button")
	board.leave(); await process_frame; assert(not Input.emulate_mouse_from_touch and not g.endless_board_open)
	await g.start_endless(); g.endless_score=1; g.word_count=1; g.duration=5; g.finish(false); g.finalize_endless()
	g.open_rankings(true); await process_frame; await process_frame; board=g.get_children().back()
	assert(not board.send_button.disabled and board.nickname.editable and board.nickname.text=="Novo ime")
	board.nickname.text="Sledece ime"; board.nickname.text_changed.emit(board.nickname.text)
	board.leave(); await process_frame; assert(service.calls.size()==2)
	print("PASS: next lower run starts unsent; leaving without Send saves name locally only")
	g.dispatch("records"); await process_frame; board=g.get_children().back()
	while board.busy: await process_frame
	board.mode="daily"; board.rebuild(); await board.refresh(); assert(board.rows_view.daily)
	board.refresh(); board.mode="endless"; board.rebuild(); board.refresh()
	while board.busy: await process_frame
	assert(board.cached_category.begins_with("endless") and not board.rows_view.daily and service.calls.size()==2)
	board.leave(); await process_frame
	print("PASS: global tabs never upload drafts and preserve latest category")
	await g.start_battle(true); g.persist_battle(); assert(g.valid_snapshot(g.save.data.endless))
	var letters: Array=g.lex.letters.duplicate(); await g.restore_battle(true); assert(g.lex.letters==letters and g.lex.joker_enabled)
	print("PASS: Joker saved duel resumes")
	await process_frame; g.queue_free(); await process_frame; await process_frame; quit()
