extends Effect

export(String) var tag = ""
export(int) var tag_nb = 1

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_specific_tag_item_bonus"

func apply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return

    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key].append([key_hash, value, tag, tag_nb])

func unapply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return

    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key].erase([key_hash, value, tag, tag_nb])

func get_args(_player_index: int) -> Array:
    var tag_name: String = "tag_yztato_" + tag if !tag.begins_with("stat_") else tag
    tag_name = tr(tag_name.to_upper())

    var items: Array = RunData.get_player_items_ref(_player_index)
    var nb_specific_tag_items: int = 0
    var bonus_value: int = 0
    for item in items: for item_tag in item.tags:
        if item_tag != tag: continue

        nb_specific_tag_items += 1

    bonus_value = value * nb_specific_tag_items / tag_nb

    return [Utils.ncl_get_true_stat_name(key), str(value), tag_name, str(bonus_value), str(tag_nb)]

func serialize() -> Dictionary:
    var serialized: Dictionary = serialize()
    serialized.tag = tag
    serialized.tag_nb = tag_nb

    return serialized

func deserialize_and_merge(effect: Dictionary) -> void:
    .deserialize_and_merge(effect)
    tag = effect.tag as String
    tag_nb = effect.tag_nb as int
