extends StructureEffect

export(int) var trap_count: int = 1
export(int) var chance: int = 100

var col_b: String = "[/color]"

var weapon_pos: int = -1

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_vine_trap"

func get_text(player_index: int, _colored: bool = true) -> String:
    var str_trap_count: String = "[color=#" + ProgressData.settings.color_positive + "]" + str(trap_count) + "[/color]"
    var str_chance: String = "[color=#" + ProgressData.settings.color_positive + "]" + str(chance) + "%[/color]"
    var attack_speed: String = "[color=#" + ProgressData.settings.color_positive + "]" + str(round(stats.cooldown / 60.0 * 100.0) / 100.0) + "[/color]"
    
    var enemy_speed: int = stats.speed_percent_modifier
    var str_enemy_speed: String = str(enemy_speed)
    if enemy_speed < 0: str_enemy_speed = "[color=#" + ProgressData.settings.color_positive + "]" + str(enemy_speed) + "%[/color]"
    elif enemy_speed > 0: str_enemy_speed = "[color=#" + ProgressData.settings.color_negative + "]" + str(enemy_speed) + "%[/color]"
    
    var text = Text.text("EFFECT_YZTATO_VINE_TRAP_FRONT", [str_trap_count, str_chance, attack_speed, str_enemy_speed])
    text = text + get_trap_damage_text(stats, player_index)
    return text

func apply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].append([trap_count, chance, self ])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].erase([trap_count, chance, self ])
    Utils.reset_stat_cache(player_index)

func serialize() -> Dictionary:
    var serialized =.serialize()
    serialized.trap_count = trap_count
    serialized.chance = chance
    
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    trap_count = serialized.trap_count as int
    chance = serialized.chance as int

# =========================== Method =========================== #
func get_trap_damage_text(stats: Resource, player_index: int) -> String:
    var percent_dmg_bonus: float = (1 + (Utils.get_stat(Keys.stat_percent_damage_hash, player_index) / 100.0))
    var true_damage: float = percent_dmg_bonus * (Utils.ncl_get_scaling_stats_dmg(stats.scaling_stats, player_index) + stats.damage)
    var damage: int = max(1, round(true_damage)) as int
    var text: String = Utils.ncl_get_dmg_text_with_scaling_stats(damage, stats.scaling_stats, stats.damage)
    return text
