extends DoubleValueEffect

# =========================== Extension =========================== #
static func get_id() -> String:
	return "yztato_double_value_need_plus"

func get_args(_player_index: int) -> Array:
	var str_value: String = str(value) if value < 0 else "+" + str(value)
	var str_value2: String = str(value2) if value2 < 0 else "+" + str(value2)
	str_value2 += "% "
	
	return [str_value, tr(key.to_upper()), str_value2]
