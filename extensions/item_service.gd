extends "res://singletons/item_service.gd"

# =========================== Extention =========================== #
func _get_rand_item_for_wave(wave: int, player_index: int, type: int, args: GetRandItemForWaveArgs)->ItemParentData:
	var item :ItemParentData = ._get_rand_item_for_wave(wave, player_index, type, args)
	item = _yztato_weapon_set_filter(item, player_index, type, wave, args)
	item = _yztato_weapon_set_delete(item, player_index, type, wave, args)
	item = _yztato_weapons_banned(item, player_index, type, wave, args)
	item = _yztato_force_curse_items(item, player_index)

	return item


# =========================== Custom =========================== #
func _yztato_weapon_set_filter(item: ItemParentData, player_index: int, type: int, wave: int, args: GetRandItemForWaveArgs) -> ItemParentData:
	var weapon_set_filters = RunData.get_player_effect("yztato_weapon_set_filter", player_index)
	if weapon_set_filters.size() == 0 or type != TierData.WEAPONS: return item

	# Check Weapon Match Set
	var pool = get_pool(get_tier_from_wave(wave, player_index), type)
	var has_valid_weapons = false
	for pool_item in pool:
		for set in pool_item.sets:
			if weapon_set_filters.has(set.my_id):
				has_valid_weapons = true
				break
		if has_valid_weapons: break
	
	# Filter Until Required Set
	if has_valid_weapons:
		var has_required_set = false
		while !has_required_set:
			for set in item.sets:
				if weapon_set_filters.has(set.my_id):
					has_required_set = true
					break
			
			if !has_required_set: item = ._get_rand_item_for_wave(wave, player_index, type, args)
	
	return item

func _yztato_weapon_set_delete(item: ItemParentData, player_index: int, type: int, wave: int, args: GetRandItemForWaveArgs) -> ItemParentData:
	var weapon_set_deletes = RunData.get_player_effect("yztato_weapon_set_delete", player_index)
	if weapon_set_deletes.size() == 0 or type != TierData.WEAPONS: return item

	# Check Weapon No Forbidden Set
	var pool = get_pool(get_tier_from_wave(wave, player_index), type)
	var has_valid_weapons = false
	for pool_item in pool:
		var has_forbidden_set = false
		for set in pool_item.sets:
			if weapon_set_deletes.has(set.my_id):
				has_forbidden_set = true
				break
		if not has_forbidden_set:
			has_valid_weapons = true
			break

	# Filter Until No Forbidden Set
	if has_valid_weapons:
		var has_forbidden_set = false
		while not has_forbidden_set:
			for set in item.sets:
				if weapon_set_deletes.has(set.my_id):
					has_forbidden_set = true
					break

			if has_forbidden_set:
				item = ._get_rand_item_for_wave(wave, player_index, type, args)
				has_forbidden_set = false
			else: break

	return item

func _yztato_weapons_banned(item: ItemParentData, player_index: int, type: int, wave: int, args: GetRandItemForWaveArgs) -> ItemParentData:
	var player_character = RunData.get_player_character(player_index)
	
	if player_character.banned_items.size() == 0 or type != TierData.WEAPONS: return item
		
	if not player_character.banned_items.has(item.weapon_id): return item

	# Check Weapon Not Banned
	var pool = get_pool(get_tier_from_wave(wave, player_index), type)
	var has_valid_weapons = false
	for pool_item in pool:
		if not player_character.banned_items.has(pool_item.weapon_id):
			has_valid_weapons = true
			break
			
	# Filter Until Not banned
	if has_valid_weapons:
		while player_character.banned_items.has(item.weapon_id):
			item = ._get_rand_item_for_wave(wave, player_index, type, args)
	
	return item

func _yztato_force_curse_items(item: ItemParentData, player_index: int) -> ItemParentData:
	var force_curse = RunData.get_player_effect("yztato_force_curse_items", player_index)
	if item in characters: return item
	if force_curse == 0 or item.is_cursed: return item
	
	var DLCData1: DLCData = ProgressData.available_dlcs[0]
	return DLCData1.curse_item(item, player_index)
