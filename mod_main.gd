extends Node

const MYMODNAME_MOD_DIR: String = "Yoko-YzTato/"
const MYMODNAME_LOG: String = "Yoko-YzTato"

var dir: String = ""
var ext_dir: String = ""
var trans_dir: String = ""

# =========================== Extension =========================== #
func _init():
    ModLoaderLog.info("========== Add Translation ==========", MYMODNAME_LOG)
    dir = ModLoaderMod.get_unpacked_dir() + MYMODNAME_MOD_DIR
    trans_dir = dir + "translations/"
    ext_dir = dir + "extensions/"
    
    # NameSpace ~ Node: /root/ModLoader/Yoko-YzTato/Yztato
    # progress_data.gd --> _ready --> ProgressData.Yztato
    var Yztato_instance = load(dir + "content_data/NameSpace.gd").new()
    Yztato_instance.name = "Yztato"
    add_child(Yztato_instance)
    
    #######################################
    ########## Add translations ##########
    #####################################
    ModLoaderMod.add_translation(trans_dir + "Yztato.en.translation")
    ModLoaderMod.add_translation(trans_dir + "Yztato.zh_Hans_CN.translation")
    
    ModLoaderLog.info("========== Add Translation Done ==========", MYMODNAME_LOG)

    var extensions: Array = [

        "enemy.gd",
        # EFFECTS : extrusion_attack

        "weapons_container.gd",
        # EFFECTS : blade_storm[ 1/4 ]

        "entity_spawner.gd",
        # EFFECTS : gain_stat_when_killed_single_scaling[ 1/3 ], blood_rage[ 1/2 ],
        # ACHIEVE : dark_forest_rule

        "player.gd",
        # EFFECTS : blade_storm[ 2/4 ], lifesteal[ 1/2 ], blood_rage[ 2/2 ],
        #           temp_stat_per_interval[ hit_protection ], heal_on_damage_taken,
        #           upgrade_when_killed_enemies[ 1/4 ]    
        # ACHIEVE : only_in, more_than_enough

        "main.gd",
        # EFFECTS : end of wave, level up, special_picked_up_change_stat,
        #           stats_chance_on_level_up

        "player_explosion.gd",
        # EFFECTS : explosion_erase_bullets

        "item_service.gd",
        # EFFECTS : weapon_set_filter, weapon_set_delete
        
        "utils.gd",
        # EFFECTS : blade_storm[ 3/4 ]
        # EFFECTS' NAMES
        
        "progress_data.gd",
        # Mod's Contents
        # Extensions After DLC

        "run_data.gd",
        # EFFECTS : lifesteal[ 2/2 ]
        # Tracked Effects

        "sound_manager.gd",
        # Sound Fix[ 1/2 ]

        "sound_manager_2d.gd",
        # Sound Fix[ 2/2 ]

        "weapon_service.gd",
        # EFFECTS : damage_scaling, crit_damage

        "upgrades_ui.gd",
        # EFFECTS : extra_upgrade

        "shop.gd",
        # EFFECTS : random_curse_on_reroll[ 1/2 ]

        "coop_shop.gd",
        # EFFECTS : random_curse_on_reroll[ 2/2 ]

        "melee_weapon.gd",
        # EFFECTS : melee_erase_bullets, melee_bounce_bullets,
        #           flying_sword, blade_storm[ 4/4 ], leave_fire[ 1/2 ], 
        #           gain_stat_when_killed_single_scaling[ 2/3 ], multi_hit[ 1/2 ],
        #           vine_trap[ 1/2 ], upgrade_when_killed_enemies[ 2/4 ]
        # ACHIEVE : counterattack 

        "ranged_weapon.gd",
        # EFFECTS : upgrade_when_killed_enemies[ 3/4 ], boomerang_weapon, 
        #           leave_fire[ 2/2 ], multi_hit[ 2/2 ], vine_trap[ 2/2 ]
        #           gain_stat_when_killed_single_scaling[ 3/3 ],
        # ACHIEVE : sudden_misfortune

        "wave_manager.gd",
        # EFFECTS : extra_enemies_next_waves

        "player_projectile.gd",
        # EFFECTS : upgrade_when_killed_enemies[ 4/4 ]

        "player_run_data.gd",
        # EFFECTS' NAMES
        
    ]

    for path in extensions:
        var extension_path = ext_dir + path
        ModLoaderMod.install_script_extension(extension_path)
