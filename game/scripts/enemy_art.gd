extends RefCounted

const ATLAS = preload("res://assets/art/enemies.png")
const CELL := Vector2(362,362)
# The generated rows have unequal gutters. Explicit regions preserve crowns and weapons.
const ROWS := [Vector2(0,342),Vector2(342,353),Vector2(695,391)]
# Bottom of the opaque boot pixels within each region, excluding transparent padding.
const FEET := [324.0,322.0,323.0,320.0,338.0,335.0,335.0,337.0,341.0,341.0,340.0,340.0]
# Portrait focus points measured in each cell; faces differ with stance and silhouette.
const FACES := [Vector2(.48,.23),Vector2(.43,.22),Vector2(.50,.21),Vector2(.51,.22),Vector2(.48,.22),Vector2(.47,.22),Vector2(.48,.19),Vector2(.50,.21),Vector2(.50,.14),Vector2(.45,.14),Vector2(.48,.13),Vector2(.52,.16)]

static func apply(actor: Sprite2D, portrait: Sprite2D, encounter: int) -> void:
	actor.texture=ATLAS
	actor.material=null
	actor.hframes=1; actor.vframes=1; actor.frame=0
	actor.region_enabled=true
	var row: Vector2=ROWS[encounter/4]
	actor.region_rect=Rect2(encounter%4*CELL.x,row.x,CELL.x,row.y)
	actor.flip_h=encounter == 6
	actor.set_meta("encounter",encounter)
	var origin := Vector2(encounter%4,encounter/4)*CELL
	var region := Rect2(origin+FACES[encounter]*CELL-Vector2(53,53),Vector2(106,106))
	portrait.setup_region(ATLAS,region,false)
	portrait.flip_h=actor.flip_h

static func foot_offset(encounter: int) -> float:
	return FEET[encounter]-ROWS[encounter/4].y/2.0

static func draw_preview(canvas: CanvasItem, encounter: int, feet: Vector2, height: float) -> void:
	var row: Vector2=ROWS[encounter/4]
	var scale := height/CELL.y
	var region := Rect2(encounter%4*CELL.x,row.x,CELL.x,row.y)
	canvas.draw_set_transform(feet,0,Vector2(-scale if encounter==6 else scale,scale))
	canvas.draw_texture_rect_region(ATLAS,Rect2(-CELL.x/2,-FEET[encounter],CELL.x,row.y),region)
	canvas.draw_set_transform(Vector2.ZERO)
