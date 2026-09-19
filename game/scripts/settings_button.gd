extends Button
const FIELD=preload("res://assets/ui/settings/field.svg")
const SELECTED=preload("res://assets/ui/settings/selected.svg")
const SAVE=preload("res://assets/ui/settings/save.svg")
const TRACK_OFF=preload("res://assets/ui/settings/switch-off.svg")
const TRACK_ON=preload("res://assets/ui/settings/switch-on.svg")
const KNOB=preload("res://assets/ui/settings/knob.svg")
var kind:=0 # choice, save, switch, close, dropdown
var selected:=false
var expanded:=false
var calm:=false
var progress:=0.0
var face: Font
var pixels:=17
func _ready() -> void:
	clip_text=true; mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	for state in ["normal","hover","pressed","focus"]: add_theme_stylebox_override(state,StyleBoxEmpty.new())
	for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]: add_theme_color_override(state,Color.TRANSPARENT)
	progress=1.0 if selected else 0.0
func _process(delta: float) -> void:
	var target:=1.0 if selected else 0.0
	if kind==2 and progress!=target:
		progress=move_toward(progress,target,delta*6 if not calm else 1); queue_redraw()
func framed(texture: Texture2D) -> void:
	# SVGs are rasterized at 3x; keep six logical pixel corners at any width.
	var source:=Vector2(texture.get_size())
	var sx: Array=[0.0,18.0,source.x-18,source.x]; var sy: Array=[0.0,18.0,source.y-18,source.y]
	var dx: Array=[0.0,6.0,size.x-6,size.x]; var dy: Array=[0.0,6.0,size.y-6,size.y]
	for row in 3:
		for col in 3:
			draw_texture_rect_region(texture,Rect2(dx[col],dy[row],dx[col+1]-dx[col],dy[row+1]-dy[row]),Rect2(sx[col],sy[row],sx[col+1]-sx[col],sy[row+1]-sy[row]))
func _draw() -> void:
	if kind==2:
		var r:=Rect2(Vector2.ZERO,size)
		draw_texture_rect(TRACK_OFF,r,false)
		draw_texture_rect(TRACK_ON,r,false,Color(1,1,1,progress))
		var d:=size.y-2
		draw_texture_rect(KNOB,Rect2(2+(size.x-d-4)*progress,1,d,d),false)
		return
	if kind==3:
		draw_circle(size/2,size.x/2-2,Color("071b2b")); draw_arc(size/2,size.x/2-3,0,TAU,64,Color("e6bb6e"),1.5,true)
		var p:=size/2; draw_line(p-Vector2(6,6),p+Vector2(6,6),Color("f6d597"),2.3,true); draw_line(p+Vector2(-6,6),p+Vector2(6,-6),Color("f6d597"),2.3,true)
		return
	if kind==1: draw_texture_rect(SAVE,Rect2(Vector2.ZERO,size),false)
	else: framed(SELECTED if selected else FIELD)
	var tint:=Color("f9eac9") if kind!=1 else Color("1b1a12")
	var available:=size.x-(40 if selected or kind==4 else 20)
	var font_size:=pixels
	while face.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x>available and font_size>11: font_size-=1
	var tw:=face.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x
	var x:=12.0 if kind==4 else (size.x-tw-(14 if selected else 0))/2
	draw_string(face,Vector2(x,(size.y-face.get_height(font_size))/2+face.get_ascent(font_size)),text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size,tint)
	if selected:
		var p:=Vector2(size.x-20,size.y/2)
		draw_polyline(PackedVector2Array([p+Vector2(-5,0),p+Vector2(-1,4),p+Vector2(7,-6)]),Color("ffe0a0"),2.2,true)
	if kind==4:
		var p:=Vector2(size.x-18,size.y/2); var direction: float=-1 if expanded else 1
		draw_polyline(PackedVector2Array([p+Vector2(-6,-3*direction),p+Vector2(0,3*direction),p+Vector2(6,-3*direction)]),Color("f7d28c"),2.2,true)
	if has_focus(): draw_rect(Rect2(Vector2(2,2),size-Vector2(4,4)),Color(1,.85,.55,.45),false,1)
