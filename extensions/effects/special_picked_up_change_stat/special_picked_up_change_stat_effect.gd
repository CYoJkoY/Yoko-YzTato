extends GainStatEveryKilledEnemiesEffect

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_special_picked_up_change_stat"

func apply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key_hash].append([key_hash, value, stat_hash, stat_nb])

func unapply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return
    
    var effects: Dictionary = RunData.get_player_effects(player_index)
    effects[custom_key_hash].erase([key_hash, value, stat_hash, stat_nb])

func get_args(_player_index: int) -> Array:
    var stat_icon: Texture = ItemService.get_stat_small_icon(stat_hash)
    var w = 18 * ProgressData.settings.font_size
    var stat_icon_text: String = "[img=%sx%s]%s[/img]" % [w, w, stat_icon.resource_path]
    var str_stat_nb: String = str(stat_nb)
    if stat_nb >= 0:
        str_stat_nb = "+" + str_stat_nb
    return [str(value), tr(key.to_upper()), str_stat_nb, tr(stat.to_upper()), stat_icon_text]
