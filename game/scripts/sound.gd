extends Node

var enabled := true:
	set(value):
		enabled = value
		if not value:
			for voice in voices: voice.stop()
var streams: Dictionary = {}
var voices: Array[AudioStreamPlayer] = []
var cursor := 0

func _ready() -> void:
	for i in 10:
		var player := AudioStreamPlayer.new()
		player.volume_db = -9
		add_child(player)
		voices.append(player)
	for key in ["tap","word","shot","flight","hit","explosion","shield","arc","heal","freeze","win","lose","upgrade"]:
		streams[key] = load("res://assets/audio/"+key+".wav")

func play(key: String, pitch: float = 1.0) -> void:
	if not enabled or voices.is_empty(): return
	var voice := voices[cursor % voices.size()]
	cursor += 1
	voice.stream = streams.get(key,streams.tap)
	voice.pitch_scale = pitch
	voice.volume_db = -15 if key == "tap" else -12 if key == "flight" else -9
	voice.play()
