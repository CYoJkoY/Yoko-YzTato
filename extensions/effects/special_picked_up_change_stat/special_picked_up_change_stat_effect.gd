extends NullEffect

export (String) var stat: String = "stat_lifesteal"
var stat_hash: int = Keys.empty_hash
export (int) var stat_nb: int = 1

# =========================== Extension =========================== #
func duplicate(subresources := false) -> Resource:
    var duplication = .duplicate(subresources)
    if stat_hash == Keys.empty_hash and stat != "":
        stat_hash = Keys.generate_hash(stat)

    duplication.stat_hash = stat_hash

    return duplication

static func get_id()->String:
    return "yztato_special_picked_up_change_stat"

func _generate_hashes() -> void:
    ._generate_hashes()
    stat_hash = Keys.generate_hash(stat)

func apply(player_index: int)->void :
    var effect_items = RunData.get_player_effect(custom_key_hash, player_index)
    effect_items.push_back([key_hash, value, stat_hash, stat_nb])

func unapply(player_index: int)->void :
    var effect_items = RunData.get_player_effect(custom_key_hash, player_index)
    effect_items.erase([key_hash, value, stat_hash, stat_nb])

func get_args(_player_index: int)->Array:
    var stat_icon: Texture = ItemService.get_stat_small_icon(stat_hash)
    var w = 18 * ProgressData.settings.font_size
    var stat_icon_text: String = "[img=%sx%s]%s[/img]" % [w, w, stat_icon.resource_path]
    var str_stat_nb: String = str(stat_nb)
    if stat_nb >= 0:
        str_stat_nb = "+" + str_stat_nb
    return [str(value), tr(key.to_upper()), str_stat_nb, tr(stat.to_upper()), stat_icon_text]

func serialize()->Dictionary:
    var serialized = .serialize()
    serialized.stat = stat
    serialized.stat_nb = stat_nb

    return serialized


func deserialize_and_merge(serialized: Dictionary)->void :
    .deserialize_and_merge(serialized)
    stat = serialized.stat as String
    stat_hash = Keys.generate_hash(stat)
    stat_nb = serialized.stat_nb as int
