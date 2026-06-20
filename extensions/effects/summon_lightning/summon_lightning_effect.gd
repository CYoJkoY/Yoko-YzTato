extends Effect

export(PackedScene) var summon_lightning_warning_scene = null

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_summon_lightning"

func apply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return

    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].append(self)

func unapply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return

    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].erase(self)

func serialize() -> Dictionary:
    var serialized: Dictionary =.serialize()
    serialized.summon_lightning_warning_scene = summon_lightning_warning_scene.resource_path

    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    summon_lightning_warning_scene = load(serialized.summon_lightning_warning_scene) as PackedScene
