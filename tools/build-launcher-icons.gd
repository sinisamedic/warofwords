extends SceneTree

# Android's adaptive viewport is 108dp; the normal visible artwork is 72dp.
# Package the unchanged master with the required overscan margin; do not redraw it.
func _initialize() -> void:
	var master := Image.load_from_file("res://assets/launcher/icon-main.png")
	if master == null:
		push_error("Launcher master missing")
		quit(1)
		return
	master.convert(Image.FORMAT_RGBA8)
	master.resize(288,288,Image.INTERPOLATE_LANCZOS)
	var foreground := Image.create(432,432,false,Image.FORMAT_RGBA8)
	foreground.fill(Color.TRANSPARENT)
	foreground.blit_rect(master,Rect2i(0,0,288,288),Vector2i(72,72))
	var result := foreground.save_png("res://assets/launcher/icon-foreground.png")
	if result != OK:
		push_error("Could not write adaptive foreground")
	quit(0 if result == OK else 1)
