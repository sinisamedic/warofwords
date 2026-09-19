extends RefCounted
const O = preload("res://scripts/ornaments.gd")
const SKY = preload("res://assets/art/endless/sky-court.png")
const CARDS = [preload("res://assets/art/endless/mode-campaign.png"),preload("res://assets/art/endless/portal-enemies.png"),preload("res://assets/art/endless/mode-daily.png")]
const PORTAL_HERO = preload("res://assets/art/endless/portal-hero.png")
const PORTAL = preload("res://assets/art/endless/portal-ring.png")
const WAVE_REFERENCE = preload("res://assets/art/endless/wave-design-reference.png")
const WAVE_GLOW = preload("res://assets/ui/wave-glow.svg")
const WAVE_PANEL = preload("res://assets/ui/wave-panel.svg")
const BOSS_SR = preload("res://assets/art/endless/boss-sr.png")
const BOSS_EN = preload("res://assets/art/endless/boss-en.png")
const HOURGLASS = preload("res://assets/art/endless/hourglass-v2.png")
const GOLD := Color("f3c569")
const CREAM := Color("fff1ce")
const INK := Color("10283d")

static func cover(c: CanvasItem, texture: Texture2D, rect: Rect2, phase: float = 0.0) -> void:
	var s := Vector2(texture.get_size())
	var scale_factor := maxf(rect.size.x/s.x,rect.size.y/s.y)*1.035
	var crop := rect.size/scale_factor
	var origin := (s-crop)/2+Vector2(sin(phase)*minf(7,(s.x-crop.x)/2),cos(phase)*minf(7,(s.y-crop.y)/2))
	c.draw_texture_rect_region(texture,rect,Rect2(origin,crop))

static func fit(c: CanvasItem, texture: Texture2D, rect: Rect2) -> void:
	var s := Vector2(texture.get_size())
	s*=minf(rect.size.x/s.x,rect.size.y/s.y)
	c.draw_texture_rect(texture,Rect2(rect.get_center()-s/2,s),false)

static func card_rect(c, i: int) -> Rect2:
	var gap: float=clampf(c.size.x*.035,26,42)
	var w: float=(c.size.x-76-gap*2)/3
	return Rect2(38+i*(w+gap),119,w,c.size.y-186)

static func home(c) -> void:
	O.frame(c,Rect2(20,16,48,46))
	O.ui_icon(c,"settings",Rect2(29,24,30,30))
	c.buttons.append({"rect":Rect2(20,16,48,46),"id":"settings","value":-1,"enabled":true})
	c.coin_counter(Rect2(c.size.x-179,16,159,46))
	var names := ["CAMPAIGN","ENDLESS WORDS","DAILY CHALLENGE"]
	var ids := ["campaign","endless_entry","daily"]
	for i in 3:
		var r := card_rect(c,i)
		O.frame(c,r,2)
		var art := Rect2(r.position+Vector2(8,9),Vector2(r.size.x-16,r.size.y-122))
		var phase: float=0.0 if c.save.data.calm else c.clock*.35+i
		cover(c,CARDS[i],art,phase)
		if i==1:
			var center := art.get_center()
			var diameter := minf(art.size.x,art.size.y)*.98
			c.draw_set_transform(center,0.0 if c.save.data.calm else c.clock*.42)
			c.draw_texture_rect(PORTAL,Rect2(-Vector2.ONE*diameter/2,Vector2.ONE*diameter),false)
			c.draw_set_transform(Vector2.ZERO)
			fit(c,PORTAL_HERO,Rect2(art.position+Vector2(2,art.size.y*.16),Vector2(art.size.y*.84,art.size.y*.84)))
		if not c.save.data.calm:
			for j in 8:
				var u: float=fposmod(c.clock*.10+j*.137,1.0)
				var p := Vector2(art.position.x+art.size.x*(.14+fposmod(j*.273, .73)),art.end.y-u*art.size.y)
				c.draw_circle(p,1.1+sin(j+c.clock)*.4,Color(1,.83,.4,sin(u*PI)*.65))
			if i==2:
				var p := art.position+art.size*Vector2(.415,.42)
				O.glow(c,p,25,Color(1,.74,.2,.22+.1*sin(c.clock*2)))
				for j in 13:
					var at := p+Vector2(sin(j*2.7)*2,fposmod(c.clock*28+j*4,46))
					c.draw_circle(at,1.8,Color("fff0a0"))
		c.draw_line(Vector2(r.position.x+10,art.end.y),Vector2(r.end.x-10,art.end.y),GOLD,1)
		c.text(names[i],Rect2(r.position.x+12,art.end.y+3,r.size.x-24,34),24,CREAM,true)
		var status: String=c.t("%d / 24 levels") % c.save.data.wins.size() if i==0 else c.t("Best score: %d") % c.endless_record().get("score",0) if i==1 else c.t("A new challenge every day")
		c.text(status,Rect2(r.position.x+12,art.end.y+37,r.size.x-24,24),17)
		var resume: bool=not c.save.data.battle.is_empty() if i==0 else not c.save.data.endless.is_empty() if i==1 else false
		c.action("CONTINUE DUEL" if resume and i==0 else "CONTINUE RUN" if resume else ["OPEN MAP","ENTER ARENA","PLAY CHALLENGE"][i],Rect2(r.position.x+10,r.end.y-52,r.size.x-20,42),"continue" if resume and i==0 else ids[i],-1,true)
		# The artwork and label are also useful touch targets.
		c.buttons.append({"rect":Rect2(r.position,r.size-Vector2(0,57)),"id":ids[i],"value":-1,"enabled":true})
	fit(c,c.title_emblem,Rect2(c.size.x/2-192,0,384,146))
	var bw: float=minf(230,(c.size.x-120)/3)
	for i in 3:
		var r := Rect2(c.size.x/2-1.5*bw-14+i*(bw+14),c.size.y-53,bw,42)
		var id: String=["arsenal","upgrades","records"][i]
		O.frame(c,r)
		if i<2:
			var source := Rect2(25,125,925,650) if i==0 else Rect2(950,130,800,650)
			var sz := source.size*(61/source.size.y)
			c.draw_texture_rect_region(c.menu_icons,Rect2(r.position+Vector2(-11,-16),sz),source)
		c.text(["ARSENAL","UPGRADES","RECORDS"][i],Rect2(r.position+Vector2(67 if i<2 else 12,3),Vector2(bw-(79 if i<2 else 24),36)),20,CREAM,true)
		c.buttons.append({"rect":r,"id":id,"value":-1,"enabled":true})

