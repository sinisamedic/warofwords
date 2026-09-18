extends RefCounted
const E = preload("res://scripts/equipment.gd")
const Art = preload("res://scripts/ornaments.gd")
var textures: Dictionary = {}

func icon(c: CanvasItem, id: String, p: Vector2, radius: float, color: Color, amount: int = -1, capacity: int = 1) -> void:
	var old := E.DEFAULTS.find(id)
	if id!="breach" or amount>=0:
		Art.medallion(c,maxi(0,old),p,radius,color,amount,capacity)
	if old>=0: return
	if not textures.has(id):
		var path := "res://assets/art/equipment-"+id+".png"
		if ResourceLoader.exists(path): textures[id]=load(path)
	if not textures.has(id): return
	if id=="breach":
		# Preserve the original alpha silhouette, including the lance beyond its rim.
		# Battle keeps an outer live charge ring around the complete illustration.
		var art_radius := radius-(12 if amount>=0 else 0)
		c.draw_texture_rect(textures[id],Rect2(p-Vector2.ONE*art_radius,Vector2.ONE*art_radius*2),false)
		return
	var points := PackedVector2Array()
	var uv := PackedVector2Array()
	var r := radius-(12 if amount>=0 else 7)
	for n in 64:
		var v := Vector2.from_angle(TAU*n/64.0)
		points.append(p+v*r)
		uv.append(Vector2(.5,.5)+v*.43)
	c.draw_polygon(points,PackedColorArray([Color.WHITE]),uv,textures[id])

func campaign_reward(c: Control, id: String, center: Vector2) -> void:
	var owned := E.unlocked(id,c.save.data)
	Art.glow(c,center,82,Color(c.GOLD,.24))
	icon(c,id,center,62,c.GOLD)
	if owned: Art.earned_badge(c,center+Vector2(39,40),24)
	Art.jewel(c,center+Vector2(-43,39),13,c.INK)
	c.text("i",Rect2(center+Vector2(-53,26),Vector2(20,26)),18,c.GOLD,true)

func reward_marker(c: CanvasItem, p: Vector2, owned: bool) -> void:
	Art.jewel(c,p,14,Color("23574d") if owned else Color("744b21"))
	# A small gift chest keeps the level number and its stars unobstructed.
	c.draw_rect(Rect2(p-Vector2(7,5),Vector2(14,11)),Color("f3c569"))
	c.draw_line(p+Vector2(-8,-6),p+Vector2(8,-6),Color("fff1ce"),3,true)
	c.draw_line(p+Vector2(0,-7),p+Vector2(0,7),Color("875321"),3,true)
	if owned: Art.earned_badge(c,p+Vector2(10,10),7)

func draw_reward_info(c: Control, id: String) -> void:
	if not E.DATA.has(id): return
	var sr: bool=c.save.data.ui_language=="sr"
	var slot := E.slot_of(id)
	var color: Color=c.COLORS[mini(slot,3)] if slot<4 else c.GOLD
	var width := minf(750,c.size.x-48)
	var r := Rect2((c.size.x-width)/2,35,width,410)
	var x := r.position.x
	var y := r.position.y
	c.panel(r,c.INK,c.GOLD); c.draw_texture_rect(Art.FILIGREE,r,false)
	c.text("NAGRADA NIVOA %d" % (c.mission+1) if sr else "LEVEL %d REWARD" % (c.mission+1),Rect2(x+30,y+16,width-60,32),23,c.GOLD,true)
	var p := Vector2(x+112,y+154)
	Art.glow(c,p,108,Color(color,.30)); icon(c,id,p,76,color)
	if E.unlocked(id,c.save.data): Art.earned_badge(c,p+Vector2(48,49),22)
	else: Art.padlock(c,p+Vector2(48,49))
	c.text(E.DATA[id].name,Rect2(x+219,y+65,width-250,38),28,color,true,HORIZONTAL_ALIGNMENT_LEFT)
	var desc: Array=E.DATA[id].sr if sr else E.DATA[id].desc
	for i in 2: c.text(desc[i],Rect2(x+219,y+114+i*29,width-250,28),21,c.CREAM,false,HORIZONTAL_ALIGNMENT_LEFT,false)
	c.text("KAKO SE KORISTI" if sr else "HOW TO USE",Rect2(x+32,y+231,width-64,27),21,c.GOLD,true)
	var usage: Array
	if slot==4:
		usage=["Izaberi artefakt u Arsenalu pre borbe.","Deluje automatski; ne troši energiju."] if sr else ["Equip the artifact in the Arsenal before battle.","Its effect is automatic; no energy is needed."]
	else:
		var colors := ["zlatna","plava","ljubičasta","zelena"] if sr else ["gold","blue","purple","green"]
		usage=["Opremi u Arsenalu. Spajaj slova: %s boja puni uređaj." % colors[slot],"Kada skupiš %d energije, dodirni njegov medaljon u borbi." % E.DATA[id].cost] if sr else ["Equip in the Arsenal. Link %s letters to charge it." % colors[slot],"At %d energy, tap its medallion during battle." % E.DATA[id].cost]
	for i in 2: c.text(usage[i],Rect2(x+32,y+265+i*28,width-64,27),19,c.CREAM)
	c.action("ZATVORI" if sr else "CLOSE",Rect2(r.get_center().x-110,r.end.y-65,220,47),"reward_close",-1,true)

