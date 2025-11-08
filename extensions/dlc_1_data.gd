extends "res://dlcs/dlc_1/dlc_1_data.gd"

# =========================== Extension =========================== #
func curse_item(item_data: ItemParentData, player_index: int, turn_randomization_off: bool = false, min_modifier: float = 0.0)->ItemParentData:
	if yz_has_yztato_effect(item_data.effects):
		return _yztato_curse_item(item_data, player_index, turn_randomization_off, min_modifier)
	else:
		return .curse_item(item_data, player_index, turn_randomization_off, min_modifier)
	
# =========================== Custom =========================== #
func _yztato_curse_item(item_data: ItemParentData, _player_index: int, turn_randomization_off: bool = false, min_modifier: float = 0.0)->ItemParentData:
	if item_data.is_cursed:
		return item_data

	var new_effects: = []
	var max_effect_modifier = 0.0
	var curse_effect_modified: = false
	var new_item_data = item_data.duplicate()

	if item_data is WeaponData:
		var effect_modifier: = _get_cursed_item_effect_modifier(turn_randomization_off, min_modifier)
		max_effect_modifier = max(max_effect_modifier, effect_modifier)
		new_item_data.stats = _boost_weapon_stats_damage(item_data.stats, effect_modifier)

	for effect in item_data.effects:
		var effect_modifier: = _get_cursed_item_effect_modifier(turn_randomization_off, min_modifier)
		max_effect_modifier = max(max_effect_modifier, effect_modifier)

		var new_effect = effect.duplicate()

		match new_effect.get_id():
			"yztato_boomerang_weapon":
				print(new_effect.get_id() + " OK")
				new_effect.min_damage_mul = _curse_effect_value(new_effect.min_damage_mul, effect_modifier)
				new_effect.max_damage_mul = _curse_effect_value(new_effect.max_damage_mul, effect_modifier)
			
			"yztato_damage_scaling":
				print(new_effect.get_id() + " OK")
				var new_scaling_stats: Array = []
				for scaling in new_effect.scaling_stats:
					scaling[1] = _curse_effect_value(scaling[1], effect_modifier, {"process_negative": false})
					new_scaling_stats.append(scaling)
				new_effect.scaling_stats = new_scaling_stats
			
			"yztato_gain_random_primary_stat_when_killed":
				print(new_effect.get_id() + " OK")
				new_effect.need_num = _curse_effect_value(new_effect.need_num, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})

			"yztato_gain_stat_when_killed_single_scaling":
				print(new_effect.get_id() + " OK")
				new_effect.scaling_percent = _curse_effect_value(new_effect.scaling_percent, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})
				new_effect.value = _curse_effect_value(new_effect.value, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})

			"yztato_multi_hit":
				print(new_effect.get_id() + " OK")
				new_effect.value = _curse_effect_value(new_effect.value, effect_modifier, {"process_negative": false})
				new_effect.damage_percent = _curse_effect_value(new_effect.damage_percent, effect_modifier, {"process_negative": false})

			"yztato_random_primary_stat_over_time":
				print(new_effect.get_id() + " OK")
				new_effect.value = _curse_effect_value(new_effect.value, effect_modifier, {"process_negative": false})
				new_effect.interval = _curse_effect_value(new_effect.interval, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})

			"yztato_special_picked_up_change_stat":
				print(new_effect.get_id() + " OK")
				new_effect.value = _curse_effect_value(new_effect.value, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})
			
			"yztato_temp_stats_per_interval":
				print(new_effect.get_id() + " OK")
				new_effect.value = _curse_effect_value(new_effect.value, effect_modifier, {"process_negative": false, "has_min": true, "min_num": new_effect.value + 1})

			"yztato_upgrade_when_killed_enemies":
				print(new_effect.get_id() + " OK")
				new_effect.value = _curse_effect_value(new_effect.value, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})
				
			"yztato_vine_trap":
				print(new_effect.get_id() + " OK")
				new_effect.trap_count = _curse_effect_value(new_effect.trap_count, effect_modifier, {"process_negative": false})
				new_effect.chance = _curse_effect_value(new_effect.chance, effect_modifier, {"process_negative": false})
				
			_: new_effect = yz_process_other_effect(new_effect, effect_modifier)

		new_effects.append(new_effect)

	if not curse_effect_modified:
		var curse_effect = Effect.new()
		curse_effect.key = "stat_curse"
		curse_effect.value = round(max(1.0, curse_per_item_value * item_data.value * (1.0 + max_effect_modifier))) as int
		curse_effect.effect_sign = Sign.OVERRIDE
		new_effects.append(curse_effect)

	new_item_data.effects = new_effects
	new_item_data.is_cursed = true

	new_item_data.curse_factor = max_effect_modifier

	return new_item_data as ItemParentData

func yz_process_other_effect(effect: Resource, modifier: float):
	match effect.key:
		"yztato_damage_against_not_boss", \
		"yztato_random_primary_stat_on_hit":
			print(effect.key + " OK")
			effect.value = _curse_effect_value(effect.value, modifier)
			return effect

		"yztato_heal_on_damage_taken", \
		"yztato_random_curse_on_reroll":
			print(effect.key + " OK")
			effect.value = _curse_effect_value(effect.value, modifier, {"process_negative": false})
			effect.value2 = _curse_effect_value(effect.value, modifier, {"step": 1, "process_negative": false})
			return effect

	match effect.custom_key:
		"yztato_stat_on_hit":
			print(effect.custom_key + " OK")
			effect.value = _curse_effect_value(effect.value, modifier)
			return effect
		"yztato_stats_chance_on_level_up":
			print(effect.custom_key + " OK")
			effect.value = _curse_effect_value(effect.value, modifier)
			effect.value2 = _curse_effect_value(effect.value, modifier, {"step": 1, "process_negative": false})
			return effect
	
	effect.value = _curse_effect_value(effect.value, modifier, {"process_negative": false})
	return effect

# =========================== Method =========================== #
func yz_has_yztato_effect(effects: Array) -> bool:
	for effect in effects:
		if effect.get_id().begins_with("yztato") or \
		effect.key.begins_with("yztato") or \
		effect.custom_key.begins_with("yztato"):
			return true
	return false

func _curse_effect_value(
	value: float, modifier: float, options: Dictionary = {}
) -> float:
	
	var step: float = options.get("step", 0.01)
	var process_negative: bool = options.get("process_negative", true)
	var is_negative: bool = options.get("is_negative", false)
	var has_min: bool = options.get("has_min", false)
	var min_num: float = options.get("min_num", 0.0)
	var has_max: bool = options.get("has_max", false)
	var max_num: float = options.get("max_num", 0.0)

	match is_negative or (process_negative and value < 0.0):
		true:
			print("Negative")
			value = stepify(value / (1.0 + modifier), step)
		false:
			print("Positive")
			value = stepify(value * (1.0 + modifier), step)

	if has_min: value = max(value, min_num)
	if has_max: value = min(value, max_num)

	return value
