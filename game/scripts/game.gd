extends Control

const Lexicon = preload("res://scripts/lexicon.gd")
const SaveData = preload("res://scripts/save_data.gd")
const Sound = preload("res://scripts/sound.gd")
const Ornaments = preload("res://scripts/ornaments.gd")
const Portrait = preload("res://scripts/portrait.gd")
const Localization = preload("res://scripts/localization.gd")
const Actor = preload("res://scripts/actor.gd")
const CREAM := Color("fff1ce")
const GOLD := Color("f3c569")
const INK := Color("10283d")
const COLORS := [Color("ffd053"),Color("78bfff"),Color("b896f5"),Color("62dcb5")]
const NAMES := ["PULSE","AEGIS","ARC","MEND"]
const ROLES := ["Direct energy blast","Block the next attack","Strike and interrupt","Restore your health"]
const COSTS := [4,5,7,5]
const POWER_NAMES := ["TIME FREEZE","FRESH BOARD","OVERCHARGE"]
const POWER_DESC := ["Stop the enemy for 8s","A new field of letters","Double your next word"]
const REGIONS := ["SUNWARD RUINS","THE SKY BRIDGES","THE OBSERVATORY"]
const ENEMIES := ["Training Sentinel","Copper Scout","Gatekeeper","BRONZE WARDEN","Sky Watcher","Storm Sentinel","Bridge Guardian","TEMPEST WARDEN","Astral Sentinel","Archive Keeper","Sunforged Elite","THE LAST WARDEN"]

var font: Font = preload("res://assets/fonts/Lato-Bold.ttf")
var title_font: Font = preload("res://assets/fonts/Cinzel.ttf")
var arena: Texture2D = preload("res://assets/art/arena.png")
var map_art: Texture2D = preload("res://assets/art/map.png")
var fighters: Texture2D = preload("res://assets/art/fighters.png")
var lex = Lexicon.new(false)
var lexicons: Dictionary = {}
var portraits: Array[Sprite2D] = []
var tap_composition := false
var loading := true
var dictionary_thread: Thread
var save = SaveData.new()
var sfx: Node
var hero: Sprite2D
var enemy_actor: Sprite2D
var screen := "home"
var previous := "home"
var selected := 0
var mission := 0
var chapter := 0
var overlay := ""
var buttons: Array[Dictionary] = []
var buttons_state := ""
var hitboxes: Array[Rect2] = []
var pressed_action := ""
var pressed_value := -1
var touch_id := -1
var dragging := false
var drag_moved := false
var drag_position := Vector2.ZERO
var path: Array[int] = []
var hint_path: Array[int] = []
var hint_time := 0.0
var notice := ""
var notice_time := 0.0
var clock := 0.0
var attack_flash := 0.0
var hero_flash := 0.0
var projectiles: Array[Dictionary] = []
var sparks: Array[Dictionary] = []
var hp := 100
var foe_hp := 80
var foe_max := 80
var energy: Array[int] = [0,0,0,0]
var shield := 0
var countdown := 12.0
var freeze := 0.0
var surge := false
var boost_used := false
var used: Dictionary = {}
var word_count := 0
var best_word := ""
var duration := 0.0
var ended := false
var won := false
var reward := 0
var stars := 0
var enemy_attacks := 0
var shuffled := 0
var journal_page := 0
var autosave_clock := 0.0
var fps_label := false
var debug_sample_at := 0

func _ready() -> void:
	Engine.max_fps = 60
	Input.use_accumulated_input = false
	var heading := FontVariation.new()
	heading.base_font = title_font
	heading.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"):800}
	title_font = heading
	save.load_game()
	lex = Lexicon.new(false, save.data.word_language)
	lexicons[lex.language] = lex
	mission = save.data.unlocked
	chapter = mission / 4
	sfx = Sound.new()
	add_child(sfx)
	sfx.enabled = save.data.sound
	hero = Actor.new()
	enemy_actor = Actor.new()
	hero.setup(fighters,false)
	enemy_actor.setup(fighters,true)
	add_child(hero)
	add_child(enemy_actor)
	hero.z_index = -1
	enemy_actor.z_index = -1
	for opponent in [false,true]:
		var portrait = Portrait.new()
		portrait.setup(fighters,opponent)
		add_child(portrait)
		portraits.append(portrait)
	# Background is drawn by a sibling behind both actors; HUD is drawn by this Control.
	var backdrop := Node2D.new()
	backdrop.name = "Backdrop"
	backdrop.z_index = -2
	backdrop.draw.connect(_draw_backdrop.bind(backdrop))
	add_child(backdrop)
	resized.connect(func(): queue_redraw(); backdrop.queue_redraw())
	get_tree().auto_accept_quit = false
	queue_redraw()
	dictionary_thread = Thread.new()
	dictionary_thread.start(lex.load_dictionary)
	call_deferred("finish_loading")
	if "--qa" in OS.get_cmdline_user_args():
		call_deferred("_run_visual_qa")

func finish_loading() -> void:
	while dictionary_thread.is_alive():
		await get_tree().process_frame
	dictionary_thread.wait_to_finish()
	dictionary_thread = null
	loading = false
	if OS.is_debug_build():
		print("WarOfWords: ready")
	queue_redraw()

func select_dictionary(code: String) -> void:
	if lexicons.has(code):
		lex = lexicons[code]
		return
	loading = true
	lex = Lexicon.new(false,code)
	lexicons[code] = lex
	dictionary_thread = Thread.new()
	dictionary_thread.start(lex.load_dictionary)
	await finish_loading()

func t(value: String) -> String:
	return Localization.translate(value,save.data.get("ui_language","en"))

func _exit_tree() -> void:
	if dictionary_thread != null:
		dictionary_thread.wait_to_finish()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if screen == "battle" and not ended:
			overlay = "pause"
			path.clear()
			dragging = false
			touch_id = -1
			persist_battle()
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		back()
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		persist_battle()
		get_tree().quit()

