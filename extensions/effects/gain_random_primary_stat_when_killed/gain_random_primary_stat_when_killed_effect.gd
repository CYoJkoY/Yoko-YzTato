extends NullEffect

export (int) var need_num: int = 1

# =========================== Extention =========================== #
static func get_id()->String:
    return "yztato_gain_random_primary_stat_when_killed"

func apply(player_index: int)->void :
    var effects = RunData.get_player_effects(player_index)
    if key == "": return
    effects[key].push_back([value, need_num])
    Utils.reset_stat_cache(player_index)


func unapply(player_index: int)->void :
    var effects = RunData.get_player_effects(player_index)
    effects[key].erase([value, need_num])
    Utils.reset_stat_cache(player_index)

func get_args(_player_index: int)->Array:
    var strval: String = str(value) if value < 0 else "+" + str(value)
    return [strval, str(need_num)]

func serialize()->Dictionary:
    var serialized = .serialize()
    serialized.need_num = need_num

    return serialized


func deserialize_and_merge(serialized: Dictionary)->void :
    .deserialize_and_merge(serialized)
    need_num = serialized.need_num as int
