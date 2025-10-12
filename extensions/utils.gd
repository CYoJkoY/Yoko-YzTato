extends "res://singletons/utils.gd"

# =========================== Extention =========================== #
func is_manual_aim(player_index: int)-> bool:
	var Adjust = .is_manual_aim(player_index)
	Adjust = _yztato_blade_storm_manual_aim(Adjust,player_index)

	return Adjust

# =========================== Custom =========================== #
func _yztato_blade_storm_manual_aim(Adjust: bool, player_index: int)-> bool:
	var blade_storm = RunData.get_player_effect("yztato_blade_storm",player_index)
	if blade_storm.size() > 0:
		return false
	return Adjust
