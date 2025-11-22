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
    ModLoaderMod.add_translation(trans_dir + "YzTato.en.translation")
    ModLoaderMod.add_translation(trans_dir + "YzTato.zh_Hans_CN.translation")
    
    ModLoaderLog.info("========== Add Translation Done ==========", MYMODNAME_LOG)

    var extensions: Array = [

        "enemy.gd",
        # EFFECTS : extrusion_attack, damage_against_not_boss

        "weapons_container.gd",
        # EFFECTS : blade_storm[ 1/4 ]

        "entity_spawner.gd",
        # EFFECTS : gain_stat_when_killed_single_scaling[ 1/3 ], blood_rage[ 1/3 ],
        #           gain_random_primary_stat_when_killed
        # ACHIEVE : dark_forest_rule

        "player.gd",
        # EFFECTS : blade_storm[ 2/4 ], lifesteal[ 1/2 ], blood_rage[ 2/3 ],
        #           stat_on_hit, invincible_on_hit_duration, random_primary_stat_on_hit
        #           random_primary_stat_over_time, temp_stat_per_interval[ hit_protection ]
        #           heal_on_damage_taken, upgrade_when_killed_enemies[ 1/4 ]
        # ACHIEVE : only_in, more_than_enough

        "main.gd",
        # EFFECTS : end of wave, level up, special_picked_up_change_stat,
        #           blood_rage[ 3/3 ], stats_chance_on_level_up

        "player_explosion.gd",
        # EFFECTS : explosion_erase_bullets

        "item_service.gd",
        # EFFECTS : weapon_set_filter, weapon_set_delete, force_curse_items
        # Weapon Banned
        
        "utils.gd",
        # EFFECTS : blade_storm[ 3/4 ]
        
        "progress_data.gd",
        # Mod's Contents
        # Extensions After DLC

        "run_data.gd",
        # EFFECTS : lifesteal[ 2/2 ]
        # Tracked Items

        "sound_manager.gd",
        # Sound Fix[ 1/2 ]

        "sound_manager_2d.gd",
        # Sound Fix[ 2/2 ]

        "weapon_service.gd",
        # EFFECTS : crit, yztato_damage_scaling

        "upgrades_ui.gd",
        # EFFECTS : extra_upgrade

        "base_shop.gd",
        # EFFECTS : random_curse_on_reroll

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
        
    ]

    var extensions2: Array = [
        
        ["player_run_data.gd", "res://singletons/player_run_data.gd"],
        # EFFECTS' NAMES
        
    ]

    for path in extensions:
        ModLoaderMod.install_script_extension(ext_dir + path)
    for path2 in extensions2:
        YZ_extend_script(path2, ext_dir)

func YZ_extend_script(script: Array, _ext_dir: String) -> void:
    var child_script_path: String = _ext_dir + script[0]
    var parent_script_path: String = script[1]
    
    var mod_id: String = _ModLoaderPath.get_mod_dir(get_script().resource_path)
    
    if not ModLoaderStore.saved_extension_paths.has(mod_id):
        ModLoaderStore.saved_extension_paths[mod_id] = []
    ModLoaderStore.saved_extension_paths[mod_id].append(child_script_path)
    
    if not File.new().file_exists(child_script_path):
        ModLoaderLog.error("The child script path '%s' does not exist" % [child_script_path], MYMODNAME_LOG)
        return

    _apply_script_extension_now(child_script_path, parent_script_path)

func _apply_script_extension_now(child_script_path: String, parent_script_path: String) -> void:
    var child_script: Script = load(child_script_path)
    child_script.set_meta("extension_script_path", child_script_path)
    child_script.reload(true)

    var parent_script: Script = load(parent_script_path)

    if not ModLoaderStore.saved_scripts.has(parent_script_path):
        ModLoaderStore.saved_scripts[parent_script_path] = []
        ModLoaderStore.saved_scripts[parent_script_path].append(parent_script)

    ModLoaderStore.saved_scripts[parent_script_path].append(child_script)
    
    ModLoaderLog.info("Installing script extension: %s <- %s" % [parent_script_path, child_script_path], MYMODNAME_LOG)

    child_script.take_over_path(parent_script_path)