func _process(delta: float) -> void:
	if OS.is_debug_build() and Time.get_ticks_msec()-debug_sample_at >= 15000:
		debug_sample_at=Time.get_ticks_msec()
		print("WarOfWords: performance screen=%s fps=%d draw_calls=%d" % [screen,Engine.get_frames_per_second(),RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)])
	clock += delta
	notice_time = maxf(0,notice_time-delta)
	hint_time = maxf(0,hint_time-delta)
	attack_flash = maxf(0,attack_flash-delta)
	hero_flash = maxf(0,hero_flash-delta)
	var active := screen == "battle" and overlay.is_empty() and not ended and not loading
	if active:
		duration += delta
		if freeze > 0:
			freeze = maxf(0,freeze-delta)
		else:
			countdown -= delta
			if countdown <= 0:
				enemy_attack()
		autosave_clock += delta
		if autosave_clock >= 5:
			autosave_clock = 0
			persist_battle()
	for p in projectiles:
		p.time += delta
	projectiles = projectiles.filter(func(p): return p.time < 0.5)
	for p in sparks:
		p.time += delta
	sparks = sparks.filter(func(p): return p.time < 0.7)
	update_actors()
	queue_redraw()

func update_actors() -> void:
	if hero == null:
		return
	hero.visible = screen in ["home","battle","arsenal","powers"]
	enemy_actor.visible = screen == "battle"
	for i in portraits.size():
		portraits[i].visible = screen == "battle" and overlay.is_empty() and not loading
		portraits[i].position = Vector2(44 if i == 0 else size.x-44,33)
	var bob := 0.0 if save.data.calm else sin(clock*2.0)*1.3
	if screen == "battle":
		var actor_height := 137.0
		hero.scale = Vector2.ONE*actor_height/fighters.get_height()
		enemy_actor.scale = hero.scale
		hero.position = Vector2(size.x*0.20,119+bob)
		enemy_actor.position = Vector2(size.x*0.80,117-bob)
		hero.modulate = Color(1,0.55,0.45) if hero_flash > 0 else Color.WHITE
		enemy_actor.modulate = Color(1.4,1.1,0.6) if attack_flash > 0 else Color(1,1-float(mission%4)*0.055,1)
	else:
		var actor_height := size.y*0.84
		hero.scale = Vector2.ONE*actor_height/fighters.get_height()
		hero.position = Vector2(size.x*0.24,size.y*0.55+bob)
		hero.modulate = Color.WHITE
		if screen in ["arsenal","powers"]:
			hero.visible = false

func _draw_backdrop(node: Node2D) -> void:
	var tex := map_art if screen == "campaign" else arena
	var target := Rect2(Vector2.ZERO,size)
	if screen == "battle":
		target.size.y = 180
	var ratio := target.size.x/target.size.y
	var tw := float(tex.get_width())
	var th := float(tex.get_height())
	var region := Rect2(0,0,tw,th)
	if tw/th > ratio:
		region.size.x = th*ratio
		region.position.x = (tw-region.size.x)/2
	else:
		region.size.y = tw/ratio
		region.position.y = (th-region.size.y)*0.35
	node.draw_texture_rect_region(tex,target,region)
	if screen != "battle":
		node.draw_rect(Rect2(Vector2.ZERO,size),Color(0.03,0.09,0.14,0.16))

func panel(rect: Rect2, color: Color = INK, border: Color = GOLD, radius: int = 14) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0,0,0,0.4)
	style.shadow_size = 5
	style.shadow_offset = Vector2(0,3)
	draw_style_box(style,rect)
	var inner := rect.grow(-4)
	draw_line(inner.position,Vector2(inner.end.x,inner.position.y),Color(border,0.23),1,true)

func text(value: String, rect: Rect2, font_size: int = 22, color: Color = CREAM, heading: bool = false, align: int = HORIZONTAL_ALIGNMENT_CENTER, localize: bool = true) -> void:
	if localize: value = t(value)
	var face := title_font if heading else font
	var actual := font_size
	while face.get_string_size(value,align,-1,actual).x > rect.size.x and actual > 16:
		actual -= 1
	var baseline := rect.position.y+(rect.size.y+face.get_ascent(actual)-face.get_descent(actual))/2
	draw_string(face,Vector2(rect.position.x,baseline),value,align,rect.size.x,actual,color)

func action(label: String, rect: Rect2, id: String, value: int = -1, primary: bool = false, enabled: bool = true) -> void:
	var color := Color("eab955") if primary else Color("183b54")
	if not enabled:
		color = Color("344651")
	if pressed_action == id and pressed_value == value:
		color = color.darkened(0.22)
	panel(rect,color,GOLD if enabled else Color("78909c"))
	text(label,rect.grow(-8),24,INK if primary and enabled else CREAM,true)
	buttons.append({"rect":rect,"id":id,"value":value,"enabled":enabled})

func header(title: String, back_to: String = "home") -> void:
	action("<",Rect2(22,16,54,50),back_to)
	panel(Rect2(83,16,330,50))
	text(title,Rect2(93,16,310,50),28,CREAM,true,HORIZONTAL_ALIGNMENT_LEFT)
	panel(Rect2(size.x-177,16,155,50))
	text("%d   ◈" % int(save.data.coins),Rect2(size.x-169,16,139,50),26,GOLD)

func icon(kind: int, center: Vector2, radius: float, color: Color = GOLD) -> void:
	Ornaments.medallion(self,kind,center,radius,color)

func _draw() -> void:
	buttons_state = screen+"|"+overlay
	buttons.clear()
	hitboxes.clear()
	if loading:
		panel(Rect2(size.x/2-290,size.y/2-82,580,164),INK)
		text("WAR OF WORDS",Rect2(size.x/2-270,size.y/2-68,540,60),38,GOLD,true)
		text("Preparing your word arsenal...",Rect2(size.x/2-270,size.y/2+1,540,42),25)
		draw_arc(Vector2(size.x/2,size.y/2+59),10,clock*3,clock*3+PI*1.5,24,GOLD,3,true)
		return
	match screen:
		"home": draw_home()
		"campaign": draw_campaign()
		"arsenal": draw_arsenal()
		"powers": draw_powers()
		"upgrades": draw_upgrades()
		"battle": draw_battle()
		"settings": draw_settings()
		"journal": draw_journal()
	if not overlay.is_empty():
		draw_overlay()
	if notice_time > 0:
		var width := minf(570,size.x-80)
		var notice_y := 133.0 if screen=="battle" else size.y-66
		panel(Rect2((size.x-width)/2,notice_y,width,38),Color("e9c77e"),CREAM)
		text(notice,Rect2((size.x-width)/2+10,notice_y,width-20,38),21,INK)
	if fps_label:
		text(str(Engine.get_frames_per_second()),Rect2(0,0,60,24),16)

