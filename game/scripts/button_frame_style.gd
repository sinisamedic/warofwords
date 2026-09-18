extends StyleBox
## Native Buttons share the same high-resolution frame geometry as custom UI.
var kind := 0
var tint := Color.WHITE
func _draw(canvas_item: RID, rect: Rect2) -> void:
	var art=load("res://scripts/ornaments.gd")
	var texture: Texture2D=art.FRAMES[kind]
	for patch in art.button_patches(rect,kind):
		RenderingServer.canvas_item_add_texture_rect_region(canvas_item,patch[0],texture.get_rid(),patch[1],tint,false,true)
