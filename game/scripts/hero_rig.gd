extends Node2D

# Original nine-part cutout rig. Sprite regions remain unmodified in the source atlas.
const ATLAS := preload("res://assets/art/hero-parts.png")
var joints: Dictionary = {}
var player: AnimationPlayer
var muzzle: Marker2D
var defeated := false
var defeat_start: Dictionary={}

func _init() -> void:
	var clean := Shader.new()
	clean.code="shader_type canvas_item; varying vec4 tint; void vertex(){tint=COLOR;} void fragment(){ vec4 c=texture(TEXTURE,UV); COLOR=vec4(c.rgb,c.a*smoothstep(0.02,0.12,c.a))*tint; }"
	var mat := ShaderMaterial.new(); mat.shader=clean
	# Legs stay grounded. Upper-body and clothing joints animate independently.
	leg("BackLeg",Vector2(-4,-65),Rect2(435,786,321,431),Vector2(266,40),.166,Vector2(145,220),Vector2(71,340),mat)
	leg("FrontLeg",Vector2(4,-65),Rect2(903,784,332,429),Vector2(61,40),.168,Vector2(151,206),Vector2(219,339),mat)
	var body := Node2D.new(); body.name="Body"; body.position=Vector2(0,-65); add_child(body); joints.Body=body
	part("Coat",body,Vector2(-3,-1),Rect2(843,68,386,326),Vector2(268,25),.175,mat).z_index=-1
	var rear := part("BackArm",body,Vector2(-19,-34),Rect2(92,457,282,285),Vector2(221,51),.10,mat)
	part("BackHand",rear,Vector2(-18,18),Rect2(504,471,233,268),Vector2(187,40),.095,mat)
	part("Torso",body,Vector2.ZERO,Rect2(510,45,237,345),Vector2(151,304),.14,mat)
	part("Head",body,Vector2(0,-40),Rect2(80,90,265,227),Vector2(172,220),.11,mat)
	var front := part("FrontArm",body,Vector2(-1,-33),Rect2(864,513,356,167),Vector2(35,55),.092,mat)
	body.move_child(front,2)
	var hand := part("FrontHand",front,Vector2(28,6),Rect2(18,918,389,137),Vector2(35,44),.10,mat)
	muzzle=Marker2D.new(); muzzle.name="Muzzle"; muzzle.position=Vector2(35,3); hand.add_child(muzzle)
	player=AnimationPlayer.new(); player.name="Animations"; add_child(player)
	var library := AnimationLibrary.new()
	var idle := Animation.new(); idle.length=3.6; idle.loop_mode=Animation.LOOP_LINEAR
	track(idle,"Body:position",[0,.9,1.8,2.7,3.6],[Vector2(0,-65),Vector2(.8,-66.6),Vector2(0,-65),Vector2(-.6,-64.2),Vector2(0,-65)])
	track(idle,"Body/Head:rotation",[0,.9,1.8,2.7,3.6],[0.0,-.035,0.0,.025,0.0])
	track(idle,"Body/Coat:rotation",[0,.9,1.8,2.7,3.6],[-.025,.065,.015,-.055,-.025])
	track(idle,"Body/BackArm:rotation",[0,.9,1.8,2.7,3.6],[0.0,.05,0.0,-.04,0.0])
	track(idle,"Body/BackArm/BackHand:rotation",[0,1.8,3.6],[.035,-.04,.035])
	track(idle,"Body/FrontArm:rotation",[0,.9,1.8,2.7,3.6],[0.0,-.025,0.0,.025,0.0])
	track(idle,"Body/FrontArm/FrontHand:rotation",[0,1.8,3.6],[0.0,.035,0.0])
	library.add_animation("idle",idle)
	var fire := Animation.new(); fire.length=.48
	track(fire,"Body:position",[0,.06,.18,.48],[Vector2(0,-65),Vector2(-3,-66),Vector2(-1,-65),Vector2(0,-65)])
	track(fire,"Body/FrontArm:rotation",[0,.05,.17,.48],[0.0,-.18,-.07,0.0])
	track(fire,"Body/FrontArm/FrontHand:rotation",[0,.05,.17,.48],[0.0,-.10,.025,0.0])
	track(fire,"Body/Head:rotation",[0,.09,.48],[0.0,-.075,0.0])
	track(fire,"Body/Coat:rotation",[0,.14,.48],[0.0,-.16,0.0])
	library.add_animation("fire",fire)
	var hit := Animation.new(); hit.length=.48
	track(hit,"Body:position",[0,.08,.26,.48],[Vector2(0,-65),Vector2(-4,-62),Vector2(1,-64),Vector2(0,-65)])
	track(hit,"Body/Head:rotation",[0,.07,.22,.48],[0.0,-.15,.04,0.0])
	track(hit,"Body/FrontArm:rotation",[0,.1,.3,.48],[0.0,-.25,.08,0.0])
	track(hit,"Body/BackArm:rotation",[0,.1,.48],[0.0,.20,0.0])
	track(hit,"Body/Coat:rotation",[0,.16,.48],[0.0,.19,0.0])
	library.add_animation("hit",hit)
	player.add_animation_library("",library)
	player.animation_finished.connect(func(_clip): player.play("idle",.10))
	player.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	player.play("idle")
	player.advance(0)