func draw_home() -> void:
	var x := size.x*0.48
	var width := size.x-x-42
	panel(Rect2(x,58,width,139),Color(0.035,0.10,0.16,0.94))
	text("WAR OF",Rect2(x,62,width,50),38,GOLD,true)
	text("WORDS",Rect2(x,109,width,75),60,CREAM,true)
	panel(Rect2(x+width*.1,200,width*.8,32),Color(0.035,0.10,0.16,0.9),Color("547283"),8)
	text("SUNWARD RUINS",Rect2(x,200,width,32),23,CREAM,true)
	action("PLAY  >",Rect2(x,240,width,66),"campaign",-1,true)
	var split := (width-12)/2
	action("ARSENAL",Rect2(x,322,split,58),"arsenal")
	action("UPGRADES",Rect2(x+split+12,322,split,58),"upgrades")
	if not save.data.battle.is_empty():
		action("CONTINUE DUEL",Rect2(x,393,width,50),"continue",-1,true)
	else:
		action("WORD JOURNAL",Rect2(x,393,width,50),"journal")
	action("OPTIONS",Rect2(22,18,150,46),"settings")
	panel(Rect2(size.x-177,18,155,46))
	text("%d   ◈" % int(save.data.coins),Rect2(size.x-169,18,139,46),26,GOLD)
	text("OFFLINE  •  SOLO CAMPAIGN",Rect2(24,size.y-36,size.x*.4,28),17,CREAM)

func draw_campaign() -> void:
	header("CAMPAIGN")
	panel(Rect2(size.x*.25,80,size.x*.5,45))
	text(REGIONS[chapter],Rect2(size.x*.25,80,size.x*.5,45),26,GOLD,true)
	var points: Array[Vector2] = []
	for i in 4:
		points.append(Vector2(105+i*(size.x-210)/3,255-sin(i*1.4)*65))
	for i in 3:
		draw_line(points[i],points[i+1],Color("192f3a"),11,true)
		draw_line(points[i],points[i+1],GOLD if chapter*4+i<save.data.unlocked else Color("718792"),5,true)
	for i in 4:
		var level := chapter*4+i
		var completed: bool = save.data.wins.has(str(level))
		var available: bool = level <= save.data.unlocked
		var p := points[i]
		draw_circle(p,37,INK)
		draw_arc(p,37,0,TAU,48,GOLD if available else Color("809ca8"),4,true)
		if level == mission:
			draw_arc(p,43,0,TAU,48,CREAM,2,true)
		text("%02d" % (level+1) if available else "LOCK",Rect2(p-Vector2(32,30),Vector2(64,60)),24,CREAM,true)
		if completed:
			text("★".repeat(int(save.data.wins[str(level)])),Rect2(p.x-42,p.y+40,84,28),20,GOLD)
		buttons.append({"rect":Rect2(p-Vector2(42,42),Vector2(84,84)),"id":"mission","value":level,"enabled":available})
	var y := size.y-134
	panel(Rect2(24,y,size.x-48,112))
	text(t(ENEMIES[mission]).to_upper(),Rect2(44,y+8,size.x-320,40),26,CREAM,true,HORIZONTAL_ALIGNMENT_LEFT)
	text("CPU  •  %s  •  +%d COINS" % [t("BOSS" if mission%4==3 else "DUEL"),40+mission*5 if save.data.wins.has(str(mission)) else 120+mission*20],Rect2(44,y+51,size.x-320,35),19,GOLD,false,HORIZONTAL_ALIGNMENT_LEFT)
	action("PREPARE >",Rect2(size.x-249,y+29,205,58),"powers",-1,true)
	if chapter > 0:
		action("<",Rect2(23,86,50,46),"chapter",chapter-1)
	if chapter < 2:
		action(">",Rect2(size.x-73,86,50,46),"chapter",chapter+1,false,save.data.unlocked >= (chapter+1)*4)

func draw_arsenal() -> void:
	header("ARSENAL")
	var width := (size.x-70)/4
	for i in 4:
		var rect := Rect2(20+i*(width+10),90,width,270)
		panel(rect,INK,GOLD if i==selected else COLORS[i])
		icon(i,Vector2(rect.get_center().x,173),54,COLORS[i])
		text(NAMES[i],Rect2(rect.position.x+5,235,width-10,36),27,CREAM,true)
		text("LEVEL %d" % int(save.data.levels[i]),Rect2(rect.position.x,282,width,30),21,GOLD)
		text("EQUIPPED",Rect2(rect.position.x,320,width,28),18,COLORS[i])
		buttons.append({"rect":rect,"id":"select","value":i,"enabled":true})
	panel(Rect2(size.x*.2,368,size.x*.6,35),INK,Color("547283"),8)
	text(t(ROLES[selected])+t("  •  %d ENERGY") % COSTS[selected],Rect2(20,369,size.x-40,34),22)
	action("POWER-UPS",Rect2(24,size.y-65,212,48),"powers")
	action("UPGRADE >",Rect2(size.x-236,size.y-65,212,48),"upgrades",-1,true)

func draw_powers() -> void:
	header("POWER-UPS","campaign")
	panel(Rect2(150,78,size.x-300,37),INK,Color("547283"),8)
	text("CHOOSE ONE FOR BATTLE",Rect2(150,79,size.x-300,35),26,GOLD,true)
	var width := (size.x-84)/3
	for i in 3:
		var rect := Rect2(24+i*(width+18),126,width,260)
		panel(rect,INK,GOLD if i==save.data.selected_power else Color("7298b2"))
		icon(4+i,Vector2(rect.get_center().x,197),49,[COLORS[1],GOLD,COLORS[2]][i])
		text(POWER_NAMES[i],Rect2(rect.position.x+8,252,width-16,34),25,CREAM,true)
		text(POWER_DESC[i],Rect2(rect.position.x+9,298,width-18,30),20)
		text("EQUIPPED" if i==save.data.selected_power else "TAP TO EQUIP",Rect2(rect.position.x+8,344,width-16,30),21,GOLD)
		buttons.append({"rect":rect,"id":"power","value":i,"enabled":true})
	action("ARSENAL",Rect2(24,size.y-68,200,50),"arsenal")
	text("ONE FREE USE PER DUEL",Rect2(245,size.y-68,size.x-490,50),18,CREAM)
	action("BATTLE >",Rect2(size.x-224,size.y-68,200,50),"start",-1,true)

