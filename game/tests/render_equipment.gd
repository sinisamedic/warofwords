extends SceneTree
var g
var directory: String
func _initialize() -> void: call_deferred("run")
func shot(name: String) -> void:
	g.update_actors(); g.queue_redraw(); g.get_node("Backdrop").queue_redraw()
	await process_frame; await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory+"/"+name+".png")
func run() -> void:
	directory=ProjectSettings.globalize_path("res://../.local/equipment-qa-"+str(root.size.x))
	DirAccess.make_dir_recursive_absolute(directory)
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/equipment-visual-save.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=11
	g.change_screen("arsenal"); g.arsenal_slot=1; g.arsenal_choice=1
	await shot("locked-en")
	for n in 12: g.save.data.wins[str(n)]=3
	g.save.data.lexicon_earned=true
	for language in ["en","sr"]:
		g.save.data.ui_language=language
		for n in 5:
			g.arsenal_slot=n; g.arsenal_choice=1; g.change_screen("arsenal")
			await shot("arsenal-%s-%d" % [language,n])
	g.save.data.loadout=["breach","mirror","seal","bloom"]; g.save.data.artifact="reserve"
	g.change_screen("powers"); await shot("preparation-sr")
	g.mission=5; await g.start_battle(); g.energy.assign([4,6,5,5]); g.reserves.assign([2,1,2,1]); g.seal_time=18
	g.shield=14; g.shield_kind="mirror"; g.bloom_ticks=4; g.bloom_time=2; g.bloom_amount=6
	g.hp=50; g.clock=2; await shot("battle-sr")
	g.change_screen("upgrades"); g.selected=3; await shot("upgrade-sr")
	g.queue_free(); await process_frame; await create_timer(.5).timeout; quit()
