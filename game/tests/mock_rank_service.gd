extends "res://scripts/rank_service.gd"
var offline := false
var calls: Array=[]
func call_rank_api(method: String, payload: Dictionary) -> Dictionary:
	calls.append({"method":method,"payload":payload.duplicate(true)})
	await get_tree().process_frame
	return {"error":"offline"} if offline else {"saved":true}
func leaderboard(mode: String, _language: String, _adjacent: bool) -> Dictionary:
	await get_tree().process_frame
	if offline: return {"error":"offline"}
	var rows: Array=[]
	for i in 22:
		rows.append({"position":i+1,"nickname":["Vitez reči","Zlatni feniks","Sinisa","Čuvar kule"][i%4],"score":18240-i*503,"wave":16-i/2,"word_count":84-i,"own":i==2})
	return {"rows":rows,"total":22,"day":"2026-09-19" if mode=="daily" else ""}
