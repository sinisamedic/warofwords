extends RefCounted
const O = preload("res://scripts/ornaments.gd")
const SKY = preload("res://assets/art/endless/sky-court.png")
const CARDS = [preload("res://assets/art/endless/mode-campaign.png"),preload("res://assets/art/endless/portal-scene.png"),preload("res://assets/art/endless/mode-daily.png")]
const PORTAL = preload("res://assets/art/endless/portal-ring.png")
const SKULL = preload("res://assets/ui/boss-skull.svg")
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
	return Rect2(38+i*(w+gap),98,w,c.size.y-165)

static func home(c) -> void:
	fit(c,c.title_emblem,Rect2(c.size.x/2-140,-7,280,112))
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
		if not c.save.data.calm:
			for j in 8:
				var u: float=fposmod(c.clock*.10+j*.137,1.0)
				var p := Vector2(art.position.x+art.size.x*(.14+fposmod(j*.273, .73)),art.end.y-u*art.size.y)
				c.draw_circle(p,1.1+sin(j+c.clock)*.4,Color(1,.83,.4,sin(u*PI)*.65))
			if i==2:
				var p := art.position+art.size*Vector2(.45,.42)
				O.glow(c,p,25,Color(1,.74,.2,.22+.1*sin(c.clock*2)))
				for j in 13:
					var at := p+Vector2(sin(j*2.7)*2,fposmod(c.clock*28+j*4,46))
					c.draw_circle(at,1.8,Color("fff0a0"))
		c.draw_line(Vector2(r.position.x+10,art.end.y),Vector2(r.end.x-10,art.end.y),GOLD,1)
		c.text(names[i],Rect2(r.position.x+12,art.end.y+3,r.size.x-24,34),24,CREAM,true)
		var status: String=c.t("%d / 24 levels") % c.save.data.wins.size() if i==0 else c.t("Best wave: %d") % c.endless_record().get("wave",0) if i==1 else c.t("A new challenge every day")
		c.text(status,Rect2(r.position.x+12,art.end.y+37,r.size.x-24,24),17)
		var resume: bool=not c.save.data.battle.is_empty() if i==0 else not c.save.data.endless.is_empty() if i==1 else false
		c.action("CONTINUE DUEL" if resume and i==0 else "CONTINUE RUN" if resume else ["OPEN MAP","ENTER ARENA","PLAY CHALLENGE"][i],Rect2(r.position.x+10,r.end.y-52,r.size.x-20,42),"continue" if resume and i==0 else ids[i],-1,true)
		# The artwork and label are also useful touch targets.
		c.buttons.append({"rect":Rect2(r.position,r.size-Vector2(0,57)),"id":ids[i],"value":-1,"enabled":true})
	var bw: float=minf(230,(c.size.x-120)/3)
	for i in 3:
		c.action(["ARSENAL","UPGRADES","RECORDS"][i],Rect2(c.size.x/2-1.5*bw-14+i*(bw+14),c.size.y-53,bw,42),["arsenal","upgrades","records"][i])

static func hourglass(c, p: Vector2, fraction: float) -> void:
	fit(c,HOURGLASS,Rect2(p-Vector2(34,31),Vector2(68,62)))
	var f := clampf(fraction,0,1)
	var col := Color("7aeee0") if c.countdown>=3 else Color("ffba65")
	if f>0: O.glow(c,p,26,Color(col,.13))
	if not c.save.data.calm and not c.ended:
		for i in 3: c.draw_circle(p+Vector2(0,fposmod(c.clock*22+i*6,16)),.7,CREAM)

