extends "res://dlcs/dlc_1/dlc_1_data.gd"

# =========================== Extension =========================== #
func curse_item(item_data: ItemParentData, player_index: int, turn_randomization_off: bool = false, min_modifier: float = 0.0) -> ItemParentData:
    if yz_has_effect_yztato(item_data.effects):
        return _yztato_curse_item(item_data, player_index, turn_randomization_off, min_modifier)
    else:
        return.curse_item(item_data, player_index, turn_randomization_off, min_modifier)
    
# =========================== Custom =========================== #
func _yztato_curse_item(item_data: ItemParentData, _player_index: int, turn_randomization_off: bool = false, min_modifier: float = 0.0) -> ItemParentData:
    if item_data.is_cursed:
        return item_data

    var new_effects := []
    var max_effect_modifier = 0.0
    var curse_effect_modified := false
    var new_item_data = item_data.duplicate()

    if item_data is WeaponData:
        var effect_modifier := _get_cursed_item_effect_modifier(turn_randomization_off, min_modifier)
        max_effect_modifier = max(max_effect_modifier, effect_modifier)
        new_item_data.stats = _boost_weapon_stats_damage(item_data.stats, effect_modifier)

    for effect in item_data.effects:
        var effect_modifier := _get_cursed_item_effect_modifier(turn_randomization_off, min_modifier)
        max_effect_modifier = max(max_effect_modifier, effect_modifier)

        var new_effect = effect.duplicate()

        match new_effect.get_id():
            "yztato_boomerang_weapon":
                new_effect.min_damage_mul = Utils.ncl_curse_effect_value(new_effect.min_damage_mul, effect_modifier)
                new_effect.max_damage_mul = Utils.ncl_curse_effect_value(new_effect.max_damage_mul, effect_modifier)
            
            "yztato_damage_scaling":
                var new_scaling_stats: Array = new_effect.scaling_stats.duplicate()
                for scaling in new_scaling_stats:
                    scaling[1] = Utils.ncl_curse_effect_value(scaling[1], effect_modifier, {"process_negative": false})

            "yztato_gain_stat_when_killed_single_scaling":
                new_effect.scaling_percent = Utils.ncl_curse_effect_value(new_effect.scaling_percent, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})
                new_effect.value = Utils.ncl_curse_effect_value(new_effect.value, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})

            "yztato_multi_hit":
                new_effect.value = Utils.ncl_curse_effect_value(new_effect.value, effect_modifier, {"process_negative": false})
                new_effect.damage_percent = Utils.ncl_curse_effect_value(new_effect.damage_percent, effect_modifier, {"process_negative": false})

            "yztato_special_picked_up_change_stat", \
            "yztato_upgrade_when_killed_enemies":
                new_effect.value = Utils.ncl_curse_effect_value(new_effect.value, effect_modifier, {"is_negative": true, "has_min": true, "min_num": 1})
            
            "yztato_temp_stats_per_interval":
                new_effect.value = Utils.ncl_curse_effect_value(new_effect.value, effect_modifier, {"process_negative": false, "has_min": true, "min_num": new_effect.value + 1})
                
            "yztato_vine_trap":
                new_effect.trap_count = Utils.ncl_curse_effect_value(new_effect.trap_count, effect_modifier, {"process_negative": false})
                new_effect.chance = Utils.ncl_curse_effect_value(new_effect.chance, effect_modifier, {"process_negative": false})
                
            "yztato_chimera_weapon":
                var new_chimera_projectile_stats: Array = new_effect.chimera_projectile_stats.duplicate()
                for stats in new_chimera_projectile_stats:
                    for scaling in stats.scaling_stats:
                        scaling[1] = Utils.ncl_curse_effect_value(scaling[1], effect_modifier, {"process_negative": false})

            _: new_effect = yz_process_other_effect(new_effect, effect_modifier)

        new_effects.append(new_effect)

    if !curse_effect_modified:
        var curse_effect = Effect.new()
        curse_effect.key = "stat_curse"
        curse_effect.value = round(max(1.0, curse_per_item_value * item_data.value * (1.0 + max_effect_modifier))) as int
        curse_effect.effect_sign = Sign.OVERRIDE
        new_effects.append(curse_effect)

    new_item_data.effects = new_effects
    new_item_data.is_cursed = true

    new_item_data.curse_factor = max_effect_modifier

    return new_item_data as ItemParentData

func yz_process_other_effect(effect: Resource, modifier: float):
    match effect.key:
        "yztato_heal_on_damage_taken", \
        "yztato_random_curse_on_reroll":
            effect.value = Utils.ncl_curse_effect_value(effect.value, modifier, {"process_negative": false})
            effect.value2 = Utils.ncl_curse_effect_value(effect.value2, modifier, {"step": 1, "process_negative": false})
            return effect

    match effect.custom_key:
        "yztato_stats_chance_on_level_up":
            effect.value = Utils.ncl_curse_effect_value(effect.value, modifier)
            effect.value2 = Utils.ncl_curse_effect_value(effect.value2, modifier, {"step": 1, "process_negative": false})
            return effect
    
    effect.value = Utils.ncl_curse_effect_value(effect.value, modifier, {"process_negative": false})
    return effect

# =========================== Method =========================== #
func yz_has_effect_yztato(effects: Array) -> bool:
    for effect in effects:
        if effect.get_id().begins_with("yztato") or \
        effect.key.begins_with("yztato") or \
        effect.custom_key.begins_with("yztato"):
            return true
    return false