static func hourglass(c, p: Vector2, fraction: float) -> void:
	fit(c,HOURGLASS,Rect2(p-Vector2(34,31),Vector2(68,62)))
	var f := clampf(fraction,0,1)
	var col := Color("7aeee0") if c.countdown>=3 else Color("ffba65")
	if f>0: O.glow(c,p,26,Color(col,.13))
	if not c.save.data.calm and not c.ended:
		for i in 3: c.draw_circle(p+Vector2(0,fposmod(c.clock*22+i*6,16)),.7,CREAM)

static func hud(c) -> void:
	var mid: float=c.size.x/2
	c.draw_texture_rect(WAVE_PANEL,Rect2(mid-112,53,224,66),false)
	var base: int=((c.endless_wave-1)/5)*5
	c.text(c.t("WAVE %d") % c.endless_wave,Rect2(mid-70,55,140,21),17,CREAM,true)
	for i in 5:
		var p := Vector2(mid+(i-2)*39,96)
		var current: bool=base+i+1==c.endless_wave
		if current:
			c.draw_circle(p,15,Color("0c202b"))
			var pulse: float=1.0 if c.save.data.calm else .95+.05*sin(c.clock*3)
			c.draw_texture_rect(WAVE_GLOW,Rect2(p-Vector2(23,23),Vector2(46,46)),false,Color(1,1,1,pulse))
		else: O.jewel(c,p,13,Color("245573"),false)
		if i==4:
			var points := PackedVector2Array()
			var uv := PackedVector2Array()
			for k in 64:
				var direction := Vector2.from_angle(k*TAU/64)
				points.append(p+direction*14)
				uv.append((Vector2(379,86)+direction*27)/Vector2(WAVE_REFERENCE.get_size()))
			c.draw_polygon(points,PackedColorArray([Color.WHITE]),uv,WAVE_REFERENCE)
		else: c.text(str(base+i+1),Rect2(p-Vector2(10,12),Vector2(20,23)),16,CREAM,true)
		if base+i+1<c.endless_wave:
			c.draw_polyline(PackedVector2Array([p+Vector2(-6,9),p+Vector2(-1,14),p+Vector2(8,3)]),Color("37d949"),3.2,true)
	hourglass(c,Vector2(mid,154),c.countdown/c.interval())

static func score_badge(c, canvas: CanvasItem) -> void:
	if c.screen!="battle" or not c.endless_mode or not c.overlay.is_empty() or c.loading: return
	var rect := Rect2(14,50,60,20)
	O.frame(canvas,rect)
	c.text(str(c.endless_score),Rect2(21,51,46,17),13,CREAM,true,HORIZONTAL_ALIGNMENT_CENTER,false,canvas)

