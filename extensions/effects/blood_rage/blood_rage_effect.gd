extends NullEffect

export (int) var interval: int = 3
export (float) var duration: float = 1.5
export (Array, Array) var stats_change: Array = [
    ["stat_percent_damage", 15],
    ["stat_attack_speed", 12],
    ["stat_dodge", -6],
    ["stat_armor", -5]
]
var stats_change_hashes: Array = []

# =========================== Extension =========================== #
func duplicate(subresources := false) -> Resource:
    var duplication = .duplicate(subresources)
    if stats_change_hashes.empty() and not stats_change.empty():
        stats_change_hashes = Utils.convert_to_hash_array(stats_change)
    
    duplication.stats_change_hashes = stats_change_hashes
    
    return duplication

static func get_id() -> String:
    return "yztato_blood_rage"

func _generate_hashes() -> void:
    ._generate_hashes()
    stats_change_hashes = Utils.convert_to_hash_array(stats_change)

func apply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].append([interval, duration, stats_change_hashes])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].erase([interval, duration, stats_change_hashes])
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int) -> Array:
    var args: Array = []
    var stats_arg: String = ""
    
    for stat_change in stats_change:
        var val: int = stat_change[1]
        var name: String = tr(stat_change[0].to_upper())
        var str_val: String = str(val) if val < 0 else "+{0}".format([val])
        stats_arg += "{1}{0},".format([name, str_val])
    
    args.append(str(interval))
    args.append(str(duration))
    args.append(stats_arg)
    
    return args

func serialize() -> Dictionary:
    var serialized = .serialize()
    serialized.interval = interval
    serialized.duration = duration
    serialized.stats_change = stats_change
    
    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    interval = serialized.interval as int
    duration = serialized.duration as float
    stats_change = serialized.stats_change as Array
    stats_change_hashes = Utils.convert_to_hash_array(serialized.stats_change)
