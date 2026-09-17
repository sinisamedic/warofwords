extends Node2D

# A small textured mesh bends the existing leg at the knee and ankle.
# UVs always sample the original atlas; no bitmap cutting or new artwork is needed.
var surface: Polygon2D
var rest := PackedVector2Array()
var pixels := PackedVector2Array()
var knee := Vector2.ZERO
var ankle := Vector2.ZERO
var rest_hip := Vector2.ZERO
var knee_pixel := 0.0
var ankle_pixel := 0.0

func setup(atlas: Texture2D, region: Rect2, pivot: Vector2, factor: float, bend: Vector2, boot: Vector2, shader: ShaderMaterial) -> void:
	rest_hip=position
	knee=(bend-pivot)*factor; ankle=(boot-pivot)*factor
	knee_pixel=bend.y; ankle_pixel=boot.y
	surface=Polygon2D.new(); surface.texture=atlas; surface.material=shader; add_child(surface)
	var uv := PackedVector2Array()
	var faces: Array[PackedInt32Array]=[]
	for y in 13:
		for x in 7:
			var p := Vector2(x*region.size.x/6.0,y*region.size.y/12.0)
			pixels.append(p); rest.append((p-pivot)*factor); uv.append(region.position+p)
	for y in 12:
		for x in 6:
			var i := y*7+x
			faces.append(PackedInt32Array([i,i+1,i+8,i+7]))
	surface.polygon=rest; surface.uv=uv; surface.polygons=faces

func reset_pose() -> void:
	position=rest_hip; rotation=0; surface.polygon=rest

func collapse(hip: Vector2, amount: float) -> void:
	var boot := rest_hip+ankle
	var direction := (boot-hip).normalized()
	var length_a := knee.length()
	var length_b := (ankle-knee).length()
	var distance := clampf(hip.distance_to(boot),absf(length_a-length_b)+.01,length_a+length_b-.01)
	var along := (length_a*length_a-length_b*length_b+distance*distance)/(2*distance)
	var height := sqrt(maxf(0,length_a*length_a-along*along))
	var normal := Vector2(-direction.y,direction.x)
	var joint_a := hip+direction*along+normal*height
	var joint_b := hip+direction*along-normal*height
	# The knee folds above the floor while the boot retains its planted orientation.
	var joint := joint_a if joint_a.y<joint_b.y else joint_b
	var upper_angle := (joint-hip).angle()-knee.angle()
	var lower_angle := (boot-joint).angle()-(ankle-knee).angle()
	var vertices := PackedVector2Array()
	for i in rest.size():
		var p := rest[i]
		var upper := hip+p.rotated(upper_angle)
		var lower := joint+(p-knee).rotated(lower_angle)
		var foot := boot+p-ankle
		var folded := upper.lerp(lower,smoothstep(knee_pixel-28,knee_pixel+28,pixels[i].y))
		folded=folded.lerp(foot,smoothstep(ankle_pixel-28,ankle_pixel+28,pixels[i].y))
		vertices.append((rest_hip+p).lerp(folded,amount))
	position=Vector2.ZERO; surface.polygon=vertices
