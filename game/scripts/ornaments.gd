extends RefCounted

const ATLAS = preload("res://assets/art/ability-atlas.png")
const GOLD := Color("ecc477")
const INK := Color("0d263b")
const TOKENS := [preload("res://assets/ui/token-gold.svg"),preload("res://assets/ui/token-blue.svg"),preload("res://assets/ui/token-violet.svg"),preload("res://assets/ui/token-mint.svg"),preload("res://assets/ui/token-navy.svg")]
const METAL := preload("res://assets/ui/metal-disc.svg")
const GEM := preload("res://assets/ui/gold-gem.svg")
const WEAVE := preload("res://assets/ui/board-weave.svg")
const FRAMES := [preload("res://assets/ui/frame-navy.svg"),preload("res://assets/ui/frame-gold.svg"),preload("res://assets/ui/frame-panel.svg"),preload("res://assets/ui/status-plaque.svg")]
const GLOW := preload("res://assets/ui/glow.svg")
const ICONS := {"arsenal":preload("res://assets/ui/icon-arsenal.svg"),"upgrades":preload("res://assets/ui/icon-gears.svg"),"upgrade":preload("res://assets/ui/icon-gears.svg"),"settings":preload("res://assets/ui/icon-settings.svg"),"journal":preload("res://assets/ui/icon-journal.svg"),"coin":preload("res://assets/ui/icon-coin.svg"),"powers":preload("res://assets/ui/icon-power.svg"),"help":preload("res://assets/ui/icon-help.svg")}
static var styles: Dictionary = {}
const PALETTE := [Color("ffd053"),Color("78bfff"),Color("b896f5"),Color("62dcb5")]

static func gradient_disc(c: CanvasItem, p: Vector2, radius: float, _top: Color, _bottom: Color) -> void:
	c.draw_texture_rect(METAL,Rect2(p-Vector2.ONE*radius,Vector2.ONE*radius*2),false)

static func jewel(c: CanvasItem, p: Vector2, radius: float, color: Color, chosen: bool = false) -> void:
	var kind := PALETTE.find(color)
	if kind < 0: kind=4
	c.draw_texture_rect(TOKENS[kind],Rect2(p-Vector2.ONE*(radius+2),Vector2.ONE*(radius+2)*2),false)
	if chosen:
		c.draw_arc(p,radius+2,0,TAU,64,Color("ffe39d"),2.5,true)

static func gem(c: CanvasItem, p: Vector2, r: float = 5) -> void:
	c.draw_texture_rect(GEM,Rect2(p-Vector2.ONE*r,Vector2.ONE*r*2),false)

static func frame(c: CanvasItem, rect: Rect2, kind: int = 0, tint: Color = Color.WHITE) -> void:
	if kind != 2:
		# Three horizontal slices scale the complete bevel vertically. Preserving
		# top/bottom pixel margins makes a short mobile plaque almost solid gold.
		var texture: Texture2D = FRAMES[kind]
		var source_cap := 36.0 if kind == 3 else 18.0
		var cap := minf(18,rect.size.x/3)
		var tw := float(texture.get_width())
		var th := float(texture.get_height())
		c.draw_texture_rect_region(texture,Rect2(rect.position,Vector2(cap,rect.size.y)),Rect2(0,0,source_cap,th),tint)
		c.draw_texture_rect_region(texture,Rect2(rect.position+Vector2(cap,0),Vector2(rect.size.x-2*cap,rect.size.y)),Rect2(source_cap,0,tw-2*source_cap,th),tint)
		c.draw_texture_rect_region(texture,Rect2(rect.end.x-cap,rect.position.y,cap,rect.size.y),Rect2(tw-source_cap,0,source_cap,th),tint)
		return
	var key := str(kind)+tint.to_html()
	if not styles.has(key):
		var style := StyleBoxTexture.new()
		style.texture = FRAMES[kind]
		style.set_texture_margin_all(30 if kind == 2 else 18)
		if kind != 2:
			style.texture_margin_top=10
			style.texture_margin_bottom=10
		style.modulate_color = tint
		styles[key] = style
	c.draw_style_box(styles[key],rect)

static func plaque(c: CanvasItem, rect: Rect2) -> void:
	frame(c,rect,3)

static func ui_icon(c: CanvasItem, id: String, rect: Rect2) -> void:
	if ICONS.has(id): c.draw_texture_rect(ICONS[id],rect,false)

static func glow(c: CanvasItem, p: Vector2, radius: float, color: Color) -> void:
	c.draw_texture_rect(GLOW,Rect2(p-Vector2.ONE*radius,Vector2.ONE*radius*2),false,color)

static func art(c: CanvasItem, kind: int, p: Vector2, radius: float, tint: Color = Color.WHITE) -> void:
	# UV sampling preserves the original atlas; only the round illustration is drawn.
	var centers := [Vector2(.126,.25),Vector2(.377,.25),Vector2(.624,.25),Vector2(.870,.25),Vector2(.126,.716),Vector2(.377,.716),Vector2(.624,.716),Vector2(.870,.716)]
	var center: Vector2 = centers[kind]
	var points := PackedVector2Array()
	var uv := PackedVector2Array()
	for n in 64:
		var v := Vector2.from_angle(TAU*n/64.0)
		points.append(p+v*radius)
		uv.append(center+v*Vector2(.103,.206))
	c.draw_polygon(points,PackedColorArray([tint]),uv,ATLAS)

static func medallion(c: CanvasItem, kind: int, p: Vector2, radius: float, color: Color, amount: int = -1, capacity: int = 1, disabled: bool = false) -> void:
	c.draw_circle(p+Vector2(0,4),radius+2,Color("071420"))
	gradient_disc(c,p,radius,Color("fff0b6"),Color("775029"))
	c.draw_circle(p,radius-2,Color("081c2d"))
	var art_radius := radius-(12 if amount>=0 else 9)
	art(c,kind,p,art_radius,Color(.48,.48,.48) if disabled else Color.WHITE)
	c.draw_arc(p,art_radius,0,TAU,64,color.darkened(.25),1.5,true)
	if amount < 0:
		c.draw_arc(p,radius-4.5,0,TAU,64,color,2,true)
	else:
		var background := PackedVector2Array()
		var charged := PackedVector2Array()
		var highlight := PackedVector2Array()
		for n in capacity:
			var a := -PI/2+TAU*n/capacity+.026
			var b := -PI/2+TAU*(n+1)/capacity-.026
			for step in 16:
				var v1 := Vector2.from_angle(lerpf(a,b,step/16.0))
				var v2 := Vector2.from_angle(lerpf(a,b,(step+1)/16.0))
				background.append_array([p+v1*(radius-5),p+v2*(radius-5)])
				if n < amount:
					charged.append_array([p+v1*(radius-5),p+v2*(radius-5)])
					highlight.append_array([p+v1*(radius-6.4),p+v2*(radius-6.4)])
		c.draw_multiline(background,Color("354453"),7,true)
		if not charged.is_empty():
			c.draw_multiline(charged,color,7,true)
			c.draw_multiline(highlight,color.lightened(.55),1.2,true)
		if amount >= capacity:
			c.draw_arc(p,radius+2,0,TAU,64,Color(color,.45),2,true)
	gem(c,p-Vector2(0,radius-4),2.5)
