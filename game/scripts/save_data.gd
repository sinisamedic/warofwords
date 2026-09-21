extends RefCounted
const Equipment = preload("res://scripts/equipment.gd")
const Campaign = preload("res://scripts/campaign.gd")

var path := "user://progress.json"
var data: Dictionary = {}

func defaults() -> Dictionary:
	return {"version":1,"age_group":"","practice_records":{},"loadout":["pulse","aegis","arc","mend"],"artifact":"none","lexicon_earned":false,"pending_unlocks":[],"coins":180,"levels":[1,1,1,1],"wins":{},"unlocked":0,"selected_power":0,"sound":true,"music":true,"haptics":true,"calm":false,"adjacent_only":true,"ui_language":"en","word_language":"en","tutorial":false,"battle":{},"endless":{},"endless_outbox":[],"endless_name_dirty":false,"endless_pending":{},"endless_records":{},"total_words":0,"longest":"","dictionary":[]}

func load_game() -> void:
	data = defaults()
	var device_language := preload("res://scripts/languages.gd").device_language(OS.get_locale())
	data.ui_language=device_language; data.word_language=device_language
	data.weapon = "pulse"
	for file_path in [path,path+".bak"]:
		if not FileAccess.file_exists(file_path):
			continue
		var json := JSON.new()
		if json.parse(FileAccess.get_file_as_string(file_path)) != OK:
			continue
		var parsed = json.data
		if parsed is Dictionary and parsed.get("version",0) == 1:
			for key in data:
				if parsed.has(key) and typeof(parsed[key]) == typeof(data[key]):
					data[key] = parsed[key]
			if data.age_group in ["13_15","16_17"]: data.age_group="teen"
			if not preload("res://scripts/age_policy.gd").known(data): data.age_group=""
			# JSON represents integers as floats, so validate numeric fields separately.
			data.coins = clampi(number(parsed.get("coins"),180),0,999999)
			data.unlocked = clampi(number(parsed.get("unlocked"),0),0,Campaign.COUNT-1)
			# A completed old campaign opens chapter four immediately after upgrading.
			if data.wins.has("11"): data.unlocked=maxi(12,data.unlocked)
			data.selected_power = clampi(number(parsed.get("selected_power"),0),0,2)
			data.weapon = "breach" if parsed.get("weapon") == "breach" and data.wins.has("3") else "pulse"
			data.total_words = maxi(0,number(parsed.get("total_words"),0))
			if not data.levels is Array or data.levels.size() != 4:
				data.levels = [1,1,1,1]
			for i in 4:
				data.levels[i] = clampi(number(data.levels[i],1),1,8)
			data.dictionary = data.dictionary.filter(func(word): return word is String)
			for key in ["ui_language","word_language"]:
				if data[key] not in preload("res://scripts/languages.gd").CODES: data[key] = "en"
			for key in data.wins.keys():
				data.wins[key] = clampi(number(data.wins[key],1),1,3)
			# Migrate legacy gold-only equipment without changing an unfinished duel.
			if not parsed.has("loadout"): data.loadout=[data.weapon,"aegis","arc","mend"]
			data.loadout=Equipment.loadout(data)
			data.weapon=data.loadout[0]
			if data.artifact not in ["none","lexicon","reserve"] or not Equipment.unlocked(data.artifact,data): data.artifact="none"
			var pending: Array = []
			for id in data.pending_unlocks:
				if id is String and Equipment.DATA.has(id) and id not in Equipment.DEFAULTS and Equipment.unlocked(id,data) and id not in pending:
					pending.append(id)
			data.pending_unlocks=pending
			var valid_runs: Array=[]
			for entry in data.endless_outbox:
				if not entry is Dictionary or not entry.get("id") is String or entry.get("language") not in preload("res://scripts/languages.gd").CODES or not entry.get("adjacent") is bool: continue
				var valid := true
				for field in ["score","wave","words","seconds"]:
					if number(entry.get(field),-1)<0: valid=false
				if valid: valid_runs.append(entry)
			data.endless_outbox=valid_runs
			for key in data.endless_pending.keys():
				var entry = data.endless_pending[key]
				if not preload("res://scripts/languages.gd").record_key(key) or not entry is Dictionary:
					data.endless_pending.erase(key); continue
				var valid := true
				for field in ["score","wave","words","seconds"]:
					if number(entry.get(field),-1)<0: valid=false
				if not valid: data.endless_pending.erase(key)
			for key in data.endless_records.keys():
				var record = data.endless_records[key]
				if not preload("res://scripts/languages.gd").record_key(key) or not record is Dictionary:
					data.endless_records.erase(key); continue
				data.endless_records[key]={"score":maxi(0,number(record.get("score"),0)),"wave":maxi(0,number(record.get("wave"),0))}
			for key in data.practice_records.keys():
				if not preload("res://scripts/languages.gd").record_key(key): data.practice_records.erase(key)
				else: data.practice_records[key]=maxi(0,number(data.practice_records[key],0))
			break

func number(value: Variant, fallback: int) -> int:
	return int(value) if (value is int or value is float) and is_finite(float(value)) else fallback

func save_game() -> bool:
	var file := FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	var base := ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(path):
		var previous := JSON.new()
		if previous.parse(FileAccess.get_file_as_string(path)) == OK and previous.data is Dictionary:
			DirAccess.copy_absolute(base,base+".bak")
	return DirAccess.rename_absolute(base+".tmp",base) == OK
