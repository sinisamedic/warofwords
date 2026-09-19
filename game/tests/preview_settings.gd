extends SceneTree
var g
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate()
	g.online_writes_enabled=false
	g.save.path="res://../.local/settings-preview.json"
	root.add_child(g)
	while g.loading: await process_frame
	g.daily_screen.profile_path="res://../.local/settings-preview-profile.json"
	g.save.data=g.save.defaults(); g.save.data.tutorial=true
	g.save.data.ui_language="sr"; g.save.data.word_language="sr"
	g.daily_screen.local_nickname="Sinisa"
	g.change_screen("settings"); await process_frame
	g.settings_screen.picker="word_language"; g.settings_screen.rebuild()
	root.title="War of Words — pregled podešavanja"
