extends Control
const O=preload("res://scripts/ornaments.gd")
const SKY=preload("res://assets/art/endless/sky-court.png")
var host
var result_mode := false
var mode := "endless"
var language := "sr"
var adjacent := true
var nickname: LineEdit
var status: Label
var empty: Label
var rows_view: Control
var scroll: ScrollContainer
var form: Control
var request_id := 0
var name_timer: Timer
var panel_rect: Rect2
var list_rect: Rect2
var name_dirty := false
var busy := false
var cached_rows: Array=[]
var cached_category := ""
func local_text(en: String,sr: String) -> String: return sr if host.save.data.ui_language=="sr" else en
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); z_index=100; mouse_filter=Control.MOUSE_FILTER_STOP
	host.endless_board_open=true
	language=host.lex.language if result_mode else host.save.data.word_language
	adjacent=host.lex.adjacent_only if result_mode else host.save.data.adjacent_only
	form=Control.new(); form.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); form.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(form)
	name_timer=Timer.new(); name_timer.one_shot=true; name_timer.wait_time=.9; name_timer.timeout.connect(save_name); add_child(name_timer)
	host.rankings.changed.connect(service_changed)
	resized.connect(rebuild)
	rebuild()
	refresh()
	host.rankings.flush()
func label(value: String, rect: Rect2, pixels: int=17) -> Label:
	var item := Label.new(); item.text=value; item.position=rect.position; item.size=rect.size
	item.add_theme_font_override("font",host.font); item.add_theme_font_size_override("font_size",pixels); item.add_theme_color_override("font_color",Color("fff1ce")); item.mouse_filter=Control.MOUSE_FILTER_IGNORE
	form.add_child(item); return item
func button(value: String, rect: Rect2, callback: Callable, gold := false) -> void:
	var b := Button.new(); b.text=value; b.position=rect.position; b.size=rect.size
	b.add_theme_font_override("font",host.font); b.add_theme_font_size_override("font_size",17)
	for state in ["normal","hover","pressed","disabled","focus"]:
		var style=preload("res://scripts/button_frame_style.gd").new(); style.kind=1 if gold else 0
		b.add_theme_stylebox_override(state,style)
	for state in ["font_color","font_hover_color","font_pressed_color"]: b.add_theme_color_override(state,Color("10283d") if gold else Color("fff1ce"))
	b.pressed.connect(callback); form.add_child(b)
