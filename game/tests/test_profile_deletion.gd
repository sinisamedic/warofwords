extends SceneTree
class FakeService:
	extends "res://scripts/daily_service.gd"
	var calls := 0
	var reply: Dictionary = {"deleted":true}
	func request_json(endpoint: String, payload: Dictionary, token := "") -> Dictionary:
		assert(endpoint=="/functions/v1/daily")
		assert(payload.action=="delete_profile" and payload.confirm=="DELETE_MY_PROFILE")
		assert(token=="test-token")
		calls+=1
		return reply
var failures := 0
func check(ok: bool, message: String) -> void:
	print(("PASS " if ok else "FAIL ")+message)
	if not ok: failures+=1
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var service=FakeService.new()
	service.session_path="res://../.local/delete-test-session.json"
	service.access_allowed=func(): return true
	root.add_child(service)
	service.session.clear()
	var result=await service.delete_profile()
	check(result.get("deleted",false) and service.calls==0,"deletion does not create a new account")
	service.session={"access_token":"test-token","expires_at":Time.get_unix_time_from_system()+3600}
	service.config={"url":"https://test.invalid","publishable_key":"sb_publishable_test"}
	var file=FileAccess.open(service.session_path,FileAccess.WRITE); file.store_string(JSON.stringify(service.session)); file.close()
	service.reply={"error":"offline"}
	result=await service.delete_profile()
	check(result.has("error") and not service.session.is_empty() and FileAccess.file_exists(service.session_path),"failure retains identity for retry")
	service.reply={"deleted":true}
	result=await service.delete_profile()
	check(result.get("deleted",false) and service.session.is_empty() and not FileAccess.file_exists(service.session_path),"successful deletion clears token file")
	service.access_allowed=func(): return false
	var before=service.calls
	result=await service.delete_profile()
	check(result.has("error") and service.calls==before,"under-13 network isolation remains")
	service.queue_free(); await process_frame
	quit(1 if failures else 0)
