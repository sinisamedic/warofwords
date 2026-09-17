extends Node
## Only the public project URL/key belong in the build. Never a service-role key.
var config: Dictionary = {}
var session: Dictionary = {}
var session_path := "user://daily-session.json"
var busy := false

func _ready() -> void:
	if FileAccess.file_exists("res://online_config.json"):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string("res://online_config.json"))
		if parsed is Dictionary: config=parsed
	if FileAccess.file_exists(session_path):
		var parsed = JSON.parse_string(FileAccess.get_file_as_string(session_path))
		if parsed is Dictionary: session=parsed
	if session.get("project_url","")!=config.get("url",""): session={}

func configured() -> bool:
	return str(config.get("url","")).begins_with("https://") and str(config.get("publishable_key","")).begins_with("sb_publishable_")

func request_json(endpoint: String, payload: Dictionary, token := "") -> Dictionary:
	var http := HTTPRequest.new()
	http.timeout=15; http.body_size_limit=1024*1024
	add_child(http)
	var headers := PackedStringArray(["Content-Type: application/json","apikey: "+str(config.publishable_key)])
	if not token.is_empty(): headers.append("Authorization: Bearer "+token)
	var error := http.request(str(config.url).trim_suffix("/")+endpoint,headers,HTTPClient.METHOD_POST,JSON.stringify(payload))
	if error!=OK:
		http.queue_free(); return {"error":"Connection failed"}
	var response: Array=await http.request_completed
	http.queue_free()
	if response[0]!=HTTPRequest.RESULT_SUCCESS: return {"error":"Connection failed"}
	var body = JSON.parse_string(response[3].get_string_from_utf8())
	if not body is Dictionary: return {"error":"Service unavailable"}
	if int(response[1])<200 or int(response[1])>=300:
		return {"error":str(body.get("error","Sign-in or service unavailable")),"status":int(response[1])}
	return body

func ensure_session() -> Dictionary:
	if not configured(): return {"error":"Online service is not connected yet"}
	if float(session.get("expires_at",0))>Time.get_unix_time_from_system()+60: return {}
	var response: Dictionary
	if session.has("refresh_token"):
		response=await request_json("/auth/v1/token?grant_type=refresh_token",{"refresh_token":session.refresh_token})
	else:
		response=await request_json("/auth/v1/signup",{})
	if response.has("error") or not response.has("access_token"):
		return {"error":"Sign-in unavailable. Check connection and anonymous sign-in settings."}
	session=response
	session.project_url=config.url
	var file := FileAccess.open(session_path,FileAccess.WRITE)
	if file==null: return {"error":"Could not save online identity"}
	file.store_string(JSON.stringify(session)); file.close()
	return {}

func call_api(action: String, payload: Dictionary) -> Dictionary:
	if busy: return {"error":"Please wait"}
	busy=true
	var auth := await ensure_session()
	if auth.has("error"): busy=false; return auth
	var body := payload.duplicate(true)
	body.action=action; body.version=preload("res://scripts/daily_rules.gd").VERSION
	var result := await request_json("/functions/v1/daily",body,str(session.access_token))
	if int(result.get("status",0))==401:
		session.expires_at=0
		auth=await ensure_session()
		if not auth.has("error"): result=await request_json("/functions/v1/daily",body,str(session.access_token))
	busy=false
	return result
