extends Effect

export (Resource) var extra_group_data: Resource
export (int) var waves: int

# =========================== Extention =========================== #
static func get_id() -> String:
    return "extra_enemy_next_waves"

func apply(player_index: int) -> void:
    var effect_items = RunData.get_player_effect(key_hash, player_index)
    for existing_item in effect_items:
        if existing_item[0] == extra_group_data.resource_path:
            existing_item[1] += value
            existing_item[2] += waves
            Utils.reset_stat_cache(player_index)
            return

    effect_items.append([extra_group_data.resource_path, value, waves])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    var effect_items = RunData.get_player_effect(key_hash, player_index)
    for i in effect_items.size():
        var effect_item = effect_items[i]
        if effect_item[0] == extra_group_data.resource_path:
            effect_item[1] -= value
            effect_item[2] -= waves

            if effect_item[1] == 0:
                effect_items.remove(i)

            Utils.reset_stat_cache(player_index)
            return

func get_args(_player_index: int) -> Array:
    var args: Array = .get_args(_player_index)
    var str_waves: String = tr("INFINITE") if waves >= 999 else str(waves)
    args.push_back(str_waves)
    
    return args

func serialize() -> Dictionary:
    var serialized = .serialize()
    serialized.extra_group_data = extra_group_data.resource_path
    serialized.waves = waves
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    extra_group_data = load(serialized.extra_group_data) as Resource
    waves = serialized.waves as int
