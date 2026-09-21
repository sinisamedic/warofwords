extends Node
## One request at a time. Only the SDK reward callback may authorize a revive.
signal changed
signal completed(earned: bool)
const MAX_CONTINUES := 3
const APP_ID := "ca-app-pub-5562106147014166~4923218215"
const UNIT_ID := "ca-app-pub-5562106147014166/2184629377"
const TEST_UNIT_ID := "ca-app-pub-3940256099942544/5224354917"
# Release activation is a separate, reviewed change after UMP/Play/policy setup.
const TEST_ADS := true
var state := "idle"
var earned := false
var token := 0
var elapsed := 0.0
var backend: Node
var backend_factory: Callable
var access_allowed: Callable
var is_minor: Callable
func allowed() -> bool: return access_allowed.is_valid() and access_allowed.call()

func supported() -> bool:
	return allowed() and (backend_factory.is_valid() or (OS.get_name()=="Android" and Engine.has_singleton("PoingGodotAdMobRewardedAd")))

func busy() -> bool:
	return state in ["consent","loading","showing"]

func request() -> void:
	if busy(): return
	if not supported(): state="unavailable"; changed.emit(); return
	token+=1; earned=false; state="consent"; elapsed=0
	backend=backend_factory.call() if backend_factory.is_valid() else load("res://scripts/admob_backend.gd").new()
	if not backend_factory.is_valid(): backend.under_age_of_consent=not is_minor.is_valid() or is_minor.call()
	backend.phase.connect(_phase.bind(token))
	backend.reward.connect(_reward.bind(token))
	backend.closed.connect(_closed.bind(token))
	backend.failed.connect(_failed.bind(token))
	add_child(backend)
	changed.emit()
	backend.begin(TEST_ADS,TEST_UNIT_ID if TEST_ADS else UNIT_ID)

func _phase(value: String, request_token: int) -> void:
	if request_token!=token or not busy(): return
	state=value; elapsed=0; changed.emit()

func _reward(request_token: int) -> void:
	if request_token==token and state=="showing": earned=true

func _closed(request_token: int) -> void:
	if request_token!=token or not busy(): return
	var granted := earned and allowed()
	_cleanup(); state="idle" if granted else "skipped"; changed.emit(); completed.emit(granted)

func _failed(request_token: int) -> void:
	if request_token!=token or not busy(): return
	_cleanup(); state="unavailable"; changed.emit(); completed.emit(false)

func cancel() -> void:
	if state=="showing": return
	_cleanup(); state="idle"; changed.emit()

func _cleanup() -> void:
	token+=1; earned=false
	if is_instance_valid(backend):
		backend.stop(); backend.queue_free()
	backend=null

func _process(delta: float) -> void:
	if state!="loading": return
	elapsed+=delta
	if elapsed>=30: _failed(token)

func _exit_tree() -> void:
	if is_instance_valid(backend): backend.stop()
