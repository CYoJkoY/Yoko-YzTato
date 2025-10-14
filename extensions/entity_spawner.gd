extends "res://global/entity_spawner.gd"

# EFFECT : gain_stat_when_killed_single_scaling
var kill_count: Dictionary = {}
var effect_single_kill_count: Dictionary = {}

# EFFECT : gain_random_primary_stat
var primary_stats: Array = [
	"stat_max_hp", "stat_hp_regeneration", "stat_lifesteal", "stat_percent_damage",
	"stat_melee_damage", "stat_ranged_damage", "stat_elemental_damage", "stat_attack_speed",
	"stat_crit_chance", "stat_engineering", "stat_range", "stat_armor", "stat_dodge",
	"stat_speed", "stat_luck", "stat_harvesting"
	]
var kill_count_2: Dictionary = {}

### hellfire ###
var enemies_killed_is_burning: int = 0

# =========================== Extention =========================== #
func _on_enemy_died(enemy: Node2D, _args: Entity.DieArgs)->void :
	_yztato_gain_stat_when_killed_single_scaling_on_enemy_died()
	_yztato_blood_rage_on_enemy_died()
	_yztato_gain_random_primary_stat_on_enemy_died()
	_yztato_chal_on_enemy_died(enemy)
	._on_enemy_died(enemy, _args)

func on_enemy_charmed(enemy: Entity)->void :
	.on_enemy_charmed(enemy)
	_yztato_chal_on_enemy_charmed(charmed_enemies)

# =========================== Custom =========================== #
func _yztato_gain_stat_when_killed_single_scaling_on_enemy_died()-> void:
	for player_index in RunData.players_data.size():
		var current_kill_count = kill_count.get(player_index, 0) + 1
		kill_count[player_index] = current_kill_count

		var gain_stat_when_killed_single_scaling: Array = RunData.get_player_effect("yztato_gain_stat_when_killed_single_scaling", player_index)
		
		if !gain_stat_when_killed_single_scaling.empty():
			var stats_updated: bool = false
			
			# key, value, stat, stat_nb, scaling_stat, scaling_percent
			for effect_index in gain_stat_when_killed_single_scaling.size():
				var effect = gain_stat_when_killed_single_scaling[effect_index]

				if effect[0] == "all":
					var initial_count = current_kill_count - 1
					var current_effect_count = effect_single_kill_count.get(effect_index, initial_count) + 1
					effect_single_kill_count[effect_index] = current_effect_count

					var scaling_value = effect[1] + Utils.get_stat(effect[4], player_index) * effect[5]
					
					if scaling_value > 0 and current_effect_count % int(scaling_value) == 0:
						effect_single_kill_count[effect_index] = 0
						RunData.add_stat(effect[2], effect[3], player_index)
						stats_updated = true
						
			if stats_updated:
				RunData.emit_signal("stats_updated", player_index)

func _yztato_blood_rage_on_enemy_died()-> void:
	for player_index in RunData.players_data.size():
		if _players[player_index] and is_instance_valid(_players[player_index]):
			_players[player_index].on_enemy_killed_reset_blood_rage()

func _yztato_gain_random_primary_stat_on_enemy_died()-> void:
	for player_index in RunData.players_data.size():
		var current_kill_count_2: int = kill_count_2.get(player_index, 0) + 1
		kill_count_2[player_index] = current_kill_count_2

		var gain_random_primary_stat_when_killed = RunData.get_player_effect("yztato_gain_random_primary_stat_when_killed", player_index)
		if gain_random_primary_stat_when_killed.empty(): return

		for effect_index in gain_random_primary_stat_when_killed.size():
			var effect = gain_random_primary_stat_when_killed[effect_index]
			var stat_num: int = effect[0]
			var enemy_num: int = effect[1]
			if current_kill_count_2 % enemy_num == 0:
				var random_stat = primary_stats[randi() % primary_stats.size()]
				RunData.add_stat(random_stat, stat_num, player_index)
				RunData.emit_signal("stats_updated", player_index)

func _yztato_chal_on_enemy_charmed(charmed_enemies: Array)-> void:
	### dark_forest_rule ###
	print(charmed_enemies.size())
	ChallengeService.try_complete_challenge("chal_dark_forest_rule", charmed_enemies.size())

func _yztato_chal_on_enemy_died(enemy: Entity)-> void:
	### hellfire ###
	if enemy._is_burning: enemies_killed_is_burning += 1
	ChallengeService.try_complete_challenge("chal_hellfire", enemies_killed_is_burning)
