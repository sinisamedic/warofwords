extends SceneTree
var g
var directory := "res://../.local/wave-two-qa"
func _initialize() -> void: call_deferred("run")
func shot(label: String) -> void:
	g.queue_redraw(); g.get_node("Backdrop").queue_redraw(); g.update_actors()
	await process_frame; await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(directory+"/"+label+".png")
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): directory=arg.trim_prefix("--out=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
	g=load("res://main.tscn").instantiate(); g.save.path="res://../.local/wave-two-render.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=23; g.save.data.ui_language="sr"
	for i in 24: g.save.data.wins[str(i)]=3
	g.save.data.loadout=["ember","bastion","seal","siphon"]
	for mission in range(12,24):
		g.mission=mission; g.change_screen("campaign"); await shot("map-%02d" % (mission+1))
		await g.start_battle(); await shot("battle-%02d" % (mission+1))
	for language in ["sr","en"]:
		g.save.data.ui_language=language
		for id in ["ember","resonator","bastion","siphon"]:
			g.change_screen("arsenal"); g.arsenal_slot=g.Equipment.slot_of(id); g.arsenal_choice=g.Equipment.SLOTS[g.arsenal_slot].find(id)
			await shot("arsenal-"+id+"-"+language)
		g.mission=23; await g.start_battle(); g.enemy_attacks=1; g.shield=24; g.shield_kind="bastion"; g.bastion_hits=2
		g.burn_ticks=3; g.burn_amount=6; g.burn_time=2; g.seal_time=20; g.hp=56
		await shot("statuses-"+language)
		g.foe_hp=0; g.finish(true); g.result_delay=0; g.overlay="result"; await shot("final-"+language)
	g.queue_free(); await process_frame; await create_timer(.5).timeout; quit()
