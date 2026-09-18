extends RefCounted

const ATLAS = preload("res://assets/art/enemies.png")
const WAVE_TWO = preload("res://assets/art/enemies-wave-two.png")
const CELL := Vector2(362,362)
# The generated rows have unequal gutters. Explicit regions preserve crowns and weapons.
const ROWS := [Vector2(0,342),Vector2(342,353),Vector2(695,391)]
# Bottom of the opaque boot pixels within each region, excluding transparent padding.
const FEET := [324.0,322.0,323.0,320.0,338.0,335.0,335.0,337.0,341.0,341.0,340.0,340.0]
# Portrait focus points measured in each cell; faces differ with stance and silhouette.
const FACES := [Vector2(.48,.23),Vector2(.43,.22),Vector2(.50,.21),Vector2(.51,.22),Vector2(.48,.22),Vector2(.47,.22),Vector2(.48,.19),Vector2(.50,.21),Vector2(.50,.14),Vector2(.45,.14),Vector2(.48,.13),Vector2(.52,.16)]

static func apply(actor: Sprite2D, portrait: Sprite2D, encounter: int) -> void:
	if encounter>=12:
		apply_wave_two(actor,portrait,encounter)
		return
	actor.texture=ATLAS
	var material := ShaderMaterial.new()
	material.shader=preload("res://assets/ui/enemy-defeat.gdshader")
	actor.material=material
	actor.hframes=1; actor.vframes=1; actor.frame=0
	actor.region_enabled=true
	var row: Vector2=ROWS[encounter/4]
	actor.region_rect=Rect2(encounter%4*CELL.x,row.x,CELL.x,row.y)
	material.set_shader_parameter("region_uv",Vector4(actor.region_rect.position.x/ATLAS.get_width(),actor.region_rect.position.y/ATLAS.get_height(),CELL.x/ATLAS.get_width(),row.y/ATLAS.get_height()))
	actor.flip_h=encounter == 6
	actor.set_meta("encounter",encounter)
	var origin := Vector2(encounter%4,encounter/4)*CELL
	var region := Rect2(origin+FACES[encounter]*CELL-Vector2(53,53),Vector2(106,106))
	portrait.setup_region(ATLAS,region,false)
	portrait.flip_h=actor.flip_h

static func foot_offset(encounter: int) -> float:
	if encounter>=12:
		var region := wave_region(encounter)
		return wave_feet(encounter)-region.size.y/2
	return FEET[encounter]-ROWS[encounter/4].y/2.0

static func draw_preview(canvas: CanvasItem, encounter: int, feet: Vector2, height: float) -> void:
	if encounter>=12:
		var region := wave_region(encounter)
		var factor := height/cell_height(encounter)
		canvas.draw_set_transform(feet,0,Vector2.ONE*factor)
		canvas.draw_texture_rect_region(WAVE_TWO,Rect2(-region.size.x/2,-wave_feet(encounter),region.size.x,region.size.y),region)
		canvas.draw_set_transform(Vector2.ZERO)
		return
	var row: Vector2=ROWS[encounter/4]
	var scale := height/CELL.y
	var region := Rect2(encounter%4*CELL.x,row.x,CELL.x,row.y)
	canvas.draw_set_transform(feet,0,Vector2(-scale if encounter==6 else scale,scale))
	canvas.draw_texture_rect_region(ATLAS,Rect2(-CELL.x/2,-FEET[encounter],CELL.x,row.y),region)
	canvas.draw_set_transform(Vector2.ZERO)

static func cell_height(encounter: int) -> float:
	return float(WAVE_TWO.get_height())/3 if encounter>=12 else CELL.y

static func wave_region(encounter: int) -> Rect2:
	var i := encounter-12
	# Explicit gutters preserve the tyrant's hammer and the wider tree silhouette.
	var columns := [Vector2(0,390),Vector2(390,314),Vector2(704,314),Vector2(1018,430)]
	var rows := [Vector2(0,356),Vector2(356,358),Vector2(714,372)]
	var col: Vector2=columns[i%4]
	# The pearl armor extends farther right than the figures above it.
	if i==10: col=Vector2(704,336)
	if i==11: col=Vector2(1040,408)
	var row: Vector2=rows[i/4]
	return Rect2(col.x,row.x,col.y,row.y)

static func wave_feet(encounter: int) -> float:
	return wave_region(encounter).size.y-5

static func apply_wave_two(actor: Sprite2D, portrait: Sprite2D, encounter: int) -> void:
	actor.texture=WAVE_TWO
	actor.hframes=1; actor.vframes=1; actor.frame=0
	actor.region_enabled=true; actor.region_rect=wave_region(encounter)
	actor.flip_h=false; actor.set_meta("encounter",encounter)
	var material := ShaderMaterial.new()
	material.shader=preload("res://assets/ui/enemy-defeat.gdshader")
	var origin := actor.region_rect.position/Vector2(WAVE_TWO.get_size())
	var extent := actor.region_rect.size/Vector2(WAVE_TWO.get_size())
	material.set_shader_parameter("region_uv",Vector4(origin.x,origin.y,extent.x,extent.y))
	actor.material=material
	var focus: Vector2 = [Vector2(.50,.22),Vector2(.49,.22),Vector2(.43,.24),Vector2(.55,.20),Vector2(.51,.23),Vector2(.52,.26),Vector2(.48,.29),Vector2(.54,.29),Vector2(.45,.23),Vector2(.57,.28),Vector2(.53,.28),Vector2(.56,.28)][encounter-12]
	var face_size := actor.region_rect.size.x*.29
	portrait.setup_region(WAVE_TWO,Rect2(actor.region_rect.position+focus*actor.region_rect.size-Vector2.ONE*face_size/2,Vector2.ONE*face_size),false)
	portrait.flip_h=false
