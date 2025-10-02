extends Effect

# =========================== Extension =========================== #
static func get_id() -> String:
	return "yztato_value_need_plus"

func get_args(_player_index: int) -> Array:
	var str_value: String = str(value) if value < 0 else "+" + str(value)
	
	return [str_value, tr(key.to_upper())]
