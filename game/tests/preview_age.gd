extends SceneTree
var g
func _initialize() -> void: call_deferred("run")
func run() -> void:
	g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/age-preview-progress.json"
	var seed=load("res://scripts/save_data.gd").new(); seed.path=g.save.path; seed.data=seed.defaults(); seed.data.ui_language=load("res://scripts/languages.gd").device_language(OS.get_locale()); seed.data.word_language=seed.data.ui_language; seed.data.tutorial=true; seed.save_game()
	root.add_child(g)
	while g.loading: await process_frame
	g.daily_screen.service.access_allowed=func(): return false
	g.daily_screen.profile_path="res://../.local/age-preview-profile.json"
	g.daily_screen.pending_path="res://../.local/age-preview-pending.json"
	g.save.data.music=false; g.music.set_enabled(false)
	root.title="War of Words — pregled uzrasta · F1 ponovni izbor · F2 poraz u Beskraju"
func _process(_delta: float) -> bool:
	if g==null or g.loading: return false
	if Input.is_physical_key_pressed(KEY_F1) and not is_instance_valid(g.age_screen):
		if g.screen=="daily": g.daily_screen.close_screen()
		if is_instance_valid(g.settings_screen): g.settings_screen.leave()
		g.change_screen("home"); g.save.data.age_group=""; g.open_age_screen("age")
	if Input.is_physical_key_pressed(KEY_F2) and not is_instance_valid(g.age_screen) and g.screen!="battle":
		preview_defeat()
	return false
func preview_defeat() -> void:
	if g.screen=="daily": g.daily_screen.close_screen()
	if is_instance_valid(g.settings_screen): g.settings_screen.leave()
	await g.start_endless(); g.endless_score=234; g.hp=0; g.finish(false)
