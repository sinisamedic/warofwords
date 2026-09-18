extends SceneTree

var game
var directory: String

func _initialize() -> void: call_deferred("run")

func shot(label: String) -> void:
	game.update_actors(); game.queue_redraw(); game.get_node("Backdrop").queue_redraw()
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory+"/"+label+".png")

func run() -> void:
	directory=ProjectSettings.globalize_path("res://../.local/campaign-polish-%dx%d" % [root.size.x,root.size.y])
	DirAccess.make_dir_recursive_absolute(directory)
	game=load("res://main.tscn").instantiate()
	game.save.path="res://../.local/campaign-polish-render.json"
	root.add_child(game)
	while game.loading: await process_frame
	game.set_process(false); game.sfx.enabled=false; game.music.set_enabled(false)
	game.save.data=game.save.defaults(); game.save.data.tutorial=true; game.save.data.unlocked=11
	game.clock=2
	for language in ["sr","en"]:
		game.save.data.ui_language=language
		for level in [0,2,3,5,7,9]:
			game.save.data.wins={}; game.mission=level
			game.change_screen("campaign"); await shot("%s-campaign-%02d-reward" % [language,level+1])
			if level==0: continue
			game.save.data.wins[str(level)]=3
			await shot("%s-campaign-%02d-earned" % [language,level+1])
		game.change_screen("powers")
		for i in 3:
			game.save.data.selected_power=i
			await shot("%s-power-%d" % [language,i])
		game.save.data.calm=true; await shot("%s-power-calm" % language); game.save.data.calm=false
		for level in [0,3,11]:
			game.mission=level
			await game.start_battle()
			game.ended=true; game.won=true; game.result_delay=0; game.overlay="result"
			game.stars=3; game.reward=180; game.word_count=12; game.duration=124
			game.best_word="POBEDNIK" if language=="sr" else "TRIUMPH"
			game.new_equipment.clear()
			await shot("%s-victory-%02d" % [language,level+1])
	game.queue_free(); await process_frame; await create_timer(.5).timeout
	print("CAMPAIGN POLISH VISUAL QA COMPLETE"); quit()
