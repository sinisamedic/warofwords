extends Control

const Lexicon = preload("res://scripts/lexicon.gd")
const SaveData = preload("res://scripts/save_data.gd")
const Sound = preload("res://scripts/sound.gd")
const Ornaments = preload("res://scripts/ornaments.gd")
const Portrait = preload("res://scripts/portrait.gd")
const Localization = preload("res://scripts/localization.gd")
const Actor = preload("res://scripts/actor.gd")
const HeroRig = preload("res://scripts/hero_rig.gd")
const EnemyArt = preload("res://scripts/enemy_art.gd")
const CREAM := Color("fff1ce")
const GOLD := Color("f3c569")
const INK := Color("10283d")
const GROUND_Y := 177.0
const DEFEAT_DURATION := 1.65
const COLORS := [Color("ffd053"),Color("78bfff"),Color("b896f5"),Color("62dcb5")]
const NAMES := ["PULSE","AEGIS","ARC","MEND"]
const ROLES := ["Direct energy blast","Block the next attack","Strike and interrupt","Restore your health"]
const COSTS := [4,5,7,5]
const POWER_NAMES := ["TIME FREEZE","FRESH BOARD","OVERCHARGE"]
const POWER_DESC := ["Stop the enemy for 8s","A new field of letters","Double your next word"]
const REGIONS := ["SUNWARD RUINS","THE SKY BRIDGES","THE OBSERVATORY"]
const ENEMIES := ["Training Sentinel","Copper Scout","Gatekeeper","BRONZE WARDEN","Sky Watcher","Storm Sentinel","Bridge Guardian","TEMPEST WARDEN","Astral Sentinel","Archive Keeper","Sunforged Elite","THE LAST WARDEN"]

var font: Font = preload("res://assets/fonts/Lato-Bold.ttf")
var title_font: Font = preload("res://assets/fonts/NotoSerif.ttf")
var title_emblem: Texture2D = preload("res://assets/art/title-emblem.png")
var board_environment: Texture2D = preload("res://assets/art/board-environment.png")
var arena: Texture2D = preload("res://assets/art/arena.png")
var map_art: Texture2D = preload("res://assets/art/map.png")
const CAMPAIGN_ART := [preload("res://assets/art/campaign-sunward.png"),preload("res://assets/art/campaign-sky.png"),preload("res://assets/art/campaign-observatory.png")]
var campaign_background_from := 0
var campaign_background_time := .55
var campaign_background_direction := 1.0
var fighters: Texture2D = preload("res://assets/art/fighters.png")
var menu_icons: Texture2D = preload("res://assets/art/menu-icons.png")
var lex = Lexicon.new(false)
var lexicons: Dictionary = {}
var portraits: Array[Sprite2D] = []
var tap_composition := false
var loading := true
var dictionary_thread: Thread
var save = SaveData.new()
var sfx: Node
var music: Node
var enemy_art_mission := -1
var hero_recoil := 0.0
var enemy_recoil := 0.0
var hero_hit_strength := 0.0
var enemy_hit_strength := 0.0
var page_gesture := false
var page_origin := Vector2.ZERO
var page_screen := ""
var campaign_track: Control
var campaign_offset := 0.0
var campaign_slide_from := 0.0
var campaign_slide_time := .32
var hero: Node2D
var home_hero: Sprite2D
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
var fx = preload("res://scripts/combat_fx.gd").new()
var result_delay := 0.0
var ready_flash: Array[float] = [0.0,0.0,0.0,0.0]
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
var daily_screen: Control

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
	music = preload("res://scripts/music.gd").new()
	add_child(music)
	music.set_enabled(save.data.music)
	hero = HeroRig.new()
	home_hero = Actor.new()
	home_hero.setup(fighters,false)
	enemy_actor = Actor.new()
	enemy_actor.setup(fighters,true)
	add_child(hero)
	add_child(home_hero)
	add_child(enemy_actor)
	hero.z_index = -1
	home_hero.z_index = -1
	enemy_actor.z_index = -1
	for opponent in [false,true]:
		var portrait = Portrait.new()
		portrait.setup(fighters,opponent)
		add_child(portrait)
		portraits.append(portrait)
	# Background is drawn by a sibling behind both actors; HUD is drawn by this Control.
	var backdrop := Node2D.new()
	backdrop.name = "Backdrop"
	backdrop.z_index = -10
	backdrop.draw.connect(_draw_backdrop.bind(backdrop))
	add_child(backdrop)
	campaign_track=Control.new()
	campaign_track.name="CampaignTrack"
	campaign_track.mouse_filter=Control.MOUSE_FILTER_IGNORE
	campaign_track.clip_contents=true
	campaign_track.draw.connect(draw_campaign_track.bind(campaign_track))
	add_child(campaign_track)
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
	if daily_screen==null:
		daily_screen=preload("res://scripts/daily_screen.gd").new()
		daily_screen.host=self
		add_child(daily_screen)
		daily_screen.hide()
		daily_screen.closed.connect(func(): change_screen("home"))
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
		if screen=="campaign":
			page_gesture=false; touch_id=-1; pressed_action=""; settle_campaign(chapter)
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
	# A suspended app must not fast-forward projectiles or CPU turns on its first frame.
	delta = minf(delta,.05)
	if OS.is_debug_build() and Time.get_ticks_msec()-debug_sample_at >= 15000:
		debug_sample_at=Time.get_ticks_msec()
		print("WarOfWords: performance screen=%s fps=%d draw_calls=%d" % [screen,Engine.get_frames_per_second(),RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)])
	clock += delta
	if screen=="campaign":
		campaign_background_time=minf(.55,campaign_background_time+delta)
		get_node("Backdrop").queue_redraw()
	if screen=="campaign" and not page_gesture and campaign_offset!=0:
		campaign_slide_time=minf(.32,campaign_slide_time+delta)
		campaign_offset=lerpf(campaign_slide_from,0,1-pow(1-campaign_slide_time/.32,3))
		if save.data.calm: campaign_offset=0
	if campaign_track != null:
		campaign_track.visible=screen=="campaign" and overlay.is_empty() and not loading
		if campaign_track.visible: campaign_track.queue_redraw()
	notice_time = maxf(0,notice_time-delta)
	hint_time = maxf(0,hint_time-delta)
	attack_flash = maxf(0,attack_flash-delta)
	hero_flash = maxf(0,hero_flash-delta)
	music.battle = screen == "battle"
	music.ducked = not overlay.is_empty()
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
	if screen == "battle" and overlay.is_empty() and not loading:
		advance_combat(delta)
		for i in 4: ready_flash[i]=maxf(0,ready_flash[i]-delta)
		hero_recoil=maxf(0,hero_recoil-delta)
		enemy_recoil=maxf(0,enemy_recoil-delta)
		if ended and result_delay > 0:
			result_delay=maxf(0,result_delay-delta)
			if result_delay == 0:
				overlay="result"
				sfx.play("win" if won else "lose")
	for p in sparks:
		p.time += delta
	sparks = sparks.filter(func(p): return p.time < 0.7)
	hero.advance_pose(delta,save.data.calm,loading or (screen=="battle" and (not overlay.is_empty() or ended)))
	update_actors()
	queue_redraw()

