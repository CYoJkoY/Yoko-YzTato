extends Effect

export var stat: String = "hit_protection"
var stat_hash: int = Keys.empty_hash
export var interval: int = 1
export var reset_on_hit: bool = false

# =========================== Extension =========================== #
func duplicate(subresources := false) -> Resource:
    var duplication =.duplicate(subresources)
    if stat_hash == Keys.empty_hash and stat != "":
        stat_hash = Keys.generate_hash(stat)

    duplication.stat_hash = stat_hash

    return duplication

static func get_id() -> String:
    return "yztato_temp_stats_per_interval"

func _generate_hashes() -> void:
    ._generate_hashes()
    stat_hash = Keys.generate_hash(stat)

func apply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key_hash].append([stat_hash, value, interval, reset_on_hit])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key_hash].erase([stat_hash, value, interval, reset_on_hit])
    Utils.reset_stat_cache(player_index)

func _add_custom_args() -> void:
    var interval_as_neutral := CustomArg.new()
    interval_as_neutral.arg_index = 2
    interval_as_neutral.arg_sign = Sign.NEUTRAL
    custom_args.append(interval_as_neutral)


func get_text(player_index: int, colored: bool = true) -> String:
    if interval == 1:
        text_key = "EFFECT_TEMP_STATS_PER_INTERVAL_SINGULAR"
    return.get_text(player_index, colored)


func get_args(_player_index: int) -> Array:
    return [str(value), tr(stat.to_upper()), str(interval)]


func serialize() -> Dictionary:
    var serialized =.serialize()
    serialized.stat = stat
    serialized.interval = interval
    serialized.reset_on_hit = reset_on_hit
    return serialized


func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    stat = serialized.stat as String
    stat_hash = Keys.generate_hash(stat)
    interval = serialized.interval as int
    reset_on_hit = serialized.reset_on_hit as bool
