extends SceneTree
var g
class PreviewAd extends Node:
	signal phase(value: String)
	signal reward
	signal closed
	signal failed
	func begin(_test,_id): pass
	func stop(): pass
func _initialize(): call_deferred("run")
func run():
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://../.local/admob/render"))
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/admob/render-save.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.save.data=g.save.defaults(); g.save.data.tutorial=true
	g.save.data.music=false; g.save.data.sound=false; g.music.set_enabled(false); g.sfx.enabled=false
	g.rewarded.backend_factory=func(): return PreviewAd.new()
	await g.start_endless(); g.endless_score=5432; g.endless_continues=1; g.hp=0; g.finish(false); g.result_delay=0; g.show_endless_defeat()
	for lang in ["sr","en","de","fr","es","it"]:
		g.save.data.ui_language=lang; g.queue_redraw(); g.get_node("Backdrop").queue_redraw(); g.update_actors()
		await process_frame; await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../.local/admob/render/continue-"+lang+".png")
	g.queue_free(); await process_frame; quit()
