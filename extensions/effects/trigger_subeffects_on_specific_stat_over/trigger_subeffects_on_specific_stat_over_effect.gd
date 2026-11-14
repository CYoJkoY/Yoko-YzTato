extends Effect

enum StatOverType {
    EQUAL,
    UP_E,
    DOWN_E,
    UP,
    DOWN,
    EQUAL_MULTI,
}

export(Array, Resource) var sub_effects
export(Array, StatOverType) var over_types
export(Array, int) var stat_over_values

# Resource-local caches; never retain players, scenes or a growing history.
var _subeffect_ids: Array = []
var _color_tags: RegEx = null

# ══════════════════════════════════════════ Extension ══════════════════════════════════════════ #
static func get_id() -> String:
    return "yztato_trigger_subeffect_on_specific_stat_over"

func apply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash:
        return

    RunData.get_player_effect(custom_key_hash, player_index).append(self)
    update_subeffects(player_index)

func unapply(player_index: int) -> void:
    if custom_key_hash == Keys.empty_hash:
        return

    update_subeffects(player_index, true)
    RunData.get_player_effect(custom_key_hash, player_index).erase(self)

# Keep the original IDs so active effects in existing saves are not applied twice.
func get_subeffect_id(index: int) -> int:
    if _subeffect_ids.size() != sub_effects.size():
        _subeffect_ids.clear()
        for sub_effect in sub_effects:
            _subeffect_ids.append(Utils.ncl_generate_composite_hash([
                key_hash, custom_key_hash, sub_effect.key_hash,
                sub_effect.custom_key_hash, Keys.generate_hash(sub_effect.get_id())
            ]))
    return _subeffect_ids[index]

func is_condition_met(index: int, stat_num: float) -> bool:
    var threshold: int = stat_over_values[index]
    match over_types[index]:
        StatOverType.EQUAL:
            return threshold == Utils.LARGE_NUMBER or stat_num == threshold
        StatOverType.UP_E:
            return stat_num >= threshold
        StatOverType.DOWN_E:
            return stat_num <= threshold
        StatOverType.UP:
            return stat_num > threshold
        StatOverType.DOWN:
            return stat_num < threshold
        StatOverType.EQUAL_MULTI:
            return threshold == Utils.LARGE_NUMBER or (threshold != 0 and fmod(stat_num, threshold) == 0.0)
    return false

func update_subeffects(player_index: int, removing: bool = false) -> void:
    var active: Array = RunData.get_player_effect(Utils.yztato_triggered_subeffects, player_index)
    var stat_num: float = Utils.get_stat(key_hash, player_index)
    for i in range(stat_over_values.size()):
        var sub_effect_id: int = get_subeffect_id(i)
        var should_apply: bool = not removing and is_condition_met(i, stat_num)
        if should_apply and not active.has(sub_effect_id):
            active.append(sub_effect_id)
            RunData.apply_effects_array([sub_effects[i]], player_index)
            RunData._are_player_stats_dirty[player_index] = true
        elif not should_apply and active.has(sub_effect_id):
            active.erase(sub_effect_id)
            RunData.unapply_effects_array([sub_effects[i]], player_index)
            RunData._are_player_stats_dirty[player_index] = true

func get_args(_player_index: int) -> Array:
    var sub_effects_text: String = ""
    var stat_hash: int = Keys.generate_hash(key)
    var stat_num: float = RunData.get_stat(stat_hash, _player_index) if _player_index == RunData.DUMMY_PLAYER_INDEX else Utils.get_stat(stat_hash, _player_index)
    if _color_tags == null:
        _color_tags = RegEx.new()
        _color_tags.compile("\\[/?color(?:=[^\\]]*)?\\]")

    for i in range(stat_over_values.size()):
        var stat_over_value: int = stat_over_values[i]
        var over_type: int = over_types[i]

        var str_stat_over_value: String = ""
        var str_over_type: String = ""

        match stat_over_value:
            Utils.LARGE_NUMBER:
                str_stat_over_value = tr("YZTATO_ANY_INT")
            _:
                str_stat_over_value = str(stat_over_values[i])

        match over_type:
            0:
                str_over_type = tr("YZTATO_EQUAL").format([str_stat_over_value]) # Equal
            1:
                str_over_type = tr("YZTATO_UP_E").format([str_stat_over_value]) # Up_E
            2:
                str_over_type = tr("YZTATO_DOWN_E").format([str_stat_over_value]) # Down_E
            3:
                str_over_type = tr("YZTATO_UP").format([str_stat_over_value]) # Up
            4:
                str_over_type = tr("YZTATO_DOWN").format([str_stat_over_value]) # Down
            5:
                str_over_type = tr("YZTATO_EQUAL_MULTI").format([str_stat_over_value]) # Equal Multi

        var w: int = 20 * ProgressData.settings.font_size
        var line: String = "[color=%s]%s[/color]: %s" % [
            Utils.SECONDARY_FONT_COLOR_HTML, str_over_type, sub_effects[i].get_text(_player_index)
        ]
        if not is_condition_met(i, stat_num):
            line = "[color=#808080]%s[/color]" % _color_tags.sub(line, "", true)
        sub_effects_text += "[img=%sx%s]%s[/img] %s\n" % [
            w, w, "res://items/stats/empty.png",
            line
        ]

    sub_effects_text = sub_effects_text.strip_edges()

    return [Utils.ncl_get_true_stat_name(key), sub_effects_text]

func serialize() -> Dictionary:
    var serialized =.serialize()

    var serialized_sub_effects: Array = []
    for sub_effect in sub_effects:
        var data: Dictionary = sub_effect.serialize()
        data["_script"] = sub_effect.get_script().resource_path
        serialized_sub_effects.append(data)

    serialized.sub_effects = serialized_sub_effects
    serialized.over_types = over_types
    serialized.stat_over_values = stat_over_values

    return serialized

func deserialize_and_merge(serialized: Dictionary) -> void:
    .deserialize_and_merge(serialized)
    sub_effects = []
    _subeffect_ids.clear()

    for serialized_sub_effect in serialized.sub_effects:
        var script_path: String = serialized_sub_effect.get("_script", "")
        var sub_effect: Effect = null

        var effect_script: Script = load(script_path)
        sub_effect = effect_script.new()

        sub_effect.deserialize_and_merge(serialized_sub_effect)
        sub_effects.append(sub_effect)

    over_types = serialized.over_types as Array
    stat_over_values = serialized.stat_over_values as Array
