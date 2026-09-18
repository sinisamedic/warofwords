extends SceneTree
var g
var directory: String

class TransparencyCheck extends Control:
	func _draw() -> void:
		var art=load("res://assets/art/equipment-breach.png")
		draw_rect(Rect2(Vector2.ZERO,size),Color.WHITE)
		draw_rect(Rect2(size.x/2,0,size.x/2,size.y),Color("0d263b"))
		var edge := minf(size.y-30,size.x/2-30)
		for n in 2:
			draw_texture_rect(art,Rect2(Vector2(size.x*(.25+.5*n)-edge/2,(size.y-edge)/2),Vector2.ONE*edge),false)

func _initialize() -> void: call_deferred("run")
func shot(label: String) -> void:
	g.update_actors(); g.queue_redraw(); g.get_node("Backdrop").queue_redraw()
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory+"/"+label+".png")

func run() -> void:
	directory=ProjectSettings.globalize_path("res://../.local/unlocks-qa-%dx%d" % [root.size.x,root.size.y])
	DirAccess.make_dir_recursive_absolute(directory)
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/unlocks-visual-save.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=11
	for language in ["en","sr"]:
		g.save.data.ui_language=language
		for mission in ([3] if language=="en" else [2,3,5,7,9]):
			g.mission=mission; g.change_screen("campaign"); await shot("campaign-%s-%d" % [language,mission+1])
		g.save.data.wins={"3":3}; g.mission=3; g.change_screen("campaign"); await shot("owned-"+language)
		g.save.data.wins={}; g.change_screen("home")
		for id in ["breach","lexicon","reserve"]:
			g.save.data.pending_unlocks=[id,"mirror"]
			g.show_pending_unlock(); await shot("unlock-%s-%s" % [language,id])
	g.save.data.pending_unlocks=[]; g.overlay=""
	var inspection := TransparencyCheck.new(); inspection.size=g.size; g.add_child(inspection)
	await shot("transparency-white-navy")
	inspection.queue_free(); g.queue_free(); await process_frame; await create_timer(.5).timeout
	print("UNLOCK VISUAL QA COMPLETE"); quit()
