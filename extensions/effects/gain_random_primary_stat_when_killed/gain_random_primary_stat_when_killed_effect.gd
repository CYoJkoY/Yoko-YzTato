extends NullEffect

export (int) var need_num: int = 1
export (int) var times: int = 1

# =========================== Extension =========================== #
static func get_id()->String:
    return "yztato_gain_random_primary_stat_when_killed"

func apply(player_index: int)->void :
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].append([value, need_num, times])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int)->void :
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].erase([value, need_num, times])
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int)->Array:
    var strval: String = str(value) if value < 0 else "+" + str(value)
    return [strval, str(need_num), str(times)]

func serialize()->Dictionary:
    var serialized = .serialize()
    serialized.need_num = need_num
    serialized.times = times
    
    return serialized

func deserialize_and_merge(serialized: Dictionary)->void :
    .deserialize_and_merge(serialized)
    need_num = serialized.need_num as int
    times = serialized.times as int
