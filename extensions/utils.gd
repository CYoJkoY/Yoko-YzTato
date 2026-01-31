extends "res://singletons/utils.gd"

# Effects
var yztato_destory_weapons_hash: int = Keys.generate_hash("yztato_destory_weapons")
var yztato_set_stat_hash: int = Keys.generate_hash("yztato_set_stat")
var yztato_life_steal_hash: int = Keys.generate_hash("yztato_life_steal")
var yztato_melee_erase_bullets_hash: int = Keys.generate_hash("yztato_melee_erase_bullets")
var yztato_flying_sword_hash: int = Keys.generate_hash("yztato_flying_sword")
var yztato_blade_storm_hash: int = Keys.generate_hash("yztato_blade_storm")
var yztato_leave_fire_hash: int = Keys.generate_hash("yztato_leave_fire")
var yztato_chimera_weapon_hash: int = Keys.generate_hash("yztato_chimera_weapon")
var yztato_explosion_erase_bullets_hash: int = Keys.generate_hash("yztato_explosion_erase_bullets")
var yztato_upgrade_when_killed_enemies_hash: int = Keys.generate_hash("yztato_upgrade_when_killed_enemies")
var yztato_gain_stat_when_killed_single_scaling_hash: int = Keys.generate_hash("yztato_gain_stat_when_killed_single_scaling")
var yztato_melee_bounce_bullets_hash: int = Keys.generate_hash("yztato_melee_bounce_bullets")
var yztato_special_picked_up_change_stat_hash: int = Keys.generate_hash("yztato_special_picked_up_change_stat")
var yztato_weapon_set_filter_hash: int = Keys.generate_hash("yztato_weapon_set_filter")
var yztato_weapon_set_delete_hash: int = Keys.generate_hash("yztato_weapon_set_delete")
var yztato_boomerang_weapon_hash: int = Keys.generate_hash("yztato_boomerang_weapon")
var yztato_one_shot_loot_hash: int = Keys.generate_hash("yztato_one_shot_loot")
var yztato_extra_upgrade_hash: int = Keys.generate_hash("yztato_extra_upgrade")
var yztato_blood_rage_hash: int = Keys.generate_hash("yztato_blood_rage")
var yztato_multi_hit_hash: int = Keys.generate_hash("yztato_multi_hit")
var yztato_vine_trap_hash: int = Keys.generate_hash("yztato_vine_trap")
var yztato_stats_chance_on_level_up_hash: int = Keys.generate_hash("yztato_stats_chance_on_level_up")
var yztato_heal_on_damage_taken_hash: int = Keys.generate_hash("yztato_heal_on_damage_taken")
var yztato_temp_stats_per_interval_hash: int = Keys.generate_hash("yztato_temp_stats_per_interval")
var yztato_extra_enemies_next_waves_hash: int = Keys.generate_hash("yztato_extra_enemies_next_waves")
var yztato_damage_scaling_hash: int = Keys.generate_hash("yztato_damage_scaling")
var yztato_random_curse_on_reroll_hash: int = Keys.generate_hash("yztato_random_curse_on_reroll")
var yztato_extrusion_attack_hash: int = Keys.generate_hash("yztato_extrusion_attack")

# Tracking Effects
var yztato_item_ghost_tree_hash: int = Keys.generate_hash("yztato_item_ghost_tree")
var yztato_character_xiake_1_hash: int = Keys.generate_hash("yztato_character_xiake_1")
var yztato_character_xiake_2_hash: int = Keys.generate_hash("yztato_character_xiake_2")

# Tracking Items
var item_yztato_cursed_box_hash: int = Keys.generate_hash("item_yztato_cursed_box")
var character_yztato_fanatic_hash: int = Keys.generate_hash("character_yztato_fanatic")
var character_yztato_baseball_player_hash = Keys.generate_hash("character_yztato_baseball_player")
var item_yztato_insurance_policy_hash: int = Keys.generate_hash("item_yztato_insurance_policy")

# Challenges
var chal_dark_forest_rule_hash: int = Keys.generate_hash("chal_dark_forest_rule")
var chal_hellfire_hash: int = Keys.generate_hash("chal_hellfire")
var chal_counterattack_hash: int = Keys.generate_hash("chal_counterattack")
var chal_more_than_enough_hash: int = Keys.generate_hash("chal_more_than_enough")
var chal_only_in_hash: int = Keys.generate_hash("chal_only_in")
var chal_sudden_misfortune_hash: int = Keys.generate_hash("chal_sudden_misfortune")
var chal_one_force_subdue_ten_hash: int = Keys.generate_hash("chal_one_force_subdue_ten")

# =========================== Extension =========================== #
func is_manual_aim(player_index: int)-> bool:
    var is_manual: bool = .is_manual_aim(player_index) || false
    is_manual = _yztato_blade_storm_manual_aim(is_manual, player_index)

    return is_manual

# =========================== Custom =========================== #
func _yztato_blade_storm_manual_aim(is_manual: bool, player_index: int)-> bool:
    var blade_storm: int = RunData.get_player_effect(Utils.yztato_blade_storm_hash,player_index)
    if blade_storm != 0:
        is_manual = false
    return is_manual