func update_actors() -> void:
	if hero == null:
		return
	hero.visible = screen == "battle"
	home_hero.visible = screen == "home"
	enemy_actor.visible = screen == "battle"
	for i in portraits.size():
		portraits[i].visible = screen == "battle" and overlay.is_empty() and not loading
		portraits[i].position = Vector2(44 if i == 0 else size.x-44,33)
	if screen == "battle":
		if not ended and hero.defeated: hero.reset_pose()
		if enemy_art_mission != mission:
			EnemyArt.apply(enemy_actor,portraits[1],mission)
			enemy_art_mission=mission
		hero.scale = Vector2.ONE*.84
		enemy_actor.scale = Vector2.ONE*128.0/EnemyArt.CELL.y
		var idle: bool = not save.data.calm and not ended
		var enemy_breath := 1.0+sin(clock*1.8+.8)*.032 if idle else 1.0
		enemy_actor.scale.y*=enemy_breath
		var hero_kick := 0.0 if save.data.calm else hit_offset(hero_recoil,hero_hit_strength)
		var enemy_kick := 0.0 if save.data.calm else hit_offset(enemy_recoil,enemy_hit_strength)
		hero.rotation = -hero_kick*.0025
		enemy_actor.rotation = enemy_kick*.0025+(sin(clock*1.15+.9)*.025 if idle else 0.0)
		# Rotation and breathing happen about the feet, keeping both fighters grounded.
		hero.position = Vector2(size.x*.20-hero_kick,GROUND_Y)
		enemy_actor.position = Vector2(size.x*.80+enemy_kick,GROUND_Y)-Vector2(0,EnemyArt.foot_offset(mission)*enemy_actor.scale.y).rotated(enemy_actor.rotation)
		hero.modulate = Color(1,0.55,0.45) if hero_flash > 0 and not save.data.calm else Color.WHITE
		enemy_actor.modulate = Color(1.4,1.1,0.6) if attack_flash > 0 and not save.data.calm else Color.WHITE
		enemy_actor.material.set_shader_parameter("dissolve",0.0)
		if ended:
			animate_defeat(enemy_actor if won else hero,won)
	else:
		# The large home illustration stays intact; the cutout rig is only used in combat.
		home_hero.scale=Vector2.ONE*size.y*.84/fighters.get_height()
		home_hero.position=Vector2(size.x*.24,size.y*.48+(0.0 if save.data.calm else sin(clock*2.1)*3.2))
		home_hero.rotation=0.0 if save.data.calm else sin(clock*1.5)*.008
	var muzzle: Vector2=get_global_transform().affine_inverse()*hero.muzzle_position()
	fx.player_muzzle=Vector2(muzzle.x/maxf(1,size.x),muzzle.y)

func hit_offset(remaining: float, strength: float) -> float:
	if remaining <= 0: return 0
	var u := 1.0-remaining/.48
	return strength*exp(-u*4.5)*(1.0+sin(u*TAU*3.5)*.55)

func animate_defeat(actor: Node2D, opponent: bool) -> void:
	var u := clampf(1.0-result_delay/DEFEAT_DURATION,0,1)
	actor.modulate=Color.WHITE
	actor.rotation=0
	if save.data.calm:
		actor.modulate.a=1.0-smoothstep(.30,1.0,u)
		return
	if opponent:
		actor.material.set_shader_parameter("dissolve",smoothstep(.12,.88,u))
	else:
		hero.defeat_pose(u,false)
		actor.modulate.a=1.0-smoothstep(.88,1.0,u)

func advance_combat(delta: float) -> void:
	var impacts: Array = fx.advance(delta)
	for impact in impacts:
		if ended: break
		var blocked: bool = not impact.player and shield > 0
		var damage: int = impact.damage
		if impact.player:
			foe_hp=maxi(0,foe_hp-damage)
			if impact.kind == "arc":
				countdown=interval()+3
				message("Enemy attack interrupted")
			attack_flash=.22; enemy_recoil=.48
			enemy_hit_strength=11.0 if impact.kind == "word" else 25.0
		else:
			damage=maxi(0,damage-shield); shield=0
			hp=maxi(0,hp-damage)
			hero.react("hit",save.data.calm)
			hero_flash=.22; hero_recoil=.48; hero_hit_strength=12.0 if blocked else 22.0
			message("Shield absorbed the attack" if damage==0 else t("Enemy hit  −%d HP") % damage)
		fx.impact(impact,blocked)
		sfx.play("shield" if blocked else "hit" if impact.kind == "word" else "explosion",randf_range(.96,1.04))
		haptic(30 if impact.kind == "word" else 90,.4 if impact.kind == "word" else .95)
		# First lethal arrival wins; projectiles still in flight are canceled with the duel.
		if foe_hp <= 0: finish(true)
		elif hp <= 0: finish(false)
	if not impacts.is_empty() and not ended: persist_battle()

func _draw_backdrop(node: Node2D) -> void:
	if screen=="campaign":
		var u := smoothstep(0,.55,campaign_background_time)
		draw_campaign_background(node,CAMPAIGN_ART[campaign_background_from],1.0,-18*u*campaign_background_direction)
		draw_campaign_background(node,CAMPAIGN_ART[chapter],u,18*(1-u)*campaign_background_direction)
		node.draw_rect(Rect2(Vector2.ZERO,size),Color(.03,.09,.14,.16))
		return
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
	if screen == "battle":
		for x in [.20,.80]:
			node.draw_set_transform(Vector2(size.x*x,GROUND_Y-1),0,Vector2(1,.14))
			node.draw_circle(Vector2.ZERO,29,Color(.025,.07,.10,.28))
			node.draw_circle(Vector2.ZERO,21,Color(.025,.07,.10,.19))
		node.draw_set_transform(Vector2.ZERO)
	if screen != "battle":
		node.draw_rect(Rect2(Vector2.ZERO,size),Color(0.03,0.09,0.14,0.16))

func draw_campaign_background(node: Node2D, tex: Texture2D, alpha: float, shift: float) -> void:
	# A small overscan allows a gentle pan during the dissolve without exposing an edge.
	var target := Rect2(-22+shift,-8,size.x+44,size.y+16)
	var source := Rect2(Vector2.ZERO,tex.get_size())
	var ratio := target.size.x/target.size.y
	if source.size.x/source.size.y>ratio:
		source.size.x=source.size.y*ratio
		source.position.x=(tex.get_width()-source.size.x)/2
	else:
		source.size.y=source.size.x/ratio
		source.position.y=(tex.get_height()-source.size.y)*.4
	node.draw_texture_rect_region(tex,target,source,Color(1,1,1,alpha))

func panel(rect: Rect2, _color: Color = INK, _border: Color = GOLD, _radius: int = 14) -> void:
	Ornaments.frame(self,rect,2 if rect.size.y > 75 else 0,Color.WHITE if _border == GOLD else _border.lightened(.55))

