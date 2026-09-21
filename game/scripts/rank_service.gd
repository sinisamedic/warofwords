extends Node
signal changed
var host
var busy := false
var message := ""
var current_run_id := ""
var sending_run_id := ""
var sent_runs: Dictionary={}
func nickname() -> String:
	return host.daily_screen.local_nickname
func valid_name(value: String) -> bool:
	var regex := RegEx.new(); regex.compile("^[\\p{L}\\p{N} _-]{3,20}$")
	return regex.search(value.strip_edges())!=null
func remember_nickname(value: String) -> bool:
	value=value.strip_edges()
	if not valid_name(value): return false
	var file := FileAccess.open(host.daily_screen.profile_path,FileAccess.WRITE)
	if file==null: return false
	file.store_string(JSON.stringify({"nickname":value})); file.close()
	host.daily_screen.local_nickname=value
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
	if not host.online_allowed(): current_run_id=""; host.save.save_game(); return
	var bytes := Crypto.new().generate_random_bytes(16).hex_encode()
	var entry := result.duplicate(true)
	entry.id=bytes.substr(0,8)+"-"+bytes.substr(8,4)+"-"+bytes.substr(12,4)+"-"+bytes.substr(16,4)+"-"+bytes.substr(20,12)
	current_run_id=entry.id
	host.save.data.endless_outbox.append(entry)
	host.save.save_game()
	# A saved run is a draft. Only the explicit Send action may publish it.
func send_run(run_id: String, entered_name: String) -> void:
	if not host.online_allowed(): return
	if host.endless_continue_pending: return
	if busy or not host.online_writes_enabled or sent_runs.has(run_id): return
	if not valid_name(entered_name): message="Enter your nickname to send the result"; changed.emit(); return
	var item: Dictionary={}
	for entry in host.save.data.endless_outbox:
		if entry.id==run_id: item=entry.duplicate(true); break
	if item.is_empty(): return
	if not remember_nickname(entered_name): message="Name could not be saved"; changed.emit(); return
	busy=true; sending_run_id=run_id; message="Sending result…"; changed.emit()
	var response := await call_rank_api("endless_finish",{"p_run":item.id,"p_language":item.language,"p_adjacent":item.adjacent,"p_nickname":entered_name.strip_edges(),"p_score":int(item.score),"p_wave":int(item.wave),"p_words":int(item.words),"p_seconds":int(item.seconds)})
	if not response.has("error") and bool(response.get("saved",false)):
		sent_runs[run_id]=true
		for i in range(host.save.data.endless_outbox.size()-1,-1,-1):
			if host.save.data.endless_outbox[i].id==run_id: host.save.data.endless_outbox.remove_at(i)
		host.save.save_game(); message="Result sent"
	else: message="Saved on device. Retry when online."
	busy=false; sending_run_id=""; changed.emit()
func leaderboard(mode: String, language: String, adjacent: bool, run_id: String = "") -> Dictionary:
	if mode=="daily": return await host.daily_screen.service.call_api("leaderboard",{"language":language,"adjacent":adjacent})
	return await call_rank_api("endless_attempt_leaderboard",{"p_adjacent":adjacent,"p_run":null if run_id.is_empty() else run_id})