func rebuild() -> void:
	if not is_instance_valid(form): return
	var typed: String=nickname.text if is_instance_valid(nickname) else host.rankings.nickname()
	for child in form.get_children(): form.remove_child(child); child.queue_free()
	var w: float=minf(930,size.x-30)
	panel_rect=Rect2((size.x-w)/2,12,w,size.y-24)
	var x: float=panel_rect.position.x
	var right: float=panel_rect.end.x
	if result_mode:
		list_rect=Rect2(x+310,186,w-335,size.y-279)
		label(local_text("YOUR NAME","TVOJ NADIMAK"),Rect2(x+310,71,230,21),14)
		nickname=LineEdit.new(); nickname.position=Vector2(x+310,96); nickname.size=Vector2(w-335,35); nickname.text=typed; nickname.max_length=20; nickname.placeholder_text=local_text("Enter a nickname to publish","Unesi nadimak za objavu")
		nickname.add_theme_font_override("font",host.font); nickname.add_theme_font_size_override("font_size",19)
		var style := StyleBoxFlat.new(); style.bg_color=Color("0a2131"); style.border_color=Color("c6a25d"); style.set_border_width_all(1); style.set_corner_radius_all(6); style.content_margin_left=12
		nickname.add_theme_stylebox_override("normal",style); nickname.add_theme_stylebox_override("focus",style)
		nickname.text_changed.connect(func(_value): name_dirty=true; name_timer.start())
		nickname.text_submitted.connect(func(_value): name_timer.stop(); save_name())
		form.add_child(nickname)
		status=label(host.t(host.rankings.message),Rect2(x+310,135,w-335,23),14)
		if not host.online_autosubmit: status.text=local_text("PREVIEW · test scores are not published","PREGLED · probni rezultat se ne objavljuje")
		button(local_text("MENU","MENI"),Rect2(x+24,size.y-66,155,40),func(): leave(); host.change_screen("home"))
		button(local_text("TRY AGAIN","POKUŠAJ PONOVO"),Rect2(right-239,size.y-66,215,40),func(): leave(); host.dispatch("endless_retry"),true)
	else:
		button(local_text("ENDLESS WORDS","BESKRAJ REČI"),Rect2(x+w/2-239,77,230,40),func(): mode="endless"; rebuild(); refresh(),mode=="endless")
		button(local_text("DAILY CHALLENGE","DNEVNI IZAZOV"),Rect2(x+w/2+9,77,230,40),func(): mode="daily"; rebuild(); refresh(),mode=="daily")
		button("SR" if language=="sr" else "EN",Rect2(right-272,127,66,30),func(): language="en" if language=="sr" else "sr"; rebuild(); refresh())
		button(host.t("ADJACENT" if adjacent else "ANY LETTERS"),Rect2(right-197,127,173,30),func(): adjacent=not adjacent; rebuild(); refresh())
		status=label("",Rect2(x+24,130,w-325,27),15)
		list_rect=Rect2(x+24,182,w-48,size.y-275)
		button(local_text("CLOSE","ZATVORI"),Rect2(x+w/2-96,size.y-66,192,40),leave)
	var header_y: float=list_rect.position.y-21
	label(local_text("PLAYER","IGRAČ"),Rect2(list_rect.position.x+44,header_y,200,18),13)
	label(local_text("SCORE","BODOVI"),Rect2(list_rect.end.x-140,header_y,82,18),13)
	label(local_text("WORDS","REČI") if mode=="daily" else local_text("WAVE","TALAS"),Rect2(list_rect.end.x-48,header_y,48,18),11)
	scroll=ScrollContainer.new(); scroll.position=list_rect.position; scroll.size=list_rect.size; scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; form.add_child(scroll)
	rows_view=preload("res://scripts/rank_rows.gd").new(); rows_view.host=host; rows_view.daily=mode=="daily"; rows_view.size_flags_horizontal=Control.SIZE_EXPAND_FILL; scroll.add_child(rows_view)
	if cached_category==mode+language+str(adjacent):
		rows_view.rows=cached_rows; rows_view.custom_minimum_size.y=cached_rows.size()*40
	empty=label("",Rect2(list_rect.position+Vector2(12,24),Vector2(list_rect.size.x-24,80)),17); empty.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	empty.gui_input.connect(retry_input)
	queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color(.015,.035,.065,.94)); O.frame(self,panel_rect,2)
	draw_texture_rect(SKY,panel_rect.grow(-12),false,Color(.48,.62,.73,.18))
	host.text(local_text("RUN COMPLETE","POHOD ZAVRŠEN") if result_mode else local_text("HALL OF CHAMPIONS","DVORANA ŠAMPIONA"),Rect2(panel_rect.position.x+50,26,panel_rect.size.x-100,35),27,Color("f3c569"),true,HORIZONTAL_ALIGNMENT_CENTER,false,self)
	for side in [0,1]:
		O.gem(self,Vector2(panel_rect.position.x+29 if side==0 else panel_rect.end.x-29,45),7)
	draw_line(Vector2(panel_rect.position.x+40,66),Vector2(panel_rect.end.x-40,66),Color("977943"),1,true)
	if result_mode:
		var x: float=panel_rect.position.x+24
		O.frame(self,Rect2(x,83,260,size.y-165),2)
		O.glow(self,Vector2(x+130,139),70,Color(1,.7,.15,.22))
		host.text(str(host.endless_score),Rect2(x+18,99,224,49),37,Color("f3c569"),true,HORIZONTAL_ALIGNMENT_CENTER,false,self)
		host.text("SCORE",Rect2(x+18,151,224,20),15,Color("fff1ce"),false,HORIZONTAL_ALIGNMENT_CENTER,true,self)
		var values := [str(host.endless_wave),str(host.endless_words+host.word_count),"%d:%02d" % [int(host.endless_seconds+host.duration)/60,int(host.endless_seconds+host.duration)%60]]
		var names := [local_text("Wave","Talas"),local_text("Words","Reči"),local_text("Time","Vreme")]
		for i in 3:
			host.text(names[i],Rect2(x+22,188+i*30,120,25),17,Color("c8d7dc"),false,HORIZONTAL_ALIGNMENT_LEFT,false,self)
			host.text(values[i],Rect2(x+148,188+i*30,89,25),20,Color("fff1ce"),true,HORIZONTAL_ALIGNMENT_RIGHT,false,self)
		for i in 4: host.equipment_ui.icon(self,host.battle_loadout[i],Vector2(x+55+i*50,305),19,host.COLORS[i])
		host.text(local_text("GLOBAL RANKING","GLOBALNA LISTA"),Rect2(panel_rect.position.x+310,71,panel_rect.size.x-335,21),14,Color("f3c569"),false,HORIZONTAL_ALIGNMENT_RIGHT,false,self)
