extends Control
const O=preload("res://scripts/ornaments.gd")
var host
var rows: Array=[]
var daily := false
var separate_current := false
const ROW_HEIGHT := 40
const DIVIDER_HEIGHT := 20
func _ready() -> void:
	# Painted rows have no actions; gestures belong to the ScrollContainer.
	mouse_filter=Control.MOUSE_FILTER_IGNORE
func has_divider() -> bool:
	return separate_current and rows.size()>10
func row_y(index: int) -> int:
	return index*ROW_HEIGHT+(DIVIDER_HEIGHT if has_divider() and index>=10 else 0)
func set_rows(value: Array) -> void:
	rows=value
	custom_minimum_size.y=rows.size()*ROW_HEIGHT+(DIVIDER_HEIGHT if has_divider() else 0)
	queue_redraw()
func _draw() -> void:
	if has_divider():
		var y := 10*ROW_HEIGHT+DIVIDER_HEIGHT/2
		draw_line(Vector2(8,y),Vector2(size.x-8,y),Color("cba85c"),1,true)
	for i in rows.size():
		var row: Dictionary=rows[i]
		var r := Rect2(0,row_y(i),size.x,36)
		var own: bool=row.get("own",false)
		if row.get("current",false):
			draw_rect(r.grow(1),Color("f3c569"))
		var bg := StyleBoxFlat.new(); bg.bg_color=Color("24475c") if own else Color("102c3d") if i%2==0 else Color("0c2232"); bg.set_corner_radius_all(5)
		bg.set_border_width_all(1); bg.border_color=Color("cba85c") if own else Color("34505b"); draw_style_box(bg,r)
		var rank_value := int(row.get("position",i+1))
		if rank_value<=3: O.jewel(self,Vector2(21,r.get_center().y),11,Color("ffd053") if rank_value==1 else Color("78bfff"),false)
		host.text(str(rank_value),Rect2(7,r.position.y+4,28,28),15,Color("fff1ce"),true,HORIZONTAL_ALIGNMENT_CENTER,false,self)
		host.text(str(row.get("nickname","")),Rect2(44,r.position.y+4,size.x-190,28),16,Color("ffe1a0") if own else Color("fff1ce"),false,HORIZONTAL_ALIGNMENT_LEFT,false,self)
		host.text(str(int(row.get("score",0))),Rect2(size.x-146,r.position.y+4,91,28),17,Color("f3c569"),true,HORIZONTAL_ALIGNMENT_RIGHT,false,self)
		host.text(str(int(row.get("word_count",0) if daily else row.get("wave",0))),Rect2(size.x-48,r.position.y+4,42,28),15,Color("c2d7df"),false,HORIZONTAL_ALIGNMENT_CENTER,false,self)
