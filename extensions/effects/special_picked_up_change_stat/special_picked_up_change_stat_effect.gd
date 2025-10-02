extends NullEffect

export (String) var stat = "stat_lifesteal"
export (int) var stat_nb = 1

# =========================== Extension =========================== #
static func get_id()->String:
	return "yztato_special_picked_up_change_stat"

func apply(player_index: int)->void :
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].push_back([key, value, stat, stat_nb])


func unapply(player_index: int)->void :
	var effects = RunData.get_player_effects(player_index)
	effects[custom_key].erase([key, value, stat, stat_nb])

func get_args(_player_index: int)->Array:
	var stat_icon: Texture = ItemService.get_stat_small_icon(stat)
	var w = 18 * ProgressData.settings.font_size
	var stat_icon_text: String = "[img=%sx%s]%s[/img]" % [w, w, stat_icon.resource_path]
	var str_stat_nb: String = str(stat_nb)
	if stat_nb >= 0:
		str_stat_nb = "+" + str_stat_nb
	return [str(value), tr(key.to_upper()), str_stat_nb, tr(stat.to_upper()), stat_icon_text]

func serialize()->Dictionary:
	var serialized = .serialize()
	serialized = _yztato_special_picked_up_change_stat_serialize(serialized)

	return serialized


func deserialize_and_merge(serialized: Dictionary)->void :
	.deserialize_and_merge(serialized)
	_yztato_special_picked_up_change_stat_deserialize_and_merge(serialized)


# =========================== Custom =========================== #
func _yztato_special_picked_up_change_stat_serialize(serialized: Dictionary)-> Dictionary:
	serialized.stat = stat
	serialized.stat_nb = stat_nb
	return serialized

func _yztato_special_picked_up_change_stat_deserialize_and_merge(serialized: Dictionary)-> void:
	stat = serialized.stat as String
	stat_nb = serialized.stat_nb as int
