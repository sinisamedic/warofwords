extends Control
## Separate screen: campaign save, upgrades and dictionary settings are never modified.
signal closed
const Rules = preload("res://scripts/daily_rules.gd")
const Lexicon = preload("res://scripts/lexicon.gd")
const Service = preload("res://scripts/daily_service.gd")
const Ornaments = preload("res://scripts/ornaments.gd")
const GOLD := Color("f3c569")
const CREAM := Color("fff1ce")
const INK := Color("10283d")
var host: Control
var service: Node
var rules = Rules.new()
var lex: RefCounted
var mode := "lobby"
var language := "en"
var adjacent := true
var ranked := false
var deadline := 0
var start_ticks := 0
var elapsed_offset := 0
var start_unix := 0.0
var attempt: Dictionary = {}
var pending: Dictionary = {}
var leaderboard: Dictionary = {}
var page := 0
var status := ""
var selection: Array[int] = []
var dragging := false
var drag_moved := false
var pointer := -1
var drag_position := Vector2.ZERO
var ui: Control
var nickname: LineEdit
var profile_path := "user://daily-profile.json"
var pending_path := "user://daily-pending.json"
var requesting := false
var local_nickname := ""
var busy_label := ""
const BACKDROP = preload("res://assets/art/campaign-observatory.png")
var previous_touch_emulation := false

func tr_daily(en: String, sr: String) -> String:
	return sr if host.save.data.ui_language=="sr" else en

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	service=Service.new(); add_child(service)
	ui=Control.new(); ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter=Control.MOUSE_FILTER_IGNORE; add_child(ui)
	if FileAccess.file_exists(profile_path):
		var profile=JSON.parse_string(FileAccess.get_file_as_string(profile_path))
		if profile is Dictionary: local_nickname=str(profile.get("nickname",""))
	if FileAccess.file_exists(pending_path):
		var saved=JSON.parse_string(FileAccess.get_file_as_string(pending_path))
		if saved is Dictionary:
			pending={str(saved.id):saved} if saved.has("id") else saved

func open() -> void:
	previous_touch_emulation=Input.emulate_mouse_from_touch
	Input.emulate_mouse_from_touch=true
	visible=true; mode="lobby"; status=""; leaderboard={}; page=0
	language=host.save.data.word_language; adjacent=host.save.data.adjacent_only
	rebuild()
	if service.configured(): await refresh_leaderboard()

func button(label: String, rect: Rect2, callback: Callable, enabled := true) -> void:
	var item := Button.new()
	item.text=label; item.position=rect.position; item.size=rect.size
	item.disabled=not enabled or requesting
	item.add_theme_font_override("font",host.font)
	item.add_theme_font_size_override("font_size",19)
	var primary := label in ["PLAY RANKED","RANGIRANI POKUŠAJ","SUBMIT","POTVRDI","LEADERBOARD","RANG-LISTA"]
	for color_name in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
		item.add_theme_color_override(color_name,INK if primary else CREAM)
	item.add_theme_color_override("font_disabled_color",Color("85939c"))
	for style_name in ["normal","hover","pressed","disabled","focus"]:
		var style = preload("res://scripts/button_frame_style.gd").new()
		style.kind=1 if primary else 0
		style.content_margin_left=18; style.content_margin_right=18
		style.tint=Color(.55,.55,.55) if style_name=="disabled" else Color(.8,.8,.8) if style_name=="pressed" else Color(1.12,1.12,1.12) if style_name in ["hover","focus"] else Color.WHITE
		item.add_theme_stylebox_override(style_name,style)
	item.pressed.connect(callback); ui.add_child(item)

