extends NullEffect

export (int) var interval: int = 3
export (int) var percent_damage_bonus: int = 15
export (int) var attack_speed_bonus: int = 12
export (int) var dodge_bonus: int = -6
export (int) var armor_bonus: int = -5
export (float) var duration: float = 1.5

var current_timer: int = 0
var is_active: bool = false
var active_effects: Array = []

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_blood_rage"

func apply(player_index: int) -> void:
    var effect_items = RunData.get_player_effect(key_hash, player_index)
    effect_items.push_back([interval, 1, percent_damage_bonus, attack_speed_bonus, dodge_bonus, armor_bonus, duration])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    var effect_items = RunData.get_player_effect(key_hash, player_index)
    effect_items.erase([interval, 1, percent_damage_bonus, attack_speed_bonus, dodge_bonus, armor_bonus, duration])
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int) -> Array:
    var str_percent_damage_bonus: String = str(percent_damage_bonus) if percent_damage_bonus < 0 else "+" + str(percent_damage_bonus)
    var str_attack_speed_bonus: String = str(attack_speed_bonus) if attack_speed_bonus < 0 else "+" + str(attack_speed_bonus)
    var str_dodge_bonus: String = str(dodge_bonus) if dodge_bonus < 0 else "+" + str(dodge_bonus)
    var str_armor_bonus: String = str(armor_bonus) if armor_bonus < 0 else "+" + str(armor_bonus)

    return [str(interval), str_percent_damage_bonus, str_attack_speed_bonus, str_dodge_bonus, str_armor_bonus, str(duration)]

func serialize() -> Dictionary:
    var serialized = .serialize()
    serialized.interval = interval
    serialized.percent_damage_bonus = percent_damage_bonus
    serialized.attack_speed_bonus = attack_speed_bonus
    serialized.dodge_bonus = dodge_bonus
    serialized.armor_bonus = armor_bonus
    serialized.duration = duration
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    interval = serialized.interval as int
    percent_damage_bonus = serialized.percent_damage_bonus as int
    attack_speed_bonus = serialized.attack_speed_bonus as int
    dodge_bonus = serialized.dodge_bonus as int
    armor_bonus = serialized.armor_bonus as int
    duration = serialized.duration as float
