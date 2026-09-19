extends SceneTree
var g
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/settings-render.json"; root.add_child(g)
	while g.loading: await process_frame
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.daily_screen.local_nickname="Sinisa"
	for code in ["sr","de","fr","es","it","en"]:
		g.save.data.ui_language=code; g.change_screen("settings"); await process_frame
		g.settings_screen.picker="word_language"; g.settings_screen.rebuild()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../.local/settings-"+code+".png")
		g.change_screen("home"); await process_frame
	g.queue_free(); await process_frame; quit()
