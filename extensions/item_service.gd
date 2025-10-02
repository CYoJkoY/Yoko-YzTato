extends "res://singletons/item_service.gd"

# =========================== Extention =========================== #
func _get_rand_item_for_wave(wave: int, player_index: int, type: int, args: GetRandItemForWaveArgs)->ItemParentData:
	var item :ItemParentData = ._get_rand_item_for_wave(wave, player_index, type, args)
	item = _yztato_weapon_set_filter(item, player_index, type, wave, args)
	item = _yztato_weapon_set_delete(item, player_index, type, wave, args)
	item = _yztato_weapons_banned(item, player_index, type, wave, args)

	return item

func apply_item_effect_modifications(item: ItemParentData, player_index: int)->ItemParentData:
	item = .apply_item_effect_modifications(item, player_index)
	item = _yztato_force_curse_items(item, player_index)

	return item


# =========================== Custom =========================== #
func _yztato_weapon_set_filter(item: ItemParentData, player_index: int, type: int, wave: int, args: GetRandItemForWaveArgs) -> ItemParentData:
	var weapon_set_filters = RunData.get_player_effect("yztato_weapon_set_filter", player_index)
	if weapon_set_filters.size() > 0 and type == TierData.WEAPONS:
		var max_attempts = 100
		var attempts = 0
		var has_required_set = false

		while attempts < max_attempts and not has_required_set:
			for set in item.sets:
				if weapon_set_filters.has(set.my_id):
					has_required_set = true
					break
			
			if not has_required_set:
				item = ._get_rand_item_for_wave(wave, player_index, type, args)
				attempts += 1
	
	return item

func _yztato_weapon_set_delete(item: ItemParentData, player_index: int, type: int, wave: int, args: GetRandItemForWaveArgs) -> ItemParentData:
	var weapon_set_deletes = RunData.get_player_effect("yztato_weapon_set_delete", player_index)

	if weapon_set_deletes.size() > 0 and type == TierData.WEAPONS:
		var max_attempts = 100
		var attempts = 0
		var has_forbidden_set = false

		while attempts < max_attempts and not has_forbidden_set:
			for set in item.sets:
				if weapon_set_deletes.has(set.my_id):
					has_forbidden_set = true
					break

			if has_forbidden_set:
				item = ._get_rand_item_for_wave(wave, player_index, type, args)
				attempts += 1
				has_forbidden_set = false

			else:
				break

	return item

func _yztato_force_curse_items(item: ItemParentData, player_index: int) -> ItemParentData:
	var force_curse = RunData.get_player_effect("yztato_force_curse_items", player_index)
	if force_curse != 0:
		var DLCData1: DLCData = ProgressData.available_dlcs[0]
		return DLCData1.curse_item(item, player_index)
	return item

func _yztato_weapons_banned(item: ItemParentData, player_index: int, type: int, wave: int, args: GetRandItemForWaveArgs) -> ItemParentData:
	var player_character = RunData.get_player_character(player_index)
	
	if player_character.banned_items.size() > 0 and type == TierData.WEAPONS \
	and player_character.banned_items.has(item.my_id):
		var max_attempts = 100
		var attempts = 0
		var is_banned = true
		
		while attempts < max_attempts and is_banned:
			item = ._get_rand_item_for_wave(wave, player_index, type, args)
			is_banned = player_character.banned_items.has(item.my_id)
			attempts += 1
	
	return item