func draw_upgrades() -> void:
	header("UPGRADES",previous if previous in ["home","arsenal"] else "home")
	var left := size.x*0.29
	icon(selected,Vector2(left,228),93,COLORS[selected])
	panel(Rect2(left-145,86,290,49))
	text(NAMES[selected],Rect2(left-145,86,290,49),32,CREAM,true)
	for i in 4:
		var p := Vector2(left-117+i*78,385)
		icon(i,p,31,COLORS[i])
		if selected == i:
			draw_arc(p,36,0,TAU,48,GOLD,3,true)
		buttons.append({"rect":Rect2(p-Vector2(35,35),Vector2(70,70)),"id":"select","value":i,"enabled":true})
	var x := size.x*.54
	var width := size.x-x-24
	var level := int(save.data.levels[selected])
	var price := upgrade_cost(selected)
	panel(Rect2(x,90,width,344))
	text("LEVEL %d  >  %d" % [level,mini(8,level+1)],Rect2(x+12,106,width-24,50),32,GOLD,true)
	text(["DAMAGE","PROTECTION","DAMAGE","HEALING"][selected],Rect2(x+16,169,width-32,30),23)
	text(str(effect(selected)) if level==8 else t("%d  >  %d") % [effect(selected),effect(selected)+[8,5,6,6][selected]],Rect2(x+16,206,width-32,48),35,COLORS[selected])
	text("CHARGE   %d ENERGY" % COSTS[selected],Rect2(x+16,265,width-32,34),23)
	action("MAX LEVEL" if level==8 else t("UPGRADE  ◈ %d") % price,Rect2(x+20,319,width-40,56),"upgrade",selected,true,level<8 and save.data.coins>=price)
	text("Fully upgraded" if level==8 else "Earn coins in campaign" if save.data.coins<price else t("Balance after: %d") % (int(save.data.coins)-price),Rect2(x+12,386,width-24,29),19)

func board_rect() -> Rect2:
	return Rect2((size.x-454)/2,205,454,256)

func tile_center(i: int) -> Vector2:
	return board_rect().position+Vector2((i%7)*65+32,(i/7)*65+32)

func health_bar(rect: Rect2, current: int, maximum: int, opponent: bool) -> void:
	Ornaments.plaque(self,rect)
	var start := rect.position.x+17 if opponent else rect.position.x+38
	var width := rect.size.x-55
	var label := t("WARDEN" if mission%4==3 else "SENTINEL") + " · CPU" if opponent else t("YOU")
	text(label,Rect2(start,rect.position.y+1,width-70,20),18,CREAM,true,HORIZONTAL_ALIGNMENT_LEFT)
	text("%d/%d" % [current,maximum],Rect2(start+width-82,rect.position.y+1,82,20),18,CREAM)
	var bar := Rect2(start,rect.position.y+23,width,11)
	draw_style_box(health_style(Color("060f20")),bar.grow(1))
	var colors := [Color("ffa26e"),Color("ff6046"),Color("ba2e24")] if opponent else [Color("d1ff78"),Color("88e344"),Color("439d25")]
	var fill := Rect2(bar.position,Vector2(bar.size.x*float(current)/maximum,11))
	draw_polygon(PackedVector2Array([fill.position,Vector2(fill.end.x,fill.position.y),fill.end,Vector2(fill.position.x,fill.end.y)]),PackedColorArray([colors[0],colors[0],colors[2],colors[2]]))
	draw_line(fill.position+Vector2(0,1),Vector2(fill.end.x,fill.position.y+1),colors[0],1)
	var portrait_center := Vector2(size.x-44 if opponent else 44,33)
	Ornaments.gradient_disc(self,portrait_center,28,Color("fff0b6"),Color("97703b"))
	draw_circle(portrait_center,25,INK)

func health_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	return style