func text(value: String, rect: Rect2, font_size: int = 22, color: Color = CREAM, heading: bool = false, align: int = HORIZONTAL_ALIGNMENT_CENTER, localize: bool = true, canvas: CanvasItem = null) -> void:
	if localize: value = t(value)
	var face := title_font if heading else font
	var actual := font_size
	while face.get_string_size(value,align,-1,actual).x > rect.size.x and actual > 16:
		actual -= 1
	var baseline := rect.position.y+(rect.size.y+face.get_ascent(actual)-face.get_descent(actual))/2
	var target: CanvasItem = self if canvas == null else canvas
	target.draw_string(face,Vector2(rect.position.x,baseline),value,align,rect.size.x,actual,color)

func action(label: String, rect: Rect2, id: String, value: int = -1, primary: bool = false, enabled: bool = true) -> void:
	var tint := Color.WHITE if enabled else Color(.52,.57,.61)
	if pressed_action == id and pressed_value == value: tint = tint.darkened(.22)
	Ornaments.frame(self,rect,1 if primary else 0,tint)
	var text_rect := rect.grow(-10)
	var has_icon: bool = Ornaments.ICONS.has(id) and (rect.size.x >= 200 or rect.size.y >= 78)
	if has_icon and rect.size.y >= 78:
		Ornaments.ui_icon(self,id,Rect2(rect.get_center().x-24,rect.position.y+6,48,48))
		text_rect = Rect2(rect.position.x+14,rect.end.y-39,rect.size.x-28,29)
	elif has_icon:
		var side := minf(32,rect.size.y-18)
		Ornaments.ui_icon(self,id,Rect2(rect.position.x+15,rect.get_center().y-side/2,side,side))
		text_rect.position.x += side+6; text_rect.size.x -= side+6
	text(label,text_rect,22 if has_icon else 24,INK if primary and enabled else CREAM,true)
	buttons.append({"rect":rect,"id":id,"value":value,"enabled":enabled})

func coin_counter(rect: Rect2) -> void:
	Ornaments.frame(self,rect)
	Ornaments.ui_icon(self,"coin",Rect2(rect.position.x+5,rect.get_center().y-22,44,44))
	text(str(int(save.data.coins)),Rect2(rect.position.x+49,rect.position.y,rect.size.x-62,rect.size.y),26,CREAM,true)

func header(title: String, back_to: String = "home") -> void:
	action("<",Rect2(22,16,54,50),back_to)
	panel(Rect2(83,16,330,50))
	text(title,Rect2(93,16,310,50),28,CREAM,true)
	coin_counter(Rect2(size.x-177,16,155,50))

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
	if notice_time > 0 and screen not in ["battle","settings"]:
		var width := minf(570,size.x-80)
		var notice_y := 133.0 if screen=="battle" else size.y-66
		panel(Rect2((size.x-width)/2,notice_y,width,38),Color("e9c77e"),CREAM)
		text(notice,Rect2((size.x-width)/2+18,notice_y,width-36,38),21,CREAM)
	if fps_label:
		text(str(Engine.get_frames_per_second()),Rect2(0,0,60,24),16)

func draw_home() -> void:
	var x := size.x*0.48
	var width := size.x-x-42
	var emblem_width := minf(width+14,375)
	draw_texture_rect(title_emblem,Rect2(x+(width-emblem_width)/2,16,emblem_width,220),false)
	var play := home_play_rect()
	Ornaments.frame(self,play,1,Color.WHITE.darkened(.22) if pressed_action == "campaign" else Color.WHITE)
	text("PLAY",Rect2(play.position.x+25,play.position.y,play.size.x-83,play.size.y),38,INK,true)
	var arrow := Vector2(play.end.x-46,play.get_center().y)
	draw_colored_polygon(PackedVector2Array([arrow+Vector2(-7,-12),arrow+Vector2(9,0),arrow+Vector2(-7,12)]),INK)
	buttons.append({"rect":play,"id":"campaign","value":-1,"enabled":true})
	var split := (width-12)/2
	var card_height := 114.0 if not save.data.battle.is_empty() else 151.0
	for i in 2:
		var rect := Rect2(x+i*(split+12),296,split,card_height)
		var id := "arsenal" if i == 0 else "upgrades"
		Ornaments.frame(self,rect,0,Color.WHITE.darkened(.22) if pressed_action == id else Color.WHITE)
		var source := Rect2(25,125,925,650) if i == 0 else Rect2(950,130,800,650)
		var icon_height := card_height-34
		var icon_width := minf(split-18,icon_height*source.size.x/source.size.y)
		draw_texture_rect_region(menu_icons,Rect2(rect.get_center().x-icon_width/2,rect.position.y+2,icon_width,icon_height),source)
		text("ARSENAL" if i == 0 else "UPGRADES",Rect2(rect.position.x+12,rect.end.y-38,split-24,26),25,CREAM,true)
		buttons.append({"rect":rect,"id":id,"value":-1,"enabled":true})
	if not save.data.battle.is_empty():
		action("CONTINUE DUEL",Rect2(x,418,width,44),"continue",-1,true)
	action("OPTIONS",Rect2(22,18,205,46),"settings")
	action("DAILY CHALLENGE",Rect2(24,size.y-96,290,48),"daily")
	Ornaments.frame(self,Rect2(237,18,50,46))
	Ornaments.ui_icon(self,"journal",Rect2(246,25,32,32))
	buttons.append({"rect":Rect2(237,18,50,46),"id":"journal","value":-1,"enabled":true})
	coin_counter(Rect2(size.x-177,18,155,46))
	text("CAMPAIGN  •  DAILY CHALLENGE",Rect2(24,size.y-36,size.x*.4,28),17,CREAM)

func home_play_rect() -> Rect2:
	var x := size.x*.48
	var width := size.x-x-42
	var play_width := minf(340,width*.78)
	return Rect2(x+(width-play_width)/2,214,play_width,74)

func campaign_points() -> Array[Vector2]:
	var points: Array[Vector2]=[]
	var width := size.x*.64-84
	for i in 4: points.append(Vector2(46+i*(width-92)/3,100-sin(i*1.4)*36))
	return points

func campaign_span() -> float:
	return size.x*.64-44

func settle_campaign(target: int) -> void:
	var next := clampi(target,0,mini(2,int(save.data.unlocked)/4))
	if next!=chapter:
		campaign_background_from=chapter
		campaign_background_time=0
		campaign_background_direction=signf(next-chapter)
		campaign_offset+=(next-chapter)*campaign_span()
		chapter=next; mission=chapter*4
	campaign_slide_from=campaign_offset; campaign_slide_time=0
	if save.data.calm:
		campaign_offset=0
		campaign_background_time=.55

func draw_campaign_track(canvas: Control) -> void:
	if screen!="campaign": return
	var points := campaign_points()
	for page in 3:
		var offset := campaign_offset+(page-chapter)*campaign_span()
		if absf(offset)>canvas.size.x+45: continue
		canvas.draw_set_transform(Vector2(offset,0))
		for i in 3:
			canvas.draw_line(points[i],points[i+1],Color("192f3a"),11,true)
			canvas.draw_line(points[i],points[i+1],GOLD if page*4+i<save.data.unlocked else Color("718792"),5,true)
		for i in 4:
			var level := page*4+i
			var available: bool=level<=save.data.unlocked
			var p := points[i]
			Ornaments.jewel(canvas,p,36,(COLORS[0] if level==mission else COLORS[1]) if available else INK,level==mission)
			if available:
				text("%02d" % (level+1),Rect2(p-Vector2(32,30),Vector2(64,60)),24,INK,true,HORIZONTAL_ALIGNMENT_CENTER,false,canvas)
			else:
				Ornaments.padlock(canvas,p)
			if save.data.wins.has(str(level)):
				text("★".repeat(int(save.data.wins[str(level)])),Rect2(p.x-42,p.y+40,84,28),20,GOLD,false,HORIZONTAL_ALIGNMENT_CENTER,false,canvas)
	canvas.draw_set_transform(Vector2.ZERO)

