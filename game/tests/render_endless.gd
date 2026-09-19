extends SceneTree
var g
var directory := "res://../.local/endless-qa"
func _initialize() -> void: call_deferred("run")
func shot(label: String) -> void:
	g.queue_redraw(); g.get_node("Backdrop").queue_redraw(); g.update_actors()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory+"/"+label+".png")
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): directory=arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/endless-render.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=23
	g.save.data.loadout=["ember","bastion","seal","siphon"]
	for i in 24: g.save.data.wins[str(i)]=3
	for lang in ["sr","en"]:
		g.save.data.ui_language=lang; g.save.data.word_language=lang
		g.change_screen("home"); g.clock=1; await shot("home-"+lang)
		g.clock=3; await shot("home-motion-"+lang)
		g.save.data.calm=true; g.clock=1; await shot("home-calm-1-"+lang)
		g.clock=3; await shot("home-calm-2-"+lang); g.save.data.calm=false
		g.change_screen("endless_prepare"); await shot("prepare-"+lang)
		await g.start_endless()
		g.endless_wave=4; g.mission=g.Endless.opponent(4); g.hp=76; g.endless_score=2840
		await shot("battle-"+lang)
		g.endless_wave=5; g.finish(true); g.result_delay=0; g.overlay="endless_boss"
		await shot("boss-"+lang)
		g.change_screen("records"); await shot("records-"+lang)
		g.change_screen("settings"); await shot("settings-"+lang)
	g.queue_free(); await process_frame; await create_timer(.3).timeout; quit()