func draw_battle() -> void:
	# The frame, medallions and tokens use the approved battle illustration's visual language.
	panel(Rect2(0,177,size.x,size.y-177),Color("102b41"),Color("a78048"),0)
	draw_texture_rect(Ornaments.WEAVE,Rect2(2,179,size.x-4,size.y-181),true)
	var board := board_rect()
	Ornaments.plaque(self,Rect2(board.position-Vector2(7,9),board.size+Vector2(14,17)))
	for x in 6:
		for y in 3:
			Ornaments.gem(self,board.position+Vector2(64.5+x*65,64.5+y*65),3)
	var health_width := minf(350,size.x*.365)
	health_bar(Rect2(43,10,health_width,40),hp,100,false)
	health_bar(Rect2(size.x-health_width-43,10,health_width,40),foe_hp,foe_max,true)
	Ornaments.jewel(self,Vector2(size.x/2,33),24,Color("245573"))
	text("II",Rect2(size.x/2-20,10,40,44),29,GOLD,true)
	buttons.append({"rect":Rect2(size.x/2-27,6,54,54),"id":"pause","value":-1,"enabled":true})
	var intent := t("FROZEN  %.1fs") % freeze if freeze > 0 else t("INCOMING  %.1fs") % countdown if countdown<3 else t("Next attack  %ds") % int(ceil(countdown))
	if notice_time <= 0:
		panel(Rect2(size.x/2-113,136,226,32),Color("63392f") if countdown<3 and freeze<=0 else INK,GOLD,12)
		text(intent,Rect2(size.x/2-108,136,216,32),18)
	if shield>0:
		draw_arc(Vector2(size.x*.20,120),55,-PI*.5,PI*.5,32,COLORS[1],3,true)
	if not path.is_empty():
		var word := ""
		for i in path: word += lex.letters[i]
		Ornaments.plaque(self,Rect2(size.x/2-158,173,316,32))
		text(word,Rect2(size.x/2-148,174,296,30),24,GOLD,true,HORIZONTAL_ALIGNMENT_CENTER,false)
		if tap_composition and not (dragging and drag_moved):
			action("×",Rect2(size.x/2-216,161,49,43),"clear")
			action("✓",Rect2(size.x/2+167,161,49,43),"submit")
	for i in 28:
		var p := tile_center(i)
		Ornaments.jewel(self,p,29.5,COLORS[lex.types[i]],i in path)
		if hint_time>0 and i in hint_path:
			draw_arc(p,32,0,TAU,48,CREAM,2,true)
		hitboxes.append(Rect2(p-Vector2(30,30),Vector2(60,60)))
	if path.size()>1:
		var points := PackedVector2Array()
		for i in path: points.append(tile_center(i))
		draw_polyline(points,Color(1,.79,.32,.5),9,true)
		draw_polyline(points,Color("fff2c2"),4,true)
	for i in 28:
		var p := tile_center(i)
		text(lex.letters[i],Rect2(p.x-26,p.y-27,52,43),32 if lex.letters[i].length()==1 else 25,Color("071723"),true)
	for i in 28:
		var p := tile_center(i)
		text(["ϟ","◆","≈","+"][lex.types[i]],Rect2(p.x-12,p.y+12,24,16),16,Color("193a46"))
	for i in 4:
		var center := ability_center(i)
		var ready: bool = energy[i] >= COSTS[i]
		Ornaments.medallion(self,i,center,47,COLORS[i],energy[i],COSTS[i])
		var label := Rect2(center.x-58,center.y+29,116,43)
		Ornaments.plaque(self,label)
		text(NAMES[i],Rect2(label.position.x+5,label.position.y+1,106,21),19,CREAM,true)
		text("READY" if ready else t("%d/%d") % [energy[i],COSTS[i]],Rect2(label.position.x+5,label.position.y+21,106,21),18,GOLD if ready else CREAM)
		buttons.append({"rect":Rect2(center-Vector2(59,48),Vector2(118,122)),"id":"fire","value":i,"enabled":true})
	var help_center := Vector2(size.x/2-313,446)
	var power_center := Vector2(size.x/2+294,446)
	Ornaments.medallion(self,7,help_center,25,GOLD)
	buttons.append({"rect":Rect2(help_center-Vector2(30,27),Vector2(60,54)),"id":"hint","value":-1,"enabled":true})
	Ornaments.plaque(self,Rect2(power_center.x-10,426,77,40))
	Ornaments.medallion(self,4+save.data.selected_power,power_center,25,COLORS[1],-1,1,boost_used)
	text("×0" if boost_used else "×1",Rect2(power_center.x+26,427,35,38),23,Color("728894") if boost_used else CREAM)
	buttons.append({"rect":Rect2(power_center-Vector2(29,27),Vector2(99,54)),"id":"boost","value":-1,"enabled":not boost_used})
	for p in projectiles:
		var progress: float = p.time/0.5
		var start_x: float = size.x*(0.24 if p.player else 0.77)
		var end_x: float = size.x*(0.78 if p.player else 0.22)
		var location := Vector2(lerpf(start_x,end_x,progress),117-sin(progress*PI)*20)
		draw_circle(location,10*(1-progress*0.4),p.color)
		draw_arc(location,15,0,TAU,20,Color(p.color,0.4),4,true)
	for particle in sparks:
		var time: float = particle.time
		var location: Vector2 = particle.pos+particle.vel*time+Vector2(0,80)*time*time
		draw_circle(location,4*(1-time/0.7),Color(particle.color,1-time/0.7))

func ability_center(i: int) -> Vector2:
	return Vector2(size.x/2+(-313 if i<2 else 313),236+(i%2)*111)

func draw_settings() -> void:
	header("OPTIONS")
	var gap := 20.0
	var width := (size.x-72-gap)/2
	var right := 36+width+gap
	panel(Rect2(28,84,width+16,308))
	panel(Rect2(right-8,84,width+16,308))
	for i in 3:
		var key: String = ["sound","haptics","calm"][i]
		var label := t(["SOUND","HAPTICS","REDUCED MOTION"][i])
		action(label+"   "+t("ON" if save.data[key] else "OFF"),Rect2(38,105+i*73,width-4,56),key,-1,save.data[key])
	text("INTERFACE LANGUAGE",Rect2(right,99,width,30),22,GOLD,true)
	var half := (width-10)/2
	action("English",Rect2(right,137,half,51),"ui_language",0,save.data.ui_language=="en")
	action("Srpski",Rect2(right+half+10,137,half,51),"ui_language",1,save.data.ui_language=="sr")
	text("WORD DICTIONARY",Rect2(right,210,width,30),22,GOLD,true)
	action("English",Rect2(right,250,half,51),"word_language",0,save.data.word_language=="en")
	action("Srpski",Rect2(right+half+10,250,half,51),"word_language",1,save.data.word_language=="sr")
	text("LJ · NJ · DŽ · Č · Ć · Š · Đ · Ž" if save.data.word_language=="sr" else "A–Z · 76,802 words",Rect2(right,312,width,28),19)
	text("Offline dictionaries  •  v0.1.1",Rect2(38,336,width-4,32),18)
	panel(Rect2(28,394,size.x-56,29),INK,Color("547283"),8)
	text("Applies to new duels. Saved duels keep their dictionary.",Rect2(34,394,size.x-68,29),18,CREAM)
	action("HOW TO PLAY",Rect2(36,427,width,46),"help")
	action("CREDITS",Rect2(right,427,width,46),"credits")

func draw_journal() -> void:
	header("WORD JOURNAL")
	panel(Rect2(24,87,size.x-48,size.y-165))
	text("%d words found   •   Best: %s" % [save.data.total_words,save.data.longest if not save.data.longest.is_empty() else "—"],Rect2(42,101,size.x-84,36),24,GOLD)
	var list: Array = save.data.dictionary.duplicate()
	list.reverse()
	if list.is_empty():
		text("Your discoveries will appear here after a duel.",Rect2(42,192,size.x-84,60),24)
	for i in mini(12,maxi(0,list.size()-journal_page*12)):
		var word: String = list[journal_page*12+i]
		var column := i%3
		var row: int = i/3
		text(word,Rect2(50+column*(size.x-100)/3,153+row*43,(size.x-120)/3,39),25,CREAM,true,HORIZONTAL_ALIGNMENT_CENTER,false)
	action("<",Rect2(28,size.y-62,60,46),"journal_page",journal_page-1,false,journal_page>0)
	text("PAGE %d" % (journal_page+1),Rect2(size.x/2-100,size.y-62,200,46),21)
	action(">",Rect2(size.x-88,size.y-62,60,46),"journal_page",journal_page+1,false,(journal_page+1)*12<list.size())