func rebuild() -> void:
	if nickname!=null and is_instance_valid(nickname): local_nickname=nickname.text
	for child in ui.get_children():
		ui.remove_child(child); child.queue_free()
	nickname=null
	button(tr_daily("BACK","NAZAD"),Rect2(22,16,100,46),leave)
	if mode=="lobby":
		var w := size.x*.48-44
		nickname=LineEdit.new(); nickname.text=local_nickname
		nickname.placeholder_text=tr_daily("Nickname (3–20 characters)","Nadimak (3–20 znakova)")
		nickname.max_length=20; nickname.position=Vector2(38,117); nickname.size=Vector2(w,42)
		nickname.add_theme_font_override("font",host.font); nickname.add_theme_font_size_override("font_size",20)
		nickname.add_theme_color_override("font_color",CREAM)
		nickname.add_theme_color_override("font_placeholder_color",Color("acbcc3"))
		var entry := StyleBoxFlat.new()
		entry.bg_color=Color("091d2e"); entry.border_color=Color("a88a51")
		entry.set_border_width_all(1); entry.set_corner_radius_all(7)
		entry.content_margin_left=12; entry.content_margin_right=12
		nickname.add_theme_stylebox_override("normal",entry)
		nickname.add_theme_stylebox_override("focus",entry)
		nickname.editable=not requesting; ui.add_child(nickname)
		button("EN" if language=="en" else "SR",Rect2(38,174,90,42),toggle_language)
		button(tr_daily("Adjacent","Susedna") if adjacent else tr_daily("Any letters","Bilo koja"),Rect2(140,174,w-102,42),toggle_rule)
		button(tr_daily("PLAY RANKED","RANGIRANI POKUŠAJ"),Rect2(38,276,w,48),start_ranked,service.configured())
		button(tr_daily("PRACTICE","VEŽBAJ"),Rect2(38,337,w,48),start_practice)
		button(tr_daily("REFRESH","OSVEŽI"),Rect2(size.x-174,91,136,40),refresh_leaderboard,service.configured())
		button("<",Rect2(size.x*.53,390,48,44),func(): page=maxi(0,page-1); queue_redraw())
		button(">",Rect2(size.x-86,390,48,44),func(): page=mini(maxi(0,(leaderboard.get("rows",[]).size()-1)/6),page+1); queue_redraw())
	elif mode=="running":
		button(tr_daily("CLEAR","OBRIŠI"),Rect2(size.x/2-170,432,150,38),func(): selection.clear(); queue_redraw())
		button(tr_daily("SUBMIT","POTVRDI"),Rect2(size.x/2+20,432,150,38),submit_word)
	elif mode=="result":
		button(tr_daily("LEADERBOARD","RANG-LISTA"),Rect2(size.x/2-230,374,220,48),show_lobby)
		if ranked and not bool(attempt.get("verified",false)) and not bool(attempt.get("expired",false)):
			button(tr_daily("RETRY UPLOAD","PONOVI SLANJE"),Rect2(size.x/2+10,374,220,48),upload_result)
		else:
			button(tr_daily("PRACTICE AGAIN","VEŽBAJ PONOVO"),Rect2(size.x/2+10,374,220,48),start_practice)
	queue_redraw()

func toggle_language() -> void:
	language="sr" if language=="en" else "en"; leaderboard={}; page=0; status=""; rebuild()
	if service.configured(): await refresh_leaderboard()

func toggle_rule() -> void:
	adjacent=not adjacent; leaderboard={}; page=0; status=""; rebuild()
	if service.configured(): await refresh_leaderboard()

func leave() -> void:
	if requesting: return
	if mode=="running":
		# Leaving ends the local play; ranked time still expires on the server.
		mode="confirm_leave"; selection.clear(); dragging=false; pointer=-1
		rebuild()
		button(tr_daily("KEEP PLAYING","NASTAVI"),Rect2(size.x/2-230,290,220,48),func(): mode="running"; rebuild())
		button(tr_daily("LEAVE CHALLENGE","NAPUSTI IZAZOV"),Rect2(size.x/2+10,290,220,48),close_screen)
	else:
		close_screen()

func close_screen() -> void:
	Input.emulate_mouse_from_touch=previous_touch_emulation
	visible=false; closed.emit()

func _exit_tree() -> void:
	if visible: Input.emulate_mouse_from_touch=previous_touch_emulation

func show_lobby() -> void:
	mode="lobby"; status=""; rebuild()
	if service.configured(): await refresh_leaderboard()

