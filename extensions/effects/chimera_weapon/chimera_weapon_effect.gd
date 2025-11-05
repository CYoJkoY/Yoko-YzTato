extends NullEffect

export(Array, Resource) var chimera_projectile_stats: Array = []
export(Array, Resource) var chimera_texture_sets: Array = []

var col_b = "[/color]"

# =========================== Extension =========================== #

static func get_id()-> String:
	return "yztato_chimera_weapon"

func get_text(player_index: int, _colored: bool = true)-> String:
	var text = _yztato_chimera_get_text(player_index)

	return text

func serialize()-> Dictionary:
	var serialized = .serialize()
	serialized = _yztato_chimera_serialize(serialized)

	return serialized

func deserialize_and_merge(serialized:Dictionary)-> void:
	.deserialize_and_merge(serialized)
	_yztato_chimera_deserialize_and_merge(serialized)


# =========================== Custom =========================== #
func _yztato_chimera_get_text(player_index : int)-> String:
	var text = Text.text("EFFECT_YZTATO_CHIMERA_FRONT",[str(value)])
	for stats in chimera_projectile_stats:
		text = text + ", " + get_projectile_text(stats, player_index)
	return text

func _yztato_chimera_serialize(serialized)-> Dictionary:
	serialized.chimera_projectile_stats = []
	for projectile_stats in chimera_projectile_stats:
		serialized.chimera_projectile_stats.push_back(projectile_stats.resource_path)
	return serialized

func _yztato_chimera_deserialize_and_merge(serialized)-> void:
	if serialized.has("chimera_projectile_stats"):
		for projectile_stats_path in serialized.chimera_projectile_stats:
			chimera_projectile_stats.push_back(load(projectile_stats_path))

# =========================== Method =========================== #
func get_projectile_text(stats: Resource, player_index : int)->String:
		var percent_dmg_bonus: float = (1 + (Utils.get_stat("stat_percent_damage", player_index) / 100.0))
		var damage: int = int(max(1, round(percent_dmg_bonus * (get_scaling_stats_dmg(stats.scaling_stats, player_index) + stats.damage))))
		var text: String = get_dmg_text_with_scaling_stats(damage, stats.scaling_stats, stats.damage)
		return text

func get_scaling_stats_dmg(p_scaling_stats: Array, player_index : int) -> int:
	var bonus_dmg: int = 0

	for scaling_stat in p_scaling_stats:
		bonus_dmg += (Utils.get_stat(scaling_stat[0], player_index) * scaling_stat[1]) as int

	return bonus_dmg

func get_dmg_text_with_scaling_stats(damage: int, p_scaling_stats: Array, base_damage) -> String:

	var a: String = get_signed_col_a(damage, base_damage)
	var dmg_text: String = a + str(damage) + col_b

	var text: String = dmg_text

	if damage != base_damage:
		var initial_dmg_text: String = str(base_damage)
		text += get_init_a() + initial_dmg_text + col_b

	text += " (" + WeaponService.get_scaling_stats_icon_text(p_scaling_stats) + ")"

	return text

func get_signed_col_a(value: float, base_value: float) -> String:
	var col_pos_a: String = "[color=#"+ ProgressData.settings.color_positive +"]"
	var col_neutral_a: String = "[color=white]"
	var col_neg_a: String = "[color=#"+ ProgressData.settings.color_negative +"]"
	if value > base_value: return col_pos_a
	elif value == base_value: return col_neutral_a
	else: return col_neg_a

func get_init_a() -> String:
	return " [color=" + Utils.GRAY_COLOR_STR + "]| "
