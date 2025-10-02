extends "res://ui/menus/run/character_selection.gd"

# =========================== Extention =========================== #
func _get_unlocked_elements(player_index: int)->Array:
	var unlocked: Array = ._get_unlocked_elements(player_index)
	unlocked = _yztato_unlock_all_chars(unlocked, player_index)
	
	return unlocked

# =========================== Custom =========================== #
func _yztato_unlock_all_chars(unlocked: Array, player_index: int) -> Array:
	if ProgressData.settings.yztato_unlock_all_chars:
		var all_unlocked: = []
		for element in _get_all_possible_elements(player_index):
			all_unlocked.push_back(element.my_id)
		return all_unlocked

	return unlocked
