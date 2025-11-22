extends Effect

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_melee_bounce"
    
func get_args(_player_index: int) -> Array:
    var args: Array = .get_args(_player_index)
    var col_pos: String = "[color=#" + ProgressData.settings.color_positive + "]"
    var col_neg: String = "[color=#" + ProgressData.settings.color_negative + "]"
    args.push_back(col_pos)
    args.push_back(col_neg)
    
    return args
