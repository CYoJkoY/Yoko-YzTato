extends "res://ui/menus/run/character_selection.gd"

# =========================== Extention =========================== #
func _get_unlocked_elements(player_index: int)->Array:
	var unlocked: Array = ._get_unlocked_elements(player_index)
	unlocked = _yztato_unlock_all_chars(unlocked, player_index)
	
	return unlocked

func _on_selections_completed()->void :
	_yztato_on_selections_completed()

# =========================== Custom =========================== #
func _yztato_unlock_all_chars(unlocked: Array, player_index: int) -> Array:
	if ProgressData.settings.yztato_unlock_all_chars:
		var all_unlocked: = []
		for element in _get_all_possible_elements(player_index):
			all_unlocked.push_back(element.my_id)
		return all_unlocked

	return unlocked

func _yztato_on_selections_completed() -> void:
	if ProgressData.settings.yztato_starting_items:
		for player_index in RunData.get_player_count():
			var character = _player_characters[player_index]
			RunData.add_character(character, player_index)

		_change_scene(MenuData.item_selection_scene)

	else:
		for player_index in RunData.get_player_count():
			var character = _player_characters[player_index]
			RunData.add_character(character, player_index)

		if RunData.some_player_has_weapon_slots():
			_change_scene(MenuData.weapon_selection_scene)
		else :
			_change_scene(MenuData.difficulty_selection_scene)
