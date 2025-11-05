extends NullEffect

export (int) var damage_percent: int = 50

# =========================== Extension =========================== #
static func get_id()-> String:
	return "yztato_multi_hit"

func apply(player_index: int) -> void:
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].push_back([value, damage_percent])
	Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].erase([value, damage_percent])
	Utils.reset_stat_cache(player_index)

func get_args(_player_index: int) -> Array:
	return [str(value), str(damage_percent)]

func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized = _yztato_multi_hit_serialize(serialized)
	
	return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	_yztato_multi_hit_deserialize_and_merge(serialized)

# =========================== Custom =========================== #
func _yztato_multi_hit_serialize(serialized: Dictionary) -> Dictionary:
	serialized.damage_percent = damage_percent
	return serialized

func _yztato_multi_hit_deserialize_and_merge(serialized: Dictionary) -> void:
	damage_percent = serialized.damage_percent as int