func refresh_leaderboard() -> void:
	if requesting: return
	requesting=true; status=tr_daily("Loading…","Učitavanje…"); rebuild()
	var response: Dictionary=await service.call_api("leaderboard",{"language":language,"adjacent":adjacent})
	requesting=false
	if response.has("error"): status=tr_daily("Could not load online results.","Mrežni rezultati nisu dostupni.")
	else: leaderboard=response; status=""; page=0
	rebuild()

func prepare_lexicon() -> void:
	# Campaign may own an unfinished board: share only immutable dictionary data.
	var previous_lexicon: RefCounted=host.lex
	await host.select_dictionary(language)
	lex=Lexicon.new(false,language)
	lex.words=host.lex.words; lex.prefixes=host.lex.prefixes
	lex.adjacent_only=adjacent
	host.lex=previous_lexicon

func start_practice() -> void:
	if requesting: return
	requesting=true; status=tr_daily("Preparing…","Priprema…"); rebuild()
	await prepare_lexicon()
	var day := Time.get_date_string_from_system(true)
	var seed_value := ("practice:"+day+language+str(adjacent)).sha256_text().left(7).hex_to_int()+1
	rules.begin(seed_value,language,adjacent)
	ranked=false; attempt={}; elapsed_offset=0; start_ticks=Time.get_ticks_msec(); deadline=start_ticks+Rules.DURATION_MS
	start_unix=Time.get_unix_time_from_system()
	requesting=false; mode="running"; status=""; selection.clear(); rebuild()

func start_ranked() -> void:
	if requesting: return
	local_nickname=nickname.text.strip_edges()
	var regex := RegEx.new(); regex.compile("^[\\p{L}\\p{N} _-]{3,20}$")
	if regex.search(local_nickname)==null:
		status=tr_daily("Use 3–20 letters, numbers, spaces, _ or -.","Unesi 3–20 slova, brojeva, razmaka, _ ili -."); queue_redraw(); return
	var profile := FileAccess.open(profile_path,FileAccess.WRITE)
	if profile==null: status=tr_daily("Could not save profile.","Profil nije sačuvan."); return
	profile.store_string(JSON.stringify({"nickname":local_nickname})); profile.close()
	requesting=true; status=tr_daily("Connecting…","Povezivanje…"); rebuild()
	await prepare_lexicon()
	var response: Dictionary=await service.call_api("start",{"language":language,"adjacent":adjacent,"nickname":local_nickname})
	requesting=false
	if response.has("error"):
		status=tr_daily("Could not start. Check connection and server setup.","Pokušaj nije pokrenut. Proveri vezu i server."); rebuild(); return
	attempt=response; ranked=true
	if bool(response.get("finished",false)):
		rules.score=int(response.score); attempt.verified=true; mode="result"
		status=tr_daily("Today's result is already verified.","Današnji rezultat je već potvrđen."); rebuild(); return
	rules.begin(int(response.seed),language,adjacent)
	var saved_attempt: Dictionary=pending.get(str(response.id),{})
	if saved_attempt.get("language","")==language and bool(saved_attempt.get("adjacent",false))==adjacent:
		for move in saved_attempt.get("moves",[]):
			var replay_path: Array[int]=[]
			for cell in move.get("path",[]): replay_path.append(int(cell))
			if not rules.accept(replay_path,int(move.get("ms",-1)),lex):
				status=tr_daily("Saved attempt is invalid.","Sačuvani pokušaj nije ispravan."); mode="result"; rebuild(); return
	# Use the server's remaining duration; request time may include cold-start/auth work.
	# The server's own clock remains the authority for accepting the final submission.
	var remaining := maxi(0,int(response.remaining_ms))
	elapsed_offset=Rules.DURATION_MS-remaining
	start_ticks=Time.get_ticks_msec(); deadline=start_ticks+remaining
	start_unix=Time.get_unix_time_from_system()
	mode="running"; status=""; selection.clear(); save_pending(); rebuild()
	if remaining==0: finish_run()

