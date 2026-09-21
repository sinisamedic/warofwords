extends SceneTree
const L=preload("res://scripts/languages.gd")
const Lex=preload("res://scripts/lexicon.gd")
var failures := 0
func check(ok: bool, message: String) -> void:
	print(("PASS " if ok else "FAIL ")+message)
	if not ok: failures+=1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	check(L.CODES.back()=="sr","Serbian last")
	for code in L.CODES:
		var lex=Lex.new(true,code); lex.joker_enabled=true
		check(lex.words.size()>50000,code+" full dictionary")
		if L.STARTERS.has(code):
			for word in L.STARTERS[code]: check(lex.contains(word) and lex.tokens(word).size()<=7,code+" starter "+word)
		lex.generate(); check(lex.letters.size()==28 and not lex.solutions.is_empty(),code+" playable board")
		for letter in lex.letters: check(lex.valid_tile(letter),code+" valid tile "+letter)
		check(preload("res://scripts/localization.gd").translate("OPTIONS",code)!="OPTIONS" or code=="en",code+" translated settings")
	var g=load("res://main.tscn").instantiate(); g.online_writes_enabled=false; g.save.path="res://../.local/languages-test.json"; root.add_child(g)
	while g.loading: await process_frame
	if is_instance_valid(g.age_screen): g.age_screen.kind="info"; g.age_screen.leave()
	await process_frame
	g.daily_screen.profile_path="res://../.local/languages-profile.json"
	g.save.data=g.save.defaults(); g.save.data.age_group="adult"; g.save.data.ui_language="en"; g.save.data.tutorial=true
	g.change_screen("settings"); await process_frame
	var s=g.settings_screen
	s.draft.ui_language="fr"; s.draft.word_language="de"; s.nickname.text="Testeur"
	s.picker="word_language"; s.rebuild()
	check(s.form.has_node("Language_sr"),"all six native language choices")
	s.apply_settings(); await process_frame
	check(g.save.data.ui_language=="fr" and g.save.data.word_language=="de","independent languages saved")
	check(g.rankings.nickname()=="Testeur","shared nickname saved locally")
	check(g.save.data.endless_outbox.is_empty(),"settings never publishes scores")
	g.change_screen("settings"); await process_frame
	g.settings_screen.draft.ui_language="it"; g.settings_screen.leave(); await process_frame
	check(g.save.data.ui_language=="fr","Back discards draft")
	var save=preload("res://scripts/save_data.gd").new(); save.path=g.save.path; save.load_game()
	check(save.data.ui_language=="fr" and save.data.word_language=="de","language preferences survive restart")
	g.queue_free(); await process_frame
	quit(1 if failures else 0)
