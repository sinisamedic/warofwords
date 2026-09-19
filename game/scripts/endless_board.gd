extends Control
const O=preload("res://scripts/ornaments.gd")
var host
var nickname: LineEdit
var content: Label
var status: Label
var controls: Array[Button]=[]
var language := "sr"
var adjacent := true
var busy := false
func local_text(en: String,sr: String) -> String: return sr if host.save.data.ui_language=="sr" else en
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index=100; mouse_filter=Control.MOUSE_FILTER_STOP
	host.endless_board_open=true
	language=host.lex.language; adjacent=host.lex.adjacent_only
	var w: float=minf(720,host.size.x-40)
	var x: float=(host.size.x-w)/2
	var title := Label.new(); title.text=local_text("ENDLESS · GLOBAL TOP","BESKRAJ · GLOBALNA LISTA"); title.position=Vector2(x+20,26); title.size=Vector2(w-40,34); title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(title); style_label(title,26)
	nickname=LineEdit.new(); nickname.position=Vector2(x+24,79); nickname.size=Vector2(210,38); nickname.placeholder_text=local_text("Your nickname","Tvoj nadimak"); nickname.max_length=20; nickname.add_theme_font_override("font",host.font); nickname.add_theme_font_size_override("font_size",19); add_child(nickname)
	if FileAccess.file_exists(host.daily_screen.profile_path):
		var profile=JSON.parse_string(FileAccess.get_file_as_string(host.daily_screen.profile_path))
		if profile is Dictionary: nickname.text=str(profile.get("nickname",""))
	button(local_text("PUBLISH BEST","OBJAVI REKORD"),Rect2(x+244,79,220,38),publish)
	button("SR / EN",Rect2(x+474,79,100,38),func(): language="en" if language=="sr" else "sr"; refresh())
	button(local_text("RULE","PRAVILO"),Rect2(x+584,79,w-608,38),func(): adjacent=not adjacent; refresh())
	status=Label.new(); status.position=Vector2(x+24,123); status.size=Vector2(w-48,42); status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; add_child(status); style_label(status,16)
	var scroll := ScrollContainer.new(); scroll.position=Vector2(x+24,173); scroll.size=Vector2(w-48,host.size.y-268); add_child(scroll)
	content=Label.new(); content.size_flags_horizontal=Control.SIZE_EXPAND_FILL; scroll.add_child(content); style_label(content,20)
	button(local_text("BACK","NAZAD"),Rect2(x+24,host.size.y-68,145,42),leave)
	button(local_text("REFRESH","OSVEŽI"),Rect2(x+w-184,host.size.y-68,160,42),refresh)
	var note := Label.new(); note.text=local_text("Beta · results reported by the game","Beta · rezultati prijavljeni iz igre"); note.position=Vector2(x+180,host.size.y-61); note.size=Vector2(w-380,30); note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; add_child(note); style_label(note,14)
	refresh()
func style_label(label: Label, font_size: int) -> void:
	label.add_theme_font_override("font",host.font); label.add_theme_font_size_override("font_size",font_size); label.add_theme_color_override("font_color",Color("fff1ce"))
func button(label: String, rect: Rect2, callback: Callable) -> void:
	var b := Button.new(); b.text=label; b.position=rect.position; b.size=rect.size; b.add_theme_font_override("font",host.font); b.add_theme_font_size_override("font_size",16)
	for state in ["normal","hover","pressed","disabled","focus"]:
		var frame=preload("res://scripts/button_frame_style.gd").new(); frame.kind=0; b.add_theme_stylebox_override(state,frame)
	b.pressed.connect(callback); add_child(b); controls.append(b)
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(.015,.04,.07,.97))
	O.frame(self,Rect2((size.x-minf(720,size.x-40))/2,12,minf(720,size.x-40),size.y-24),2)
func lock(value: bool) -> void:
	busy=value
	for b in controls: b.disabled=value
func call_rank_api(name: String, payload: Dictionary) -> Dictionary:
	var service=host.daily_screen.service
	var auth: Dictionary=await service.ensure_session()
	if auth.has("error"): return auth
	return await service.request_json("/rest/v1/rpc/"+name,payload,str(service.session.access_token))
func refresh() -> void:
	if busy: return
	lock(true); status.text=local_text("Connecting…","Povezivanje…"); content.text=""
	var data: Dictionary=await call_rank_api("endless_leaderboard",{"p_language":language,"p_adjacent":adjacent})
	lock(false)
	if data.has("error"): status.text=local_text("Could not load. Check connection and try again.","Lista nije učitana. Proveri vezu i pokušaj ponovo."); return
	status.text=("SR" if language=="sr" else "EN")+" · "+host.t("ADJACENT" if adjacent else "ANY LETTERS")+" · "+str(int(data.get("total",0)))+local_text(" players"," igrača")
	for row in data.get("rows",[]):
		content.text+="%s%d.  %s     %d   ·   %s %d\n\n" % ["★ " if row.own else "",int(row.position),str(row.nickname),int(row.score),local_text("wave","talas"),int(row.wave)]
	if content.text.is_empty(): content.text=local_text("No scores yet. Be the first!","Još nema rezultata. Budi prvi!")
func publish() -> void:
	if busy: return
	var regex := RegEx.new(); regex.compile("^[\\p{L}\\p{N} _-]{3,20}$")
	var name_value := nickname.text.strip_edges()
	if regex.search(name_value)==null: status.text=local_text("Nickname: 3–20 letters or numbers.","Nadimak: 3–20 slova ili brojeva."); return
	var key: String=host.Endless.key(language,adjacent)
	var result: Dictionary=host.save.data.get("endless_pending",{}).get(key,{})
	if result.is_empty() or int(result.get("words",0))<1: status.text=local_text("Finish a new run in this category first.","Prvo završi novi pohod u ovoj kategoriji."); return
	lock(true); status.text=local_text("Publishing…","Slanje…")
	var response: Dictionary=await call_rank_api("endless_submit",{"p_language":language,"p_adjacent":adjacent,"p_nickname":name_value,"p_score":int(result.score),"p_wave":int(result.wave),"p_words":int(result.words),"p_seconds":int(result.seconds)})
	lock(false)
	if response.has("error"): status.text=local_text("Not sent. Your score is saved; try again.","Nije poslato. Rezultat je sačuvan; pokušaj ponovo."); return
	var file := FileAccess.open(host.daily_screen.profile_path,FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"nickname":name_value})); file.close()
	host.daily_screen.local_nickname=name_value
	refresh()
func leave() -> void:
	if busy: return
	host.endless_board_open=false
	queue_free()
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		get_viewport().set_input_as_handled(); leave()

