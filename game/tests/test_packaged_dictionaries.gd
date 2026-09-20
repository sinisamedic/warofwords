extends SceneTree
const Lex = preload("res://scripts/lexicon.gd")
var failures := 0

func check(ok: bool, message: String) -> void:
	print(("PASS " if ok else "FAIL ") + message)
	if not ok: failures += 1

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1:
		push_error("Pass directory extracted from APK after --")
		quit(1)
		return
	for code in ["en", "de", "fr", "es", "it", "sr"]:
		var source = Lex.new(true, code)
		var packaged = Lex.new(false, code)
		packaged.load_dictionary(args[0])
		check(packaged.words.size() > 50000, code + " packaged full dictionary")
		check(packaged.words == source.words, code + " every packaged word matches source")
		packaged.generate()
		check(not packaged.solutions.is_empty(), code + " packaged board playable")
		if not packaged.solutions.is_empty():
			var word: String = packaged.solutions.keys()[0]
			var route: Array[int] = []
			route.assign(packaged.solutions[word])
			check(packaged.validate_path(route) == word, code + " packaged player word accepted")
	quit(1 if failures else 0)
