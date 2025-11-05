extends NullEffect

export (int) var interval: int = 1

# =========================== Extention =========================== #
static func get_id()->String:
	return "yztato_random_primary_stat_over_time"

func apply(player_index: int)->void :
	var effects = RunData.get_player_effects(player_index)
	if key == "": return
	effects[key].push_back([value, interval])
	Utils.reset_stat_cache(player_index)

func unapply(player_index: int)->void :
	var effects = RunData.get_player_effects(player_index)
	effects[key].erase([value, interval])
	Utils.reset_stat_cache(player_index)

func get_args(_player_index: int)->Array:
	var strval: String = str(value) if value < 0 else "+" + str(value)
	return [strval, str(interval)]

func serialize()->Dictionary:
	var serialized = .serialize()
	serialized.interval = interval

	return serialized

func deserialize_and_merge(serialized: Dictionary)->void :
	.deserialize_and_merge(serialized)
	interval = serialized.interval as int