func save_pending() -> void:
	if not ranked: return
	pending[str(attempt.id)]={"id":attempt.id,"language":language,"adjacent":adjacent,"moves":rules.moves.duplicate(true)}
	while pending.size()>8: pending.erase(pending.keys()[0])
	var file := FileAccess.open(pending_path+".tmp",FileAccess.WRITE)
	if file==null: status=tr_daily("Could not save attempt.","Pokušaj nije sačuvan."); return
	file.store_string(JSON.stringify(pending)); file.close()
	DirAccess.rename_absolute(ProjectSettings.globalize_path(pending_path+".tmp"),ProjectSettings.globalize_path(pending_path))

func submit_word() -> void:
	if mode!="running": return
	var elapsed := Rules.DURATION_MS-remaining_ms()
	if elapsed>=Rules.DURATION_MS: finish_run(); return
	var word: String=rules.word_at(selection)
	if rules.accept(selection,elapsed,lex):
		status=word; host.sfx.play("word"); save_pending()
	else: status=tr_daily("Invalid, repeated or too short.","Nevažeća, ponovljena ili prekratka reč.")
	selection.clear(); queue_redraw()

func finish_run() -> void:
	if mode not in ["running","confirm_leave"]: return
	mode="result"; selection.clear(); dragging=false; pointer=-1; save_pending()
	status=tr_daily("Practice only — not on the global list.","Vežba — rezultat ne ulazi na globalnu listu.")
	rebuild()
	if ranked: await upload_result()

func upload_result() -> void:
	if requesting or not ranked: return
	requesting=true; status=tr_daily("Verifying result…","Provera rezultata…"); rebuild()
	# Allow for network clock estimation; server requires the entire 120-second window.
	await get_tree().create_timer(1.2).timeout
	var result: Dictionary=await service.call_api("submit",{"id":attempt.id,"language":language,"adjacent":adjacent,"moves":rules.moves})
	requesting=false
	if bool(result.get("verified",false)):
		rules.score=int(result.score); attempt.verified=true
		status=tr_daily("Verified on the global leaderboard.","Potvrđeno na globalnoj rang-listi.")
	elif int(result.get("status",0))==410:
		attempt.expired=true
		status=tr_daily("Submission expired. This score is not ranked.","Rok je istekao. Rezultat nije rangiran.")
	else:
		status=tr_daily("Not uploaded. Retry within 30 seconds of the end.","Nije poslato. Ponovi u roku od 30 s od kraja.")
	rebuild()

func remaining_ms() -> int:
	# Monotonic time resists clock rollback; wall time also covers device deep sleep.
	var wall_elapsed := maxi(0,int((Time.get_unix_time_from_system()-start_unix)*1000))
	return maxi(0,mini(deadline-Time.get_ticks_msec(),Rules.DURATION_MS-elapsed_offset-wall_elapsed))

func _process(_delta: float) -> void:
	if not visible: return
	if mode in ["running","confirm_leave"] and remaining_ms()==0: finish_run()
	queue_redraw()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_APPLICATION_PAUSED]:
		selection.clear(); dragging=false; pointer=-1
	if what==NOTIFICATION_RESIZED and is_instance_valid(ui): rebuild()

func label(value: String, rect: Rect2, font_size := 22, color := CREAM, heading := false) -> void:
	var face: Font=host.title_font if heading else host.font
	while font_size>12 and face.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>rect.size.x:
		font_size-=1
	draw_string(face,Vector2(rect.position.x,rect.position.y+(rect.size.y-face.get_height(font_size))/2+face.get_ascent(font_size)),value,HORIZONTAL_ALIGNMENT_CENTER,rect.size.x,font_size,color)

func tile_rect(i: int) -> Rect2:
	return Rect2(size.x/2-224+(i%7)*64,164+(i/7)*64,56,56)

