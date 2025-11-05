extends NullEffect

static func get_id() -> String:
	return "yztato_upgrade_when_killed_enemies"

func get_args(_player_index: int) -> Array:
	var displayed_key = key

	if custom_key == "starting_weapon":
		displayed_key = key.substr(0, key.length() - 2)

	return [str(value), tr(displayed_key.to_upper())]


func serialize() -> Dictionary:

	var custom_args_serialized = []

	for custom_arg in custom_args:
		custom_args_serialized.push_back(custom_arg.serialize())

	return {
		"effect_id": get_id(),
		"key": key,
		"custom_key": custom_key,
		"text_key": text_key,
		"storage_method": storage_method,
		"value": str(value),
		"effect_sign": effect_sign,
		"base_value": base_value,
		"curse_factor": curse_factor,
		"custom_args": custom_args_serialized
	}


func deserialize_and_merge(effect: Dictionary) -> void:
	key = effect.key
	custom_key = effect.custom_key
	text_key = effect.text_key
	value = effect.value as int
	effect_sign = effect.effect_sign as int
	storage_method = effect.storage_method as int
	base_value = effect.base_value
	curse_factor = effect.curse_factor if "curse_factor" in effect else 0.0

	if "custom_args" in effect:
		var deserialized_custom_args = []
		for serialized_custom_arg in effect.custom_args:
			var deserialized_custom_arg = CustomArg.new()
			deserialized_custom_arg.deserialize_and_merge(serialized_custom_arg)
			deserialized_custom_args.push_back(deserialized_custom_arg)
		custom_args = deserialized_custom_args
