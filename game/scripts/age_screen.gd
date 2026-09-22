extends Control
const O=preload("res://scripts/ornaments.gd")
const SKY=preload("res://assets/art/endless/sky-court.png")
const FRAME=preload("res://assets/ui/settings/frame.svg")
var host
var kind := "age"
var result_mode := false
var selected := -1
var form: Control
var panel: Rect2
var old_touch := false
var error := false
var deleting := false
var delete_status := ""
var privacy_copy: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/privacy-copy.json"))
func privacy_text(key: String) -> String:
	var index := ["en","sr","de","fr","es","it"].find(host.save.data.ui_language)
	return privacy_copy[key][maxi(index,0)]
func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	z_index=200; mouse_filter=Control.MOUSE_FILTER_STOP
	old_touch=Input.emulate_mouse_from_touch; Input.emulate_mouse_from_touch=true
	form=Control.new(); form.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(form)
	resized.connect(rebuild); rebuild()
func words(key: String) -> String: return host.age_text(key)
func label(value: String, rect: Rect2, pixels := 18, gold := false) -> Label:
	var item := Label.new(); item.text=value; item.position=rect.position; item.size=rect.size
	item.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; item.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	item.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; item.mouse_filter=Control.MOUSE_FILTER_IGNORE
	item.add_theme_font_override("font",host.title_font if gold else host.font)
	item.add_theme_font_size_override("font_size",pixels); item.add_theme_color_override("font_color",host.GOLD if gold else host.CREAM)
	form.add_child(item); item.size=rect.size; return item
func button(value: String, rect: Rect2, callback: Callable, chosen := false) -> Button:
	var b=preload("res://scripts/settings_button.gd").new(); b.text=value; b.position=rect.position; b.size=rect.size
	b.face=host.font; b.pixels=18; b.kind=0; b.selected=chosen; b.calm=host.save.data.calm
	b.pressed.connect(callback); form.add_child(b); return b
func rebuild() -> void:
	for child in form.get_children(): form.remove_child(child); child.queue_free()
	var w: float=minf(780,size.x-32)
	panel=Rect2((size.x-w)/2,18,w,size.y-36)
	var x: float=panel.position.x; var y: float=panel.position.y
	label(words("title" if kind=="age" else "records" if kind=="records" else "privacy"),Rect2(x+95,y+24,w-190,40),27,true)
	if kind=="delete_confirm":
		label(privacy_text("confirm"),Rect2(x+50,y+88,w-100,155),19)
		if not delete_status.is_empty(): label(privacy_text(delete_status),Rect2(x+55,y+247,w-110,68),16)
		var accept:=button(privacy_text("working" if deleting else "yes"),Rect2(size.x/2-230,panel.end.y-83,280,44),delete_online)
		accept.disabled=deleting
		var cancel:=button(privacy_text("cancel"),Rect2(size.x/2+65,panel.end.y-83,170,44),func(): kind="info"; delete_status=""; rebuild())
		cancel.disabled=deleting
	elif kind=="age":
		label(words("question"),Rect2(x+45,y+80,w-90,58),18)
		var labels: Array=[words("under"),"13–17","18+"]
		for i in 3:
			button(labels[i],Rect2(x+55+i*(w-100)/3,y+180,(w-130)/3,52),func(): selected=i; rebuild(),selected==i).name="AgeChoice%d" % i
		label(words("error" if error else "local"),Rect2(x+60,y+271,w-120,52),15)
		var confirm:=button(words("save"),Rect2(size.x/2-130,panel.end.y-73,260,46),confirm_age)
		confirm.disabled=selected<0; confirm.modulate=Color(.5,.5,.5) if selected<0 else Color.WHITE; confirm.add_theme_color_override("font_disabled_color",Color.TRANSPARENT); confirm.name="ConfirmAge"
		# Language choice does not select an age or disclose feature differences.
		var lang:=button(host.save.data.ui_language.to_upper(),Rect2(panel.end.x-92,y+31,54,28),func():
			var codes=host.AgePolicy.COPY["title"]
			var languages=["en","sr","de","fr","es","it"]
			host.save.data.ui_language=languages[(languages.find(host.save.data.ui_language)+1)%codes.size()]; rebuild())
		lang.pixels=13
	else:
		label(words("older" if host.online_allowed() else "restricted"),Rect2(x+50,y+81,w-100,105),17)
		if kind=="records":
			var lines: Array[String]=[]
			if result_mode: lines.append(host.t("SCORE")+": "+str(host.endless_score)+"   ·   "+host.t("WAVE")+": "+str(host.endless_wave))
			for key in host.save.data.endless_records:
				var record: Dictionary=host.save.data.endless_records[key]
				lines.append(host.t("ENDLESS WORDS")+" · "+record_name(str(key))+"   ·   "+str(record.get("score",0))+"   ·   "+host.t("WAVE")+" "+str(record.get("wave",0)))
			for key in host.save.data.practice_records:
				lines.append(words("practice")+" · "+record_name(str(key))+" · "+str(host.save.data.practice_records[key]))
			var sc:=ScrollContainer.new(); sc.position=Vector2(x+55,y+203); sc.size=Vector2(w-110,panel.size.y-294); sc.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED; form.add_child(sc)
			var content:=Label.new(); content.text="\n".join(lines) if not lines.is_empty() else words("empty"); content.add_theme_font_override("font",host.font); content.add_theme_font_size_override("font_size",18); content.add_theme_color_override("font_color",host.CREAM); content.size_flags_horizontal=Control.SIZE_EXPAND_FILL; content.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; sc.add_child(content)
		else:
			label(privacy_text("done") if delete_status=="done" else words("local"),Rect2(x+60,y+186,w-120,52),16)
			button(privacy_text("policy"),Rect2(x+55,y+249,w-110,34),func(): OS.shell_open("https://gottaplay.net/wow/privacy/"))
			button(privacy_text("web"),Rect2(x+55,y+290,w-110,34),func(): OS.shell_open("https://gottaplay.net/wow/delete-data/"))
			if host.online_allowed(): button(privacy_text("delete"),Rect2(x+55,y+331,w-110,34),func(): kind="delete_confirm"; delete_status=""; rebuild())
		button(host.t("GOT IT"),Rect2(size.x/2-130,panel.end.y-70,260,44),leave)
	queue_redraw()