func _draw() -> void:
	if host==null: return
	var source := Rect2(Vector2.ZERO,BACKDROP.get_size())
	var ratio := size.x/size.y
	if source.size.x/source.size.y>ratio:
		source.size.x=source.size.y*ratio; source.position.x=(BACKDROP.get_width()-source.size.x)/2
	else:
		source.size.y=source.size.x/ratio; source.position.y=(BACKDROP.get_height()-source.size.y)*.35
	draw_texture_rect_region(BACKDROP,Rect2(Vector2.ZERO,size),source)
	draw_rect(Rect2(Vector2.ZERO,size),Color(.015,.045,.085,.47))
	Ornaments.plaque(self,Rect2(size.x/2-215,12,430,54))
	label(tr_daily("DAILY CHALLENGE","DNEVNI IZAZOV"),Rect2(size.x/2-190,16,380,42),28,GOLD,true)
	if mode=="lobby":
		Ornaments.frame(self,Rect2(22,85,size.x*.48-12,350),2)
		Ornaments.frame(self,Rect2(size.x*.51,85,size.x*.49-22,350),2)
		label(tr_daily("YOUR PROFILE","TVOJ PROFIL"),Rect2(38,87,size.x*.48-44,27),18,GOLD,true)
		label(tr_daily("120 seconds · no hints or upgrades","120 sekundi · bez pomoći i unapređenja"),Rect2(32,226,size.x*.48-25,25),16)
		label(tr_daily("One ranked attempt per day/category","Jedan pokušaj dnevno po kategoriji"),Rect2(32,250,size.x*.48-25,22),16)
		label(tr_daily("GLOBAL RANKING","RANG-LISTA"),Rect2(size.x*.52,94,size.x*.48-214,27),17,GOLD,true)
		if not service.configured():
			label(tr_daily("Online service is not connected yet.","Online servis još nije povezan."),Rect2(size.x*.52,209,size.x*.48-40,30),18)
			label(tr_daily("Practice is available.","Vežbanje je dostupno."),Rect2(size.x*.52,242,size.x*.48-40,30),18)
		elif leaderboard.is_empty():
			label(tr_daily("Loading results…","Učitavanje rezultata…") if requesting else tr_daily("Refresh to retry.","Osveži za novi pokušaj."),Rect2(size.x*.52,215,size.x*.48-40,30),18)
		else:
			var rows: Array=leaderboard.get("rows",[])
			if rows.is_empty(): label(tr_daily("No verified results yet.","Još nema potvrđenih rezultata."),Rect2(size.x*.52,215,size.x*.48-40,30),18)
			for i in mini(6,maxi(0,rows.size()-page*6)):
				var row: Dictionary=rows[page*6+i]
				var row_color := GOLD if row.get("own",false) else CREAM
				var row_rect := Rect2(size.x*.52+8,145+i*39,size.x*.48-42,35)
				draw_rect(row_rect,Color(.65,.46,.16,.23) if row.get("own",false) else Color(.4,.65,.8,.055) if i%2==0 else Color(0,0,0,.1))
				if row.get("own",false): draw_rect(Rect2(row_rect.position,Vector2(3,35)),GOLD)
				label(str(int(row.position))+".",Rect2(size.x*.52,145+i*39,44,35),19,row_color)
				label(str(row.nickname).left(20),Rect2(size.x*.52+48,145+i*39,size.x*.48-165,35),18,row_color)
				label(str(int(row.score)),Rect2(size.x-112,145+i*39,76,35),19,row_color)
			label(str(leaderboard.get("day",""))+" UTC · "+str(int(leaderboard.get("total",0))),Rect2(size.x*.59,397,size.x*.28,28),14)
	elif mode=="running":
		Ornaments.frame(self,Rect2(size.x/2-243,153,486,273),2)
		draw_texture_rect(Ornaments.WEAVE,Rect2(size.x/2-228,162,456,253),true,Color(1,1,1,.28))
		Ornaments.frame(self,Rect2(22,78,240,42))
		Ornaments.frame(self,Rect2(size.x-262,78,240,42))
		var seconds := maxi(0,int(ceil(remaining_ms()/1000.0)))
		label((tr_daily("RANKED","RANGIRANO") if ranked else tr_daily("PRACTICE","VEŽBA"))+"  ·  "+language.to_upper(),Rect2(22,78,240,42),22,GOLD)
		label("%d:%02d" % [seconds/60,seconds%60],Rect2(size.x/2-90,75,180,45),34,Color("ff997e") if seconds<=15 else GOLD)
		label(tr_daily("Score: ","Bodovi: ")+str(rules.score),Rect2(size.x-260,78,240,42),24)
		var selected_word := ""
		for index in selection: selected_word+=rules.letters[index]
		label(selected_word if not selected_word.is_empty() else status,Rect2(24,123,size.x-48,32),21)
		for i in 28:
			var rect := tile_rect(i)
			Ornaments.jewel(self,rect.get_center(),27,Ornaments.PALETTE[0] if i in selection else Color("416779"),i in selection)
			label(rules.letters[i],rect,27,INK if i in selection else CREAM)
		for i in range(1,selection.size()): draw_line(tile_rect(selection[i-1]).get_center(),tile_rect(selection[i]).get_center(),Color(1,.85,.4,.4),4,true)
	elif mode=="result":
		var panel := Rect2(size.x/2-300,110,600,328)
		Ornaments.frame(self,panel,2)
		draw_texture_rect(Ornaments.FILIGREE,panel,false)
		Ornaments.glow(self,Vector2(size.x/2,228),132,Color(1,.72,.24,.24))
		draw_texture_rect(Ornaments.CRESTS[1],Rect2(size.x/2-77,72,154,100),false)
		label(tr_daily("CHALLENGE COMPLETE","IZAZOV ZAVRŠEN"),Rect2(size.x/2-275,166,550,35),26,GOLD,true)
		label(str(rules.score),Rect2(size.x/2-200,206,400,73),64,GOLD,true)
		label(tr_daily("POINTS","BODOVA"),Rect2(size.x/2-200,280,400,24),17)
		label(language.to_upper()+"  ·  "+(tr_daily("ADJACENT","SUSEDNA SLOVA") if adjacent else tr_daily("ANY LETTERS","BILO KOJA SLOVA")),Rect2(size.x/2-260,311,520,23),15,Color("a8c5d4"))
		label(status,Rect2(size.x/2-275,340,550,26),17,Color("9ee3c6") if attempt.get("verified",false) else CREAM)
	elif mode=="confirm_leave":
		Ornaments.frame(self,Rect2(size.x/2-320,140,640,220),2)
		label(tr_daily("Leave? The challenge timer keeps running.","Napusti izazov? Vreme nastavlja da teče."),Rect2(30,175,size.x-60,65),25,GOLD)
	if mode=="lobby": label(status,Rect2(24,443,size.x-48,26),17,GOLD)