func draw_overlay() -> void:
	buttons.clear()
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.02,0.06,0.10,0.86))
	var width := minf(670,size.x-60)
	var rect := Rect2((size.x-width)/2,55,width,size.y-110)
	panel(rect,Color("133249"))
	var title := "PAUSED"
	var lines: Array[String] = []
	match overlay:
		"pause":
			lines = ["Your duel is safely paused.","Progress is saved on this device."]
		"help":
			title="WORDS BECOME POWER"
			lines=["Link neighboring letters, including diagonals.","Release to submit; drag back to undo a letter.","Colors charge the matching abilities. Tap READY.","Long words hit harder. Find each word once per duel.","Tap letters + ✓ also works. HINT reveals a path."]
		"credits":
			title="WAR OF WORDS"
			lines=["An original offline word-combat adventure.","Built with Godot 4.7.2 (MIT).", "English: SCOWL · Serbian: LibreOffice (MPL-2.0).","Cinzel / Lato: SIL Open Font License.","Original AI-assisted art and synthesized sound.","Full notices included in the project and app package."]
		"result":
			title="VICTORY" if won else "DEFEATED"
			lines=["★".repeat(stars) if won else "A new word. A better moment. Try again.",t("%d words  •  Best: %s") % [word_count,best_word if not best_word.is_empty() else "—"],t("+%d coins   •   %.0f seconds") % [reward,duration]]
			if won and mission==11:
				lines.append("The observatory is free. Campaign complete!")
		"replace":
			title="START A NEW DUEL?"
			lines=["Your unfinished duel will be replaced.","Your coins and upgrades are safe."]
		"exit":
			title="LEAVE THE GAME?"
			lines=["Your progress has been saved."]
	text(title,Rect2(rect.position.x+18,rect.position.y+15,width-36,48),32,GOLD,true)
	var start := rect.position.y+84
	for i in lines.size():
		text(lines[i],Rect2(rect.position.x+22,start+i*32,width-44,31),21)
	var y := rect.end.y-71
	var middle := size.x/2
	match overlay:
		"pause":
			action("MENU",Rect2(middle-300,y,125,51),"save_home")
			action("OPTIONS",Rect2(middle-165,y,190,51),"settings")
			action("RESUME",Rect2(middle+45,y,255,51),"resume",-1,true)
		"result":
			action("MAP",Rect2(middle-275,y,140,51),"campaign")
			action("UPGRADES",Rect2(middle-119,y,185,51),"upgrades")
			action("NEXT >" if won and mission<11 else "RETRY",Rect2(middle+81,y,194,51),"next",-1,true)
		"replace":
			action("CANCEL",Rect2(middle-220,y,200,51),"dismiss")
			action("START",Rect2(middle+20,y,200,51),"new_battle",-1,true)
		"exit":
			action("BACK",Rect2(middle-210,y,190,51),"dismiss")
			action("QUIT",Rect2(middle+20,y,190,51),"quit")
		_:
			action("GOT IT",Rect2(middle-120,y,240,51),"resume",-1,true)

func _input(event: InputEvent) -> void:
	if loading:
		return
	if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:
		back()
	if event is InputEventScreenTouch:
		var p: Vector2 = get_global_transform_with_canvas().affine_inverse()*event.position
		if event.pressed and touch_id==-1:
			touch_id=event.index
			press(p)
		elif not event.pressed and event.index==touch_id:
			touch_id=-1
			if event.canceled:
				path.clear(); dragging=false
			else:
				release(p)
	if event is InputEventScreenDrag and event.index==touch_id:
		move(get_global_transform_with_canvas().affine_inverse()*event.position)
	if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and touch_id==-1:
		var p: Vector2 = get_global_transform_with_canvas().affine_inverse()*event.position
		if event.pressed:
			press(p)
		else:
			release(p)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and touch_id==-1:
		move(get_global_transform_with_canvas().affine_inverse()*event.position)

func press(p: Vector2) -> void:
	pressed_action=""; pressed_value=-1
	if buttons_state != screen+"|"+overlay: return
	if screen=="battle" and overlay.is_empty() and not ended:
		for i in hitboxes.size():
			if hitboxes[i].has_point(p):
				dragging=true; drag_moved=false; drag_position=p; add_letter(i); return
	for b in buttons:
		if b.rect.has_point(p) and b.enabled:
			pressed_action=b.id; pressed_value=b.value; return

func move(p: Vector2) -> void:
	if not dragging:
		return
	# Touch events can skip a tile during a fast swipe or a slow frame.
	# Sample the travelled segment so every crossed neighboring cell is considered.
	var start := drag_position
	var steps := maxi(1,int(ceil(start.distance_to(p)/12.0)))
	for step in range(1,steps+1):
		trace_point(start.lerp(p,float(step)/steps))
	drag_position=p

func trace_point(p: Vector2) -> void:
	for i in hitboxes.size():
		if hitboxes[i].has_point(p) and (path.is_empty() or path.back()!=i):
			drag_moved=true
			tap_composition=false
			add_letter(i)
			return

func release(p: Vector2) -> void:
	if dragging:
		dragging=false
		if drag_moved:
			submit_word()
		else:
			tap_composition = not path.is_empty()
		return
	var id := pressed_action
	var value := pressed_value
	pressed_action=""; pressed_value=-1
	if buttons_state != screen+"|"+overlay: return
	for b in buttons:
		if b.id==id and b.value==value and b.rect.has_point(p) and b.enabled:
			sfx.play("tap")
			dispatch(id,value)
			return

func add_letter(i: int) -> void:
	if path.size()>1 and path[-2]==i:
		path.pop_back(); return
	if i in path or (not path.is_empty() and not lex.adjacent(path.back(),i)):
		return
	path.append(i)
	sfx.play("tap",1+path.size()*0.035)
	if save.data.haptics and OS.get_name()=="Android":
		Input.vibrate_handheld(12)