func part(id: String, parent: Node2D, at: Vector2, region: Rect2, pivot: Vector2, factor: float, mat: ShaderMaterial) -> Node2D:
	var joint := Node2D.new(); joint.name=id; joint.position=at; parent.add_child(joint); joints[id]=joint
	var sprite := Sprite2D.new(); sprite.texture=ATLAS; sprite.region_enabled=true; sprite.region_rect=region
	sprite.centered=false; sprite.offset=-pivot; sprite.scale=Vector2.ONE*factor; sprite.material=mat
	joint.add_child(sprite)
	return joint

func track(clip: Animation, path: String, times: Array, values: Array) -> void:
	var i := clip.add_track(Animation.TYPE_VALUE); clip.track_set_path(i,NodePath(path))
	clip.track_set_interpolation_type(i,Animation.INTERPOLATION_CUBIC)
	for n in times.size(): clip.track_insert_key(i,times[n],values[n])

func advance_pose(delta: float, calm: bool, frozen: bool) -> void:
	if defeated: return
	if calm:
		player.play("idle"); player.seek(0,true)
	elif not frozen:
		player.advance(delta)

func react(clip: String, calm: bool) -> void:
	if calm or defeated: return
	# Reset non-keyed joints before one-shot actions, then blend back into breathing.
	player.play("idle"); player.seek(0,true); player.play(clip); player.advance(0)

func muzzle_position() -> Vector2:
	return muzzle.global_position

func leg(id: String, at: Vector2, region: Rect2, pivot: Vector2, factor: float, knee: Vector2, ankle: Vector2, mat: ShaderMaterial) -> void:
	var node=preload("res://scripts/hero_leg.gd").new()
	node.name=id; node.position=at; add_child(node); joints[id]=node
	node.setup(ATLAS,region,pivot,factor,knee,ankle,mat)

func reset_pose() -> void:
	defeated=false
	for id in joints:
		joints[id].rotation=0
	joints.BackLeg.reset_pose(); joints.FrontLeg.reset_pose()
	player.play("idle"); player.seek(0,true)

func begin_defeat() -> void:
	defeated=true; defeat_start.clear()
	for id in joints: defeat_start[id]={"position":joints[id].position,"rotation":joints[id].rotation}
	player.stop(true)

func defeat_pose(u: float, calm: bool) -> void:
	if not defeated: begin_defeat()
	if calm: return
	# Recoil, knees giving way, weight landing on the hand, then a settled collapse.
	var fall := smoothstep(.12,.76,u)
	var settle := sin(clampf((u-.64)/.20,0,1)*PI)*2.0
	var body: Node2D=joints.Body
	body.position=Vector2(-5*sin(u*PI),lerpf(-65,-10,fall)+settle)
	body.rotation=lerpf(0,1.37,smoothstep(.25,.82,u))-.08*sin(clampf(u/.24,0,1)*PI)
	var entering := smoothstep(0,.12,u)
	body.position=defeat_start.Body.position.lerp(body.position,entering)
	joints.Head.rotation=lerpf(defeat_start.Head.rotation,.36,smoothstep(.08,.58,u))
	joints.Coat.rotation=lerpf(defeat_start.Coat.rotation,-.62,smoothstep(.22,.94,u))
	joints.BackLeg.collapse(body.position+Vector2(-4,0).rotated(body.rotation),smoothstep(.08,.32,u))
	joints.FrontLeg.collapse(body.position+Vector2(4,0).rotated(body.rotation),smoothstep(.10,.34,u))
	joints.FrontArm.rotation=lerpf(defeat_start.FrontArm.rotation,.75,smoothstep(.12,.48,u))
	joints.FrontHand.rotation=lerpf(defeat_start.FrontHand.rotation,.7,smoothstep(.18,.5,u))
	joints.BackArm.rotation=lerpf(defeat_start.BackArm.rotation,-.5,smoothstep(.12,.52,u))
	joints.BackHand.rotation=lerpf(defeat_start.BackHand.rotation,-.5,smoothstep(.12,.52,u))
	var brace := smoothstep(.38,.76,u)
	place_hand(joints.FrontArm,joints.FrontHand,Vector2(35,3),Vector2(54,-4),-1,brace)
	place_hand(joints.BackArm,joints.BackHand,Vector2(-12,18),Vector2(10,-3),1,brace)

func place_hand(arm: Node2D, hand: Node2D, tip: Vector2, target: Vector2, bend: float, weight: float) -> void:
	var shoulder: Vector2=joints.Body.transform*arm.position
	var relative := target-shoulder
	var a := hand.position.length(); var b := tip.length()
	var distance := clampf(relative.length(),absf(a-b)+.01,a+b-.01)
	var spread := acos(clampf((a*a+distance*distance-b*b)/(2*a*distance),-1,1))
	var upper := relative.angle()+spread*bend
	var elbow := shoulder+Vector2.from_angle(upper)*a
	var arm_rotation: float=upper-hand.position.angle()-joints.Body.rotation
	var hand_rotation: float=(target-elbow).angle()-tip.angle()-joints.Body.rotation-arm_rotation
	arm.rotation=lerp_angle(arm.rotation,arm_rotation,weight)
	hand.rotation=lerp_angle(hand.rotation,hand_rotation,weight)
