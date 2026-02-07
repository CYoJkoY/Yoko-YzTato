extends GainStatEveryKilledEnemiesEffect

export(int, "Global", "Only Weapon") var scope: int = 0
export(String) var scaling_stat: String = ""
var scaling_stat_hash: int = Keys.empty_hash
export(float) var scaling_percent: float = 0.1
export(String) var tracking_key: String = ""
var tracking_key_hash: int = Keys.empty_hash

# =========================== Extension =========================== #
func duplicate(subresources := false) -> Resource:
    var duplication =.duplicate(subresources)
    if scaling_stat_hash == Keys.empty_hash and scaling_stat != "":
        scaling_stat_hash = Keys.generate_hash(scaling_stat)
    if tracking_key_hash == Keys.empty_hash and tracking_key != "":
        tracking_key_hash = Keys.generate_hash(tracking_key)

    duplication.scaling_stat_hash = scaling_stat_hash
    duplication.tracking_key_hash = tracking_key_hash

    return duplication

static func get_id() -> String:
    return "yztato_gain_stat_when_killed_single_scaling"

func _generate_hashes() -> void:
    ._generate_hashes()
    scaling_stat_hash = Keys.generate_hash(scaling_stat)
    tracking_key_hash = Keys.generate_hash(tracking_key)

func apply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].append([scope, value, stat_hash, stat_nb, scaling_stat_hash, scaling_percent, tracking_key_hash])
    Utils.reset_stat_cache(player_index)

func unapply(player_index: int) -> void:
    if key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[key_hash].erase([scope, value, stat_hash, stat_nb, scaling_stat_hash, scaling_percent, tracking_key_hash])
    Utils.reset_stat_cache(player_index)

func get_args(player_index: int) -> Array:
    var numer_of_need: String = str(int(value + Utils.get_stat(scaling_stat_hash, player_index) * scaling_percent))
    var stat_icon: Texture = ItemService.get_stat_small_icon(stat_hash)
    var w = 18 * ProgressData.settings.font_size
    var stat_icon_text: String = "[img=%sx%s]%s[/img]" % [w, w, stat_icon.resource_path]
    var scaling_text: String = Utils.get_scaling_stat_icon_text(scaling_stat_hash, scaling_percent)

    var tracking_value: int = RunData.ncl_get_effect_tracking_value(tracking_key_hash, player_index)
    var str_tracking_value: String = ""
    match tracking_value >= 0:
        true: str_tracking_value = Utils.ncl_create_tracking("STATS_GAINED", tracking_value)
        false: str_tracking_value = Utils.ncl_create_tracking("STATS_LOST", -tracking_value)

    return [str(stat_nb), tr(stat.to_upper()), stat_icon_text, numer_of_need, scaling_text, str_tracking_value]

func serialize() -> Dictionary:
    var serialized =.serialize()
    serialized.scope = scope
    serialized.scaling_stat = scaling_stat
    serialized.scaling_percent = scaling_percent
    serialized.tracking_key = tracking_key

    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    scope = serialized.scope as int
    scaling_stat = serialized.scaling_stat as String
    scaling_stat_hash = Keys.generate_hash(scaling_stat)
    scaling_percent = serialized.scaling_percent as float
    tracking_key = serialized.tracking_key as String
    tracking_key_hash = Keys.generate_hash(tracking_key) as int
