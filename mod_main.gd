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

	var extensions = [
		"enemy.gd",
		"weapons_container.gd",
		"shooting_attack_behavior.gd",
		"entity_spawner.gd",
		"player.gd",
		"gold.gd",
		"main.gd",
		"consumable.gd",
		"player_explosion.gd",
		"player_projectile.gd",
		"item_service.gd",
		"progress_data.gd",
		"run_data.gd",
		"sound_manager.gd",
		"sound_manager_2d.gd",
		"weapon_service.gd",
		"zone_service.gd",
		"upgrades_ui.gd",
		"menus.gd",
		"menu_choose_options.gd",
		"character_selection.gd",
		"difficulty_selection.gd",
		"secondary_stat_container.gd",
		"stats_container.gd",
		"melee_weapon.gd", 
		"ranged_weapon.gd",
		"wave_manager.gd",
		
	]
	
	var extensions2 = [
		["player_run_data.gd", "res://singletons/player_run_data.gd"],
		
	]
	
	var Test = false

	if !Test: 
		for path in extensions:
			ModLoaderMod.install_script_extension(ext_dir + path)
		for script in extensions2:
			YZ_extend(script, ext_dir)

	if Test: YZ_init(ext_dir)


	
func YZ_init(_ext_dir: String):
	ModLoaderLog.info("========== Yztato Init ==========", MYMODNAME_LOG)
	
	###########################################
	########## Add extensions Before ##########
	###########################################
	var scripts = [
		
		["enemy.gd", "res://entities/units/enemies/enemy.gd"],
		# EFFECTS : extrusion_attack, damage_against_not_boss
		# SETTING : set_enemy_transparency
		
		["weapons_container.gd", "res://entities/units/player/weapons_container.gd"],
		# EFFECTS : blade_storm[ 1/4 ]
		
		["shooting_attack_behavior.gd", "res://entities/units/enemies/attack_behaviors/shooting_attack_behavior.gd"],
		# SETTING : set_enemy_proj_transparency
		
		["entity_spawner.gd", "res://global/entity_spawner.gd"],
		# EFFECTS : gain_stat_when_killed_single_scaling[ 1/3 ], blood_rage[ 1/3 ],
		#           gain_random_primary_stat_when_killed
		# ACHIEVE : dark_forest_rule

		["player.gd", "res://entities/units/player/player.gd"],
		# EFFECTS : blade_storm[ 2/4 ], lifesteal[ 1/2 ], blood_rage[ 2/3 ],
		#           stat_on_hit, invincible_on_hit_duration, random_primary_stat_on_hit
		#           random_primary_stat_over_time, temp_stat_per_interval[ hit_protection ]
		#           heal_on_damage_taken
		# ACHIEVE : only_in, more_than_enough

		["consumable.gd", "res://items/consumables/consumable.gd"],
		# SETTING : set_consumable_transparency, optimize_pickup[ 1/2 ]
		
		["gold.gd", "res://items/materials/gold.gd"],
		# SETTING : set_gold_transparency, rainbow_gold,
		#           optimize_pickup[ 2/2 ]
		
		["main.gd", "res://main.gd"],
		# EFFECTS : end of wave, level up, special_picked_up_change_stat,
		#           blood_rage[ 3/3 ], stats_chance_on_level_up

		["player_explosion.gd", "res://projectiles/player_explosion.gd"],
		# EFFECTS : explosion_erase_bullets
		
		["player_projectile.gd", "res://projectiles/player_projectile.gd"],
		# EFFECTS : chimera_weapon, boomerang_weapon[ 1/2 ]
		
		["item_service.gd", "res://singletons/item_service.gd"],
		# EFFECTS : weapon_set_filter, weapon_set_delete, force_curse_items
		# Weapon Banned
		
		["player_run_data.gd", "res://singletons/player_run_data.gd"],
		# EFFECTS' NAMES
		
		["progress_data.gd", "res://singletons/progress_data.gd"],
		# Mod's Contents
		# EFFECTS : blade_storm[ 3/4 ]
		# SETTINGS
		
		["run_data.gd", "res://singletons/run_data.gd"],
		# EFFECTS : lifesteal[ 2/2 ]
		# SETTING : item_appearances_hide, unlock_all_challenges
		# Tracked Items
		
		["sound_manager.gd", "res://singletons/sound_manager.gd"],
		# Sound Fix[ 1/2 ]
		
		["sound_manager_2d.gd", "res://singletons/sound_manager_2d.gd"],
		# Sound Fix[ 2/2 ]
		
		["weapon_service.gd", "res://singletons/weapon_service.gd"],
		# EFFECTS : crit
		
		["zone_service.gd", "res://singletons/zone_service.gd"],
		# EFFECTS : wave
		
		["upgrades_ui.gd", "res://ui/menus/ingame/upgrades_ui.gd"],
		# EFFECTS : extra_upgrade
		
		["menus.gd", "res://ui/menus/menus.gd"],
		# SETTINGS[ 1/2 ]
		
		["menu_choose_options.gd", "res://ui/menus/pages/menu_choose_options.gd"],
		# SETTINGS[ 2/2 ]
		
		["character_selection.gd", "res://ui/menus/run/character_selection.gd"],
		# SETTING : unlock_all_chars
		
		["difficulty_selection.gd", "res://ui/menus/run/difficulty_selection/difficulty_selection.gd"],
		# SETTING : unlock_difficulties
		
		["secondary_stat_container.gd", "res://ui/menus/shop/secondary_stat_container.gd"],
		# Secondary Stats' Icons
		
		["stats_container.gd", "res://ui/menus/shop/stats_container.gd"],
		# SETTING : tertiary_stats
		
		["melee_weapon.gd", "res://weapons/melee/melee_weapon.gd"],
		# EFFECTS : melee_erase_bullets, melee_bounce_bullets,
		#           flying_sword, blade_storm[ 4/4 ], leave_fire[ 1/2 ], 
		#           gain_stat_when_killed_single_scaling[ 2/3 ], multi_hit[ 1/2 ],
		#           vine_trap[ 1/2 ]
		# SETTING : set_weapon_transparency[ 1/2 ]
		# ACHIEVE : counterattack
		
		["ranged_weapon.gd", "res://weapons/ranged/ranged_weapon.gd"],
		# EFFECTS : upgrade_range_killed_enemies, boomerang_weapon[ 2/2 ], 
		#           leave_fire[ 2/2 ], multi_hit[ 2/2 ], vine_trap[ 2/2 ]
		#           gain_stat_when_killed_single_scaling[ 3/3 ],
		# SETTING : set_weapon_transparency[ 2/2 ]
		# ACHIEVE : sudden_misfortune
		
		["wave_manager.gd", "res://zones/wave_manager.gd"],
		# EFFECTS : extra_enemies_next_waves
		
	]
	
	for script in scripts:
		YZ_extend(script, ext_dir)
	
	ModLoaderLog.info("========== Yztato Init Done ==========", MYMODNAME_LOG)

func YZ_extend(script: Array, _ext_dir: String) -> void:
	# OrignalFunction -> apply_extension
	var child_script_path: String = _ext_dir + script[0]
	var parent_script_path: String = script[1]

	var child_script: Script = load(child_script_path)
	child_script.set_meta("extension_script_path", child_script_path)

	var parent_script: Script = load(parent_script_path)

	if not ModLoaderStore.saved_scripts.has(parent_script_path):
		ModLoaderStore.saved_scripts[ parent_script_path ] = []

		ModLoaderStore.saved_scripts[parent_script_path].append(parent_script.duplicate())

	ModLoaderStore.saved_scripts[parent_script_path].append(child_script)
	
	ModLoaderLog.info("Installing script extension via Yztato: %s <- %s" % [ parent_script_path, child_script_path ], MYMODNAME_LOG)

	child_script.take_over_path(parent_script_path)
