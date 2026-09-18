extends SceneTree
var g
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	if ok: print("PASS: "+label)
	else: failures+=1; push_error("FAIL: "+label)
func battle(mission: int, gold: String="ember", blue: String="bastion", green: String="siphon") -> void:
	g.save.data.loadout=[gold,blue,"arc",green]
	g.mission=mission; await g.start_battle(); g.overlay=""
func run() -> void:
	g=load("res://main.tscn").instantiate()
	g.save.path="res://../.local/wave-two-test-save.json"; root.add_child(g)
	while g.loading: await process_frame
	g.set_process(false); g.sfx.enabled=false; g.music.set_enabled(false)
	g.save.data=g.save.defaults(); g.save.data.tutorial=true; g.save.data.unlocked=23
	for i in 24: g.save.data.wins[str(i)]=3
	check(g.Campaign.NAMES.size()==24 and g.REGIONS.size()==6,"24 named encounters in six chapters")
	for i in 24:
		await battle(i)
		check(g.valid_snapshot(g.save.data.battle),"battle %d saves and validates" % (i+1))
		g.update_actors()
		check(g.enemy_actor.get_meta("encounter")==i,"enemy identity %d" % (i+1))
		if i>=12:
			check(g.enemy_actor.texture==g.EnemyArt.WAVE_TWO,"new enemy uses new illustration %d" % (i+1))
			for clock in [0.0,1.0,2.0]:
				g.clock=clock; g.update_actors()
				check(absf(g.enemy_actor.to_global(Vector2(0,g.EnemyArt.foot_offset(i))).y-g.GROUND_Y)<.1,"new enemy feet stay grounded %d" % (i+1))
		g.restore_battle(); check(g.mission==i,"new/old battle restores its mission %d" % (i+1))
	await battle(14)
	var before: int=g.foe_hp
	g.energy[0]=5; g.fire(0)
	check(g.burn_ticks==0,"Ember starts burning only on impact")
	g.advance_combat(.43)
	check(g.foe_hp==before-6 and g.burn_ticks==3 and g.foe_guard,"armor halves Ember impact but is not destroyed")
	g.advance_equipment(2)
	check(g.foe_hp==before-12 and g.burn_ticks==2,"burn tick bypasses armor")
	g.persist_battle(); g.restore_battle(); g.overlay=""
	g.advance_equipment(4)
	check(g.foe_hp==before-24 and g.burn_ticks==0,"three burn ticks survive resume and stop")
	g.energy[0]=5; g.fire(0); g.advance_combat(.43); g.advance_equipment(1)
	g.energy[0]=5; g.fire(0); g.advance_combat(.43)
	check(g.burn_ticks==3 and g.burn_time==2,"Ember refreshes one burn instead of stacking")
	g.overlay="pause"; var burn_time: float=g.burn_time; g._process(.05)
	check(g.burn_time==burn_time,"pause freezes burn")
	g.overlay=""; g.foe_hp=1; var coins: int=g.save.data.coins
	g.advance_equipment(2)
	check(g.ended and g.won and g.fx.shots.is_empty(),"burn can win and cancel other projectiles")
	var earned: int=g.save.data.coins; g.advance_equipment(10)
	check(earned>coins and earned==g.save.data.coins,"burn awards victory once")
	await battle(12,"resonator")
	g.last_tiles=9; g.energy[0]=6; g.fire(0)
	check(g.fx.shots[0].damage==48,"Resonator uses last nine-tile word")
	g.fx.clear(); g.last_tiles=3; g.energy[0]=6; g.fire(0)
	check(g.fx.shots[0].damage==18,"new short word reduces Resonator power")
	g.fx.clear(); g.last_tiles=28; g.energy[0]=6; g.fire(0)
	check(g.fx.shots[0].damage==48,"Resonator bonus capped at thirty")
	g.last_tiles=7; g.persist_battle(); g.restore_battle()
	check(g.last_tiles==7,"last accepted tile count survives resume")
	g.overlay=""; g.fx.clear(); g.energy[1]=7; g.fire(1)
	g.launch_attack(false,"enemy",g.GOLD,10); g.advance_combat(.43)
	check(g.hp==100 and g.shield==14 and g.bastion_hits==1,"Bastion keeps unused pool after first hit")
	g.persist_battle(); g.restore_battle(); g.overlay=""
	g.launch_attack(false,"enemy",g.GOLD,8); g.advance_combat(.43)
	check(g.hp==100 and g.shield==0 and g.bastion_hits==0,"second Bastion hit expires leftover pool after restore")
	g.energy[1]=7; g.fire(1); g.launch_attack(false,"enemy",g.GOLD,30); g.advance_combat(.43)
	check(g.hp==94 and g.shield==0 and g.bastion_hits==0,"single large hit can exhaust Bastion")
	await battle(14)
	g.hp=40; g.energy[3]=6; before=g.foe_hp; g.fire(3)
	check(g.hp==40 and g.foe_hp==before,"Siphon waits for projectile impact")
	g.advance_combat(.43)
	check(g.hp==45 and g.foe_hp==before-10,"armor reduces both Siphon damage and healing")
	g.foe_hp=3; g.energy[3]=6; g.fire(3); g.advance_combat(.43)
	check(g.hp==46 and g.won,"Siphon heals half actual remaining HP, excluding overkill")
	await battle(12); g.energy[3]=6; g.fire(3)
	check(g.fx.shots.size()==1,"Siphon usable at full player health")
	g.fx.clear(); g.hp=1; g.launch_attack(false,"enemy",g.GOLD,12); g.advance_combat(.43)
	check(g.ended and not g.won and g.fx.shots.is_empty(),"lethal enemy hit cannot be undone by Siphon")
	await battle(23)
	check(g.foe_guard and g.next_enemy_move()=="ATTACK","final boss starts armored with readable cycle")
	g.enemy_attacks=1; check(g.next_enemy_move()=="HEAL","final boss announces healing")
	g.energy[2]=7; g.fire(2); g.advance_combat(.43)
	check(g.next_enemy_move()=="HEAVY HIT","Arc cancels final boss heal without losing the cycle")
	for slot in [0,1,3]:
		g.change_screen("arsenal"); g.dispatch("gear_slot",slot)
		g.dispatch("gear_view",g.Equipment.SLOTS[slot].size()-1); g.dispatch("gear_equip")
		check(g.save.data.loadout[slot]==g.Equipment.SLOTS[slot].back(),"new item reachable via Arsenal input %d" % slot)
	g.save.data=g.save.defaults(); g.save.data.wins={"11":3}; g.save.data.unlocked=11; g.save.save_game(); g.save.load_game()
	check(g.save.data.unlocked==12 and g.save.data.wins.has("11"),"old completed campaign opens level thirteen without losing wins")
	g.change_screen("campaign"); g.settle_campaign(5)
	check(g.chapter==3,"locked chapters cannot be skipped")
	for entry in [[12,"ember"],[14,"bastion"],[16,"resonator"],[19,"siphon"]]:
		g.save.data.wins={}; g.save.data.unlocked=entry[0]; g.save.data.tutorial=true
		g.mission=entry[0]; await g.start_battle()
		check(not g.Equipment.unlocked(entry[1],g.save.data),"new reward starts locked: "+entry[1])
		g.finish(true)
		check(entry[1] in g.save.data.pending_unlocks and g.Equipment.unlocked(entry[1],g.save.data),"victory unlocks and announces "+entry[1])
	g.save.data.unlocked=23; g.mission=23; await g.start_battle(); g.finish(true)
	check(g.save.data.unlocked==23,"final victory never opens nonexistent level 25")
	g.dispatch("next"); check(g.mission==23,"final replay stays on level 24")
	g.queue_free(); await process_frame; await create_timer(.5).timeout
	print("WAVE TWO RESULT: %d failures" % failures); quit(1 if failures else 0)
