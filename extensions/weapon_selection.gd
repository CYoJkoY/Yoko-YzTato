extends "res://ui/menus/run/weapon_selection.gd"

# =========================== Extention =========================== #
func _get_unlocked_elements(player_index: int)->Array:
	var unlocked: Array = ._get_unlocked_elements(player_index)
	unlocked = _yztato_starting_weapons_unlock(unlocked)

	return unlocked

func _get_all_possible_elements(player_index: int)->Array:
	var possible_weapons: Array = ._get_all_possible_elements(player_index)
	possible_weapons = _yztato_starting_weapons_possible(possible_weapons)

	return possible_weapons

# =========================== Custom =========================== #
func _yztato_starting_weapons_unlock(unlocked: Array) -> Array:
	if ProgressData.settings.yztato_starting_weapons:
		var all_unlocked: Array = []
		for weapon in ItemService.weapons:
			all_unlocked.push_back(weapon.my_id)
		return all_unlocked

	return unlocked

func _yztato_starting_weapons_possible(possible_weapons: Array) -> Array:
	if ProgressData.settings.yztato_starting_weapons:
		return ItemService.weapons

	return possible_weapons
