extends Control
## Real independently posed cutouts, clipped to the campaign illustration window.
const Actor = preload("res://scripts/actor.gd")
const SKY = preload("res://assets/art/endless/sky-court.png")
var actors: Array[Sprite2D]=[]
var phase := 0.0
var calm := false
func _ready() -> void:
	clip_contents=true; mouse_filter=Control.MOUSE_FILTER_IGNORE
	for enemy in [false,true]:
		var actor=Actor.new()
		actor.setup(preload("res://assets/art/fighters.png"),enemy)
		add_child(actor); actors.append(actor)
func pose(time: float, reduced: bool) -> void:
	phase=time; calm=reduced
	for i in actors.size():
		var a := actors[i]
		var breath := 0.0 if calm else sin(time*1.8+i*1.7)
		var h := size.y*(.97 if i==0 else 1.08)
		var s := h/a.texture.get_height()
		a.scale=Vector2(s,s*(1+breath*.027))
		a.position=Vector2(size.x*(.26 if i==0 else .76),size.y-h*.5+5-breath*2)
		a.rotation=0.0 if calm else sin(time*1.1+i)*.023
	queue_redraw()
func _draw() -> void:
	var source := Vector2(SKY.get_size())
	var factor := maxf(size.x/source.x,size.y/source.y)
	var crop := size/factor
	draw_texture_rect_region(SKY,Rect2(Vector2.ZERO,size),Rect2((source-crop)/2,crop))
