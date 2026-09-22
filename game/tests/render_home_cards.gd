extends SceneTree
var g
var directory := "res://../.local/home-cards-qa"
func _initialize() -> void: call_deferred("run")
func shot(label: String) -> void:
	g.queue_redraw(); g.get_node("Backdrop").queue_redraw(); g.update_actors()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory+"/"+label+".png")
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): directory=arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/home-cards-render.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.tutorial=true
	for lang in ["sr","en"]:
		g.save.data.ui_language=lang
		for continued in [false,true]:
			g.save.data.battle={"preview":true} if continued else {}
			g.save.data.endless={"preview":true} if continued else {}
			g.change_screen("home"); await shot("home-"+lang+"-"+str(continued))
		g.pressed_action="arsenal"; await shot("pressed-"+lang); g.pressed_action=""
	g.queue_free(); await process_frame; await create_timer(.5).timeout; quit()
