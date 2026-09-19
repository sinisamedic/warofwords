extends Control
const L = preload("res://scripts/languages.gd")
const O = preload("res://scripts/ornaments.gd")
const SKY = preload("res://assets/art/endless/sky-court.png")
const FRAME = preload("res://assets/ui/settings/frame.svg")
const FLOURISH = preload("res://assets/ui/settings/flourish.svg")
const PENCIL = preload("res://assets/ui/settings/pencil.svg")
const LABELS := {
 "sr":["Muzika","Zvučni efekti","Vibracija","Manje animacija","Jezik interfejsa","Jezik reči","Susedna","Bilo koja"],
 "en":["Music","Sound effects","Vibration","Reduced motion","Interface language","Word language","Adjacent","Any letters"],
 "de":["Musik","Soundeffekte","Vibration","Weniger Bewegung","Menüsprache","Wörtersprache","Benachbart","Beliebig"],
 "fr":["Musique","Effets sonores","Vibrations","Animations réduites","Langue des menus","Langue des mots","Adjacentes","Libres"],
 "es":["Música","Efectos de sonido","Vibración","Menos animaciones","Idioma de los menús","Idioma de las palabras","Adyacentes","Cualquiera"],
 "it":["Musica","Effetti sonori","Vibrazione","Meno animazioni","Lingua dei menu","Lingua delle parole","Adiacenti","Qualsiasi"]
}
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
var headings: Array=[]
var picker_rect:=Rect2()
var body_font: Font
func local_text(value: String) -> String: return host.Localization.translate(value,draft.ui_language)
func _ready() -> void:
	draft=host.save.data.duplicate(true)
	var regular:=FontVariation.new(); regular.base_font=preload("res://assets/fonts/Lora.ttf"); regular.variation_opentype={"wght":400}; body_font=regular
	previous_touch=Input.emulate_mouse_from_touch; Input.emulate_mouse_from_touch=true
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); z_index=100
	form=Control.new(); form.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); form.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(form)
	resized.connect(rebuild); rebuild()
func label(value: String, rect: Rect2, font_size := 17, gold := false) -> Label:
	var item := Label.new(); item.text=local_text(value); item.position=rect.position; item.size=rect.size
	item.add_theme_font_override("font",host.font if gold else body_font); item.add_theme_font_size_override("font_size",font_size)
	item.add_theme_color_override("font_color",host.GOLD if gold else host.CREAM); item.mouse_filter=Control.MOUSE_FILTER_IGNORE
	item.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS; form.add_child(item); return item
func button(value: String, rect: Rect2, callback: Callable, selected := false, kind := 0) -> Button:
	var b=preload("res://scripts/settings_button.gd").new(); b.text=local_text(value); b.position=rect.position; b.size=rect.size
	b.face=body_font if kind!=1 else host.title_font; b.pixels=16; b.kind=kind; b.selected=selected; b.calm=draft.calm
	b.pressed.connect(callback); form.add_child(b); return b
func heading(value: String, x: float, y: float, width: float) -> void:
	var item:=label(value,Rect2(x+24,y,width-24,25),18,true)
	var text_width: float=host.font.get_string_size(item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,18).x
	if text_width>width-28:
		item.add_theme_font_size_override("font_size",15); text_width=host.font.get_string_size(item.text,HORIZONTAL_ALIGNMENT_LEFT,-1,15).x
	headings.append({"p":Vector2(x,y+3),"start":Vector2(x+text_width+31,y+19),"end":Vector2(x+width,y+19)})
