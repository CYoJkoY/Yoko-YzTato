extends NullEffect

export (float) var duration = 1.0
export (float) var scale = 1.0

# =========================== Extension =========================== #
static func get_id() -> String:
	return "yztato_leave_fire"

func apply(player_index: int)->void :
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].push_back([key, value, duration, scale])
	Utils.reset_stat_cache(player_index)

func unapply(player_index: int)->void :
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].erase([key, value, duration, scale])
	Utils.reset_stat_cache(player_index)

func get_args(_player_index) -> Array:
	return [str(duration), str(scale)]

func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized = _yztato_leave_fire_serialize(serialized)

	return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	_yztato_leave_fire_deserialize_and_merge(serialized)

# =========================== Custom =========================== #
func _yztato_leave_fire_serialize(serialized: Dictionary) -> Dictionary:
	serialized.duration = duration
	serialized.scale = scale
	return serialized

func _yztato_leave_fire_deserialize_and_merge(serialized: Dictionary) -> void:
	duration = serialized.duration as float
	scale = serialized.scale as float
