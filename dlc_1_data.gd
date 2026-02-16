extends "res://dlcs/dlc_1/dlc_1_data.gd"

# =========================== Extension =========================== #
func curse_item(item_data: ItemParentData, player_index: int, turn_randomization_off: bool = false, min_modifier: float = 0.0) -> ItemParentData:
    if item_data.is_cursed: return item_data

    var new_item_data: ItemParentData =.curse_item(item_data, player_index, turn_randomization_off, min_modifier)
    if has_effect_yztato(item_data.effects):
        new_item_data = _yztato_curse_item(new_item_data, player_index, turn_randomization_off, min_modifier)
    return new_item_data
    
# =========================== Custom =========================== #
func _yztato_curse_item(item_data: ItemParentData, _player_index: int, turn_randomization_off: bool = false, min_modifier: float = 0.0) -> ItemParentData:
    var max_effect_modifier: float = 0.0
    var new_item_data: ItemParentData = item_data.duplicate()
    var new_effects: Array = []

    for effect in item_data.effects:
        if !is_effect_yztato(effect):
            new_effects.append(effect)
            continue

        var effect_modifier: float = _get_cursed_item_effect_modifier(turn_randomization_off, min_modifier)
        max_effect_modifier = max(max_effect_modifier, effect_modifier)

        var new_effect: Effect = effect.duplicate()
        var id: String = new_effect.get_id()
        var key: int = new_effect.key_hash
        var cskey: int = new_effect.custom_key_hash

        match [id, key, cskey]:
            ["yztato_boomerang_weapon", _, _]:
                new_effect.min_damage_mul = Utils.ncl_curse_effect_value(new_effect.min_damage_mul, effect_modifier)
                new_effect.max_damage_mul = Utils.ncl_curse_effect_value(new_effect.max_damage_mul, effect_modifier)
            
            ["yztato_damage_scaling", _, _]:
                var new_scaling_stats: Array = new_effect.scaling_stats.duplicate()
                for scaling in new_scaling_stats:
                    scaling[1] = Utils.ncl_curse_effect_value(scaling[1], effect_modifier, {"process_negative": false})

            ["yztato_gain_stat_when_killed_single_scaling", _, _]:
                new_effect.scaling_percent = Utils.ncl_curse_effect_value(new_effect.scaling_percent, effect_modifier, {"is_negative": true, "min_num": 1})

            ["yztato_multi_hit", _, _]:
                new_effect.damage_percent = Utils.ncl_curse_effect_value(new_effect.damage_percent, effect_modifier, {"process_negative": false})
            
            ["yztato_vine_trap", _, _]:
                new_effect.trap_count = Utils.ncl_curse_effect_value(new_effect.trap_count, effect_modifier, {"process_negative": false})
                new_effect.chance = Utils.ncl_curse_effect_value(new_effect.chance, effect_modifier, {"process_negative": false})
                
            ["yztato_chimera_weapon", _, _]:
                var new_chimera_projectile_stats: Array = new_effect.chimera_projectile_stats.duplicate()
                for stats in new_chimera_projectile_stats:
                    for scaling in stats.scaling_stats:
                        scaling[1] = Utils.ncl_curse_effect_value(scaling[1], effect_modifier, {"process_negative": false})

            ["yztato_blood_rage", _, _]:
                new_effect.interval = Utils.ncl_curse_effect_value(new_effect.interval, effect_modifier, {"is_negative": true})
                new_effect.duration = Utils.ncl_curse_effect_value(new_effect.duration, effect_modifier, {"process_negative": false})
                var new_stats_change: Array = new_effect.stats_change.duplicate()
                for stat in new_stats_change:
                    stat[1] = Utils.ncl_curse_effect_value(stat[1], effect_modifier, {"step": 1})
            
            ["yztato_leave_fire", _, _]:
                new_effect.duration = Utils.ncl_curse_effect_value(new_effect.duration, effect_modifier, {"process_negative": false})
                new_effect.scale = Utils.ncl_curse_effect_value(new_effect.scale, effect_modifier, {"process_negative": false})
                new_effect.text_key += "_CURSED"

            [_, Utils.yztato_heal_on_damage_taken_hash, _], \
            [_, Utils.yztato_random_curse_on_reroll_hash, _]:
                new_effect.value2 = Utils.ncl_curse_effect_value(new_effect.value2, effect_modifier, {"step": 1, "process_negative": false})
            
            [_, Utils.yztato_one_shot_loot_hash, _]:
                var extra_effect: Effect = Effect.new()
                extra_effect.key = "loot_alien_chance"
                extra_effect.key_hash = Keys.loot_alien_chance_hash
                extra_effect.text_key = "effect_loot_alien_chance"
                extra_effect.value = 50
                new_effects.append(extra_effect)

            [_, _, Utils.yztato_stats_chance_on_level_up_hash]:
                new_effect.value2 = Utils.ncl_curse_effect_value(new_effect.value2, effect_modifier, {"step": 1, "process_negative": false})

        new_effects.append(new_effect)
    new_item_data.effects = new_effects

    return new_item_data as ItemParentData

# =========================== Method =========================== #
func has_effect_yztato(effects: Array) -> bool:
    for effect in effects:
        if is_effect_yztato(effect):
            return true
    return false

func is_effect_yztato(effect: Effect) -> bool:
    return effect.get_id().begins_with("yztato") or \
    effect.key.begins_with("yztato") or \
    effect.custom_key.begins_with("yztato")
