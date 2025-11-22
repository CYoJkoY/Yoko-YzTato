extends NullEffect

export (String) var set_id: String = ""

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_weapon_set_delete"

func apply(player_index: int) -> void:
    var effects = RunData.get_player_effects(player_index)
    if custom_key == "": return
    effects[custom_key].append(set_id)
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    var effects = RunData.get_player_effects(player_index)
    if custom_key == "": return
    effects[custom_key].erase(set_id)
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int) -> Array:
    var set_data = ItemService.get_set(set_id)
    return [tr(set_data.name.to_upper())]

func serialize() -> Dictionary:
    var serialized = .serialize()
    serialized = _yztato_weapon_set_filter_serialize(serialized)
    
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    _yztato_weapon_set_filter_deserialize_and_merge(serialized)

# =========================== Custom =========================== #
func _yztato_weapon_set_filter_serialize(serialized: Dictionary) -> Dictionary:
    serialized.set_id = set_id
    return serialized

func _yztato_weapon_set_filter_deserialize_and_merge(serialized: Dictionary) -> void:
    set_id = serialized.set_id as String
