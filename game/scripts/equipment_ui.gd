extends RefCounted
const E = preload("res://scripts/equipment.gd")
const Art = preload("res://scripts/ornaments.gd")
var textures: Dictionary = {}

func icon(c: CanvasItem, id: String, p: Vector2, radius: float, color: Color, amount: int = -1, capacity: int = 1) -> void:
	var old := E.DEFAULTS.find(id)
	Art.medallion(c,maxi(0,old),p,radius,color,amount,capacity)
	if id=="breach": c.draw_breach_icon(p,radius); return
	if old>=0: return
	if not textures.has(id):
		var path := "res://assets/art/equipment-"+id+".png"
		if ResourceLoader.exists(path): textures[id]=load(path)
	if not textures.has(id): return
	var points := PackedVector2Array()
	var uv := PackedVector2Array()
	var r := radius-(12 if amount>=0 else 7)
	for n in 64:
		var v := Vector2.from_angle(TAU*n/64.0)
		points.append(p+v*r)
		uv.append(Vector2(.5,.5)+v*.43)
	c.draw_polygon(points,PackedColorArray([Color.WHITE]),uv,textures[id])

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
	for i in 2:
		var id: String=items[i]
		var rect := Rect2(24+i*(card_width+10),145,card_width,241)
		c.panel(rect,c.INK,color if c.arsenal_choice==i else Color("648399"))
		if c.arsenal_choice==i: Art.glow(c,rect.get_center()-Vector2(0,30),card_width*.65,Color(color,.18))
		icon(c,id,Vector2(rect.get_center().x,226),minf(65,card_width*.39),color)
		if c.arsenal_slot==4:
			var title: PackedStringArray=c.t(E.DATA[id].name).split(" ",false,1)
			for n in title.size(): c.text(title[n],Rect2(rect.position.x+10,290+n*26,card_width-20,28),21,c.CREAM,true)
		else: c.text(E.DATA[id].name,Rect2(rect.position.x+10,302,card_width-20,32),22,c.CREAM,true)
		if not E.unlocked(id,c.save.data):
			Art.padlock(c,Vector2(rect.get_center().x,355))
		else: c.text("EQUIPPED" if equipped==id else "AVAILABLE",Rect2(rect.position.x+10,344,card_width-20,30),18,color)
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
			var stat: String=c.t(["DAMAGE","PROTECTION","DAMAGE","HEALING"][c.arsenal_slot])
			stats=c.t("%d ENERGY • %s %d") % [E.DATA[id].cost,stat,value]
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
