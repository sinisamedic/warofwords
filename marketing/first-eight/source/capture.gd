extends SceneTree
## Reproducible capture of the unmodified game. No fabricated score or HP.
var g
var out := "res://../.local/social-capture"
func _initialize() -> void: call_deferred("run")
func frame(folder: String, index: int) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(out+"/"+folder+"/%04d.png" % index)
func still(label: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../marketing/first-eight/source/"+label+".png")
func run() -> void:
	for folder in ["home","battle"]: DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out+"/"+folder))
	g=load("res://main.tscn").instantiate()
	g.online_writes_enabled=false
	g.save.path=out+"/isolated-save.json"
	root.add_child(g)
	while g.loading: await process_frame
	g.save.data=g.save.defaults()
	g.save.data.music=false; g.save.data.sound=false; g.save.data.haptics=false
	g.sfx.enabled=false; g.music.set_enabled(false)
	g.change_screen("home")
	for i in 90: await frame("home",i)
	await still("home")
	g.change_screen("settings")
	await still("settings")
	g.settings_screen.leave()
	g.mission=0
	await g.start_battle()
	g.dispatch("dismiss",-1)
	await still("board")
	var evidence := {"engine":Engine.get_version_info().string,"kind":"Desktop Godot development capture; normal tutorial board; automated legal drag","letters":g.lex.letters.duplicate(),"types":g.lex.types.duplicate(),"before_hp":g.foe_hp,"path":[0,1,2,3,4],"solutions":g.lex.solutions.duplicate()}
	for i in 270:
		if i==45: g.press(g.tile_center(0))
		if i in [60,75,90,105]: g.move(g.tile_center(int((i-45)/15)))
		if i==120:
			await still("stone-selected")
			g.release(g.tile_center(4))
		if i==160: await still("stone-impact")
		await frame("battle",i)
	evidence["after_hp"]=g.foe_hp
	evidence["accepted_words"]=g.used.keys()
	evidence["word_count"]=g.word_count
	var file=FileAccess.open("res://../marketing/first-eight/source/capture-evidence.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(evidence,"\t")); file.close()
	assert(g.used.has("STONE") and g.word_count==1)
	print("SOCIAL CAPTURE: STONE accepted; enemy HP ",evidence.before_hp," -> ",g.foe_hp)
	g.queue_free(); await process_frame; quit()
