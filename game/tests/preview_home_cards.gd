extends SceneTree
## Opt-in playable desktop preview. Never touches the normal player's progress.
var g
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate()
	g.save.path="res://../.local/home-cards-preview.json"
	root.add_child(g)
	while g.loading: await process_frame
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=23
	g.save.data.ui_language="sr"; g.save.data.word_language="sr"; g.save.data.coins=3000
	g.save.data.levels=[4,4,4,4]; g.save.data.lexicon_earned=true
	for i in 13: g.save.data.wins[str(i)]=3
	g.save.data.loadout=["ember","mirror","seal","bloom"]
	g.save.data.artifact="reserve"; g.save.save_game()
	g.mission=12; g.change_screen("home")
	root.title="War of Words — PREGLED: naslovna — Arsenal i Unapređenja"
