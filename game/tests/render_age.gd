extends SceneTree
var g
func _initialize(): call_deferred("run")
func run():
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../.local/age-render"))
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/age-render/save.json"; root.add_child(g)
	while g.loading: await process_frame
	g.music.set_enabled(false); g.sfx.enabled=false; g.save.data.calm=true
	if not is_instance_valid(g.age_screen): g.open_age_screen("age")
	for lang in ["sr","en","de","fr","es","it"]:
		g.save.data.ui_language=lang
		for kind in ["age","info","records"]:
			g.save.data.age_group="under13"; g.age_screen.kind=kind; g.age_screen.rebuild()
			await process_frame; await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png("res://../.local/age-render/"+kind+"-"+lang+".png")
	g.age_screen.leave(); await process_frame
	g.save.data.ui_language="sr"; g.change_screen("daily"); g.daily_screen.open()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../.local/age-render/practice-sr.png")
	g.queue_free(); await process_frame; await process_frame; quit()
