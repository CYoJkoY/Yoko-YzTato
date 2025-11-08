extends StructureEffect

export (int) var trap_count: int = 1
export (int) var chance: int = 100

var col_b: String = "[/color]"

var weapon_pos: int = -1

# =========================== Extension =========================== #
static func get_id() -> String:
	return "yztato_vine_trap"

func get_text(player_index: int, _colored: bool = true) -> String:
	var text = _yztato_vine_trap_get_text(player_index)
	return text

func apply(player_index: int) -> void:
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].append([trap_count, chance, self])
	Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
	var effects = RunData.get_player_effects(player_index)
	if custom_key == "": return
	effects[custom_key].erase([trap_count, chance, self])
	Utils.reset_stat_cache(player_index)

func serialize() -> Dictionary:
	var serialized = .serialize()
	serialized = _yztato_vine_trap_serialize(serialized)
	
	return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
	.deserialize_and_merge(serialized)
	_yztato_vine_trap_deserialize_and_merge(serialized)

# =========================== Custom =========================== #
func _yztato_vine_trap_get_text(player_index: int) -> String:
	var str_trap_count: String = "[color=#"+ ProgressData.settings.color_positive +"]" + str(trap_count) + "[/color]"
	var str_chance: String = "[color=#"+ ProgressData.settings.color_positive +"]" + str(chance) + "%[/color]"
	var attack_speed: String = "[color=#"+ ProgressData.settings.color_positive +"]" + str(round(stats.cooldown / 60.0 * 100.0) / 100.0) + "[/color]"
	
	var enemy_speed: int = stats.speed_percent_modifier
	var str_enemy_speed: String = str(enemy_speed)
	if enemy_speed < 0: str_enemy_speed = "[color=#"+ ProgressData.settings.color_positive +"]" + str(enemy_speed) + "%[/color]"
	elif enemy_speed > 0: str_enemy_speed = "[color=#"+ ProgressData.settings.color_negative +"]" + str(enemy_speed) + "%[/color]"
	
	var text = Text.text("EFFECT_YZTATO_VINE_TRAP_FRONT", [str_trap_count, str_chance, attack_speed, str_enemy_speed])
	text = text + get_trap_damage_text(stats, player_index)
	return text

func _yztato_vine_trap_serialize(serialized: Dictionary) -> Dictionary:
	serialized.trap_count = trap_count
	serialized.chance = chance
	return serialized

func _yztato_vine_trap_deserialize_and_merge(serialized: Dictionary) -> void:
	trap_count = serialized.trap_count as int
	chance = serialized.chance as int

# =========================== Method =========================== #
func get_trap_damage_text(stats: Resource, player_index: int) -> String:
	var percent_dmg_bonus: float = (1 + (Utils.get_stat("stat_percent_damage", player_index) / 100.0))
	var damage: int = int(max(1, round(percent_dmg_bonus * (get_scaling_stats_dmg(stats.scaling_stats, player_index) + stats.damage))))
	var text: String = get_dmg_text_with_scaling_stats(damage, stats.scaling_stats, stats.damage)
	return text

func get_scaling_stats_dmg(p_scaling_stats: Array, player_index: int) -> int:
	var bonus_dmg: int = 0

	for scaling_stat in p_scaling_stats:
		bonus_dmg += int((Utils.get_stat(scaling_stat[0], player_index) * scaling_stat[1]))

	return bonus_dmg

func get_dmg_text_with_scaling_stats(damage: int, p_scaling_stats: Array, base_damage: int) -> String:
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