func draw_unlock(c: Control) -> void:
	var pending: Array=c.save.data.get("pending_unlocks",[])
	if pending.is_empty(): return
	var id: String=pending[0]
	var tint: Color=c.COLORS[mini(3,maxi(0,E.slot_of(id)))] if E.slot_of(id)<4 else c.GOLD
	var width := minf(720,c.size.x-48)
	var r := Rect2((c.size.x-width)/2,(c.size.y-416)/2,width,416)
	var x := r.position.x
	var y := r.position.y
	var middle := r.get_center().x
	c.panel(r,c.INK,c.GOLD)
	c.draw_texture_rect(Art.FILIGREE,r,false)
	Art.glow(c,Vector2(middle,y+51),200,Color(c.GOLD,.14))
	Art.gem(c,Vector2(middle,y),7)
	c.text("CONGRATULATIONS!",Rect2(x+35,y+18,width-70,42),31,c.GOLD,true)
	c.text("You have unlocked",Rect2(x+35,y+65,width-70,29),22,c.CREAM)
	c.draw_line(Vector2(x+40,y+108),Vector2(r.end.x-40,y+108),Color(c.GOLD,.32),1.5,true)
	var p := Vector2(x+145,y+216)
	var time: float=0 if c.save.data.calm else c.clock
	Art.glow(c,p,132,Color(tint,.31+.05*sin(time*2)))
	for n in 12:
		var angle: float=TAU*n/12.0+time*.08
		var v := Vector2.from_angle(angle)
		c.draw_line(p+v*98,p+v*(113+5*sin(n*1.7)),Color(tint,.28),2,true)
		if n%3==0: Art.gem(c,p+v*119,2.5)
	icon(c,id,p,88,tint)
	Art.plaque(c,Rect2(x+58,y+322,174,29))
	c.text("NEW EQUIPMENT",Rect2(x+65,y+322,160,27),16,tint,true)
	var tx := x+280
	var tw := width-310
	c.text(E.DATA[id].name,Rect2(tx,y+142,tw,44),29,tint,true,HORIZONTAL_ALIGNMENT_LEFT)
	var desc: Array=E.DATA[id].sr if c.save.data.ui_language=="sr" else E.DATA[id].desc
	for n in 2:
		c.text(desc[n],Rect2(tx,y+202+n*31,tw,29),22,c.CREAM,false,HORIZONTAL_ALIGNMENT_LEFT,false)
	c.text("Choose it in the Arsenal before your next duel.",Rect2(tx,y+280,tw,28),18,c.CREAM,false,HORIZONTAL_ALIGNMENT_LEFT)
	if pending.size()>1:
		c.text(c.t("%d more to reveal") % (pending.size()-1),Rect2(tx,y+314,tw,26),17,c.GOLD,false,HORIZONTAL_ALIGNMENT_LEFT,false)
	c.action("CONTINUE",Rect2(middle-116,r.end.y-62,232,47),"unlock_continue",-1,true)

