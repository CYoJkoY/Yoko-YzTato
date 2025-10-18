extends "res://singletons/run_data.gd"



# =========================== Extention =========================== #
func _init() -> void:
	init_tracked_items = init_tracked_effects()

func _ready():
	_yztato_unlock_all_challenges()

func manage_life_steal(weapon_stats:WeaponStats, player_index:int)->void :
	if _yztato_life_steal(weapon_stats, player_index): return
	.manage_life_steal(weapon_stats, player_index)

func init_tracked_effects()->Dictionary:
	var vanilla_tracked: Dictionary = .init_tracked_effects()

	var new_tracked: Dictionary = {
		
		"item_yztato_cursed_box": [0, 0],

	}

	new_tracked.merge(vanilla_tracked)

	return new_tracked


# =========================== Custom =========================== #
func _yztato_life_steal(weapon_stats:WeaponStats, player_index:int)-> bool:
	var life_steal = RunData.get_player_effect("yztato_life_steal",player_index)
	if life_steal.size() > 0 :
		for steal in life_steal :
			if steal[0] == "better":
				var weapon_lifesteal_chance : float = weapon_stats.lifesteal
				var true_lifesteal : float = max(weapon_lifesteal_chance, 1.0)
				if randf() < weapon_stats.lifesteal:
					emit_signal("lifesteal_effect", true_lifesteal, player_index)

			elif steal[0] == "val":
				var true_lifesteal : float = max(weapon_stats.damage * (steal[1] / 100), 1.0)
				if randf() < weapon_stats.lifesteal:
					emit_signal("lifesteal_effect", true_lifesteal, player_index)
		return true
	return false

func _yztato_unlock_all_challenges() -> void:
	if ProgressData.settings.yztato_unlock_all_challenges:
		for chal in ChallengeService.challenges:
			ChallengeService.complete_challenge(chal.my_id)
