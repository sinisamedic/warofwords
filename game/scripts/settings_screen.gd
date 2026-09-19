extends Control
const L = preload("res://scripts/languages.gd")
const O = preload("res://scripts/ornaments.gd")
const SKY = preload("res://assets/art/endless/sky-court.png")
var host
var draft: Dictionary
var nickname: LineEdit
var form: Control
var picker := ""
var status := ""
var previous_touch := false
var panel_rect: Rect2
var left: Rect2
var right: Rect2
func local_text(value: String) -> String: return host.Localization.translate(value,draft.ui_language)
func _ready() -> void:
	draft=host.save.data.duplicate(true)
	previous_touch=Input.emulate_mouse_from_touch; Input.emulate_mouse_from_touch=true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); z_index=100
	form=Control.new(); form.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); form.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(form)
	resized.connect(rebuild); rebuild()
func label(value: String, rect: Rect2, font_size := 17, gold := false) -> Label:
	var item := Label.new(); item.text=local_text(value); item.position=rect.position; item.size=rect.size
	item.add_theme_font_override("font",host.font); item.add_theme_font_size_override("font_size",font_size)
	item.add_theme_color_override("font_color",host.GOLD if gold else host.CREAM); item.mouse_filter=Control.MOUSE_FILTER_IGNORE
	item.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS; form.add_child(item); return item
func button(value: String, rect: Rect2, callback: Callable, gold := false) -> Button:
	var b := Button.new(); b.text=local_text(value); b.position=rect.position; b.size=rect.size
	b.add_theme_font_override("font",host.font); b.add_theme_font_size_override("font_size",17)
	for state in ["normal","hover","pressed","focus"]:
		var style=preload("res://scripts/button_frame_style.gd").new(); style.kind=1 if gold else 0
		b.add_theme_stylebox_override(state,style)
	for state in ["font_color","font_hover_color","font_pressed_color"]: b.add_theme_color_override(state,host.INK if gold else host.CREAM)
	b.pressed.connect(callback); form.add_child(b); return b
func rebuild() -> void:
	if not is_instance_valid(form): return
	var typed: String=nickname.text if is_instance_valid(nickname) else host.rankings.nickname()
	var focused: bool=is_instance_valid(nickname) and nickname.has_focus()
	var caret: int=nickname.caret_column if is_instance_valid(nickname) else 0
	for child in form.get_children(): form.remove_child(child); child.queue_free()
	var w: float=minf(970,size.x-30)
	panel_rect=Rect2((size.x-w)/2,12,w,size.y-24)
	left=Rect2(panel_rect.position.x+24,75,(w-72)*.48,304)
	right=Rect2(left.end.x+24,75,(w-72)*.52,304)
	label("OPTIONS",Rect2(panel_rect.position.x+70,25,w-140,38),29,true).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	button("×",Rect2(panel_rect.end.x-62,26,40,36),leave)
	label("PLAYER",Rect2(left.position.x+15,84,left.size.x-30,24),20,true)
	nickname=LineEdit.new(); nickname.position=Vector2(left.position.x+15,115); nickname.size=Vector2(left.size.x-30,37)
	nickname.text=typed; nickname.max_length=20; nickname.placeholder_text=local_text("Your nickname")
	nickname.add_theme_font_override("font",host.font); nickname.add_theme_font_size_override("font_size",20)
	var style := StyleBoxFlat.new(); style.bg_color=Color("0a2131"); style.border_color=Color("bfa165"); style.set_border_width_all(1); style.set_corner_radius_all(7); style.content_margin_left=12
	nickname.add_theme_stylebox_override("normal",style); nickname.add_theme_stylebox_override("focus",style)
	nickname.text_submitted.connect(func(_value): nickname.release_focus()); form.add_child(nickname)
	if focused: nickname.grab_focus(); nickname.caret_column=caret
	label("Name on the leaderboard" if status.is_empty() else status,Rect2(left.position.x+17,153,left.size.x-32,25),12,not status.is_empty())
	label("SOUND AND DISPLAY",Rect2(left.position.x+15,188,left.size.x-30,24),18,true)
	for i in 4:
		var key: String=["music","sound","haptics","calm"][i]
		var title: String=["MUSIC","SOUND EFFECTS","HAPTICS","REDUCED MOTION"][i]
		label(title,Rect2(left.position.x+43,220+i*33,left.size.x-130,26),14)
		var toggle := button("●   ✓" if draft[key] else "—   ●",Rect2(left.end.x-79,220+i*33,63,27),func(): draft[key]=not draft[key]; rebuild(),draft[key])
		for state in ["normal","hover","pressed","focus"]:
			var switch_style:=StyleBoxFlat.new(); switch_style.bg_color=Color("287e77") if draft[key] else Color("243b4b"); switch_style.border_color=Color("d1b171"); switch_style.set_border_width_all(1); switch_style.set_corner_radius_all(13)
			toggle.add_theme_stylebox_override(state,switch_style)
		for state in ["font_color","font_hover_color","font_pressed_color"]: toggle.add_theme_color_override(state,Color("fff1ce"))
		toggle.name="Toggle_"+key
	label("LETTER CONNECTION",Rect2(left.position.x+14,356,left.size.x-28,22),14,true)
	for i in 2:
		button("ADJACENT" if i==0 else "ANY LETTERS",Rect2(left.position.x+12+i*(left.size.x-24)/2,382,(left.size.x-24)/2,33),func(): draft.adjacent_only=i==0; rebuild(),draft.adjacent_only==(i==0))
	label("LANGUAGES",Rect2(right.position.x+15,84,right.size.x-30,25),20,true)
	for i in 2:
		var key: String=["ui_language","word_language"][i]
		label("INTERFACE LANGUAGE" if i==0 else "WORD DICTIONARY",Rect2(right.position.x+16,121+i*73,right.size.x-32,23),15)
		button(L.NAMES[draft[key]]+"    ▾",Rect2(right.position.x+12,147+i*73,right.size.x-24,39),func(): picker="" if picker==key else key; rebuild(),picker==key)
	if not picker.is_empty():
		for i in L.CODES.size():
			var code: String=L.CODES[i]
			var b:=button(L.NAMES[code]+(" ✓" if draft[picker]==code else ""),Rect2(right.position.x+12+(i%2)*(right.size.x-24)/2,273+(i/2)*42,(right.size.x-24)/2-2,38),func(): draft[picker]=code; picker=""; rebuild(),draft[picker]==code)
			b.name="Language_"+code
	else:
		var hint:=label("Applies to new duels. Saved duels keep their dictionary.",Rect2(right.position.x+20,281,right.size.x-40,62),15); hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		label("6 languages · Offline dictionaries",Rect2(right.position.x+20,351,right.size.x-40,24),14,true)
	button("SAVE",Rect2(panel_rect.end.x-252,426,148,34),apply_settings,true)
	button("BACK",Rect2(panel_rect.end.x-102,426,78,34),leave)
	for i in 3:
		var action: String=["help","journal","credits"][i]
		button(["HELP","JOURNAL","CREDITS"][i],Rect2(left.position.x+i*110,433,106,27),func(): leave(); host.dispatch(action)).add_theme_font_size_override("font_size",11)
	queue_redraw()