static func choices(c, boss: bool) -> void:
	if not boss:
		c.draw_powers(true)
		return
	var w: float=minf(780,c.size.x-40)
	var r := Rect2((c.size.x-w)/2,12,w,c.size.y-24)
	c.panel(r)
	c.draw_texture_rect(SKY,r.grow(-12),false,Color(.55,.65,.74,.24))
	c.draw_rect(Rect2(r.position+Vector2(110,8),Vector2(w-220,174)),Color(.035,.10,.15,.64))
	c.draw_texture_rect(O.WEAVE,r.grow(-12),true,Color(1,.88,.57,.16))
	c.draw_texture_rect(O.FILIGREE,Rect2(r.position.x+24,r.position.y+14,82,82),false,Color(1,.86,.52,.6))
	c.draw_set_transform(Vector2(r.end.x-24,r.position.y+14),0,Vector2(-1,1))
	c.draw_texture_rect(O.FILIGREE,Rect2(0,0,82,82),false,Color(1,.86,.52,.6))
	c.draw_set_transform(Vector2.ZERO)
	for side in [-1,1]:
		var x: float=r.get_center().x+side*(w/2-17)
		for j in 7:
			O.gem(c,Vector2(x,104+j*39),2.2)
	O.glow(c,Vector2(r.get_center().x,90),120,Color(1,.7,.18,.13))
	if boss:
		if c.save.data.ui_language in ["en","sr"]:
			fit(c,BOSS_SR if c.save.data.ui_language=="sr" else BOSS_EN,Rect2(r.position.x+90,r.position.y-4,w-180,102))
		else:
			O.frame(c,Rect2(r.position.x+90,r.position.y+10,w-180,69),1)
			c.text("BOSS DEFEATED",Rect2(r.position.x+108,r.position.y+20,w-216,47),29,c.INK,true)
		c.text(c.t("WAVE %d COMPLETE") % c.endless_wave,Rect2(r.position.x+20,99,w-40,26),20,GOLD,true)
	else:
		c.text("ENDLESS WORDS",Rect2(r.position.x+20,25,w-40,45),31,GOLD,true)
		c.text("Defeat enemies. Every fifth wave is a boss.",Rect2(r.position.x+22,70,w-44,26),19)
	c.text("CHOOSE YOUR POWER-UP",Rect2(r.position.x+20,128,w-40,31),24,CREAM,true)
	c.text("One use until the next boss." if boss else "Health and energy carry between waves.",Rect2(r.position.x+20,159,w-40,24),17)
	var cw: float=(w-72)/3
	for i in 3:
		var card := Rect2(r.position.x+22+i*(cw+14),190,cw,180)
		var on: bool=c.save.data.selected_power==i
		O.frame(c,card,2,Color.WHITE if on else Color(.68,.73,.8))
		var p := Vector2(card.get_center().x,235)
		if on: O.selection_aura(c,p,c.clock,c.save.data.calm)
		O.medallion(c,4+i,p,35,[c.COLORS[1],GOLD,c.COLORS[2]][i],-1,1,not on)
		c.text(c.POWER_NAMES[i],Rect2(card.position.x+9,277,cw-18,28),21,CREAM,true)
		c.text(c.POWER_DESC[i],Rect2(card.position.x+9,307,cw-18,25),16)
		c.text("EQUIPPED" if on else "TAP TO EQUIP",Rect2(card.position.x+8,339,cw-16,23),16,GOLD)
		c.buttons.append({"rect":card,"id":"endless_power","value":i,"enabled":true})
	c.action("MENU",Rect2(r.position.x+22,r.end.y-60,140,43),"save_home")
	c.action(c.t("CONTINUE — WAVE %d") % (c.endless_wave+1) if boss else c.t("ENTER ARENA"),Rect2(r.end.x-345,r.end.y-60,323,43),"endless_next" if boss else "endless_start",-1,true)

static func arsenal_button(c, r: Rect2) -> void:
	O.frame(c,r)
	var source := Rect2(25,125,925,650)
	var sz := source.size*(61/source.size.y)
	c.draw_texture_rect_region(c.menu_icons,Rect2(r.position+Vector2(-11,-16),sz),source)
	c.text("ARSENAL",Rect2(r.position+Vector2(67,3),Vector2(r.size.x-79,r.size.y-6)),20,CREAM,true)
	c.buttons.append({"rect":r,"id":"arsenal","value":-1,"enabled":true})

