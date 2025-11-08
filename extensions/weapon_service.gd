extends "res://singletons/weapon_service.gd"

# =========================== Extention =========================== #
func init_melee_stats(from_stats:MeleeWeaponStats, player_index:int, args: = WeaponServiceInitStatsArgs.new())->MeleeWeaponStats:
	var new_stats = .init_melee_stats(from_stats, player_index, args)
	new_stats = _yztato_crit_damage(new_stats)

	return new_stats

func init_ranged_stats(from_stats:RangedWeaponStats, player_index:int, is_special_spawn: = false, args: = WeaponServiceInitStatsArgs.new())->RangedWeaponStats:
	var new_stats = .init_ranged_stats(from_stats, player_index, is_special_spawn, args)
	new_stats = _yztato_crit_damage(new_stats)

	return new_stats

func _apply_weapon_scaling_stat_effects(scaling_stats: Array, player_index: int) -> Array:
	var new_stats: Array = ._apply_weapon_scaling_stat_effects(scaling_stats, player_index)
	new_stats = _yztato_scaling_damage(new_stats, player_index)

	return new_stats

# =========================== Custom =========================== #
func _yztato_crit_damage(new_stats: WeaponStats)-> WeaponStats:
	for player_index in RunData.players_data.size():
		var crit_damage = RunData.get_player_effect("yztato_crit_damage",player_index)
		if crit_damage != 0:
			new_stats.crit_damage += crit_damage / 100.0
	return new_stats

func _yztato_scaling_damage(new_stats: Array, player_index: int) -> Array:
	var damage_scaling_effects: Array = RunData.get_player_effect("yztato_damage_scaling", player_index)
	# stat, value, scaling stats
	if !damage_scaling_effects.empty():
		for effect in damage_scaling_effects:
			var stat: float = Utils.get_stat(effect[0], player_index)
			var value: float = effect[1]
			var scaling_stats: Array = effect[2]
			var num: float = stat / value
			
			var new_scaling_stats = new_stats.duplicate(true)
			for scaling_stat in scaling_stats:
				var scaling_stat_name: String = scaling_stat[0]
				var scaling_stat_value: float = scaling_stat[1]
				var existing_scaling_stat = find_scaling_stat(scaling_stat_name, new_scaling_stats)
				if existing_scaling_stat != null:
					existing_scaling_stat[1] += scaling_stat_value * num
				else :
					new_scaling_stats.push_back([scaling_stat_name, scaling_stat_value * num])
			return new_scaling_stats
	return new_stats
