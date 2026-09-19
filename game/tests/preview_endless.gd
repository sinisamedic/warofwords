extends SceneTree
## Isolated desktop preview. F6 opens the post-boss screen; F7 switches UI language.
var g
var held := false
var busy := true
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate()
	g.save.path="res://../.local/endless-preview.json"
	root.add_child(g)
	while g.loading: await process_frame
	g.save.data=g.save.defaults(); g.save.data.tutorial=true
	g.save.data.ui_language="sr"; g.save.data.word_language="sr"
	g.save.data.unlocked=23; g.save.data.coins=3000; g.save.data.levels=[3,3,3,3]
	for i in 24: g.save.data.wins[str(i)]=3
	g.save.data.loadout=["ember","bastion","seal","siphon"]
	g.save.save_game(); g.change_screen("home")
	root.title="War of Words — pregled • F6: posle bossa • F7: SR/EN"
	busy=false
func _process(_delta: float) -> bool:
	if busy or g==null: return false
	var down := Input.is_physical_key_pressed(KEY_F6) or Input.is_physical_key_pressed(KEY_F7)
	if down and not held:
		if Input.is_physical_key_pressed(KEY_F7):
			g.save.data.ui_language="en" if g.save.data.ui_language=="sr" else "sr"
		else: show_boss()
	held=down
	return false
func show_boss() -> void:
	busy=true
	g.change_screen("home")
	g.endless_wave=5; g.endless_score=3680; g.endless_words=28; g.endless_seconds=154
	g.endless_checkpoint=false; g.mission=g.Endless.opponent(5)
	await g.start_battle(true)
	g.hp=76; g.finish(true); g.result_delay=0; g.overlay="endless_boss"
	busy=false
