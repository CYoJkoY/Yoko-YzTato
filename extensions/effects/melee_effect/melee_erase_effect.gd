extends Effect

# =========================== Extension =========================== #
static func get_id() -> String:
	return "yztato_melee_erase"

func apply(player_index: int) -> void:
	if key == "": 
		Utils.reset_stat_cache(player_index)
		return
	.apply(player_index)
	
func unapply(player_index: int) -> void:
	if key == "": 
		Utils.reset_stat_cache(player_index)
		return
	.unapply(player_index)