func _draw() -> void:
	draw_texture_rect(SKY,Rect2(Vector2.ZERO,size),false,Color(.65,.72,.78))
	O.frame(self,panel_rect,2); draw_texture_rect(O.FILIGREE,panel_rect.grow(-8),false,Color(1,1,1,.45))
	for rect in [left,right]:
		var style:=StyleBoxFlat.new(); style.bg_color=Color("102c40"); style.border_color=Color("ab915c"); style.set_border_width_all(1); style.set_corner_radius_all(10)
		draw_style_box(style,Rect2(rect.position,Vector2(rect.size.x,343)))
		draw_line(rect.position+Vector2(15,36),Vector2(rect.end.x-15,rect.position.y+36),Color("816b44"),1,true)
	for i in 4: draw_texture_rect(O.TOGGLES[[1,0,2,3][i]],Rect2(left.position.x+14,221+i*33,24,24),false)
	O.gem(self,Vector2(size.x/2,68),5)
func apply_settings() -> void:
	var name_value:=nickname.text.strip_edges()
	if not name_value.is_empty() and not host.rankings.valid_name(name_value): status="Use 3–20 letters or numbers."; rebuild(); nickname.grab_focus(); return
	if not name_value.is_empty() and not host.rankings.remember_nickname(name_value): status="Name could not be saved"; rebuild(); return
	var old: Dictionary=host.save.data.duplicate(true)
	for key in ["ui_language","word_language","music","sound","haptics","calm","adjacent_only"]: host.save.data[key]=draft[key]
	if not host.save.save_game(): host.save.data=old; status="Could not save progress on this device"; rebuild(); return
	host.sfx.enabled=draft.sound; host.music.set_enabled(draft.music)
	# Unfinished battles keep their own dictionary and connection rule.
	leave()
func leave() -> void:
	host.settings_screen=null; Input.emulate_mouse_from_touch=previous_touch; queue_free(); host.change_screen("home")
func _exit_tree() -> void:
	Input.emulate_mouse_from_touch=previous_touch
