extends Effect

export(String) var tag = ""
export(int) var tag_nb = 1

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_gain_stat_for_every_tag_item"

func apply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return

    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key].append([key_hash, value, tag, tag_nb])

func unapply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return

    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key].erase([key_hash, value, tag, tag_nb])

func get_args(_player_index: int) -> Array:
    return [Utils.ncl_get_true_stat_name(key), str(value), ]

func serialize() -> Dictionary:
    var serialized: Dictionary = serialize()
    serialized.tag = tag
    serialized.tag_nb = tag_nb

    return serialized

func deserialize_and_merge(effect: Dictionary) -> void:
    .deserialize_and_merge(effect)
    tag = effect.tag as String
    tag_nb = effect.tag_nb as int
