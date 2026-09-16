extends Node

var enabled := true
var streams: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var cursor := 0

func _ready() -> void:
	for i in 6:
		var player := AudioStreamPlayer.new()
		player.volume_db = -15
		add_child(player)
		voices.append(player)
	for key in ["tap","word","shot","hit","win","lose","upgrade"]:
		streams[key] = make_tone(key)

func play(key: String, pitch: float = 1.0) -> void:
	if not enabled or voices.is_empty():
		return
	var voice := voices[cursor % voices.size()]
	cursor += 1
	voice.stream = streams.get(key,streams.tap)
	voice.pitch_scale = pitch
	voice.play()

func make_tone(key: String) -> AudioStreamWAV:
	var duration := 0.13
	var frequency := 520.0
	match key:
		"word": duration=0.42; frequency=660.0
		"shot": duration=0.26; frequency=220.0
		"hit": duration=0.22; frequency=110.0
		"win": duration=0.85; frequency=523.25
		"lose": duration=0.65; frequency=180.0
		"upgrade": duration=0.6; frequency=440.0
	var frames := int(duration*22050)
	var bytes := PackedByteArray()
	bytes.resize(frames*2)
	for i in frames:
		var t := float(i)/22050.0
		var f := frequency
		if key in ["win","word","upgrade"]:
			f *= [1.0,1.25,1.5,2.0][mini(3,int(t/duration*4))]
		elif key == "shot":
			f *= 1.8-t/duration
		var envelope := minf(t/0.012,1.0)*pow(1.0-t/duration,1.5)
		var sample := (sin(t*f*TAU)+sin(t*f*TAU*2.0)*0.2)*envelope*14000.0
		bytes.encode_s16(i*2,int(sample))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.data = bytes
	return stream