func retry_input(event: InputEvent) -> void:
	if (event is InputEventMouseButton and event.pressed) or (event is InputEventScreenTouch and event.pressed):
		host.rankings.flush(); refresh()
func refresh() -> void:
	request_id+=1
	if busy: return
	var token := request_id
	busy=true; empty.text=local_text("Loading ranking…","Učitavanje liste…")
	var response: Dictionary=await host.rankings.leaderboard(mode,language,adjacent)
	busy=false
	if token!=request_id:
		refresh(); return
	if response.has("error"):
		rows_view.rows=[]; rows_view.custom_minimum_size.y=0; rows_view.queue_redraw()
		empty.text=local_text("No connection. Your result stays saved.\nTap here to retry.","Nema veze sa serverom. Rezultat ostaje sačuvan.\nDodirni ovde za ponovni pokušaj.")
		empty.mouse_filter=Control.MOUSE_FILTER_STOP
		return
	empty.mouse_filter=Control.MOUSE_FILTER_IGNORE
	empty.text=local_text("No results yet. Be the first!","Još nema rezultata. Budi prvi!") if response.get("rows",[]).is_empty() else ""
	rows_view.rows=response.get("rows",[]); rows_view.custom_minimum_size.y=rows_view.rows.size()*40; rows_view.queue_redraw()
	cached_rows=rows_view.rows; cached_category=mode+language+str(adjacent)
	if not result_mode: status.text=(local_text("TODAY · ","DANAS · ")+str(response.get("day","")) if mode=="daily" else local_text("ALL-TIME BEST","NAJBOLJI REZULTATI"))
func save_name() -> void:
	if not result_mode or not name_dirty: return
	if not host.rankings.remember_nickname(nickname.text): status.text=local_text("Use 3–20 letters or numbers.","Unesi 3–20 slova ili brojeva."); return
	name_dirty=false
	if host.rankings.busy: name_dirty=true; return
	if host.save.data.endless_outbox.is_empty(): host.rankings.rename_player()
	else: host.rankings.flush()
func service_changed() -> void:
	if result_mode: status.text=host.t(host.rankings.message)
	if not host.rankings.busy:
		if name_dirty: name_timer.start()
		refresh()
func leave() -> void:
	if result_mode and name_dirty: save_name()
	request_id+=1; host.endless_board_open=false; queue_free()
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		get_viewport().set_input_as_handled(); leave()
		if result_mode: host.change_screen("home")
