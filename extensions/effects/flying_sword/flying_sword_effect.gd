extends NullEffect

export (int, "Qi", "Sword Array") var mode_type = 0

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_flying_sword"

func apply(player_index: int) -> void:
    var effect_items: Array = RunData.get_player_effect(key_hash, player_index)

    effect_items.append([value, mode_type])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    var effect_items = RunData.get_player_effect(key_hash, player_index)
    effect_items.erase([value, mode_type])
    
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int) -> Array:
    var limit: String = tr("YZTATO_WEAPON_DAMAGE_LIMIT").format([str(value)]) if value > 0 else ""
    var col_pos: String = "[color=#" + ProgressData.settings.color_positive + "]"
    var col_neg: String = "[color=#" + ProgressData.settings.color_negative + "]"
    
    return [limit, col_pos, col_neg]

func serialize() -> Dictionary:
    var serialized = .serialize()
    serialized.mode_type = mode_type
    
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    mode_type = serialized.mode_type as int