func delete_online() -> void:
	if deleting: return
	if host.rankings.busy:
		delete_status="failed"; rebuild(); return
	deleting=true; delete_status=""; rebuild()
	var result: Dictionary = await host.daily_screen.service.delete_profile()
	deleting=false
	if result.get("deleted",false):
		host.save.data.endless_outbox.clear()
		host.save.save_game()
		host.rankings.sent_runs.clear()
		host.daily_screen.pending.clear()
		host.daily_screen.leaderboard.clear()
		host.daily_screen.attempt.clear()
		if FileAccess.file_exists(host.daily_screen.pending_path): DirAccess.remove_absolute(host.daily_screen.pending_path)
		kind="info"; delete_status="done"
	else: delete_status="failed"
	rebuild()
func record_name(key: String) -> String:
	var parts:=key.split("_")
	var language: String=preload("res://scripts/languages.gd").NAMES.get(parts[0],parts[0].to_upper())
	return language+" / "+host.t("ADJACENT" if key.ends_with("adjacent") else "ANY LETTERS")
func confirm_age() -> void:
	if selected<0 or selected>2: return
	var previous: String=host.save.data.get("age_group","")
	host.save.data.age_group=host.AgePolicy.GROUPS[selected]
	if not host.save.save_game(): host.save.data.age_group=previous; error=true; rebuild(); return
	kind="info"; rebuild()
func leave() -> void:
	if kind=="age" or deleting: return
	if result_mode: host.change_screen("home")
	host.age_screen=null; queue_free()
func _exit_tree() -> void: Input.emulate_mouse_from_touch=old_touch
func _draw() -> void:
	host.ModeUI.cover(self,SKY,Rect2(Vector2.ZERO,size))
	draw_rect(Rect2(Vector2.ZERO,size),Color(.015,.035,.065,.52))
	draw_texture_rect(FRAME,panel,false)
	O.gem(self,Vector2(size.x/2,panel.position.y+73),6)
	for side in [-1,1]:
		draw_line(Vector2(size.x/2+side*19,panel.position.y+73),Vector2(size.x/2+side*(panel.size.x/2-60),panel.position.y+73),Color("997a44"),1,true)
