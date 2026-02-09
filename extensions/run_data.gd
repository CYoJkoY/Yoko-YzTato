extends "res://singletons/run_data.gd"

# =========================== Extension =========================== #
func manage_life_steal(weapon_stats: WeaponStats, player_index: int) -> void:
    if _yztato_life_steal(weapon_stats, player_index): return
    .manage_life_steal(weapon_stats, player_index)

# =========================== Custom =========================== #
func _yztato_life_steal(weapon_stats: WeaponStats, player_index: int) -> bool:
    var life_steal: int = RunData.get_player_effect(Utils.yztato_life_steal_hash, player_index)
    if life_steal == 0: return false

    var true_lifesteal: float = max(weapon_stats.damage * (life_steal / 100), 1.0)
    if Utils.get_chance_success(weapon_stats.lifesteal):
        emit_signal("lifesteal_effect", true_lifesteal, player_index)
    return true