func rebuild() -> void:
	if not is_instance_valid(form): return
	var typed: String=nickname.text if is_instance_valid(nickname) else host.rankings.nickname()
	var focused: bool=is_instance_valid(nickname) and nickname.has_focus()
	var caret: int=nickname.caret_column if is_instance_valid(nickname) else 0
	for child in form.get_children(): form.remove_child(child); child.queue_free()
	headings.clear(); picker_rect=Rect2()
	var w: float=minf(760,size.x*.76)
	panel_rect=Rect2((size.x-w)/2,14,w,452)
	var x: float=panel_rect.position.x; var y: float=panel_rect.position.y
	left=Rect2(x+28,y+73,w/2-51,323)
	right=Rect2(x+w/2+12,y+73,w/2-48,323)
	var copy: Array=LABELS[draft.ui_language]
	label("OPTIONS",Rect2(x+62,y+18,w-124,39),31,true).horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	button("",Rect2(panel_rect.end.x-61,y+22,34,34),leave,false,3)
	heading("PLAYER",left.position.x,y+73,left.size.x)
	var field:=Rect2(left.position.x+24,y+103,left.size.x-24,33)
	nickname=LineEdit.new(); nickname.position=field.position; nickname.size=field.size
	nickname.text=typed; nickname.max_length=20; nickname.placeholder_text=local_text("Your nickname")
	nickname.add_theme_font_override("font",body_font); nickname.add_theme_font_size_override("font_size",19)
	var style:=StyleBoxFlat.new(); style.bg_color=Color("061725"); style.border_color=Color("d8b775"); style.set_border_width_all(1); style.set_corner_radius_all(5)
	style.content_margin_left=16; style.content_margin_right=34; style.content_margin_top=2; style.content_margin_bottom=2
	nickname.add_theme_stylebox_override("normal",style); nickname.add_theme_stylebox_override("focus",style)
	nickname.text_submitted.connect(func(_value): nickname.release_focus()); form.add_child(nickname)
	if focused: nickname.grab_focus(); nickname.caret_column=caret
	nickname.size=field.size
	var pencil:=TextureRect.new(); pencil.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; pencil.texture=PENCIL; pencil.position=field.position+Vector2(field.size.x-31,7); pencil.size=Vector2(18,21); pencil.mouse_filter=Control.MOUSE_FILTER_IGNORE; form.add_child(pencil)
	label("Name on the leaderboard" if status.is_empty() else status,Rect2(field.position.x+6,y+138,field.size.x-6,24),12,not status.is_empty()).modulate=Color("acb7bf") if status.is_empty() else Color.WHITE
	heading("SOUND AND DISPLAY",left.position.x,y+169,left.size.x)
	for i in 4:
		var key: String=["music","sound","haptics","calm"][i]
		label(copy[i],Rect2(left.position.x+30,y+198+i*29,left.size.x-88,26),16)
		var toggle:=button("",Rect2(left.end.x-60,y+198+i*29,50,25),func(): pass,draft[key],2)
		toggle.name="Toggle_"+key; toggle.tooltip_text=copy[i]
		toggle.pressed.connect(func(): draft[key]=not draft[key]; toggle.selected=draft[key]; toggle.calm=draft.calm)
	heading("LETTER CONNECTION",left.position.x,y+322,left.size.x)
	for i in 2:
		var bw: float=(left.size.x-30)/2
		button(copy[6+i],Rect2(left.position.x+24+i*(bw+6),y+352,bw,30),func(): draft.adjacent_only=i==0; rebuild(),draft.adjacent_only==(i==0))
	heading("LANGUAGES",right.position.x,y+73,right.size.x)
	for i in 2:
		var key: String=["ui_language","word_language"][i]
		label(copy[4+i],Rect2(right.position.x+24,y+104+i*62,right.size.x-24,26),16)
		var b:=button(L.NAMES[draft[key]],Rect2(right.position.x+24,y+130+i*62,right.size.x-24,32),func(): picker="" if picker==key else key; rebuild(),false,4)
		b.expanded=picker==key
	if not picker.is_empty():
		picker_rect=Rect2(right.position.x+24,y+225,right.size.x-24,118)
		for i in L.CODES.size():
			var code: String=L.CODES[i]; var bw: float=(picker_rect.size.x-18)/2
			var b:=button(L.NAMES[code],Rect2(picker_rect.position+Vector2(6+(i%2)*(bw+6),6+(i/2)*36),Vector2(bw,32)),func(): draft[picker]=code; picker=""; rebuild(),draft[picker]==code)
			b.name="Language_"+code; b.pixels=15
	var hint:=label("Applies to new duels. Saved duels keep their dictionary.",Rect2(right.position.x+24,y+350,right.size.x-24,42),12); hint.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; hint.size=Vector2(right.size.x-24,42); hint.modulate=Color("acb7bf")
	var save_button:=button("SAVE",Rect2(size.x/2-112,y+398,224,38),apply_settings,false,1); save_button.pixels=24
	button("BACK",Rect2(size.x/2+126,y+402,100,32),leave)
	queue_redraw()
func fade_line(a: Vector2,b: Vector2,alpha:=1.0) -> void:
	var normal: Vector2=(b-a).normalized().orthogonal()*.4
	for i in 48:
		var t:=float(i)/48; var next:=float(i+1)/48
		var p:=a.lerp(b,t); var q:=a.lerp(b,next)
		var c:=Color(.87,.68,.36,sin(PI*t)*alpha); var d:=Color(.87,.68,.36,sin(PI*next)*alpha)
		draw_polygon(PackedVector2Array([p-normal,q-normal,q+normal,p+normal]),PackedColorArray([c,d,d,c]))
func _draw() -> void:
	host.ModeUI.cover(self,SKY,Rect2(Vector2.ZERO,size))
	draw_texture_rect(FRAME,panel_rect,false)
	var y: float=panel_rect.position.y
	fade_line(Vector2(panel_rect.position.x+44,y+65),Vector2(panel_rect.end.x-44,y+65))
	O.gem(self,Vector2(size.x/2,y+65),5)
	fade_line(Vector2(size.x/2,y+86),Vector2(size.x/2,y+387),.75)
	draw_texture_rect(FLOURISH,Rect2(size.x/2-8,y+221,16,23),false)
	for item in headings:
		draw_texture_rect(FLOURISH,Rect2(item.p,Vector2(17,24)),false)
		if item.end.x>item.start.x: fade_line(item.start,item.end)
	if picker_rect.size.x>0:
		var style:=StyleBoxFlat.new(); style.bg_color=Color("061625"); style.border_color=Color("b88c4c"); style.set_border_width_all(1); style.set_corner_radius_all(5)
		draw_style_box(style,picker_rect)
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