static func hud(c) -> void:
	var mid: float=c.size.x/2
	c.draw_texture_rect(WAVE_PANEL,Rect2(mid-112,54,224,66),false)
	var base: int=((c.endless_wave-1)/5)*5
	var title: String=c.t("WAVE %d") % c.endless_wave+"  ·  "+("BOSS" if c.endless_wave%5==0 else "BOSS %d" % (base+5))
	c.text(title,Rect2(mid-94,58,188,20),14,GOLD,true)
	for i in 5:
		var p := Vector2(mid+(i-2)*35,95)
		var current: bool=base+i+1==c.endless_wave
		if current:
			O.glow(c,p,23,Color(1,.70,.13,.6 if c.save.data.calm else .5+.2*sin(c.clock*3)))
		O.jewel(c,p,12,Color("245573"),current)
		if current:
			c.draw_arc(p,14,0,TAU,40,Color("ffe29c"),2.2,true)
			if not c.save.data.calm: O.gem(c,p+Vector2.from_angle(c.clock*1.5)*16,2)
		if i==4: fit(c,SKULL,Rect2(p-Vector2(10,10),Vector2(20,20)))
		else: c.text(str(base+i+1),Rect2(p-Vector2(10,11),Vector2(20,22)),12,CREAM,true)
		if base+i+1<c.endless_wave:
			c.draw_polyline(PackedVector2Array([p+Vector2(-5,10),p+Vector2(-1,14),p+Vector2(7,5)]),Color("80efae"),2.4,true)
	hourglass(c,Vector2(mid,143),c.countdown/c.interval())
	for i in 2:
		var x: float=82 if i==0 else c.size.x-272
		O.frame(c,Rect2(x,49,190,22))
		var label: String=c.t("SCORE")+": "+str(c.endless_score) if i==0 else c.t("PERSONAL BEST")+": "+str(c.endless_record().get("score",0))
		c.text(label,Rect2(x+14,51,162,18),12,CREAM)

static func choices(c, boss: bool) -> void:
	if not boss:
		c.draw_powers(true)
		return
	var w: float=minf(780,c.size.x-40)
	var r := Rect2((c.size.x-w)/2,12,w,c.size.y-24)
	c.panel(r)
	if boss:
		fit(c,BOSS_SR if c.save.data.ui_language=="sr" else BOSS_EN,Rect2(r.position.x+90,r.position.y-4,w-180,102))
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

static func result(c) -> void:
	var w: float=minf(680,c.size.x-50)
	var r := Rect2((c.size.x-w)/2,40,w,c.size.y-80)
	c.panel(r)
	c.text("RUN COMPLETE",Rect2(r.position.x+24,61,w-48,45),32,GOLD,true)
	c.text(c.t("Reached wave %d") % c.endless_wave,Rect2(r.position.x+24,116,w-48,32),25,CREAM,true)
	c.text(c.t("Score: %d") % c.endless_score,Rect2(r.position.x+24,156,w-48,48),36,GOLD,true)
	c.text(c.t("%d words  •  %.0f seconds") % [c.endless_words+c.word_count,c.endless_seconds+c.duration],Rect2(r.position.x+24,218,w-48,30),21)
	c.text("Try another loadout and beat your record.",Rect2(r.position.x+24,268,w-48,30),20)
	c.action("MENU",Rect2(r.position.x+25,r.end.y-70,180,48),"home")
	c.action("TRY AGAIN",Rect2(r.end.x-285,r.end.y-70,260,48),"endless_retry",-1,true)

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
	for lang in ["en","sr"]:
		for adjacent in [true,false]:
			var record: Dictionary=c.save.data.endless_records.get(c.Endless.key(lang,adjacent),{})
			var label: String=("English" if lang=="en" else "Srpski")+" · "+c.t("ADJACENT" if adjacent else "ANY LETTERS")
			c.text(label,Rect2(c.size.x/2-272,190+n*42,310,32),19)
			c.text(c.t("%d pts · wave %d") % [record.get("score",0),record.get("wave",0)],Rect2(c.size.x/2+43,190+n*42,232,32),20,GOLD)
			n+=1
	c.action("DAILY CHALLENGE",Rect2(c.size.x/2-170,c.size.y-70,340,47),"daily",-1,true)
