extends RefCounted

var path := "user://progress.json"
var data: Dictionary = {}

func defaults() -> Dictionary:
	return {"version":1,"coins":180,"levels":[1,1,1,1],"wins":{},"unlocked":0,"selected_power":0,"sound":true,"music":true,"haptics":true,"calm":false,"adjacent_only":true,"ui_language":"en","word_language":"en","tutorial":false,"battle":{},"total_words":0,"longest":"","dictionary":[]}

func load_game() -> void:
	data = defaults()
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
			# JSON represents integers as floats, so validate numeric fields separately.
			data.coins = clampi(number(parsed.get("coins"),180),0,999999)
			data.unlocked = clampi(number(parsed.get("unlocked"),0),0,11)
			data.selected_power = clampi(number(parsed.get("selected_power"),0),0,2)
			data.weapon = "breach" if parsed.get("weapon") == "breach" and data.wins.has("3") else "pulse"
			data.total_words = maxi(0,number(parsed.get("total_words"),0))
			if not data.levels is Array or data.levels.size() != 4:
				data.levels = [1,1,1,1]
			for i in 4:
				data.levels[i] = clampi(number(data.levels[i],1),1,8)
			data.dictionary = data.dictionary.filter(func(word): return word is String)
			for key in ["ui_language","word_language"]:
				if data[key] not in ["en","sr"]: data[key] = "en"
			for key in data.wins.keys():
				data.wins[key] = clampi(number(data.wins[key],1),1,3)
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
