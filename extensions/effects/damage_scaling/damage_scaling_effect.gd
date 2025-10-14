extends NullEffect

export (Array, Array) var scaling_stats = [["stat_max_hp", 0.5]]

# =========================== Extension =========================== #
static func get_id()-> String:
	return "yztato_damage_scaling"

func apply(player_index: int) -> void:
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].push_back([key, value, scaling_stats])
	Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].erase([key, value, scaling_stats])
	Utils.reset_stat_cache(player_index)

func get_text(_player_index: int, _colored: bool = true)-> String:
	var w = 15 * ProgressData.settings.font_size
	var small_icon: Texture = ItemService.get_stat_small_icon(key)
	var str_key: String = "%s([img=%sx%s]%s[/img])" % [tr(key.to_upper()),w, w, small_icon.resource_path]

	var value_col: String = ProgressData.settings.color_positive if value > 0 else ProgressData.settings.color_negative
	var value_text: String = str(value) if value > 0 else "-%s" % [str(value)]
	var str_value: String = "[color=%s]%s[/color]" % [value_col, value_text]

	var text = Text.text("EFFECT_YZTATO_DAMAGE_SCALING_FRONT",[str_key, str_value])
	text += yz_get_scaling_stats_icon_text(scaling_stats)

	return text

func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized.scaling_stats = scaling_stats
	
	return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	scaling_stats = serialized.scaling_stats as Array

# =========================== Methods =========================== #
func yz_get_scaling_stats_icon_text(p_scaling_stats: Array) -> String:
	var stat_icon_text: = ""
	for i in p_scaling_stats.size():
		stat_icon_text += yz_get_scaling_stat_icon_text(p_scaling_stats[i][0], p_scaling_stats[i][1])
	stat_icon_text = stat_icon_text.left(stat_icon_text.length() - 1)
		
	return stat_icon_text

func yz_get_scaling_stat_icon_text(stat: String, scaling: float = 1.0, show_plus_prefix: bool = true)->String:
	var w = 15 * ProgressData.settings.font_size
	var prefix = "+" if show_plus_prefix and scaling > 0.0 else ""
	var color = ProgressData.settings.color_positive if scaling > 0.0 else ProgressData.settings.color_negative
	var scaling_text = "[color=%s]%s%s%%[/color]" % [color, prefix, str(round(scaling * 100.0))]

	var small_icon: Texture = ItemService.get_stat_small_icon(stat)
	return "%s[img=%sx%s]%s[/img]," % [scaling_text, w, w, small_icon.resource_path]
