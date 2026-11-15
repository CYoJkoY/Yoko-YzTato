extends NullEffect

export(int) var yarn_gain: int = 1
export(int) var heal: int = 5

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
static func get_id() -> String:
    return "yztato_monster_yarn_ball_pickup"

func apply(player_index: int) -> void:
    if yarn_gain != 0:
        RunData.add_stat(Utils.stat_yztato_monster_yarn_hash, yarn_gain, player_index)

    if heal > 0:
        RunData.emit_signal("healing_effect", heal, player_index, Keys.empty_hash)

func get_args(_player_index: int) -> Array:
    return [
        str(yarn_gain),
        Utils.ncl_get_true_stat_name("stat_yztato_monster_yarn"),
        str(heal),
    ]

func serialize() -> Dictionary:
    var serialized: Dictionary = .serialize()
    serialized.yarn_gain = yarn_gain
    serialized.heal = heal

    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    yarn_gain = serialized.get("yarn_gain", serialized.get("suture_gain", 1)) as int
    heal = serialized.get("heal", 5) as int
