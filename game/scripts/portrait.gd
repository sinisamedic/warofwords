extends Sprite2D

func setup(sheet: Texture2D, opponent: bool) -> void:
	texture = sheet
	region_enabled = true
	region_rect = Rect2(1140,70,250,250) if opponent else Rect2(290,90,250,250)
	scale = Vector2.ONE * 48.0/250.0
	var shader := Shader.new()
	shader.code = """shader_type canvas_item;
uniform vec2 source_origin;
uniform vec2 source_size;
void fragment() {
 vec4 c = texture(TEXTURE, UV);
 vec2 local = (UV-source_origin)/source_size;
 float mask = 1.0-smoothstep(.48,.50,length(local-vec2(.5)));
 float key = 1.0-smoothstep(.35,.7,min(c.r,c.b)-c.g);
 COLOR = vec4(mix(vec3(.06,.15,.23),c.rgb,key),mask);
}"""
	material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("source_origin",region_rect.position/Vector2(sheet.get_size()))
	material.set_shader_parameter("source_size",region_rect.size/Vector2(sheet.get_size()))
	z_index = 1
