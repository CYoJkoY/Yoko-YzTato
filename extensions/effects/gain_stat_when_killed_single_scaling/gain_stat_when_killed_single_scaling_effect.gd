extends NullEffect

export (String) var stat: String = ""
export (int) var stat_nb: int = 1
export (String) var scaling_stat: String = ""
export (float) var scaling_percent: float = 0.1

# =========================== Extention =========================== #
static func get_id()->String:
	return "yztato_gain_stat_when_killed_single_scaling"

func apply(player_index: int)->void :
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	
	effects[custom_key].push_back([key, value, stat, stat_nb, scaling_stat, scaling_percent])
	Utils.reset_stat_cache(player_index)

func unapply(player_index: int)->void :
	var effects = RunData.get_player_effects(player_index)
	effects[custom_key].erase([key, value, stat, stat_nb, scaling_stat, scaling_percent])
	Utils.reset_stat_cache(player_index)

func get_args(player_index: int)->Array:
	var numer_of_need: String = str(int(value + Utils.get_stat(scaling_stat, player_index) * scaling_percent))
	var stat_icon: Texture = ItemService.get_stat_small_icon(stat)
	var w = 18 * ProgressData.settings.font_size
	var stat_icon_text: String = "[img=%sx%s]%s[/img]" % [w, w, stat_icon.resource_path]
	var scaling_text: String = Utils.get_scaling_stat_icon_text(scaling_stat, scaling_percent)
	return [str(stat_nb), tr(stat.to_upper()), stat_icon_text, numer_of_need, scaling_text]

func serialize()->Dictionary:
	var serialized = .serialize()
	serialized = _yztato_gain_stat_when_killed_single_scaling_serialize(serialized)

	return serialized


func deserialize_and_merge(serialized: Dictionary)->void :
	.deserialize_and_merge(serialized)
	_yztato_gain_stat_when_killed_single_scaling_deserialize_and_merge(serialized)


# =========================== Custom =========================== #
func _yztato_gain_stat_when_killed_single_scaling_serialize(serialized: Dictionary)-> Dictionary:
	serialized.stat = stat
	serialized.stat_nb = stat_nb
	serialized.scaling_stat = scaling_stat
	serialized.scaling_percent = scaling_percent
	return serialized

func _yztato_gain_stat_when_killed_single_scaling_deserialize_and_merge(serialized: Dictionary)-> void:
	stat = serialized.stat as String
	stat_nb = serialized.stat_nb as int
	scaling_stat = serialized.scaling_stat as String
	scaling_percent = serialized.scaling_percent as float