func draw_campaign() -> void:
	header("CAMPAIGN")
	panel(Rect2(size.x*.25,80,size.x*.5,45))
	text(REGIONS[chapter],Rect2(size.x*.25,80,size.x*.5,45),26,GOLD,true)
	campaign_track.position=Vector2(42,139)
	campaign_track.size=Vector2(size.x*.64-84,203)
	campaign_track.visible=overlay.is_empty() and not loading
	campaign_track.queue_redraw()
	# Keep level hit targets alive while a finger is held still across redraws.
	if absf(campaign_offset)<.5:
		var points := campaign_points()
		for i in 4:
			buttons.append({"rect":Rect2(points[i]+campaign_track.position-Vector2(42,42),Vector2(84,84)),"id":"mission","value":chapter*4+i,"enabled":chapter*4+i<=save.data.unlocked})
	var y := size.y-134
	var feet := Vector2(size.x*.82,y+14)
	Ornaments.glow(self,feet-Vector2(0,95),115,Color(.35,.72,1,.3))
	draw_arc(feet-Vector2(0,105),92,0,TAU,64,Color(GOLD,.45),1.5,true)
	panel(Rect2(24,y,size.x-48,112))
	draw_set_transform(feet,0,Vector2(1,.14))
	Ornaments.glow(self,Vector2.ZERO,72,Color(.01,.04,.07,.55))
	draw_set_transform(Vector2.ZERO)
	EnemyArt.draw_preview(self,mission,feet,238)
	text(t(ENEMIES[mission]).to_upper(),Rect2(44,y+8,size.x-320,40),26,CREAM,true,HORIZONTAL_ALIGNMENT_LEFT)
	text(t("CPU  •  %s  •  +%d COINS") % [t("BOSS" if mission%4==3 else "DUEL"),40+mission*5 if save.data.wins.has(str(mission)) else 120+mission*20],Rect2(44,y+51,size.x-320,35),19,GOLD,false,HORIZONTAL_ALIGNMENT_LEFT)
	action("PREPARE >",Rect2(size.x-249,y+29,205,58),"powers",-1,true)
	if chapter>0: action("<",Rect2(23,86,50,46),"chapter",chapter-1)
	if chapter<2: action(">",Rect2(size.x-73,86,50,46),"chapter",chapter+1,false,save.data.unlocked>=(chapter+1)*4)

func draw_arsenal() -> void:
	header("ARSENAL")
	var width := (size.x-70)/4
	for i in 4:
		var rect := Rect2(20+i*(width+10),90,width,270)
		panel(rect,INK,GOLD if i==selected else COLORS[i])
		icon(i,Vector2(rect.get_center().x,173),54,COLORS[i])
		text(NAMES[i],Rect2(rect.position.x+5,235,width-10,36),27,CREAM,true)
		text(t("LEVEL %d") % int(save.data.levels[i]),Rect2(rect.position.x,282,width,30),21,GOLD)
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
	text(t("LEVEL %d  >  %d") % [level,mini(8,level+1)],Rect2(x+12,106,width-24,50),32,GOLD,true)
	text(["DAMAGE","PROTECTION","DAMAGE","HEALING"][selected],Rect2(x+16,169,width-32,30),23)
	text(str(effect(selected)) if level==8 else t("%d  >  %d") % [effect(selected),effect(selected)+[8,5,6,6][selected]],Rect2(x+16,206,width-32,48),35,COLORS[selected])
	text(t("CHARGE   %d ENERGY") % COSTS[selected],Rect2(x+16,265,width-32,34),23)
	action("MAX LEVEL" if level==8 else t("UPGRADE  ◈ %d") % price,Rect2(x+20,319,width-40,56),"upgrade",selected,true,level<8 and save.data.coins>=price)
	text("Fully upgraded" if level==8 else "Earn coins in campaign" if save.data.coins<price else t("Balance after: %d") % (int(save.data.coins)-price),Rect2(x+12,386,width-24,29),19)

func board_rect() -> Rect2:
	return Rect2((size.x-454)/2,205,454,256)

func tile_center(i: int) -> Vector2:
	return board_rect().position+Vector2((i%7)*65+32,(i/7)*65+32)