func draw(c: Control) -> void:
	c.header("ARSENAL")
	var tw: float=(c.size.x-48)/5
	for i in 5:
		var rect := Rect2(24+i*tw,82,tw-8,49)
		c.action(["STRIKE","GUARD","CONTROL","RESTORE","ARTIFACTS"][i],rect,"gear_slot",i,i==c.arsenal_slot)
	var color: Color=c.COLORS[mini(c.arsenal_slot,3)] if c.arsenal_slot<4 else c.GOLD
	var card_width: float=(c.size.x*.48-34)/2
	var items: Array=E.SLOTS[c.arsenal_slot]
	var equipped: String=c.save.data.get("artifact","none") if c.arsenal_slot==4 else E.loadout(c.save.data)[c.arsenal_slot]
	var compact := items.size()>2
	for i in items.size():
		var id: String=items[i]
		var rect := Rect2(24+(i%2)*(card_width+10),145+(i/2)*124,card_width,117 if compact else 241)
		c.panel(rect,c.INK,c.GOLD if equipped==id else Color("9cb4c4") if c.arsenal_choice==i else Color("648399"))
		if c.arsenal_choice==i: Art.glow(c,rect.get_center()-Vector2(0,30),card_width*.65,Color(color,.18))
		var center := Vector2(rect.get_center().x,rect.position.y+36 if compact else 226)
		var radius := 32.0 if compact else minf(65,card_width*.39)
		if equipped==id:
			# Reuse the exact animated halo from the selected pre-battle power-up.
			c.draw_set_transform(center,0,Vector2.ONE*(radius/43.0))
			Art.selection_aura(c,Vector2.ZERO,c.clock,c.save.data.calm)
			c.draw_set_transform(Vector2.ZERO)
		icon(c,id,Vector2(rect.get_center().x,rect.position.y+36 if compact else 226),32 if compact else minf(65,card_width*.39),color)
		if equipped!=id: c.draw_rect(rect.grow(-7),Color(.01,.035,.07,.30 if E.unlocked(id,c.save.data) else .48))
		else: Art.earned_badge(c,center+Vector2(radius*.78,radius*.65),11 if compact else 18)
		if c.arsenal_slot==4:
			var title: PackedStringArray=c.t(E.DATA[id].name).split(" ",false,1)
			for n in title.size(): c.text(title[n],Rect2(rect.position.x+10,290+n*26,card_width-20,28),21,c.CREAM,true)
		else: c.text(E.DATA[id].name,Rect2(rect.position.x+10,rect.position.y+67 if compact else 302,card_width-20,24 if compact else 32),18 if compact else 22,c.CREAM,true)
		if not E.unlocked(id,c.save.data):
			Art.padlock(c,Vector2(rect.position.x+19 if compact else rect.get_center().x,rect.position.y+96 if compact else 355))
		else: c.text("EQUIPPED" if equipped==id else "AVAILABLE",Rect2(rect.position.x+10,rect.position.y+90 if compact else 344,card_width-20,22 if compact else 30),14 if compact else 18,c.GOLD if equipped==id else color)
		c.buttons.append({"rect":rect,"id":"gear_view","value":i,"enabled":true})
	var id: String=items[c.arsenal_choice]
	var x: float=c.size.x*.51
	var width: float=c.size.x-x-24
	c.panel(Rect2(x,145,width,241))
	c.text(E.DATA[id].name,Rect2(x+14,155,width-28,36),27,color,true)
	var desc: Array=E.DATA[id].sr if c.save.data.ui_language=="sr" else E.DATA[id].desc
	for n in 2: c.text(desc[n],Rect2(x+16,203+n*29,width-32,27),20,c.CREAM,false,HORIZONTAL_ALIGNMENT_CENTER,false)
	var ready: bool=E.unlocked(id,c.save.data)
	if ready:
		var stats: String=c.t("PASSIVE • NO ENERGY")
		if c.arsenal_slot<4:
			var value: int=E.amount(id,int(c.save.data.levels[c.arsenal_slot]))
			var stat: String=c.t("TOTAL DAMAGE" if id=="ember" else "DAMAGE" if id=="siphon" else ["DAMAGE","PROTECTION","DAMAGE","HEALING"][c.arsenal_slot])
			stats=c.t("%d ENERGY • %s %d") % [E.DATA[id].cost,stat,value]
			if id=="resonator": stats=c.t("%d ENERGY • DAMAGE %d–%d") % [E.DATA[id].cost,value,value+30]
		c.text(stats,Rect2(x+16,273,width-32,30),20,color)
		c.action("EQUIPPED" if equipped==id else "EQUIP",Rect2(x+28,323,width-56,49),"gear_equip",-1,equipped!=id,equipped!=id)
	else:
		var condition: String=c.t("Win with a word of 7+ tiles") if id=="lexicon" else c.t("Win encounter %d to unlock") % (E.DATA[id].win+1)
		c.text(condition,Rect2(x+16,277,width-32,33),21,color)
		c.action("LOCKED",Rect2(x+28,323,width-56,49),"gear_equip",-1,false,false)
	Art.plaque(c,Rect2(c.size.x/2-227,388,454,28))
	c.text("New selections apply to your next duel",Rect2(c.size.x/2-215,389,430,25),18,c.CREAM)
	c.action("POWER-UPS",Rect2(24,c.size.y-63,190,48),"powers")
	if c.arsenal_slot==4:
		c.action("REMOVE ARTIFACT",Rect2(c.size.x/2-140,c.size.y-63,280,48),"artifact_clear",-1,false,equipped!="none")
	else:
		c.text(c.t("LEVEL %d • SHARED BY COLOR") % int(c.save.data.levels[c.arsenal_slot]),Rect2(224,c.size.y-63,c.size.x-448,48),19,color)
	c.action("UPGRADES",Rect2(c.size.x-214,c.size.y-63,190,48),"gear_upgrade",-1,true,c.arsenal_slot<4)

