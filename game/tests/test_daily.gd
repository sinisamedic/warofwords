extends SceneTree
const Rules=preload("res://scripts/daily_rules.gd")
const Lexicon=preload("res://scripts/lexicon.gd")
var failures := 0
func check(ok: bool, label: String) -> void:
	if not ok: failures+=1; push_error("FAIL: "+label)
	else: print("PASS: "+label)
func _initialize() -> void:
	call_deferred("run_tests")
func run_tests() -> void:
	var fixtures: Array=[]
	for language in ["en","sr"]:
		var lex=Lexicon.new(true,language)
		for adjacent in [true,false]:
			var a=Rules.new(); var b=Rules.new()
			a.begin(123456,language,adjacent); b.begin(123456,language,adjacent)
			check(a.letters==b.letters,"repeatable board "+language+str(adjacent))
			var fixture={"seed":123456,"language":language,"adjacent":adjacent,"initial":a.letters.duplicate(),"steps":[]}
			for n in 10:
				lex.letters=a.letters.duplicate(); lex.adjacent_only=adjacent; lex.find_words(a.used)
				check(not lex.solutions.is_empty(),"playable refill "+str(n))
				if lex.solutions.is_empty(): break
				var word: String=lex.solutions.keys()[0]
				var path: Array=lex.solutions[word]
				var before: Array=a.letters.duplicate()
				check(a.accept(path,n*1000,lex),"valid move accepted")
				var surviving := 0
				for cell in a.last_refill_route:
					if cell not in path: surviving+=1
				check(a.last_refill_route.is_empty() or surviving>=2,"planted word crosses at least two surviving tiles")
				check(a.refill_nodes<=4000,"daily refill work is bounded")
				check(b.accept(path,n*1000,lex) and a.letters==b.letters and a.score==b.score,"deterministic replay")
				for i in 28:
					if i not in path: check(before[i]==a.letters[i],"unused tile retained")
				fixture.steps.append({"path":path,"ms":n*1000,"letters":a.letters.duplicate(),"score":a.score})
			var score_before: int=a.score
			check(not a.accept([0,0,1],20000,lex),"duplicate tile rejected")
			check(not a.accept([-1,1,2],20000,lex),"out of bounds rejected")
			check(not a.accept([0,1,2],120000,lex),"deadline enforced")
			check(not a.accept([0,1,2],-1,lex),"negative timestamp rejected")
			check(a.score==score_before,"invalid moves do not change score")
			fixtures.append(fixture)
	var file=FileAccess.open("res://../.local/daily-fixtures.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(fixtures)); file.close()
	var game=load("res://main.tscn").instantiate(); root.add_child(game)
	while game.loading: await process_frame
	game.music.set_enabled(false); game.sfx.enabled=false
	game.save.path="res://../.local/daily-campaign-test.json"
	game.save.data=game.save.defaults(); game.save.data.tutorial=true
	game.start_battle()
	var original=game.save.data.duplicate(true)
	var original_board: Array=game.lex.letters.duplicate()
	# This suite tests offline practice/input; automatic online refresh has its own mocked suite.
	game.daily_screen.service.config={}
	game.dispatch("daily")
	var daily=game.daily_screen
	check(Input.emulate_mouse_from_touch,"native daily controls support Android touch")
	await process_frame
	var language_button: Button
	for control in daily.ui.get_children():
		if control is Button and control.text=="EN": language_button=control
	var gui_touch := InputEventScreenTouch.new()
	gui_touch.index=0; gui_touch.position=root.get_final_transform()*language_button.get_global_transform_with_canvas()*(language_button.size/2); gui_touch.pressed=true
	Input.parse_input_event(gui_touch); await process_frame
	gui_touch=gui_touch.duplicate(); gui_touch.pressed=false
	Input.parse_input_event(gui_touch); await process_frame
	check(daily.language=="sr","native language button responds to actual touch pipeline")
	daily.profile_path="res://../.local/daily-test-profile.json"
	daily.pending_path="res://../.local/daily-test-pending.json"
	daily.language="sr"
	await daily.start_practice()
	check(game.daily_screen==daily,"dictionary load preserves daily screen")
	check(game.save.data==original,"daily does not mutate campaign save")
	check(game.lex.letters==original_board,"daily preserves campaign board")
	check(daily.rules.letters.size()==28 and daily.mode=="running","practice starts")
	daily.lex.letters=daily.rules.letters.duplicate(); daily.lex.adjacent_only=daily.adjacent; daily.lex.find_words()
	var solution: Array=daily.lex.solutions.values()[0]
	for cell in solution:
		var touch := InputEventScreenTouch.new()
		touch.index=0; touch.position=root.get_final_transform()*daily.get_global_transform_with_canvas()*daily.tile_rect(cell).get_center(); touch.pressed=true
		Input.parse_input_event(touch); await process_frame
		touch=touch.duplicate(); touch.pressed=false; Input.parse_input_event(touch); await process_frame
	check(daily.selection==solution,"touch input composes a real word")
	# Exercise the real sound preference and voice dispatch, not a mirrored stub.
	daily.selection.clear(); game.sfx.enabled=true
	var cursor_before: int=game.sfx.cursor
	daily.add_cell(solution[0]); daily.add_cell(solution[0]); daily.add_cell(-1)
	check(game.sfx.cursor==cursor_before+1,"one sound for a newly selected tile, none for duplicate or invalid cells")
	game.sfx.enabled=false; daily.add_cell(solution[1])
	check(game.sfx.cursor==cursor_before+1,"muted daily selection stays silent")
	daily.selection.assign(solution)
	var submit_button: Button
	for control in daily.ui.get_children():
		if control is Button and control.text=="SUBMIT": submit_button=control
	gui_touch=InputEventScreenTouch.new()
	gui_touch.index=0; gui_touch.position=root.get_final_transform()*submit_button.get_global_transform_with_canvas()*(submit_button.size/2); gui_touch.pressed=true
	Input.parse_input_event(gui_touch); await process_frame
	gui_touch=gui_touch.duplicate(); gui_touch.pressed=false; Input.parse_input_event(gui_touch); await process_frame
	check(daily.rules.score>0 and daily.selection.is_empty(),"touch word scores and clears selection")
	daily.leave()
	check(daily.mode=="confirm_leave","leaving asks before ending active play")
	daily.deadline=Time.get_ticks_msec()-1; daily._process(0)
	check(daily.mode=="result" and not daily.ranked,"practice finishes without upload")
	check(game.save.data==original,"practice result leaves campaign untouched")
	daily.close_screen()
	check(not Input.emulate_mouse_from_touch,"campaign touch handling restored after daily")
	game.queue_free(); await process_frame; await create_timer(.2).timeout
	print("DAILY RESULT: %d failures" % failures)
	quit(1 if failures else 0)
