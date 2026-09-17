extends SceneTree
func _initialize() -> void: call_deferred("run")
func shot(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../.local/daily-qa/"+name+".png")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../.local/daily-qa"))
	var game=load("res://main.tscn").instantiate(); root.add_child(game)
	while game.loading: await process_frame
	game.save.path="res://../.local/daily-render-save.json"
	game.save.data=game.save.defaults(); game.save.data.ui_language="sr"
	game.sfx.enabled=false; game.music.set_enabled(false)
	await shot("home")
	game.dispatch("daily")
	var daily=game.daily_screen
	daily.nickname.text="Istraživač"
	daily.rebuild()
	await shot("lobby")
	if FileAccess.file_exists("res://../.local/daily-live-leaderboard.json"):
		daily.leaderboard=JSON.parse_string(FileAccess.get_file_as_string("res://../.local/daily-live-leaderboard.json"))
		for row in daily.leaderboard.get("rows",[]):
			if row.get("own",false): daily.nickname.text=str(row.nickname)
		await shot("live-leaderboard-snapshot")
	await daily.start_practice()
	await shot("practice")
	daily.lex.letters=daily.rules.letters.duplicate(); daily.lex.find_words()
	daily.selection.assign(daily.lex.solutions.values()[0])
	await shot("selection")
	daily.submit_word()
	daily.deadline=Time.get_ticks_msec()-1; daily._process(0)
	await shot("result")
	game.queue_free(); await process_frame; await create_timer(.2).timeout; quit()
