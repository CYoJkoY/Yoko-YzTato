extends Effect

export (String) var name: String = ""
export (Resource) var extra_group_data: Resource = null
export (int) var waves: int = 0

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_extra_enemies_next_waves"

func apply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].append([extra_group_data.resource_path, value, waves])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].erase([extra_group_data.resource_path, value, waves])
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int) -> Array:
    var args: Array = .get_args(_player_index)
    var str_waves: String = tr("INFINITE") if waves >= 999 else str(waves)
    var enemy_name: String = tr(name.to_upper())

    args.append(str_waves)
    args.append(enemy_name)
    
    return args

func serialize() -> Dictionary:
    var serialized = .serialize()
    serialized.name = name
    serialized.extra_group_data = extra_group_data.resource_path
    serialized.waves = waves
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    name = serialized.name as String
    extra_group_data = load(serialized.extra_group_data) as Resource
    waves = serialized.waves as int
