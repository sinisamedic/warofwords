extends SceneTree

var failures := 0
func check(ok: bool, label: String) -> void:
	if not ok: failures+=1; push_error("FAIL: "+label)
	else: print("PASS: "+label)

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	while game.loading: await process_frame
	game.set_process(false)
	game.save.path="res://../.local/tactics-test-save.json"
	game.save.data=game.save.defaults()
	game.save.data.unlocked=11; game.save.data.tutorial=true
	game.sfx.enabled=false; game.music.set_enabled(false)
	game.mission=1
	await game.start_battle()
	game.enemy_attack(); game.advance_combat(.43)
	check(game.hp==87,"heavy enemy first attack is normal")
	check(game.next_enemy_move()=="HEAVY HIT","heavy strike announced a full turn ahead")
	game.enemy_attack()
	game.energy[1]=5; game.fire(1); game.advance_combat(.43)
	check(game.hp==82 and game.shield==0,"Aegis can counter heavy projectile in flight")
	game.mission=2; await game.start_battle()
	game.enemy_attack(); game.advance_combat(.43)
	game.foe_hp-=30
	check(game.next_enemy_move()=="HEAL","healing turn is telegraphed")
	game.energy[2]=7; game.fire(2); game.advance_combat(.43)
	check(game.enemy_attacks==2 and game.next_enemy_move()=="ATTACK","Arc cancels pending healing turn")
	var before: int=game.foe_hp
	game.enemy_attack(); game.advance_combat(.43)
	check(game.foe_hp==before,"canceled heal cannot execute on next turn")
	game.enemy_attack()
	check(game.foe_hp==before+18,"uninterrupted healer restores bounded health")
	game.mission=3; await game.start_battle()
	check(game.foe_guard,"armored enemy begins protected")
	before=game.foe_hp
	game.launch_attack(true,"pulse",game.GOLD,24); game.advance_combat(.43)
	check(game.foe_hp==before-12,"armor halves ordinary damage")
	# Exactly 28 legal tiles; six-tile word follows the first row.
	game.lex.letters.assign(Array("PLANETASTONESTREAMLINECARDSE".split("")))
	game.lex.types.assign([0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3,0,1,2,3])
	game.path.assign([0,1,2,3,4,5]); before=game.foe_hp
	game.submit_word()
	check(game.foe_guard,"long word breaks armor at impact, not launch")
	game.advance_combat(.43)
	check(not game.foe_guard and game.foe_hp==before-10,"six-tile word breaks armor and hits fully")
	game.persist_battle()
	check(game.valid_snapshot(game.save.data.battle),"new battle snapshot validates")
	game.foe_guard=true; game.restore_battle()
	check(not game.foe_guard,"broken armor stays broken after restore")
	game.overlay=""
	game.finish(true)
	check(game.breach_unlocked() and game.weapon_unlocked_now,"first boss unlocks weapon")
	var coins: int=game.save.data.coins
	game.finish(true)
	check(game.save.data.coins==coins,"result cannot award coins twice")
	game.change_screen("arsenal"); game.dispatch("weapon")
	check(game.save.data.weapon=="breach","unlocked weapon equips")
	game.mission=6; await game.start_battle()
	before=game.foe_hp; game.energy[0]=4; game.fire(0)
	game.persist_battle()
	check(game.valid_snapshot(game.save.data.battle),"Breach projectile snapshot validates")
	game.change_screen("arsenal"); game.dispatch("weapon")
	game.restore_battle(); game.overlay=""
	check(game.battle_weapon=="breach","unfinished duel retains its original weapon")
	game.advance_combat(.43)
	check(not game.foe_guard and game.foe_hp==before-18,"Breach breaks armor and deals lower full damage")
	game.save.save_game()
	var saved = game.SaveData.new(); saved.path=game.save.path; saved.load_game()
	check(saved.data.wins.has("3") and saved.data.weapon=="pulse","equipment and campaign survive disk reload")
	saved=null
	var old: Dictionary=game.save.data.battle.duplicate(true)
	old.erase("weapon"); old.erase("foe_guard"); old.projectiles=[]
	check(game.valid_snapshot(old),"old unfinished duels remain compatible")
	old.weapon="invalid"
	check(not game.valid_snapshot(old),"invalid saved weapon rejected")
	game.mission=3; await game.start_battle(); game.finish(true)
	check(not game.weapon_unlocked_now,"replaying boss does not re-award weapon")
	game.save.data=game.save.defaults(); game.change_screen("arsenal"); game.dispatch("weapon")
	check(game.save.data.get("weapon","pulse")=="pulse","locked weapon cannot equip")
	game.queue_free(); await process_frame
	# Let the audio server retire MP3 playback before the headless process exits.
	await create_timer(.5).timeout
	print("TACTICS RESULT: %d failures" % failures)
	quit(1 if failures else 0)
