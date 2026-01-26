extends NullEffect

export (String) var set_id: String = ""
var set_id_hash: int = Keys.empty_hash

# =========================== Extension =========================== #
func duplicate(subresources := false) -> Resource:
    var duplication = .duplicate(subresources)
    if set_id_hash == Keys.empty_hash and set_id != "":
        set_id_hash = Keys.generate_hash(set_id)
    
    duplication.set_id_hash = set_id_hash

    return duplication

static func get_id() -> String:
    return "yztato_weapon_set_delete"

func _generate_hashes() -> void:
    ._generate_hashes()
    set_id_hash = Keys.generate_hash(set_id)

func apply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return
    
    var effect_items = RunData.get_player_effect(custom_key_hash, player_index)
    effect_items.append(set_id_hash)
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return
    
    var effect_items = RunData.get_player_effect(custom_key_hash, player_index)
    effect_items.erase(set_id_hash)
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int) -> Array:
    var set_data = ItemService.get_set(set_id_hash)
    return [tr(set_data.name.to_upper())]

func serialize() -> Dictionary:
    var serialized = .serialize()
    serialized.set_id = set_id
    
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    set_id = serialized.set_id as String
    set_id_hash = Keys.generate_hash(set_id)
