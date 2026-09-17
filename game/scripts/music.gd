extends Node

# Independently mixed, licensed instrumental recordings; no network needed in-game.
const TRACKS = [preload("res://assets/music/fantasy-orchestral-theme.mp3"),preload("res://assets/music/treasure-hunter.mp3")]
var players: Array[AudioStreamPlayer] = []
var gains: Array[float] = [0.0,0.0]
var enabled := true
var backgrounded := false
var battle := false
var ducked := false

func _ready() -> void:
	for track in TRACKS:
		var player := AudioStreamPlayer.new()
		player.stream = track.duplicate()
		player.stream.loop = true
		player.volume_db = -80
		add_child(player)
		players.append(player)

func _process(delta: float) -> void:
	for i in players.size():
		var player := players[i]
		var audible := enabled and not backgrounded
		player.stream_paused = not audible
		if not audible: continue
		var wanted := i == (1 if battle else 0)
		if wanted and not player.playing: player.play()
		gains[i] = move_toward(gains[i],1.0 if wanted else 0.0,delta/1.4)
		# Gentle edge fades also make the menu recording's natural ending loop cleanly.
		var position := player.get_playback_position()
		var edge := minf(clampf(position/1.2,0,1),clampf((player.stream.get_length()-position)/1.5,0,1))
		player.volume_linear = gains[i]*edge*(.075 if ducked else .19)
		if not wanted and gains[i] == 0: player.stream_paused = true

func set_enabled(value: bool) -> void:
	enabled = value
	if not enabled:
		for player in players: player.stream_paused = true

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]:
		backgrounded=true
		for player in players: player.stream_paused=true
	elif what in [NOTIFICATION_APPLICATION_RESUMED,NOTIFICATION_APPLICATION_FOCUS_IN]:
		backgrounded=false
