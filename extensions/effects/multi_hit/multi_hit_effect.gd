extends NullEffect

export (int) var damage_percent: int = 50

# =========================== Extension =========================== #
static func get_id()-> String:
    return "yztato_multi_hit"

func apply(player_index: int) -> void:
    var effect_items = RunData.get_player_effect(custom_key_hash, player_index)
    effect_items.push_back([value, damage_percent])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    var effect_items = RunData.get_player_effect(custom_key_hash, player_index)
    effect_items.erase([value, damage_percent])
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int) -> Array:
    return [str(value), str(damage_percent)]

func serialize() -> Dictionary:
    var serialized = .serialize()
    serialized.damage_percent = damage_percent
    
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    damage_percent = serialized.damage_percent as int
    
