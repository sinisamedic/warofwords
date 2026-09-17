extends SceneTree
var game
func _initialize() -> void: call_deferred("run")
func shot(label: String) -> void:
	game.queue_redraw()
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../.local/tactics-qa/"+label+".png")
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../.local/tactics-qa"))
	game=load("res://main.tscn").instantiate(); root.add_child(game)
	while game.loading: await process_frame
	game.set_process(false)
	game.save.path="res://../.local/tactics-render-save.json"
	game.save.data=game.save.defaults(); game.save.data.unlocked=11; game.save.data.tutorial=true
	game.sfx.enabled=false; game.music.set_enabled(false)
	for language in ["en","sr"]:
		game.save.data.ui_language=language
		game.mission=3; await game.start_battle()
		game.hp=0; game.foe_hp=38; game.word_count=13; game.best_word="EXTRAORDINARY"; game.duration=97
		game.finish(false); game.result_delay=0; game.overlay="result"; game.update_actors()
		await shot("defeat-"+language)
		game.save.data.wins={"3":3}; game.save.data.weapon="breach"
		game.change_screen("arsenal"); await shot("arsenal-"+language)
		game.mission=6; await game.start_battle(); game.update_actors()
		await shot("armor-"+language)
		game.change_screen("campaign"); await shot("campaign-"+language)
		game.save.data.wins={}; game.mission=3; await game.start_battle(); game.finish(true)
		game.result_delay=0; game.overlay="result"; game.update_actors()
		await shot("unlock-"+language)
	game.queue_free(); await process_frame; quit()
