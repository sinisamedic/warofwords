extends Sprite2D

func setup(texture_source: Texture2D, enemy: bool) -> void:
	texture = texture_source
	hframes = 2
	frame = 1 if enemy else 0
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; varying vec4 tint; void vertex(){tint=COLOR;} void fragment(){ vec4 c=texture(TEXTURE,UV); float key=min(c.r,c.b)-c.g; float a=1.0-smoothstep(0.35,0.7,key); COLOR=vec4(c.rgb,c.a*a)*tint; }"
	var mat := ShaderMaterial.new()
	mat.shader = shader
	material = mat
