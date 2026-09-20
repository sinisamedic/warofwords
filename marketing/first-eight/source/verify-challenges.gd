extends SceneTree
func _initialize() -> void:
	var lex=load("res://scripts/lexicon.gd").new()
	var evidence=JSON.parse_string(FileAccess.get_file_as_string("res://../marketing/first-eight/source/capture-evidence.json"))
	lex.letters.assign(evidence.letters)
	lex.adjacent_only=true
	var first: Array[int]=[0,1,2,3,4]
	var second: Array[int]=[15,16,17,18,19,20]
	assert(lex.validate_path(first)=="STONE")
	assert(lex.validate_path(second)=="PLANET")
	print("CHALLENGES VERIFIED: STONE and PLANET accepted by current English dictionary and adjacency rules")
	quit()