static func result(c) -> void:
	var w: float=minf(740,c.size.x-50)
	var r := Rect2((c.size.x-w)/2,22,w,c.size.y-44)
	c.panel(r)
	c.draw_texture_rect(SKY,r.grow(-12),false,Color(.45,.58,.7,.26))
	c.draw_rect(Rect2(r.position+Vector2(14,14),Vector2(w-28,107)),Color(.025,.07,.12,.65))
	c.draw_texture_rect(O.FILIGREE,Rect2(r.position+Vector2(18,16),Vector2(80,80)),false)
	c.text("RUN COMPLETE",Rect2(r.position.x+70,37,w-140,36),29,GOLD,true)
	c.text(c.t("Reached wave %d") % c.endless_wave,Rect2(r.position.x+70,77,w-140,26),20,CREAM)
	O.glow(c,Vector2(r.get_center().x,151),95,Color(1,.68,.14,.24))
	O.frame(c,Rect2(r.get_center().x-125,117,250,67))
	c.text(str(c.endless_score),Rect2(r.get_center().x-105,124,210,38),34,GOLD,true)
	c.text("SCORE",Rect2(r.get_center().x-100,162,200,17),13,CREAM)
	var stats := [str(maxi(0,c.endless_wave-1)),str(c.endless_words+c.word_count),"%d:%02d" % [int(c.endless_seconds+c.duration)/60,int(c.endless_seconds+c.duration)%60]]
	var labels := ["ENEMIES DEFEATED","WORDS","TIME"]
	for i in 3:
		var card := Rect2(r.position.x+24+i*(w-48)/3,199,(w-66)/3,68)
		O.frame(c,card)
		c.text(stats[i],Rect2(card.position+Vector2(10,4),Vector2(card.size.x-20,32)),25,GOLD,true)
		c.text(labels[i],Rect2(card.position+Vector2(10,39),Vector2(card.size.x-20,19)),13,CREAM)
	c.text("YOUR LOADOUT",Rect2(r.position.x+24,275,w-48,20),15,GOLD)
	for i in 4: c.equipment_ui.icon(c,c.battle_loadout[i],Vector2(r.get_center().x+(i-1.5)*56,324),23,c.COLORS[i])
	c.text("Try another loadout and beat your record.",Rect2(r.position.x+24,351,w-48,23),17)
	c.action("MENU",Rect2(r.position.x+22,r.end.y-57,135,40),"home")
	c.action("GLOBAL TOP",Rect2(r.get_center().x-103,r.end.y-57,206,40),"endless_board")
	c.action("TRY AGAIN",Rect2(r.end.x-211,r.end.y-57,189,40),"endless_retry",-1,true)

static func victory(c) -> void:
	var progress: float=1-c.result_delay/c.DEFEAT_DURATION
	var dy: float=0 if c.save.data.calm else -5*sin(progress*PI)
	var r := Rect2(c.size.x/2-126,123+dy,252,48)
	O.glow(c,r.get_center(),110,Color(1,.75,.2,.3))
	O.frame(c,r,1)
	c.text("VICTORY",Rect2(r.position+Vector2(22,3),Vector2(208,24)),21,INK,true)
	c.text(c.t("WAVE %d COMPLETE") % c.endless_wave,Rect2(r.position+Vector2(22,26),Vector2(208,17)),12,INK)
	if not c.save.data.calm:
		for i in 10:
			var p := r.get_center()+Vector2.from_angle(i*TAU/10+progress)*Vector2(100,34)*(1+progress*.3)
			O.gem(c,p,2.5)

static func records(c) -> void:
	c.header("RECORDS")
	c.panel(Rect2(c.size.x/2-300,96,600,282))
	c.text("ENDLESS WORDS",Rect2(c.size.x/2-260,113,520,35),28,GOLD,true)
	c.text("Personal records on this device",Rect2(c.size.x/2-260,151,520,28),19)
	var n := 0
	for lang in preload("res://scripts/languages.gd").CODES:
		for adjacent in [true,false]:
			var record: Dictionary=c.save.data.endless_records.get(c.Endless.key(lang,adjacent),{})
			var label: String=("English" if lang=="en" else "Srpski")+" · "+c.t("ADJACENT" if adjacent else "ANY LETTERS")
			c.text(label,Rect2(c.size.x/2-272,190+n*42,310,32),19)
			c.text(c.t("%d pts · wave %d") % [record.get("score",0),record.get("wave",0)],Rect2(c.size.x/2+43,190+n*42,232,32),20,GOLD)
			n+=1
	c.action("GLOBAL TOP",Rect2(c.size.x/2-170,c.size.y-70,340,47),"endless_board",-1,true)