func dispatch(id: String, value: int = -1) -> void:
	if OS.is_debug_build(): print("WarOfWords: action=%s screen=%s overlay=%s" % [id,screen,overlay])
	match id:
		"home","campaign","arsenal","powers","upgrades","settings","journal": change_screen(id)
		"select": selected=value
		"mission": mission=value
		"chapter": chapter=value; mission=mini(save.data.unlocked,chapter*4)
		"journal_page": journal_page=maxi(0,value)
		"power": save.data.selected_power=value; save.save_game()
		"upgrade": upgrade()
		"start":
			if not save.data.battle.is_empty(): overlay="replace"
			else: start_battle()
		"new_battle": start_battle()
		"continue": restore_battle()
		"next":
			if won: mission=mini(11,mission+1)
			change_screen("powers")
		"pause": overlay="pause"; path.clear(); persist_battle()
		"resume","dismiss": overlay=""; save.data.tutorial=true; save.save_game()
		"save_home": persist_battle(); change_screen("home")
		"help": overlay="help"; path.clear()
		"credits": overlay="credits"
		"fire": fire(value)
		"clear": path.clear()
		"submit": submit_word()
		"hint": show_hint()
		"boost": power_up()
		"sound","haptics","calm":
			save.data[id]=not save.data[id]
			sfx.enabled=save.data.sound
			save.save_game()
		"ui_language":
			save.data.ui_language = ["en","sr"][value]; save.save_game()
		"word_language":
			save.data.word_language = ["en","sr"][value]; save.save_game()
			await select_dictionary(save.data.word_language)
		"quit": persist_battle(); get_tree().quit()
	queue_redraw()

func change_screen(target: String) -> void:
	if screen=="battle" and not ended:
		persist_battle()
	previous=screen
	screen=target
	overlay=""; path.clear(); dragging=false; tap_composition=false
	notice_time=0
	if target=="campaign": chapter=mission/4
	get_node("Backdrop").queue_redraw()
	queue_redraw()

func back() -> void:
	if not overlay.is_empty():
		if overlay=="result": change_screen("campaign")
		else: overlay=""
	elif screen=="battle":
		overlay="pause"; path.clear(); persist_battle()
	elif screen=="home": overlay="exit"
	else: change_screen("home")

func effect(i: int) -> int:
	return [24,20,18,24][i]+(int(save.data.levels[i])-1)*[8,5,6,6][i]

func upgrade_cost(i: int) -> int:
	return 100+int(save.data.levels[i])*60

func upgrade() -> void:
	var cost := upgrade_cost(selected)
	if save.data.levels[selected]>=8 or save.data.coins<cost:
		return
	save.data.coins-=cost
	save.data.levels[selected]+=1
	save.save_game()
	sfx.play("upgrade")
	message(t("%s upgraded to level %d") % [t(NAMES[selected]),save.data.levels[selected]])

func start_battle() -> void:
	if mission>save.data.unlocked:
		return
	await select_dictionary(save.data.word_language)
	change_screen("battle")
	hp=100; foe_max=72+mission*13+(35 if mission%4==3 else 0); foe_hp=foe_max
	energy=[0,3,0,0]; shield=0; used.clear(); word_count=0; best_word=""
	duration=0; ended=false; won=false; reward=0; stars=0; freeze=0; surge=false
	boost_used=false; enemy_attacks=0; countdown=interval()+4; shuffled=0
	projectiles.clear(); sparks.clear(); hint_path.clear(); path.clear()
	lex.generate()
	if not save.data.tutorial:
		lex.letters.assign(Array(("KAMENVAREKASUNŠTITIGRVODAMOS" if lex.language=="sr" else "STONESTREAMLINEPLANETCARDSEN").split("")))
		lex.find_words()
		overlay="help"
	persist_battle()

func interval() -> float:
	return maxf(8,14-mission*0.42)

func submit_word() -> void:
	tap_composition=false
	if path.size()<3:
		message("Use at least three letters"); path.clear(); return
	var word: String = lex.validate_path(path)
	if word.is_empty():
		message("Not in the selected dictionary"); path.clear(); return
	if used.has(word):
		message("Already found — try a different word"); path.clear(); return
	used[word]=true; word_count+=1
	if word.length()>best_word.length(): best_word=word
	var multiplier := (2 if path.size()>=6 else 1)*(2 if surge else 1)
	var gain := [0,0,0,0]
	for i in path:
		gain[lex.types[i]]+=multiplier
		for n in 3:
			sparks.append({"pos":tile_center(i),"vel":Vector2(randf_range(-50,50),randf_range(-80,-15)),"time":0.0,"color":COLORS[lex.types[i]]})
	for i in 4: energy[i]=mini(COSTS[i],energy[i]+gain[i])
	surge=false
	var damage := path.size()+maxi(0,path.size()-4)*2
	foe_hp=maxi(0,foe_hp-damage)
	attack_flash=0.2
	projectiles.append({"player":true,"color":GOLD,"time":0.0})
	sfx.play("word")
	var refreshed: bool = lex.refill(path,used)
	path.clear()
	message(t("%s  •  %d damage%s") % [word,damage,t("  •  Board refreshed") if refreshed else ""])
	if foe_hp<=0: finish(true)
	else: persist_battle()

func fire(i: int) -> void:
	if ended or energy[i]<COSTS[i]:
		message(t("%s needs %d matching energy") % [t(NAMES[i]),COSTS[i]]); return
	if i==1 and shield>0: message("Your shield is already active"); return
	if i==3 and hp>=100: message("Health is already full"); return
	energy[i]=0
	match i:
		0: foe_hp=maxi(0,foe_hp-effect(i)); attack_flash=0.4
		1: shield=effect(i)
		2: foe_hp=maxi(0,foe_hp-effect(i)); countdown=interval()+3; attack_flash=0.3
		3: hp=mini(100,hp+effect(i)); hero_flash=0
	sfx.play("shot" if i in [0,2] else "upgrade")
	if i in [0,2]: projectiles.append({"player":true,"color":COLORS[i],"time":0.0})
	message(["Pulse fired!","Shield ready","Enemy attack interrupted","Health restored"][i])
	if foe_hp<=0: finish(true)
	else: persist_battle()

func enemy_attack() -> void:
	enemy_attacks+=1
	var amount := 12+mission
	if mission%4==3 and enemy_attacks%3==0: amount+=8
	var damage := maxi(0,amount-shield)
	shield=0
	hp=maxi(0,hp-damage)
	hero_flash=0.35
	countdown=interval()
	projectiles.append({"player":false,"color":COLORS[2],"time":0.0})
	sfx.play("hit")
	if save.data.haptics and OS.get_name()=="Android": Input.vibrate_handheld(45)
	message("Shield absorbed the attack" if damage==0 else t("Enemy hit  −%d HP") % damage)
	if hp<=0: finish(false)