func health_bar(rect: Rect2, current: int, maximum: int, opponent: bool) -> void:
	Ornaments.frame(self,rect)
	var start := rect.position.x+17 if opponent else rect.position.x+38
	var width := rect.size.x-55
	var label := t(ENEMIES[mission]).capitalize() if opponent else t("YOU")
	while title_font.get_string_size(label,HORIZONTAL_ALIGNMENT_LEFT,-1,16).x > width-96:
		label=label.left(label.length()-2)+"…"
	text(label,Rect2(start,rect.position.y+1,width-96,20),17,CREAM,true,HORIZONTAL_ALIGNMENT_LEFT,false)
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
	var side_width := (size.x-490)/2
	var source_size := board_environment.get_size()
	for part in 3:
		var source_x: float = [0.0,.23,.77][part]*source_size.x
		var source_width: float = [.23,.54,.23][part]*source_size.x
		var target_x: float = [0.0,side_width,side_width+490][part]
		var target_width: float = [side_width,490.0,side_width][part]
		draw_texture_rect_region(board_environment,Rect2(target_x,177,target_width,size.y-177),Rect2(source_x,0,source_width,source_size.y))
	if shield>0 and not ended:
		Ornaments.shield_field(self,Vector2(size.x*.20,119),clock,save.data.calm)
	fx.draw(self,size.x,save.data.calm)
	var board := board_rect()
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
	if ended: intent=t("VICTORY" if won else "DEFEATED")
	Ornaments.plaque(self,Rect2(size.x/2-177,164,354,39))
	if path.is_empty():
		text(notice if notice_time > 0 else intent,Rect2(size.x/2-155,167,310,32),20,GOLD if notice_time > 0 else CREAM)
	if not path.is_empty():
		var word := ""
		for i in path: word += lex.letters[i]
		text(word,Rect2(size.x/2-152,167,304,32),25,CREAM,true,HORIZONTAL_ALIGNMENT_CENTER,false)
		if tap_composition and not (dragging and drag_moved):
			action("×",Rect2(size.x/2-232,159,49,44),"clear")
			action("✓",Rect2(size.x/2+183,159,49,44),"submit")
	for i in 28:
		var p := tile_center(i)
		Ornaments.jewel(self,p,29.5,COLORS[lex.types[i]],i in path)
		if hint_time>0 and i in hint_path:
			draw_arc(p,32,0,TAU,48,CREAM,2,true)
		hitboxes.append(Rect2(p-Vector2(30,30),Vector2(60,60)))
	if path.size()>1:
		var points := PackedVector2Array()
		for i in path: points.append(tile_center(i))
		draw_polyline(points,Color(1,.63,.12,.13),20,true)
		draw_polyline(points,Color(1,.73,.20,.3),12,true)
		draw_polyline(points,Color("ffc94a"),6,true)
		draw_polyline(points,Color("fffad9"),2.5,true)
		for j in range(points.size()-1):
			var midpoint := points[j].lerp(points[j+1],.5 if save.data.calm else fmod(clock*1.8+j*.17,1.0))
			Ornaments.glow(self,midpoint,14,Color(1,.78,.3,.75))
	for i in 28:
		var p := tile_center(i)
		text(lex.letters[i],Rect2(p.x-26,p.y-27,52,43),32 if lex.letters[i].length()==1 else 25,Color("071723"),true)
	for i in 28:
		var p := tile_center(i)
		text(["ϟ","◆","≈","+"][lex.types[i]],Rect2(p.x-12,p.y+12,24,16),16,Color("193a46"))
	if not ended:
		for i in 4:
			if energy[i]>=COSTS[i]: Ornaments.ready_aura(self,ability_center(i),COLORS[i],clock+i*.7,save.data.calm,ready_flash[i])
	for i in 4:
		var center := ability_center(i)
		var ready: bool = energy[i] >= COSTS[i]
		Ornaments.medallion(self,i,center,47,COLORS[i],energy[i],COSTS[i])
		var label := Rect2(center.x-58,center.y+29,116,43)
		Ornaments.plaque(self,label)
		text(NAMES[i],Rect2(label.position.x+9,label.position.y+4,98,18),17,CREAM,true)
		text("READY" if ready else t("%d/%d") % [energy[i],COSTS[i]],Rect2(label.position.x+9,label.position.y+23,98,16),16,GOLD if ready else CREAM)
		buttons.append({"rect":Rect2(center-Vector2(59,48),Vector2(118,122)),"id":"fire","value":i,"enabled":true})
	var help_center := Vector2(size.x/2-313,446)
	var power_center := Vector2(size.x/2+294,446)
	Ornaments.medallion(self,7,help_center,25,GOLD)
	buttons.append({"rect":Rect2(help_center-Vector2(30,27),Vector2(60,54)),"id":"hint","value":-1,"enabled":true})
	Ornaments.plaque(self,Rect2(power_center.x-10,426,77,40))
	Ornaments.medallion(self,4+save.data.selected_power,power_center,25,COLORS[1],-1,1,boost_used)
	text("×0" if boost_used else "×1",Rect2(power_center.x+26,427,35,38),23,Color("728894") if boost_used else CREAM)
	buttons.append({"rect":Rect2(power_center-Vector2(29,27),Vector2(99,54)),"id":"boost","value":-1,"enabled":not boost_used})
	for particle in sparks:
		var time: float = particle.time
		var location: Vector2 = particle.pos+particle.vel*time+Vector2(0,80)*time*time
		draw_circle(location,4*(1-time/0.7),Color(particle.color,1-time/0.7))

func ability_center(i: int) -> Vector2:
	return Vector2(size.x/2+(-313 if i<2 else 313),236+(i%2)*111)

func settings_toggle_rect(i: int) -> Rect2:
	var half := ((size.x-92)/2-10)/2
	return Rect2(38+(i%2)*(half+8),94+(i/2)*103,half-2,98)

func draw_settings() -> void:
	header("OPTIONS")
	var width := (size.x-92)/2
	var right := 56+width
	var half := (width-10)/2
	panel(Rect2(28,84,width+16,308))
	panel(Rect2(right-8,84,width+16,308))
	for i in 4:
		var key: String=["sound","music","haptics","calm"][i]
		var on: bool=save.data[key]
		var rect := settings_toggle_rect(i)
		var tint := Color.WHITE if on else Color(.55,.65,.73)
		if pressed_action==key: tint=tint.darkened(.2)
		Ornaments.frame(self,rect,0,tint)
		var center := rect.get_center()
		draw_texture_rect(Ornaments.TOGGLES[i],Rect2(center.x-32,rect.position.y+6,64,64),false,tint)
		var state_rect := Rect2(center.x-32,rect.end.y-26,64,21)
		draw_style_box(health_style(Color("2d7163") if on else Color("253848")),state_rect)
		draw_circle(Vector2(state_rect.position.x+12,state_rect.get_center().y),3.5,Color("acffdb") if on else Color("85949e"))
		text("ON" if on else "OFF",Rect2(center.x-16,state_rect.position.y,43,21),16,CREAM,false,HORIZONTAL_ALIGNMENT_CENTER,false)
		buttons.append({"rect":rect,"id":key,"value":-1,"enabled":true})
	text("LETTER CONNECTION",Rect2(38,305,width-4,29),21,GOLD,true)
	action("ADJACENT",Rect2(38,339,half-2,46),"link_rule",0,save.data.adjacent_only)
	action("ANY LETTERS",Rect2(46+half,339,half-2,46),"link_rule",1,not save.data.adjacent_only)
	text("INTERFACE LANGUAGE",Rect2(right,99,width,30),22,GOLD,true)
	action("English",Rect2(right,137,half,51),"ui_language",0,save.data.ui_language=="en")
	action("Srpski",Rect2(right+half+10,137,half,51),"ui_language",1,save.data.ui_language=="sr")
	text("WORD DICTIONARY",Rect2(right,210,width,30),22,GOLD,true)
	action("English",Rect2(right,250,half,51),"word_language",0,save.data.word_language=="en")
	action("Srpski",Rect2(right+half+10,250,half,51),"word_language",1,save.data.word_language=="sr")
	text("LJ · NJ · DŽ · Č · Ć · Š · Đ · Ž" if save.data.word_language=="sr" else "A–Z · 76,802 words",Rect2(right,315,width,28),19)
	text("Offline dictionaries  •  v0.1.7-dev",Rect2(right,349,width,26),17)
	panel(Rect2(28,394,size.x-56,29),INK)
	text(notice if notice_time>0 else "Any letters: link across the board. Applies to your current duel too.",Rect2(43,394,size.x-86,29),18,CREAM)
	action("HOW TO PLAY",Rect2(36,427,width,46),"help")
	action("CREDITS",Rect2(right,427,width,46),"credits")

func draw_journal() -> void:
	header("WORD JOURNAL")
	panel(Rect2(24,87,size.x-48,size.y-165))
	text(t("%d words found   •   Best: %s") % [save.data.total_words,save.data.longest if not save.data.longest.is_empty() else "—"],Rect2(42,101,size.x-84,36),24,GOLD)
	var list: Array = save.data.dictionary.duplicate()
	list.reverse()
	if list.is_empty():
		text("Your discoveries will appear here after a duel.",Rect2(42,192,size.x-84,60),24)
	for i in mini(20,maxi(0,list.size()-journal_page*20)):
		var word: String = list[journal_page*20+i]
		var column := i%4
		var row: int = i/4
		var cell := Rect2(42+column*(size.x-84)/4,147+row*47,(size.x-100)/4,43)
		draw_line(Vector2(cell.position.x+8,cell.end.y),Vector2(cell.end.x-8,cell.end.y),Color(GOLD,.16),1)
		text(word,cell,23,CREAM,true,HORIZONTAL_ALIGNMENT_CENTER,false)
	action("<",Rect2(28,size.y-62,60,46),"journal_page",journal_page-1,false,journal_page>0)
	text(t("PAGE %d") % (journal_page+1),Rect2(size.x/2-100,size.y-62,200,46),21)
	action(">",Rect2(size.x-88,size.y-62,60,46),"journal_page",journal_page+1,false,(journal_page+1)*20<list.size())

