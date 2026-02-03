extends NullEffect

export(Array, Resource) var chimera_projectile_stats: Array = []
export(Array, Resource) var chimera_texture_sets: Array = []

var col_b: String = "[/color]"
var set_path: String = "res://mods-unpacked/Yoko-YzTato/extensions/effects/chimera_weapon/chimera_texture_set.gd"

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_chimera_weapon"

func get_text(player_index: int, _colored: bool = true) -> String:
    var text = _yztato_chimera_get_text(player_index)

    return text

func serialize() -> Dictionary:
    var serialized =.serialize()
    var projectile_stats_data: Array = []
    var texture_sets_data: Array = []
    
    for projectile_stats in chimera_projectile_stats:
        projectile_stats_data.append(projectile_stats.serialize())
    for texture_set in chimera_texture_sets:
        texture_sets_data.append(texture_set.serialize())
    
    serialized.chimera_projectile_stats = projectile_stats_data
    serialized.chimera_texture_sets = texture_sets_data

    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    chimera_projectile_stats = []
    chimera_texture_sets = []

    if serialized.has("chimera_projectile_stats"):
        for projectile_stats in serialized.chimera_projectile_stats:
            var stats: Resource = RangedWeaponStats.new()
            stats.deserialize_and_merge(projectile_stats)
            chimera_projectile_stats.append(stats)
    
    if serialized.has("chimera_texture_sets"):
        for texture_set in serialized.chimera_texture_sets:
            var set: Resource = load(set_path).new()
            set.deserialize_and_merge(texture_set)
            chimera_texture_sets.append(set)


# =========================== Custom =========================== #
func _yztato_chimera_get_text(player_index: int) -> String:
    var text = Text.text("EFFECT_YZTATO_CHIMERA_FRONT", [str(value)])
    for stats in chimera_projectile_stats:
        text = text + ", " + get_projectile_text(stats, player_index)
    return text

# =========================== Method =========================== #
func get_projectile_text(stats: Resource, player_index: int) -> String:
    var percent_dmg_bonus: float = (1 + (Utils.get_stat(Keys.stat_percent_damage_hash, player_index) / 100.0))
    var bouns_damage: float = percent_dmg_bonus * (get_scaling_stats_dmg(stats.scaling_stats, player_index))
    var calculate_damage: int = round(bouns_damage + stats.damage) as int
    var damage: int = max(1, calculate_damage) as int
    var text: String = get_dmg_text_with_scaling_stats(damage, stats.scaling_stats, stats.damage)
    return text

func get_scaling_stats_dmg(p_scaling_stats: Array, player_index: int) -> int:
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
    var col_pos_a: String = "[color=#" + ProgressData.settings.color_positive + "]"
    var col_neutral_a: String = "[color=white]"
    var col_neg_a: String = "[color=#" + ProgressData.settings.color_negative + "]"
    if value > base_value: return col_pos_a
    elif value == base_value: return col_neutral_a
    else: return col_neg_a

func get_init_a() -> String:
    return " [color=" + Utils.GRAY_COLOR_STR + "]| "
