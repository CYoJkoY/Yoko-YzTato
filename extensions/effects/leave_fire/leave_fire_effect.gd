extends Effect

export(float) var duration: float = 1.0
export(float) var scale: float = 1.0

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_leave_fire"

func apply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key_hash].append([key_hash, value, duration, scale])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key_hash].erase([key_hash, value, duration, scale])
    Utils.reset_stat_cache(player_index)

func serialize() -> Dictionary:
    var serialized =.serialize()
    serialized.duration = duration
    serialized.scale = scale

    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    duration = serialized.duration as float
    scale = serialized.scale as float