func draw_battle_dialog(rect: Rect2, victory: bool) -> void:
	var middle := rect.get_center().x
	panel(rect)
	draw_texture_rect(Ornaments.FILIGREE,rect,false)
	Ornaments.glow(self,Vector2(middle,rect.position.y+64),145,Color(1,.71,.24,.17) if victory else Color(.25,.65,1,.17))
	draw_texture_rect(Ornaments.CRESTS[1 if victory else 0],Rect2(middle-82,rect.position.y-39,164,106),false)
	Ornaments.plaque(self,Rect2(middle-177,rect.position.y+58,354,51))
	text("VICTORY" if victory else "PAUSED",Rect2(middle-155,rect.position.y+62,310,40),32,GOLD,true)
	if victory:
		for i in 3:
			var p := Vector2(middle+(i-1)*75,rect.position.y+141)
			var radius := 29.0 if i==1 else 23.0
			if i<stars:
				Ornaments.glow(self,p,47,Color(1,.72,.25,.35))
			Ornaments.star(self,p,radius,i<stars)
			if i<stars and not save.data.calm:
				var spark := p+Vector2.from_angle(clock*.7+i*2)*35
				Ornaments.gem(self,spark,2.5)
		Ornaments.frame(self,Rect2(middle-104,rect.position.y+181,208,44))
		Ornaments.ui_icon(self,"coin",Rect2(middle-87,rect.position.y+185,35,35))
		text("+%d" % reward,Rect2(middle-44,rect.position.y+183,130,38),28,GOLD,true)
		text(t("%d words  •  %.0fs") % [word_count,duration],Rect2(rect.position.x+55,rect.position.y+234,rect.size.x-110,25),21)
		text(t("Best word: %s") % (best_word if not best_word.is_empty() else "—"),Rect2(rect.position.x+55,rect.position.y+262,rect.size.x-110,25),21,GOLD)
		if mission==11: text("CAMPAIGN COMPLETE",Rect2(middle-145,rect.position.y+161,290,22),16,GOLD,true)
	else:
		text(ENEMIES[mission],Rect2(middle-245,rect.position.y+118,490,32),24,CREAM,true)
		var values := [str(word_count),str(hp)+" / 100",str(int(duration))+"s"]
		for i in 3:
			var card := Rect2(middle-237+i*164,rect.position.y+159,146,86)
			Ornaments.frame(self,card)
			var icon_rect := Rect2(card.get_center().x-18,card.position.y+6,36,36)
			if i==0: Ornaments.ui_icon(self,"journal",icon_rect)
			else: draw_texture_rect(Ornaments.HEALTH if i==1 else Ornaments.HOURGLASS,icon_rect,false)
			text(values[i],Rect2(card.position.x+6,card.position.y+44,134,30),25,GOLD,true)
		text("Progress is saved on this device.",Rect2(rect.position.x+55,rect.position.y+260,rect.size.x-110,27),20)
	var y := rect.end.y-71
	if victory:
		action("MAP",Rect2(middle-275,y,140,51),"campaign")
		action("UPGRADES",Rect2(middle-119,y,185,51),"upgrades")
		action("NEXT >" if mission<11 else "RETRY",Rect2(middle+81,y,194,51),"next",-1,true)
	else:
		action("MENU",Rect2(middle-300,y,125,51),"save_home")
		action("OPTIONS",Rect2(middle-165,y,190,51),"settings")
		action("RESUME",Rect2(middle+45,y,255,51),"resume",-1,true)

func draw_overlay() -> void:
	buttons.clear()
	draw_rect(Rect2(Vector2.ZERO,size),Color(0.02,0.06,0.10,0.86))
	var width := minf(670,size.x-60)
	var rect := Rect2((size.x-width)/2,55,width,size.y-110)
	if overlay=="pause" or (overlay=="result" and won):
		draw_battle_dialog(rect,overlay=="result")
		return
	panel(rect,Color("133249"))
	var title := "PAUSED"
	var lines: Array[String] = []
	match overlay:
		"pause":
			lines = ["Your duel is safely paused.","Progress is saved on this device."]
		"help":
			title="WORDS BECOME POWER"
			lines=[("Link neighboring letters, including diagonals." if (lex.adjacent_only if screen=="battle" else save.data.adjacent_only) else "Link any letters. Each tile can be used once."),"Release to submit; drag back to undo a letter.","Colors charge the matching abilities. Tap READY.","Long words hit harder. Find each word once per duel.","Tap letters + ✓ also works. HINT reveals a path."]
		"credits":
			title="WAR OF WORDS"
			lines=["An original offline word-combat adventure.","Built with Godot 4.7.2 (MIT).", "English: SCOWL · Serbian: LibreOffice (MPL-2.0).","Noto Serif / Lato: SIL Open Font License.","Original AI-assisted art and synthesized sound.","Music: Joth / TAD · CC0 recordings.","Full notices included in the project and app package."]
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
	if screen=="daily":
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE: daily_screen.leave()
		return
	if loading or (ended and result_delay > 0):
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
				page_gesture=false
				if screen=="campaign": settle_campaign(chapter)
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
	page_gesture=false
	if buttons_state != screen+"|"+overlay: return
	if screen=="campaign" and absf(campaign_offset)>.5: return
	page_gesture=screen in ["campaign","journal"] and overlay.is_empty() and p.y > 75
	page_origin=p; page_screen=screen
	if screen=="battle" and overlay.is_empty() and not ended:
		for i in hitboxes.size():
			if hitboxes[i].has_point(p):
				dragging=true; drag_moved=false; drag_position=p; add_letter(i); return
	for b in buttons:
		if b.rect.has_point(p) and b.enabled:
			pressed_action=b.id; pressed_value=b.value; return

func move(p: Vector2) -> void:
	if page_gesture and p.distance_to(page_origin)>18:
		pressed_action=""; pressed_value=-1
		var travel := p-page_origin
		if screen=="campaign" and not save.data.calm and absf(travel.x)>absf(travel.y)*1.35:
			var direction := 1 if travel.x<0 else -1
			var allowed := chapter+direction>=0 and chapter+direction<=mini(2,int(save.data.unlocked)/4)
			campaign_offset=clampf(travel.x,-campaign_span()*.8,campaign_span()*.8)*(1.0 if allowed else .12)
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
	if page_gesture:
		page_gesture=false
		var travel := p-page_origin
		if page_screen == screen and overlay.is_empty() and absf(travel.x)>=50 and absf(travel.x)>absf(travel.y)*1.35:
			pressed_action=""; pressed_value=-1
			var direction := 1 if travel.x < 0 else -1
			if screen == "campaign": dispatch("chapter",chapter+direction)
			elif screen == "journal": dispatch("journal_page",journal_page+direction)
			sfx.play("tap")
			return
		if screen=="campaign": settle_campaign(chapter)
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
	if i in path or (lex.adjacent_only and not path.is_empty() and not lex.adjacent(path.back(),i)):
		return
	path.append(i)
	sfx.play("tap",1+path.size()*0.035)
	haptic(10,.25)

