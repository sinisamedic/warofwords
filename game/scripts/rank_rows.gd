extends Control
const O=preload("res://scripts/ornaments.gd")
var host
var rows: Array=[]
var daily := false
func _draw() -> void:
	for i in rows.size():
		var row: Dictionary=rows[i]
		var r := Rect2(0,i*40,size.x,36)
		var own: bool=row.get("own",false)
		var bg := StyleBoxFlat.new(); bg.bg_color=Color("24475c") if own else Color("102c3d") if i%2==0 else Color("0c2232"); bg.set_corner_radius_all(5)
		bg.set_border_width_all(1); bg.border_color=Color("cba85c") if own else Color("34505b"); draw_style_box(bg,r)
		var rank_value := int(row.get("position",i+1))
		if rank_value<=3: O.jewel(self,Vector2(21,r.get_center().y),11,Color("ffd053") if rank_value==1 else Color("78bfff"),false)
		host.text(str(rank_value),Rect2(7,r.position.y+4,28,28),15,Color("fff1ce"),true,HORIZONTAL_ALIGNMENT_CENTER,false,self)
		host.text(str(row.get("nickname","")),Rect2(44,r.position.y+4,size.x-190,28),16,Color("ffe1a0") if own else Color("fff1ce"),false,HORIZONTAL_ALIGNMENT_LEFT,false,self)
		host.text(str(int(row.get("score",0))),Rect2(size.x-146,r.position.y+4,91,28),17,Color("f3c569"),true,HORIZONTAL_ALIGNMENT_RIGHT,false,self)
		host.text(str(int(row.get("word_count",0) if daily else row.get("wave",0))),Rect2(size.x-48,r.position.y+4,42,28),15,Color("c2d7df"),false,HORIZONTAL_ALIGNMENT_CENTER,false,self)
