extends "res://singletons/player_run_data.gd"

static func init_stats(all_null_values: bool = false)->Dictionary:

    if (Utils != null) :
        var vanilla_stats = .init_stats(all_null_values)

        var new_stats: = {
            Keys.trees_hash: 0,                                                     # Debug : Only For Assert
            
        }

        new_stats.merge(vanilla_stats)

        return new_stats;
    else:
        return {}

static func init_effects()->Dictionary:

    if (Utils != null) :
        var vanilla_effects = .init_effects()

        var new_effects: = {
            Utils.yztato_gain_items_end_of_wave_hash: [],
            Utils.yztato_destory_weapons_hash: [],
            Utils.yztato_set_stat_hash: [],
            Utils.yztato_life_steal_hash: 0,
            Utils.yztato_melee_erase_bullets_hash: 0,
            Utils.yztato_flying_sword_hash: [],
            Utils.yztato_blade_storm_hash: 0,
            Utils.yztato_leave_fire_hash: [],
            Utils.yztato_chimera_weapon_hash: [],
            Utils.yztato_explosion_erase_bullets_hash: 0,
            Utils.yztato_upgrade_when_killed_enemies_hash: [],
            Utils.yztato_gain_stat_when_killed_single_scaling_hash: [],
            Utils.yztato_melee_bounce_bullets_hash: 0,
            Utils.yztato_special_picked_up_change_stat_hash: [],
            Utils.yztato_weapon_set_filter_hash: [],
            Utils.yztato_weapon_set_delete_hash: [],
            Utils.yztato_boomerang_weapon_hash: [],
            Utils.yztato_one_shot_loot_hash: 0,
            Utils.yztato_extra_upgrade_hash: 0,
            Utils.yztato_blood_rage_hash: [],
            Utils.yztato_invincible_on_hit_duration_hash: 0,
            Utils.yztato_crit_damage_hash: 0,
            Utils.yztato_force_curse_items_hash: 0,
            Utils.yztato_gain_random_primary_stat_when_killed_hash: [],
            Utils.yztato_random_primary_stat_on_hit_hash: 0,
            Utils.yztato_damage_against_not_boss_hash: 0,
            Utils.yztato_random_primary_stat_over_time_hash: [],
            Utils.yztato_multi_hit_hash: [],
            Utils.yztato_vine_trap_hash: [],
            Utils.yztato_stats_chance_on_level_up_hash: [],
            Utils.yztato_heal_on_damage_taken_hash: [],
            Utils.yztato_temp_stats_per_interval_hash: [],
            Utils.yztato_extra_enemies_next_waves_hash: [],
            Utils.yztato_damage_scaling_hash: [],
            Utils.yztato_random_curse_on_reroll_hash: [],
            Utils.yztato_extrusion_attack_hash: 0,
            Utils.yztato_stat_on_hit_hash: [],
            
        }

        new_effects.merge(vanilla_effects)

        return new_effects;
    else:
        return {}