func haptic(milliseconds: int, strength: float) -> void:
	if save.data.haptics and OS.get_name() == "Android":
		Input.vibrate_handheld(milliseconds,strength)

func launch_attack(player: bool, kind: String, color: Color, damage: int) -> void:
	if player: hero.react("fire",save.data.calm)
	fx.launch(player,kind,color,damage)
	sfx.play("arc" if kind == "arc" else "shot",1.13 if kind == "word" else 1.0)
	sfx.play("flight",.92 if not player else 1.0)
	haptic(18 if kind == "word" else 40,.3 if kind == "word" else .65)

func dispatch(id: String, value: int = -1) -> void:
	if OS.is_debug_build(): print("WarOfWords: action=%s screen=%s overlay=%s" % [id,screen,overlay])
	match id:
		"daily": change_screen("daily"); daily_screen.open()
		"home","campaign","arsenal","powers","upgrades","settings","journal": change_screen(id)
		"select": selected=value
		"mission": mission=value
		"chapter":
			settle_campaign(value)
		"journal_page": journal_page=clampi(value,0,maxi(0,(save.data.dictionary.size()-1)/20))
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
		"sound","music","haptics","calm":
			save.data[id]=not save.data[id]
			sfx.enabled=save.data.sound
			music.set_enabled(save.data.music)
			save.save_game()
			message({"sound":"SOUND EFFECTS","music":"MUSIC","haptics":"HAPTICS","calm":"REDUCED MOTION"}[id])
		"ui_language":
			save.data.ui_language = ["en","sr"][value]; save.save_game()
		"word_language":
			save.data.word_language = ["en","sr"][value]; save.save_game()
			await select_dictionary(save.data.word_language)
		"link_rule":
			save.data.adjacent_only = value == 0
			lex.adjacent_only = save.data.adjacent_only
			path.clear(); hint_path.clear(); hint_time=0
			if not save.data.battle.is_empty():
				save.data.battle.adjacent_only=save.data.adjacent_only
			if screen == "battle" and not ended: persist_battle()
			save.save_game()
		"quit": persist_battle(); get_tree().quit()
	queue_redraw()

func change_screen(target: String) -> void:
	if screen=="battle" and not ended:
		persist_battle()
	previous=screen
	screen=target
	overlay=""; path.clear(); dragging=false; tap_composition=false
	fx.clear(); result_delay=0
	campaign_offset=0; campaign_slide_time=.32
	if campaign_track!=null: campaign_track.visible=false
	hero_recoil=0; enemy_recoil=0; page_gesture=false
	notice_time=0
	if target=="campaign": chapter=mission/4
	if target=="battle" and not ended: hero.reset_pose()
	campaign_background_from=chapter; campaign_background_time=.55
	get_node("Backdrop").queue_redraw()
	update_actors()
	queue_redraw()

func back() -> void:
	if screen=="daily": daily_screen.leave(); return
	if ended and screen == "battle" and result_delay>0: return
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
	lex.adjacent_only = save.data.adjacent_only
	change_screen("battle")
	hp=100; foe_max=72+mission*13+(35 if mission%4==3 else 0); foe_hp=foe_max
	energy=[0,3,0,0]; shield=0; used.clear(); word_count=0; best_word=""
	duration=0; ended=false; won=false; reward=0; stars=0; freeze=0; surge=false
	boost_used=false; enemy_attacks=0; countdown=interval()+4; shuffled=0
	fx.clear(); sparks.clear(); hint_path.clear(); path.clear()
	ready_flash.assign([0.0,0.0,0.0,0.0])
	attack_flash=0; hero_flash=0
	lex.generate()
	if not save.data.tutorial:
		lex.letters.assign(Array(("KAMENVAREKASUNŠTITIGRVODAMOS" if lex.language=="sr" else "STONESTREAMLINEPLANETCARDSEN").split("")))
		lex.find_words()
		overlay="help"
	persist_battle()

func interval() -> float:
	return maxf(8,14-mission*0.42)

func submit_word() -> void:
	if ended or fx.shots.size() >= fx.MAX_SHOTS: return
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
	for i in 4:
		var previous_energy: int=energy[i]
		energy[i]=mini(COSTS[i],energy[i]+gain[i])
		if previous_energy<COSTS[i] and energy[i]>=COSTS[i]: ready_flash[i]=1.15
	surge=false
	var damage := path.size()+maxi(0,path.size()-4)*2
	launch_attack(true,"word",GOLD,damage)
	sfx.play("word")
	var refreshed: bool = lex.refill(path,used)
	path.clear()
	message(t("%s  •  %d damage%s") % [word,damage,t("  •  Board refreshed") if refreshed else ""])
	persist_battle()

func fire(i: int) -> void:
	if i not in [0,1,2,3] or fx.shots.size() >= fx.MAX_SHOTS: return
	if ended or energy[i]<COSTS[i]:
		message(t("%s needs %d matching energy") % [t(NAMES[i]),COSTS[i]]); return
	if i==1 and shield>0: message("Your shield is already active"); return
	if i==3 and hp>=100: message("Health is already full"); return
	energy[i]=0
	ready_flash[i]=0
	match i:
		1: shield=effect(i)
		3: hp=mini(100,hp+effect(i)); hero_flash=0
	if i in [0,2]: launch_attack(true,"arc" if i == 2 else "pulse",COLORS[i],effect(i))
	else:
		fx.burst("shield" if i == 1 else "heal",Vector2(.20,115),COLORS[i],.8)
		sfx.play("shield" if i == 1 else "heal")
		haptic(30,.4)
	message(["Pulse fired!","Shield ready","Arc fired!","Health restored"][i])
	persist_battle()

func enemy_attack() -> void:
	if ended or fx.shots.size() >= fx.MAX_SHOTS: return
	enemy_attacks+=1
	var amount := 12+mission
	if mission%4==3 and enemy_attacks%3==0: amount+=8
	countdown=interval()
	launch_attack(false,"enemy",COLORS[2],amount)
	persist_battle()

func power_up() -> void:
	if boost_used or ended: return
	boost_used=true
	match save.data.selected_power:
		0: freeze=8; message("Time frozen — keep finding words")
		1: path.clear(); lex.generate(used); message("Fresh board — new possibilities")
		2: surge=true; message("Next word gives double energy")
	sfx.play("freeze" if save.data.selected_power == 0 else "upgrade")
	fx.burst("freeze" if save.data.selected_power == 0 else "heal",Vector2(.80 if save.data.selected_power == 0 else .20,115),COLORS[1] if save.data.selected_power == 0 else GOLD,.9)
	haptic(35,.45)
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
	message(t("HINT: %s") % solution)

