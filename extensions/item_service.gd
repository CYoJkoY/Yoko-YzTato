extends "res://singletons/item_service.gd"

# Apply set constraints to the real tier pool once. Repeated random draws can
# never finish when vanilla bans/type restrictions exclude every matching item.
func update_pools(pool: Array, backup_pool: Array, player_index: int, item_tier: int, type: int) -> void:
    .update_pools(pool, backup_pool, player_index, item_tier, type)
    if type != TierData.WEAPONS:
        return
    var required: Array = RunData.get_player_effect(Utils.yztato_weapon_set_filter_hash, player_index)
    var forbidden: Array = RunData.get_player_effect(Utils.yztato_weapon_set_delete_hash, player_index)
    if required.empty() and forbidden.empty():
        return
    _yztato_filter_weapon_pool(pool, required, forbidden)
    _yztato_filter_weapon_pool(backup_pool, required, forbidden)

func _yztato_filter_weapon_pool(pool: Array, required: Array, forbidden: Array) -> void:
    var allowed: Array = []
    for weapon in pool:
        var matches: bool = required.empty()
        var excluded: bool = false
        for weapon_set in weapon.sets:
            matches = matches or required.has(weapon_set.my_id_hash)
            excluded = excluded or forbidden.has(weapon_set.my_id_hash)
        if matches and not excluded:
            allowed.append(weapon)
    # Preserve vanilla's fallback when the constraints cannot be satisfied.
    if not allowed.empty():
        pool.clear()
        pool.append_array(allowed)
