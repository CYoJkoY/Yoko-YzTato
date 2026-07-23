extends Node

const MYMODNAME_MOD_DIR: String = "Yoko-YzTato/"
const MYMODNAME_LOG: String = "Yoko-YzTato"

var dir: String = ""
var ext_dir: String = ""

# =========================== Extension =========================== #
func _init():
    dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
    ext_dir = dir + "extensions/"

    var extensions: Array = [

        "enemy.gd",
        # EFFECTS: extrusion_attack

        "weapons_container.gd",
        # EFFECTS: blade_storm[ 1/4 ]

        "entity_spawner.gd",
        # EFFECTS: gain_stat_when_killed_single_scaling[ 1/4 ]
        #          blood_rage[ 1/2 ]
        # ACHIEVE: dark_forest_rule

        "player.gd",
        # EFFECTS: blade_storm[ 2/4 ]
        #          lifestea
        #          blood_rage[ 2/2 ],
        #          temp_stat_per_interval[ hit_protection ]
        #          heal_on_damage_taken
        #          projectiles_on_hurt
        # ACHIEVE: only_in, more_than_enough

        "main.gd",
        # EFFECTS: end of wave, level up
        #          special_picked_up_change_stat,
        #          stats_chance_on_level_up
        #          trigger_subeffect_on_specific_stat_over

        "player_explosion.gd",
        # EFFECTS: explosion_erase_bullets

        "item_service.gd",
        # EFFECTS: weapon_set_filter
        #          weapon_set_delete
        
        "utils.gd",
        # EFFECTS: blade_storm[ 3/4 ]
        # EFFECTS' NAMES, Methods

        "services/weapon_service.gd",
        # EFFECTS: damage_scaling
        #          crit_damage
        #          multi_hit[ 1/3 ]
        #          vine_trap[ 1/3 ]
        #          leave_fire[ 1/3 ]
        #          gain_stat_when_killed_single_scaling[ 2/4 ]
        #          upgrade_when_killed_enemies[ 1/3 ]
        #          can_attack_while_moving[ 1/3 ]

        "upgrades_ui.gd",
        # EFFECTS: extra_upgrade

        "base_shop.gd",
        # EFFECTS: random_curse_on_reroll

        "melee_weapon.gd",
        # EFFECTS: melee_erase_bullets
        #          melee_bounce_bullets
        #          flying_sword, blade_storm[ 4/4 ]
        #          leave_fire[ 2/3 ]
        #          gain_stat_when_killed_single_scaling[ 3/4 ]
        #          multi_hit[ 2/3 ]
        #          vine_trap[ 2/3 ]
        #          upgrade_when_killed_enemies[ 2/3 ]
        #          can_attack_while_moving[ 2/3 ]
        # ACHIEVE: counterattack 

        "ranged_weapon.gd",
        # EFFECTS: boomerang_weapon
        #          leave_fire[ 3/3 ]
        #          multi_hit[ 3/3 ]
        #          vine_trap[ 3/3 ]
        #          upgrade_when_killed_enemies[ 3/3 ]
        #          gain_stat_when_killed_single_scaling[ 4/4 ]
        #          can_attack_while_moving[ 3/3 ]
        # ACHIEVE: sudden_misfortune

        "wave_manager.gd",
        # EFFECTS: extra_enemies_next_waves

        "player_run_data.gd",
        # EFFECTS' NAMES

        "run_data.gd",
        # EFFECTS: life_steal
        #          update_specific_tag_item_bonuses
        
    ]

    for path in extensions:
        var extension_path = ext_dir + path
        ModLoaderMod.install_script_extension(extension_path)
