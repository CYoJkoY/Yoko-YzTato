extends Effect

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_melee_bounce"
    
func get_args(_player_index: int) -> Array:
    var args: Array =.get_args(_player_index)
    var col_pos: String = "[color=#" + ProgressData.settings.color_positive + "]"
    
    args.append(col_pos)
    
    return args