func battle_status(c: Control) -> void:
	if c.ended: return
	if c.bastion_hits>0:
		Art.plaque(c,Rect2(c.size.x*.31-47,101,94,26))
		c.text(c.t("SHIELD ×%d") % c.bastion_hits,Rect2(c.size.x*.31-42,102,84,23),15,c.COLORS[1])
	if c.burn_ticks>0:
		var p := Vector2(c.size.x*.66,107)
		icon(c,"ember",p,21,c.COLORS[0])
		Art.plaque(c,Rect2(p.x-40,p.y+22,80,25))
		c.text("−%d ×%d" % [c.burn_amount,c.burn_ticks],Rect2(p.x-35,p.y+22,70,25),17,c.GOLD)
	if c.shield>0 and c.shield_kind=="mirror":
		var p := Vector2(c.size.x*.20,119)
		var points := PackedVector2Array()
		for n in 7: points.append(p+Vector2.from_angle(n*TAU/6)*Vector2(45,56))
		c.draw_polyline(points,Color(.73,.93,1,.85),2,true)
		for n in 3: c.draw_line(points[n],points[n+3],Color(.65,.85,1,.18),1,true)
	if c.battle_artifact!="none":
		icon(c,c.battle_artifact,Vector2(c.size.x/2,128),24,c.GOLD)
	if c.seal_time>0:
		var p := Vector2(c.size.x*.92,107)
		icon(c,"seal",p,21,c.COLORS[2])
		Art.plaque(c,Rect2(p.x-28,p.y+22,56,25))
		c.text("%ds" % ceili(c.seal_time),Rect2(p.x-23,p.y+22,46,25),18,c.CREAM)
	if c.bloom_ticks>0:
		var p := Vector2(c.size.x*.08,107)
		icon(c,"bloom",p,21,c.COLORS[3])
		Art.plaque(c,Rect2(p.x-41,p.y+22,82,25))
		c.text("+%d ×%d" % [c.bloom_amount,c.bloom_ticks],Rect2(p.x-36,p.y+22,72,25),18,c.CREAM)
