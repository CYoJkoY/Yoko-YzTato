extends "res://singletons/item_service.gd"

# =========================== Extention =========================== #
func _get_rand_item_for_wave(wave: int, player_index: int, type: int, args: GetRandItemForWaveArgs)->ItemParentData:
    var item :ItemParentData = ._get_rand_item_for_wave(wave, player_index, type, args)
    item = _yztato_weapon_set_filter(item, player_index, type, wave, args)
    item = _yztato_weapon_set_delete(item, player_index, type, wave, args)

    return item


# =========================== Custom =========================== #
func _yztato_weapon_set_filter(item: ItemParentData, player_index: int, type: int, wave: int, args: GetRandItemForWaveArgs) -> ItemParentData:
    var weapon_set_filters: Array = RunData.get_player_effect(Utils.yztato_weapon_set_filter_hash, player_index)
    if weapon_set_filters.empty() or type != TierData.WEAPONS: return item

    # Check Weapon Match Set
    var pool = get_pool(get_tier_from_wave(wave, player_index), type)
    var has_valid_weapons = false
    for pool_item in pool:
        for set in pool_item.sets:
            if weapon_set_filters.has(set.my_id_hash):
                has_valid_weapons = true
                break
        if has_valid_weapons: break
    
    # Filter Until Required Set
    if has_valid_weapons:
        var has_required_set = false
        while !has_required_set:
            for set in item.sets:
                if weapon_set_filters.has(set.my_id_hash):
                    has_required_set = true
                    break
            
            if !has_required_set: item = ._get_rand_item_for_wave(wave, player_index, type, args)
    
    return item

func _yztato_weapon_set_delete(item: ItemParentData, player_index: int, type: int, wave: int, args: GetRandItemForWaveArgs) -> ItemParentData:
    var weapon_set_deletes: Array = RunData.get_player_effect(Utils.yztato_weapon_set_delete_hash, player_index)
    if weapon_set_deletes.empty() or type != TierData.WEAPONS: return item

    # Check Weapon No Forbidden Set
    var pool = get_pool(get_tier_from_wave(wave, player_index), type)
    var has_valid_weapons = false
    for pool_item in pool:
        var has_forbidden_set = false
        for set in pool_item.sets:
            if weapon_set_deletes.has(set.my_id_hash):
                has_forbidden_set = true
                break
        if !has_forbidden_set:
            has_valid_weapons = true
            break

    # Filter Until No Forbidden Set
    if has_valid_weapons:
        var has_forbidden_set = false
        while not has_forbidden_set:
            for set in item.sets:
                if weapon_set_deletes.has(set.my_id_hash):
                    has_forbidden_set = true
                    break

            if has_forbidden_set:
                item = ._get_rand_item_for_wave(wave, player_index, type, args)
                has_forbidden_set = false
            else: break

    return item
