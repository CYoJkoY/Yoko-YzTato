extends "res://singletons/weapon_service.gd"

# =========================== Extention =========================== #
func _apply_weapon_scaling_stat_effects(scaling_stats: Array, player_index: int) -> Array:
    var new_stats: Array = ._apply_weapon_scaling_stat_effects(scaling_stats, player_index)
    new_stats = _yztato_scaling_damage(new_stats, player_index)

    return new_stats

# =========================== Custom =========================== #
func _yztato_scaling_damage(new_stats: Array, player_index: int) -> Array:
    var damage_scaling_effects: Array = RunData.get_player_effect(Utils.yztato_damage_scaling_hash, player_index)
    if not damage_scaling_effects.empty():
        for effect in damage_scaling_effects:
            var stat: float = Utils.get_stat(effect[0], player_index)
            var value: float = effect[1]
            var scaling_stats: Array = effect[2]
            var num: float = stat / value
            
            var new_scaling_stats = new_stats.duplicate(true)
            for scaling_stat in scaling_stats:
                var scaling_stat_hash: int = scaling_stat[0]
                var scaling_stat_value: float = scaling_stat[1]
                var existing_scaling_stat = find_scaling_stat(scaling_stat_hash, new_scaling_stats)
                if existing_scaling_stat != null:
                    existing_scaling_stat[1] += scaling_stat_value * num
                else :
                    new_scaling_stats.push_back([scaling_stat_hash, scaling_stat_value * num])
            return new_scaling_stats
    return new_stats
