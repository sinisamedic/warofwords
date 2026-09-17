extends RefCounted

const Art = preload("res://scripts/ornaments.gd")
var shots: Array[Dictionary] = []
var bursts: Array[Dictionary] = []
var shake := 0.0
const FLIGHT_TIME := .42

func clear() -> void:
	shots.clear(); bursts.clear(); shake=0

func launch(player: bool, kind: String, color: Color, blocked: bool = false) -> void:
	if shots.size() >= 8: shots.pop_front()
	shots.append({"player":player,"kind":kind,"color":color,"blocked":blocked,"time":0.0})
	burst("muzzle",Vector2(.245 if player else .765,115),color,.32)
	shake = maxf(shake,.10 if kind == "word" else .18)

func burst(kind: String, at: Vector2, color: Color, lifetime: float = .7) -> void:
	if bursts.size() >= 16: bursts.pop_front()
	bursts.append({"kind":kind,"at":at,"color":color,"time":0.0,"life":lifetime})

func advance(delta: float) -> Array[Dictionary]:
	var impacts: Array[Dictionary] = []
	shake = maxf(0,shake-delta)
	for b in bursts: b.time += delta
	bursts = bursts.filter(func(b): return b.time < b.life)
	for shot in shots:
		shot.time += delta
		if shot.time >= FLIGHT_TIME:
			impacts.append(shot)
			burst("shield" if shot.blocked else "impact",Vector2(.79 if shot.player else .21,116),shot.color if not shot.blocked else Color("78bfff"),.75)
			bursts.back().time = shot.time-FLIGHT_TIME
			shake = maxf(shake,.13 if shot.kind == "word" else .3)
	shots = shots.filter(func(shot): return shot.time < FLIGHT_TIME)
	return impacts

func draw(c: CanvasItem, width: float, calm: bool) -> void:
	for shot in shots:
		var u: float = clampf(shot.time/FLIGHT_TIME,0,1)
		var from := Vector2(width*(.245 if shot.player else .765),115)
		var to := Vector2(width*(.79 if shot.player else .21),116)
		var p := from.lerp(to,u)+Vector2(0,-sin(u*PI)*12)
		var direction := (to-from).normalized()
		var length := 30.0 if calm else 75.0
		var tail := p-direction*minf(length,from.distance_to(p))
		c.draw_line(tail,p,Color(shot.color,.15),20,true)
		c.draw_line(tail,p,Color(shot.color,.55),8,true)
		c.draw_line(tail.lerp(p,.25),p,Color("fff7d0"),2.5,true)
		Art.glow(c,p,24 if calm else 38,Color(shot.color,.9))
		c.draw_circle(p,5,Color("fffdea"))
		if shot.kind == "arc" and not calm:
			var points := PackedVector2Array()
			for n in 9: points.append(tail.lerp(p,n/8.0)+Vector2(0,sin(n*13+u*30)*7))
			c.draw_polyline(points,Color("eee0ff"),1.5,true)
	for b in bursts:
		var p := Vector2(b.at.x*width,b.at.y)
		var u: float = b.time/b.life
		var alpha: float = pow(1-u,1.5)
		var color := Color(b.color,alpha)
		var radius: float = (22+u*49)*(0.65 if calm else 1.0)
		if b.kind == "muzzle":
			Art.glow(c,p,18+u*25,Color(b.color,alpha*.9))
			c.draw_arc(p,8+u*22,0,TAU,24,color,2,true)
		elif b.kind in ["shield","heal","freeze"]:
			Art.glow(c,p,55,Color(b.color,alpha*.24))
			c.draw_arc(p,radius,0,TAU,48,color,3,true)
			c.draw_arc(p,radius*.8,-PI*.6,PI*.6,32,Color("e7ffff",alpha),1.5,true)
		else:
			Art.glow(c,p,radius*1.7,Color(b.color,alpha*.65))
			Art.glow(c,p,maxf(1,28*(1-u)),Color("fff8cf",alpha))
			c.draw_arc(p,radius,0,TAU,48,color,2.5,true)
		if not calm:
			var lines := PackedVector2Array()
			for n in 14:
				var angle := n*2.39996
				var ray := Vector2.from_angle(angle)
				var far := p+ray*(10+u*(35+(n%4)*10))+Vector2(0,u*u*24)
				lines.append_array([far-ray*(3+(1-u)*9),far])
			c.draw_multiline(lines,color,1.5,true)
		if b.kind in ["impact","muzzle"]:
			Art.glow(c,p,32*(1-u),Color("fff6d4",alpha))
			c.draw_circle(p,maxf(1,6*(1-u)),Color("fffef1",alpha))
