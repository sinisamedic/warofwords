extends SceneTree
var g
var directory := "res://../.local/ui-polish-qa"
func _initialize() -> void: call_deferred("run")
func shot(label: String) -> void:
	g.queue_redraw(); g.get_node("Backdrop").queue_redraw(); g.update_actors()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory+"/"+label+".png")
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): directory=arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/ui-polish-render.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=23
	g.save.data.wins={"2":3,"3":3,"7":2,"12":3,"14":2,"16":2}
	g.save.data.loadout=["ember","bastion","arc","bloom"]
	for lang in ["sr","en"]:
		g.save.data.ui_language=lang
		for mission in [2,9,12,14,16,19]:
			g.mission=mission; g.change_screen("campaign"); await shot("map-%d-" % mission+lang)
			g.dispatch("reward_info"); await shot("reward-%d-" % mission+lang); g.overlay=""
		for slot in [0,1,4]:
			g.change_screen("arsenal"); g.arsenal_slot=slot; g.arsenal_choice=0; await shot("arsenal-%d-" % slot+lang)
	g.queue_free(); await process_frame; await create_timer(.5).timeout; quit()
