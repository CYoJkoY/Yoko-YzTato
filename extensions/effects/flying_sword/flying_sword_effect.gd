extends GainStatEveryKilledEnemiesEffect

enum ModeType {Qi, SwordArray}

export(ModeType) var mode_type = ModeType.Qi

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_flying_sword"

func apply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return

    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash][mode_type] = effects[key_hash].get(mode_type, 0) + value

func unapply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return

    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash][mode_type] -= value

func get_args(_player_index: int) -> Array:
    var limit: String = tr("YZTATO_WEAPON_DAMAGE_LIMIT").format([str(value)]) if value > 0 else ""

    return [limit]

func serialize() -> Dictionary:
    var serialized =.serialize()
    serialized.mode_type = mode_type

    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    mode_type = serialized.mode_type as int