func power_up() -> void:
	if boost_used or ended: return
	boost_used=true
	match save.data.selected_power:
		0: freeze=8; message("Time frozen — keep finding words")
		1: path.clear(); lex.generate(used); message("Fresh board — new possibilities")
		2: surge=true; message("Next word gives double energy")
	sfx.play("upgrade")
	persist_battle()

func show_hint() -> void:
	if hint_time>0: return
	lex.find_words(used)
	if lex.solutions.is_empty():
		lex.generate(used)
	var solution := ""
	for word in lex.solutions:
		if solution.is_empty() or (word.length()>solution.length() and word.length()<=7): solution=word
	if solution.is_empty(): return
	hint_path.assign(lex.solutions[solution])
	hint_time=4
	message(t("Try %s — follow the highlighted letters") % solution)

func finish(victory: bool) -> void:
	if ended: return
	ended=true; won=victory; overlay="result"; path.clear(); notice_time=0
	stars=(3 if hp>=70 else 2 if hp>=35 else 1) if won else 0
	var first: bool = not save.data.wins.has(str(mission))
	reward=(120+mission*20 if first else 40+mission*5) if won else mini(25,word_count*2)
	save.data.coins+=reward
	if won:
		save.data.wins[str(mission)]=maxi(stars,int(save.data.wins.get(str(mission),0)))
		save.data.unlocked=maxi(save.data.unlocked,mini(11,mission+1))
	save.data.total_words+=word_count
	if best_word.length()>save.data.longest.length(): save.data.longest=best_word
	for word in used:
		if word not in save.data.dictionary: save.data.dictionary.append(word)
	while save.data.dictionary.size()>600: save.data.dictionary.pop_front()
	save.data.battle={}
	save.save_game()
	sfx.play("win" if won else "lose")

func persist_battle() -> void:
	if screen=="battle" and not ended and lex.letters.size()==28:
		save.data.battle={"dictionary_code":lex.language,"mission":mission,"hp":hp,"foe":foe_hp,"max":foe_max,"energy":energy,"shield":shield,"countdown":countdown,"freeze":freeze,"surge":surge,"boost_used":boost_used,"used":used,"words":word_count,"best":best_word,"duration":duration,"letters":lex.letters,"types":lex.types,"attacks":enemy_attacks,"power":save.data.selected_power}
	if not save.save_game(): message("Could not save progress on this device")

func restore_battle() -> void:
	var b: Dictionary = save.data.battle
	if b.is_empty(): return
	if not valid_snapshot(b):
		save.data.battle={}; save.save_game(); message("Old duel could not be restored. Start a new one."); return
	await select_dictionary(b.get("dictionary_code","en"))
	change_screen("battle")
	mission=int(b.mission); hp=int(b.hp); foe_hp=int(b.foe); foe_max=int(b.max)
	energy.assign(b.energy); shield=int(b.shield); countdown=float(b.countdown)
	freeze=float(b.freeze); surge=bool(b.surge); boost_used=bool(b.boost_used)
	used=b.used.duplicate(); word_count=int(b.words); best_word=b.best; duration=float(b.duration)
	lex.letters.assign(b.letters); lex.types.assign(b.types); lex.find_words(used)
	enemy_attacks=int(b.attacks); save.data.selected_power=int(b.power)
	ended=false; won=false; overlay="pause"; projectiles.clear(); sparks.clear()

func valid_snapshot(b: Dictionary) -> bool:
	for key in ["mission","hp","foe","max","energy","shield","countdown","freeze","surge","boost_used","used","words","best","duration","letters","types","attacks","power"]:
		if not b.has(key): return false
	if not b.letters is Array or b.letters.size()!=28 or not b.types is Array or b.types.size()!=28: return false
	if not b.energy is Array or b.energy.size()!=4 or not b.used is Dictionary: return false
	for key in ["mission","hp","foe","max","shield","countdown","freeze","words","duration","attacks","power"]:
		if not (b[key] is int or b[key] is float) or not is_finite(float(b[key])): return false
	if not b.best is String or not b.surge is bool or not b.boost_used is bool: return false
	for i in 4:
		if not (b.energy[i] is int or b.energy[i] is float) or b.energy[i]<0 or b.energy[i]>COSTS[i]: return false
	for word in b.used:
		if not word is String: return false
	if b.get("dictionary_code","en") not in ["en","sr"]: return false
	var tile_lex = Lexicon.new(false,b.get("dictionary_code","en"))
	for letter in b.letters:
		if not letter is String or not tile_lex.valid_tile(letter): return false
	for kind in b.types:
		if not (kind is int or kind is float): return false
		if int(kind)<0 or int(kind)>3 or float(int(kind))!=float(kind): return false
	return int(b.mission)>=0 and int(b.mission)<12 and int(b.hp)>0 and int(b.hp)<=100 and int(b.foe)>0 and int(b.max)>0 and int(b.power) in [0,1,2]

func message(value: String) -> void:
	notice=t(value); notice_time=2.2

func _run_visual_qa() -> void:
	# Opt-in developer capture through Godot's renderer, never included as an automatic run.
	while loading:
		await get_tree().process_frame
	save.path = "res://../.local/visual-progress.json"
	save.data = save.defaults()
	var directory := ProjectSettings.globalize_path("res://../.local/game-qa")
	DirAccess.make_dir_recursive_absolute(directory)
	for view in ["home","campaign","arsenal","powers","upgrades","battle"]:
		if view=="battle":
			await start_battle()
			energy.assign([4,3,3,2]); hp=84; foe_hp=56; overlay="pause"
		else: change_screen(view)
		await get_tree().process_frame
		await get_tree().process_frame
		if view=="battle": overlay=""; countdown=60
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(directory+"/"+view+".png")
	path.assign([0,1,2,3,4]); tap_composition = true
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(directory+"/battle-tap.png")
	tap_composition = false; dragging = true; drag_moved = true
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(directory+"/battle-slide.png")
	change_screen("settings"); save.data.ui_language="sr"; save.data.word_language="sr"
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(directory+"/settings-sr.png")
	await select_dictionary("en")
	change_screen("battle"); ended=false; countdown=60
	lex.letters.assign(Array("MEND".split(""))+lex.letters.slice(4))
	path.assign([0,1,2,3]); tap_composition=true
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(directory+"/english-word-serbian-ui.png")
	get_tree().quit()
