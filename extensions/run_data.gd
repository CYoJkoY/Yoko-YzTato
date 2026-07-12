extends "res://singletons/run_data.gd"

# =========================== Extension =========================== #
func manage_life_steal(weapon_stats: WeaponStats, player_index: int) -> void:
    if _yztato_life_steal(weapon_stats, player_index): return

    .manage_life_steal(weapon_stats, player_index)

func update_item_related_effects(player_index: int) -> void:
    _yztato_update_specific_tag_item_bonuses(player_index)
    .update_item_related_effects(player_index)

# =========================== Custom =========================== #
func _yztato_life_steal(weapon_stats: WeaponStats, player_index: int) -> bool:
    var life_steal: int = RunData.get_player_effect(Utils.yztato_life_steal_hash, player_index)
    if life_steal == 0: return false

    var true_lifesteal: float = max(weapon_stats.damage * (life_steal / 100), 1.0)
    if Utils.get_chance_success(weapon_stats.lifesteal):
        emit_signal("lifesteal_effect", true_lifesteal, player_index)

    return true

func _yztato_update_specific_tag_item_bonuses(player_index: int) -> void:
    var effects: Dictionary = get_player_effects(player_index)
    var old_specific_tag_item_bonuses: Dictionary = effects[Utils.yztato_old_specific_tag_item_bonuses_hash]

    for stat_hash in old_specific_tag_item_bonuses:
        assert(stat_hash is int)
        effects[stat_hash] -= old_specific_tag_item_bonuses[stat_hash]

    old_specific_tag_item_bonuses.clear()

    var items: Array = get_player_items_ref(player_index)
    var specific_tag_item_bonuses: Dictionary = {}
    for item in items: for tag in item.tags:
        specific_tag_item_bonuses[tag] = specific_tag_item_bonuses.get(tag, 0) + 1
    
    for effect in effects[Utils.yztato_specific_tag_item_bonuses_hash]:
        var tag: String = effect[2]
        var tag_count: int = specific_tag_item_bonuses.get(tag, 0)
        if tag_count == 0: continue

        var stat: int = effect[0]
        var stat_value: int = effect[1]
        var nb_scaled: int = effect[3]
        var bonus: int = stat_value * tag_count / nb_scaled
        if bonus == 0: continue

        old_specific_tag_item_bonuses[stat] = old_specific_tag_item_bonuses.get(stat, 0) + bonus
        effects[stat] += bonus
