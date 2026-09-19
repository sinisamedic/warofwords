extends "res://scripts/rank_service.gd"
var offline := false
var calls: Array=[]
func call_rank_api(method: String, payload: Dictionary) -> Dictionary:
	calls.append({"method":method,"payload":payload.duplicate(true)})
	await get_tree().process_frame
	return {"error":"offline"} if offline else {"saved":true}
func leaderboard(mode: String, _language: String, _adjacent: bool, _run_id: String = "") -> Dictionary:
	await get_tree().process_frame
	if offline: return {"error":"offline"}
	var rows: Array=[]
	for i in (22 if mode=="daily" else 10):
		rows.append({"position":i+1,"nickname":["Vitez reči","Zlatni feniks","Sinisa","Čuvar kule"][i%4],"score":28240-i*503,"wave":26-i/2,"word_count":84-i,"own":i%4==2})
	if mode=="endless" and not _run_id.is_empty():
		for i in 3:
			rows.append({"position":24+i,"nickname":["Vitez reči","Čuvar kule","Sinisa"][i],"score":[10240,10000,9958][i],"wave":8,"own":i==2,"current":i==2})
	return {"rows":rows,"total":26,"day":"2026-09-19" if mode=="daily" else ""}
