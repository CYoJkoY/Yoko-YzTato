extends "res://singletons/utils.gd"

# =========================== Extention =========================== #
func is_manual_aim(player_index: int)-> bool:
    var is_manual: bool = .is_manual_aim(player_index) || false
    is_manual = _yztato_blade_storm_manual_aim(is_manual, player_index)

    return is_manual

# =========================== Custom =========================== #
func _yztato_blade_storm_manual_aim(is_manual: bool, player_index: int)-> bool:
    var blade_storm = RunData.get_player_effect("yztato_blade_storm",player_index)
    if blade_storm.size() > 0:
        return false
    return is_manual
