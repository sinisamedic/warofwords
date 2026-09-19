extends Node
signal changed
var host
var busy := false
var message := ""
var last_response: Dictionary={}
func _ready() -> void:
	var retry := Timer.new(); retry.wait_time=45; retry.timeout.connect(flush); add_child(retry); retry.start()
func nickname() -> String:
	return host.daily_screen.local_nickname
func valid_name(value: String) -> bool:
	var regex := RegEx.new(); regex.compile("^[\\p{L}\\p{N} _-]{3,20}$")
	return regex.search(value.strip_edges())!=null
func remember_nickname(value: String) -> bool:
	value=value.strip_edges()
	if not valid_name(value): return false
	var file := FileAccess.open(host.daily_screen.profile_path,FileAccess.WRITE)
	if file==null: message="Name could not be saved"; changed.emit(); return false
	file.store_string(JSON.stringify({"nickname":value})); file.close()
	host.daily_screen.local_nickname=value
	host.save.data.endless_name_dirty=true; host.save.save_game()
	return true
func call_rank_api(method: String, payload: Dictionary) -> Dictionary:
	var service=host.daily_screen.service
	var auth: Dictionary=await service.ensure_session()
	if auth.has("error"): return auth
	var response: Dictionary=await service.request_json("/rest/v1/rpc/"+method,payload,str(service.session.access_token))
	if int(response.get("status",0))==401:
		service.session.expires_at=0
		auth=await service.ensure_session()
		if not auth.has("error"): response=await service.request_json("/rest/v1/rpc/"+method,payload,str(service.session.access_token))
	return response
func enqueue(result: Dictionary) -> void:
	var bytes := Crypto.new().generate_random_bytes(16).hex_encode()
	var entry := result.duplicate(true)
	entry.id=bytes.substr(0,8)+"-"+bytes.substr(8,4)+"-"+bytes.substr(12,4)+"-"+bytes.substr(16,4)+"-"+bytes.substr(20,12)
	host.save.data.endless_outbox.append(entry)
	host.save.save_game()
	call_deferred("flush")
func flush() -> void:
	if busy or not host.online_autosubmit: return
	if host.save.data.endless_outbox.is_empty():
		if host.save.data.endless_name_dirty: await rename_player()
		return
	if not valid_name(nickname()): message="Enter your nickname to send the result"; changed.emit(); return
	busy=true; message="Sending result…"; changed.emit()
	# Keep unacknowledged attempts on disk; the server deduplicates each run ID.
	while not host.save.data.endless_outbox.is_empty():
		var item: Dictionary=host.save.data.endless_outbox[0]
		var sent_name := nickname()
		var response := await call_rank_api("endless_finish",{"p_run":item.id,"p_language":item.language,"p_adjacent":item.adjacent,"p_nickname":sent_name,"p_score":int(item.score),"p_wave":int(item.wave),"p_words":int(item.words),"p_seconds":int(item.seconds)})
		if response.has("error"):
			busy=false; message="Saved on device. Retry when online."; changed.emit(); return
		if nickname()==sent_name: host.save.data.endless_name_dirty=false
		host.save.data.endless_outbox.pop_front(); host.save.save_game()
	busy=false; message="Result sent"; changed.emit()
	if host.save.data.endless_name_dirty: call_deferred("rename_player")
func rename_player() -> void:
	if busy or not host.online_autosubmit or not valid_name(nickname()): return
	busy=true; message="Saving name…"; changed.emit()
	var sent_name := nickname()
	var response := await call_rank_api("endless_name",{"p_nickname":sent_name})
	if not response.has("error") and nickname()==sent_name:
		host.save.data.endless_name_dirty=false; host.save.save_game()
	busy=false; message="Saved on device. Retry when online." if response.has("error") else "Name saved"
	changed.emit()
func leaderboard(mode: String, language: String, adjacent: bool) -> Dictionary:
	if mode=="daily": return await host.daily_screen.service.call_api("leaderboard",{"language":language,"adjacent":adjacent})
	return await call_rank_api("endless_leaderboard",{"p_language":language,"p_adjacent":adjacent})