func cell_at(point: Vector2) -> int:
	for i in 28:
		if tile_rect(i).has_point(point): return i
	return -1

func add_cell(i: int) -> void:
	if i<0: return
	if selection.size()>1 and selection[-2]==i: selection.pop_back(); return
	if i in selection: return
	if adjacent and not selection.is_empty():
		var before: int=selection.back()
		if absi(i%7-before%7)>1 or absi(i/7-before/7)>1: return
	selection.append(i)
	host.sfx.play("tap",1+selection.size()*.035)
	host.haptic(10,.25)

func _input(event: InputEvent) -> void:
	if not visible or mode!="running": return
	var point := Vector2.ZERO
	var press := false
	var release := false
	var motion := false
	if event is InputEventScreenTouch:
		if event.pressed and pointer==-1: pointer=event.index; press=true
		elif not event.pressed and event.index==pointer:
			pointer=-1; release=true
			if event.canceled: selection.clear(); dragging=false; return
		point=event.position
	elif event is InputEventScreenDrag and event.index==pointer: motion=true; point=event.position
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and pointer==-1:
		press=event.pressed; release=not event.pressed; point=event.position
	elif event is InputEventMouseMotion and pointer==-1 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): motion=true; point=event.position
	else: return
	point=get_global_transform_with_canvas().affine_inverse()*point
	if press and cell_at(point)>=0:
		dragging=true; drag_moved=false; drag_position=point; add_cell(cell_at(point))
	elif motion and dragging:
		if point.distance_to(drag_position)>8: drag_moved=true
		var steps := maxi(1,int(ceil(point.distance_to(drag_position)/12)))
		for step in range(1,steps+1): add_cell(cell_at(drag_position.lerp(point,float(step)/steps)))
		drag_position=point
	elif release and dragging:
		dragging=false
		if drag_moved: submit_word()