func finish(victory: bool) -> void:
	if ended: return
	ended=true; won=victory; result_delay=DEFEAT_DURATION; overlay=""; path.clear(); notice_time=0
	touch_id=-1; dragging=false; drag_moved=false; tap_composition=false; pressed_action=""
	fx.shots.clear()
	hero_recoil=0; enemy_recoil=0
	if not won: hero.begin_defeat()
	fx.burst("defeat" if won else "fall_dust",Vector2(.80 if won else .20,128),GOLD if won else COLORS[1],DEFEAT_DURATION)
	sfx.play("explosion",.78)
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

func persist_battle() -> void:
	if screen=="battle" and not ended and lex.letters.size()==28:
		save.data.battle={"adjacent_only":lex.adjacent_only,"dictionary_code":lex.language,"mission":mission,"hp":hp,"foe":foe_hp,"max":foe_max,"energy":energy,"shield":shield,"countdown":countdown,"freeze":freeze,"surge":surge,"boost_used":boost_used,"used":used,"words":word_count,"best":best_word,"duration":duration,"letters":lex.letters,"types":lex.types,"attacks":enemy_attacks,"power":save.data.selected_power}
		save.data.battle.projectiles=fx.snapshot()
	if not save.save_game(): message("Could not save progress on this device")

func restore_battle() -> void:
	var b: Dictionary = save.data.battle
	if b.is_empty(): return
	if not valid_snapshot(b):
		save.data.battle={}; save.save_game(); message("Old duel could not be restored. Start a new one."); return
	await select_dictionary(b.get("dictionary_code","en"))
	lex.adjacent_only = b.get("adjacent_only",true)
	change_screen("battle")
	mission=int(b.mission); hp=int(b.hp); foe_hp=int(b.foe); foe_max=int(b.max)
	energy.assign(b.energy); shield=int(b.shield); countdown=float(b.countdown)
	ready_flash.assign([0.0,0.0,0.0,0.0])
	freeze=float(b.freeze); surge=bool(b.surge); boost_used=bool(b.boost_used)
	used=b.used.duplicate(); word_count=int(b.words); best_word=b.best; duration=float(b.duration)
	lex.letters.assign(b.letters); lex.types.assign(b.types); lex.find_words(used)
	enemy_attacks=int(b.attacks); save.data.selected_power=int(b.power)
	ended=false; won=false; overlay="pause"; fx.restore(b.get("projectiles",[])); sparks.clear()

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
	if not b.get("adjacent_only",true) is bool: return false
	if not fx.valid_saved(b.get("projectiles",[])): return false
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
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--qa-out="): directory=ProjectSettings.globalize_path(argument.trim_prefix("--qa-out="))
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
	change_screen("home")
	await _qa_capture(directory+"/home-sr.png")
	change_screen("upgrades")
	await _qa_capture(directory+"/upgrades-sr.png")
	await select_dictionary("sr")
	change_screen("battle"); countdown=60; ended=false
	lex.letters.assign(["Đ","A","K","Č","Ć","Š","Ž","DŽ","E","P","LJ","U","B","A","V","NJ","E","G","A","R","E","K","A","M","O","S","T","I"])
	lex.types.clear()
	for i in 28: lex.types.append(i%4)
	path.assign([0,1,2]); tap_composition=true
	await _qa_capture(directory+"/battle-djak.png")
	path.clear(); tap_composition=false; set_process(false)
	fx.clear(); fx.launch(true,"pulse",GOLD,24); advance_combat(.24)
	await _qa_capture(directory+"/pulse-flight.png")
	advance_combat(.24); update_actors()
	await _qa_capture(directory+"/pulse-impact.png")
	fx.clear(); shield=20; fx.launch(false,"enemy",COLORS[2],12); advance_combat(.5); update_actors()
	await _qa_capture(directory+"/shield-impact.png")
	save.data.calm=true
	await _qa_capture(directory+"/reduced-motion.png")
	save.data.calm=false; save.data.ui_language="en"
	change_screen("journal")
	save.data.dictionary.assign(["STONE","SUNLIGHT","BRIDGE","GUARDIAN","TEMPEST","JOURNEY","ASTRAL","COPPER","ARCHIVE","THUNDER","WORDSMITH","SENTINEL","WARDEN","CRESCENT","ORBIT","CRYSTAL","FORGE","AETHER","SKYLINE","RADIANCE","BLADE"])
	await _qa_capture(directory+"/journal.png")
	for encounter in 12:
		change_screen("battle"); mission=encounter; ended=false; hp=100; foe_hp=100; foe_max=100; countdown=60
		attack_flash=0; hero_flash=0; enemy_recoil=0; hero_recoil=0
		update_actors()
		await _qa_capture(directory+"/enemy-%02d.png" % encounter)
	mission=6; shield=20; energy.assign(COSTS); ready_flash.assign([.6,.6,.6,.6]); fx.clear()
	await _qa_capture(directory+"/shield-ready.png")
	save.data.calm=true
	await _qa_capture(directory+"/shield-ready-calm.png")
	save.data.calm=false; shield=0; foe_hp=0; finish(true)
	result_delay=DEFEAT_DURATION-.48; fx.advance(.48)
	await _qa_capture(directory+"/enemy-defeat.png")
	ended=false; hp=0; foe_hp=100; fx.clear(); finish(false)
	result_delay=DEFEAT_DURATION-.65; fx.advance(.65)
	await _qa_capture(directory+"/hero-defeat.png")
	save.data.ui_language="en"; save.data.sound=true; save.data.music=false; save.data.haptics=true; save.data.calm=false
	change_screen("settings")
	await _qa_capture(directory+"/options-icons.png")
	save.data.ui_language="sr"
	await _qa_capture(directory+"/options-icons-sr.png")
	save.data.ui_language="en"; save.data.unlocked=11
	for page in 3:
		mission=page*4; change_screen("campaign")
		await _qa_capture(directory+"/campaign-%d.png" % page)
	mission=0; change_screen("campaign"); settle_campaign(1); campaign_offset=campaign_span()*.45
	await _qa_capture(directory+"/campaign-slide.png")
	change_screen("battle"); ended=false; hp=64; mission=8; word_count=6; duration=43; best_word="RADIANCE"; overlay="pause"
	await _qa_capture(directory+"/pause-ornate.png")
	ended=true; won=true; reward=240; stars=2; overlay="result"
	await _qa_capture(directory+"/victory-ornate.png")
	save.data.ui_language="sr"; mission=11; stars=3; best_word="ĐAK"
	await _qa_capture(directory+"/victory-final-sr.png")
	change_screen("battle"); ended=false; mission=0; hp=100; countdown=60; save.data.ui_language="en"; save.data.calm=false
	for pose in ["idle","fire","hit"]:
		hero.react(pose,false); hero.advance_pose(.1,false,false)
		await _qa_capture(directory+"/hero-rig-"+pose+".png")
	mission=0; change_screen("campaign"); settle_campaign(1)
	campaign_background_time=.275; campaign_offset=campaign_span()*.5
	await _qa_capture(directory+"/campaign-dissolve.png")
	get_tree().quit()

func _qa_capture(file: String) -> void:
	update_actors()
	queue_redraw()
	get_node("Backdrop").queue_redraw()
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(file)
