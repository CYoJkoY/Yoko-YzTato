extends Effect

enum StatOverType {EQUAL, UP_E, DOWN_E, UP, DOWN, EQUAL_MULTI}

export(Array, Resource) var sub_effects
export(Array, StatOverType) var over_types
export(Array, int) var stat_over_values

# =========================== Extension =========================== #
static func get_id() -> String:
    return "yztato_trigger_subeffect_on_specific_stat_over"

func apply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return

    RunData.get_player_effect(custom_key_hash, player_index).append(self)

func unapply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash: return

    RunData.get_player_effect(custom_key_hash, player_index).erase(self)

func get_args(_player_index: int) -> Array:
    var sub_effects_text: String = ""

    for i in range(stat_over_values.size()):
        var str_stat_over_value: String = ""
        var str_over_type: String = ""

        match stat_over_values[i]:
            Utils.LARGE_NUMBER: str_stat_over_value = tr("YZTATO_ANY_INT")
            _: str_stat_over_value = str(stat_over_values[i])

        match over_types[i]:
            0: str_over_type = tr("YZTATO_EQUAL").format([str_stat_over_value]) # Equal
            1: str_over_type = tr("YZTATO_UP_E").format([str_stat_over_value]) # Up_E
            2: str_over_type = tr("YZTATO_DOWN_E").format([str_stat_over_value]) # Down_E
            3: str_over_type = tr("YZTATO_UP").format([str_stat_over_value]) # Up
            4: str_over_type = tr("YZTATO_DOWN").format([str_stat_over_value]) # Down
            5: str_over_type = tr("YZTATO_EQUAL_MULTI").format([str_stat_over_value]) # Equal Multi

        var w: int = 20 * ProgressData.settings.font_size
        sub_effects_text += "[img=%sx%s]%s[/img] [color=%s]%s[/color]: %s\n" % [
            w, w, "res://items/stats/empty.png",
            Utils.SECONDARY_FONT_COLOR_HTML, str_over_type,
            sub_effects[i].get_text(_player_index)
        ]

    sub_effects_text = sub_effects_text.strip_edges()

    return [Utils.ncl_get_true_stat_name(key), sub_effects_text]

func serialize() -> Dictionary:
    var serialized =.serialize()

    var serialized_sub_effects: Array = []
    for sub_effect in sub_effects:
        var data: Dictionary= sub_effect.serialize()
        data["_script"] = sub_effect.get_script().resource_path
        serialized_sub_effects.append(data)

    serialized.sub_effects = serialized_sub_effects
    serialized.over_types = over_types
    serialized.stat_over_values = stat_over_values

    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)

    for serialized_sub_effect in serialized.sub_effects:
        var script_path: String = serialized_sub_effect.get("_script", "")
        var sub_effect: Effect = null

        var effect_script: Script = load(script_path)
        sub_effect = effect_script.new()

        sub_effect.deserialize_and_merge(serialized_sub_effect)
        sub_effects.append(sub_effect)

    over_types = serialized.over_types
    stat_over_values = serialized.stat_over_values
